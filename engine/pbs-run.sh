#!/bin/sh

path=`pwd`
filename=`ruby pbs-job_creator.rb $path $1 $2 $3 $4 $5 $6`
qsub $filename
rm $filename
