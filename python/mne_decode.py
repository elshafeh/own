# -*- coding: utf-8 -*-
"""
Created on Wed Jul  3 09:42:07 2019

@author: Hesham
"""

# for future use:
# if mne is not installed ; use: !conda install mne --yes

cd /home/mrphys/hesels/.conda/envs/demo/site-packages

import mne
import sklearn
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

dsName      = '/project/3015079.01/raw/pilot01_3015079.01_20190620_01.ds'
matName     = '/project/3015079.01/preproc_data/pilot01_targetlock_ICAclean.mat'

mat_info    = mne.io.read_raw_ctf(dsName,preload=False)
mat_data    = mne.read_epochs_fieldtrip(matName,None,data_name='dataPostICA_clean',trialinfo_column=0)

