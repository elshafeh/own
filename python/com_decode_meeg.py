#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  2 18:43:49 2019

@author: heshamelshafei
"""

import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator
import os

suj_list                                                = [1,2,3,4,8,9,10,11,12,13,14,15,16,17]

for isub in range(len(suj_list)):
    
    suj                                                 = 'yc'+ str(suj_list[isub])
        
    fname                                               = '/Volumes/heshamshung/alpha_compare/lcmv/' + suj + '.meeg.mat'
    print('Handling '+ fname)
        
    epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
    allevents                                           = epochs.events[:,-1]
    
    lm1                                                 = np.squeeze(np.array(np.where(epochs.times == -0.5)))
    lm2                                                 = np.squeeze(np.array(np.where(epochs.times == 2)))
    
    alldata                                             = alldata[:,:,lm1:lm2]
    time_axis                                           = epochs.times[lm1:lm2]
    
    x                                                   = np.squeeze(alldata)
    y                                                   = np.squeeze(allevents)        
    
    clf                                                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
    time_decod                                          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
    scores                                              = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
    scores                                              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
    
    fname_out   =  '/Volumes/heshamshung/alpha_compare/decode/meeg_dec/' + suj + '.meeg.dec.mat'
    scipy.io.savemat(fname_out, mdict={'scores': scores,'time_axis': time_axis})
    print('\nsaving '+ fname_out + '\n')
    
    del(scores,x,y,time_axis,alldata,allevents)