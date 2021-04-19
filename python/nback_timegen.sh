#!/bin/bash
subjectname=$1
module load anaconda3
source activate mne_uwu
python /home/brainrhythms/hesels/github/own/python/nback3_binning_decodetimegen.py $subjectname
