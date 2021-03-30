#!/bin/bash

for suj in sub001 sub015 sub024
do
    echo "submitting job for $suj"
    echo "/home/brainrhythms/hesels/github/own/python/bash_shell_1.sh $suj" | qsub -N "$suj-1ori" -l 'nodes=1:ppn=4,mem=63gb,walltime=71:00:00'
    echo "/home/brainrhythms/hesels/github/own/python/bash_shell_2.sh $suj" | qsub -N "$suj-1frq" -l 'nodes=1:ppn=4,mem=63gb,walltime=71:00:00'
    echo "/home/brainrhythms/hesels/github/own/python/bash_shell_3.sh $suj" | qsub -N "$suj-2ori" -l 'nodes=1:ppn=4,mem=63gb,walltime=71:00:00'
    echo "/home/brainrhythms/hesels/github/own/python/bash_shell_4.sh $suj" | qsub -N "$suj-2frq" -l 'nodes=1:ppn=4,mem=63gb,walltime=71:00:00'
done




                                            
