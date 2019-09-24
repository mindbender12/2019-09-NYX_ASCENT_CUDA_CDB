#!/bin/bash

time=-$(date +%s); 
while [ ! "$(bjobs 2>&1 | grep 'No unfinished')" ]; do 
  clear; 
  echo ===========================================; 
  echo ">>>  Job running ($(( $(date +%s) + ${time} )) seconds elapsed)";
  echo ===========================================; bjobs; 
  sleep 5; 
done;
echo "Jobs have finished running. Move to validation stage."
