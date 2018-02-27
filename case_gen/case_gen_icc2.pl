#!/usr/local/bin/perl5.8.0
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Storable;
use CGI qw(:standard);  
use DBI;  

##########################
# connect to UDC mysql db
##########################
sub handle_error {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";
    exit; #stop the program
}

my $dbh = DBI->connect(
    "dbi:mysql:data_center:pvicc018",
    "UDC",
    "",
    {
        PrintError  => 0,
        HandleError => \&handle_error,
    }
) or handle_error(DBI->errstr);

#############
# init
#############
my $run_mode = $ARGV[0];
my $flow_name = $ARGV[2];
my $design_path;
my $design_name;
my $cell_name;
my $cell_stage;
my $design_info;
my $tlu_plus_number;
my $std_cell_num;
my $sth;
my $nt_feature_test;
my $is_mv;

##################
# main function
##################

#detect mode and fetch info from db
if ($run_mode eq "path") {        #path mode
  $design_path = $ARGV[1];  
  print "Fetching design info via path input...\n";
  $sth = $dbh->prepare("SELECT * FROM cell_info WHERE Path = '$design_path' and newton_feature_test = 'true'");

} elsif ( $run_mode eq "rand") {  #rand mode
  $cell_stage = $ARGV[1];
  print "Fetching design info via stage...\n"; 
  if ($cell_stage eq "all") {
  $sth = $dbh->prepare("select * from cell_info join (select round(RAND() * ((SELECT MAX(id) FROM cell_info where newton_feature_test = 'true' and cell_stage != 'unknown' || 'non-floorplanned' || ' ' )-(SELECT MIN(id) FROM cell_info where newton_feature_test = 'true' and cell_stage != 'unknown' || 'non-floorplanned' || ' '))+(SELECT MIN(id) FROM cell_info where newton_feature_test = 'true' and cell_stage != 'unknown' || 'non-floorplanned' || ' ' )) as id) as t2 where cell_info.id >= t2.id and newton_feature_test = 'true' and cell_stage != 'unknown' || 'non-floorplanned' || ' ' limit 1");
  } elsif ( $cell_stage eq "post_route" || $cell_stage eq "post_cts" ) {  #post_route & post_cts stage
  $sth = $dbh->prepare("select * from cell_info where cell_stage = '$cell_stage' and newton_feature_test = 'true' and number_of_stand_cells <= 50000 and number_of_stand_cells >= 10000 and reg_case_count > 0 order by RAND() limit 1;");
  } else {
  $sth = $dbh->prepare("select * from cell_info where cell_stage = '$cell_stage' and newton_feature_test = 'true' and number_of_stand_cells <= 800000 and number_of_stand_cells >= 10000 and reg_case_count > 0 order by RAND() limit 1;");
  }
}

$sth->execute();
my $search_result = $sth->rows(); 

if ($search_result == 1) {
  $design_info = $sth->fetchrow_hashref();
  $design_path = $design_info->{'path'};
  $design_name = $design_info->{'design_name'};
  $cell_name = $design_info->{'cell_name'}; 
  $cell_stage = $design_info->{'cell_stage'};
  $std_cell_num = $design_info->{'number_of_stand_cells'};
  $nt_feature_test = $design_info->{'newton_feature_test'};
  $is_mv = $design_info->{'multi_voltage'};  
  #my $row_id = $design_info->{'id'};
  $tlu_plus_number = $design_info->{'tluplus_file_number'};
  print "Design name: $design_name\nCell name: $cell_name\nCell stage: $cell_stage\nDesign path: $design_path\n";
  print "Std cell number: $std_cell_num\n";
  print "NT feature test: $nt_feature_test\n";
  print "Multi Voltage: $is_mv\n";
  my $result = &generate_case_by_stage($design_path, $cell_stage, $design_name, $cell_name, $tlu_plus_number, $std_cell_num);
    
  open(result_file, ">result.log");
  print result_file ("$result\n");
  close(result_file);
} else {
  print "Empty result!\n";
  open(result_file, ">result.log");
  print result_file ("0\n");
  close(result_file);
}

$sth->finish(); 
$dbh->disconnect();

