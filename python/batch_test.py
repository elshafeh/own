#!/home/brainrhythms/hesels/.conda/envs/mne_uwu/bin/ python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  3 15:34:08 2021

@author: hesels
"""

import os
import sys

os.chdir("/home/brainrhythms/hesels/.conda/envs/mne_uwu/lib/python3.8/site-packages/")
  
import mne
import numpy as np
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import  LogisticRegressionCV
from scipy.io import (savemat,loadmat)
from sklearn.model_selection import LeaveOneOut
from sklearn.metrics import roc_auc_score


if len(sys.argv) == 2:  
    
    print('hellu')
    suj_list        = list(['sub001','sub003','sub004'])
    file_name       = '/project/3015079.01/' + sys.argv[1] + '.mat'
    savemat(file_name,{'tmp':suj_list})