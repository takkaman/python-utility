#!/bin/bash

ipcs -s
for i in `ipcs -s | awk ' {print $2}'`; do (ipcrm -s $i); done

