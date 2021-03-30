#!/bin/bash
scriptname=$1

echo "/home/brainrhythms/hesels/github/own/python/bash_setup.sh $scriptname" | qsub -N "$scriptname" -l 'nodes=1:ppn=4,mem=16gb,walltime=71:00:00'



                                            
