#!/bin/bash

for suj in sub001 sub003 sub004 sub006 sub008 sub009 sub010 sub011 sub012 sub013 sub014 sub015 sub016 sub017 sub018 sub019 sub020 sub021 sub022 sub023 sub024 sub025 sub026 sub027 sub028 sub029 sub031 sub032 sub033 sub034 sub035 sub036 sub037
do
    echo "submitting job for $suj"
    echo "/home/brainrhythms/hesels/github/own/python/bash_shell.sh $suj" | qsub -N "$suj" -l 'nodes=1:ppn=4,mem=16gb,walltime=71:00:00'
done




                                            