###################################################
# sub function -- generate_case_by_stage
###################################################
sub generate_case_by_stage {
  my $path = $_[0];
  my $stage = $_[1];
  my $d_name = $_[2];
  my $c_name = $_[3];
  my $mw_name;
  my $mw_path;
  my $tlu_num = $_[4];
  my $cell_num = $_[5];
  my $fsm;
  my $result = 0;

  #########################
  # generate step file
  #########################
  open(step_file, ">step.log");
  print step_file ("$cell_num\n");
  close(step_file); 

  #####################################
  # generate case header -- setup.tcl
  #####################################
  if ($flow_name eq "mbit") {
    $fsm = "mbit";
  } elsif ($flow_name eq "dplch") {
    $fsm = "dplch";
  } elsif ($flow_name eq "rp") {
    $fsm = "rp";
  } else {  
    if ($stage =~ "floorplanned|placed") {
      $fsm = "preroute";
    } elsif ($stage =~ "post_cts|post_clk_route") {
      $fsm = "postcts";
    } elsif ($stage =~ "post_route") {
      $fsm = "postroute";
    }else {
      print "Unknown stage!\n";
    }
  }

  if (-e $path) {

    #get orig_data path
    my $root  = $path.'/../../';
    my $orig_data = $root.'orig_data';
    #get mw name
    my $mw_line;

    #write setup.tcl
    open(case_file, ">setup.tcl");
    print case_file ("set upf_create_implicit_supply_sets false\n");
    print case_file ("####################\n");
    print case_file ("# Design Setup\n");
    print case_file ("####################\n");
    print case_file ("source $design_path/$design_name.design_setup.Newton.tcl\n");
    print case_file ("set sh_continue_on_error true\n");
    print case_file ("exec ln -s $design_path ./nt_data\n");
    print case_file ("source /remote/pv/DATA_CENTER/script/source_code/release/snps_auto_update_nlib.tcl\n");
    print case_file ("snps_auto_update_nlib \$LIBRARY_DESIGN/lib_data/NT/nwlm_tcl\n");
    print case_file ("lappend search_path nt_data\n");
   
    print case_file ("set lib_name $design_name.nlib\n");
    print case_file ("create_lib -ref_libs \$nt_ref_lib  \$lib_name\n");
    print case_file ("open_lib \$lib_name\n");
    print case_file ("read_verilog $design_name.v\n\n");
    print case_file ("redirect -file read_def.log -tee {read_def $design_name.def}\n\n"); 
    #default scenario
    if ($tlu_num >= 1) {
      print "design has tlu_plus file.\n";
      print case_file ("read_parasitic_tech -layermap \$mdb_tlu_plus_map_file -tlup \$mdb_tlu_plus_max_file -name tlu\n");
      print case_file ("set_parasitics_parameters -late_spec tlu -early_spec tlu\n");
    } else {
      print "design has no tlu_plus file.\n";
    }  
    print case_file ("read_sdc $design_name.sdc\n");

    #MCMM handling
    print case_file ("#MCMM handling\n");    
    print case_file ("source $design_path/$design_name.snps_dump_MCMM_setting.Newton.tcl\n"); 

    #MV handling
    if ($is_mv eq 'true') {
      print case_file ("#MV handling\n");
      print case_file ("load_upf $design_path/$design_name.Newton.upf\n");
#print case_file ("read_def $design_name.def\n"); 
      print case_file ("commit_upf\n");
      print case_file ("source $design_path/$design_name.fp_va.Newton.tcl\n");
#print case_file ("connect_pg_net -auto\n");
      print case_file ("check_mv_design\n");
    } else {
#print case_file ("read_def $design_name.def\n"); 
    }

    print case_file ("####################\n");
    print case_file ("# Test Part\n");
    print case_file ("####################\n");
#    print case_file ("place_opt\n");
#    print case_file ("clock_opt\n");
#    print case_file ("route_auto\n");
#    print case_file ("route_opt\n");
#    print case_file ("quit\n");
    close(case_file);

    #generate case body -- fsm    
    print "Using $fsm cfg file.\n";
    if ($fsm eq "preroute") {
      system("cp -rf /remote/us01home40/phyan/random_icc2/cfg/fsm_preroute_standard.cfg fsm.cfg");
    } elsif ($fsm eq "postcts") {
      system("cp -rf /remote/us01home40/phyan/random_icc2/cfg/fsm_postcts.cfg fsm.cfg");
    } elsif ($fsm eq "postroute") {
      system("cp -rf /remote/us01home40/phyan/random_icc2/cfg/fsm_postroute.cfg fsm.cfg");
    } elsif ($fsm eq "mbit") {
      system("cp -rf /remote/us01home40/phyan/random_icc2/cfg/fsm_preroute_mbit.cfg fsm.cfg");  
    } elsif ($fsm eq "dplch") {
      system("cp -rf /remote/us01home40/phyan/random_icc2/cfg/fsm_preroute_dplch.cfg fsm.cfg");  
    } elsif ($fsm eq "rp") {
      system("cp -rf /remote/us01home40/phyan/random_icc2/cfg/fsm_preroute_rp.cfg fsm.cfg");  
    } 

    print "Test case generated successfully!\n\n";
    $result = 1;
  } else {
    print "Path does not exist!\n\n";
    $result = 0;
  }

  return $result;

}


