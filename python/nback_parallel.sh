#!/bin/bash

for suj in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 35 36 38 39 40 41 42 43 44 46 47 48 49 50 51
do
    echo "submitting job for $suj"
    #echo "/home/brainrhythms/hesels/github/own/python/nback_cond.sh $suj" | qsub -N "sub$suj-cond" -l 'nodes=1:ppn=16,mem=63gb,walltime=71:00:00'
    #echo "/home/brainrhythms/hesels/github/own/python/nback_id.sh $suj" | qsub -N "sub$suj-id" -l 'nodes=1:ppn=16,mem=63gb,walltime=71:00:00'
    #echo "/home/brainrhythms/hesels/github/own/python/nback_cat.sh $suj" | qsub -N "sub$suj-cat" -l 'nodes=1:ppn=16,mem=63gb,walltime=71:00:00'
    echo "/home/brainrhythms/hesels/github/own/python/nback_timegen.sh $suj" | qsub -N "sub$suj-virt" -l 'nodes=1:ppn=16,mem=63gb,walltime=71:00:00'
done
