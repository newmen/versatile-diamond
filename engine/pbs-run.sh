#!/bin/sh

path=`pwd`
filename=`ruby pbs-job_creator.rb $path $1`
qsub $filename
rm $filename
