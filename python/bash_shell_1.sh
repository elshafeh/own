#!/bin/bash
subjectname=$1
module load anaconda3
source activate mne_uwu
python /home/brainrhythms/hesels/github/own/python/bil_decode_gabor_binning_loo_1_orien.py $subjectname