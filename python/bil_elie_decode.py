#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 23 15:22:50 2019

@author: heshamelshafei
"""

import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator

dir_data                            = '/Users/heshamelshafei/Dropbox/project_me/bil/meg/data/'

suj_list                            = list(['pil01','pil02','pil03','pil05','sub001'])
dcd_list                            = list(["orientation","frequency","color"])

fig, ax                             = plt.subplots(len(suj_list),len(dcd_list))

for isub in range(len(suj_list)):
    
    suj                             = suj_list[isub]
    
    print('\nHandling '+ suj+'\n')
    
    fname                           = dir_data + suj + '/preproc/' + suj + '_gratingLock_dwnsample100Hz.mat'
    eventName                       = dir_data + suj + '/preproc/' + suj + '_gratingLock_trialinfo.mat'
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    allevents                       = loadmat(eventName)['index']
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    
    for ifeat in range(len(dcd_list)):
        
        x                           = alldata
        
        if ifeat == 0:
            # orientation
            mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] == 1),1])
            mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] == 2),3])
            y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
            y[np.where(y < 80)]     = 0
            y[np.where(y > 80)]     = 1
            
        elif ifeat == 1:
            # frequeny
            mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] == 1),2])
            mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] == 2),4])
            y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
            y[np.where(y < 0.4)]    = 0
            y[np.where(y > 0.4)]    = 1
            
        elif ifeat == 2:
            # colour
            y                       = allevents[:,11]
            y[np.where(y == 1)]     = 0
            y[np.where(y == 2)]     = 1
            
        chk                         = len(np.unique(y))
        
        if chk == 2:
        
            find_trials             = np.where(allevents[:,15]==1)
            
            x                       = np.squeeze(x[find_trials,:,:])
            y                       = np.squeeze(y[find_trials])
            
            clf                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            
            scores                  = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
            scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            
            
            print('\n')
            
            ax[isub,ifeat].plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
            ax[isub,ifeat].axhline(.5, color='k', linestyle='--', label='chance')
            ax[isub,ifeat].set_xlabel('Times')
            ax[isub,ifeat].set_ylabel('AUC')
            #ax[isub,ifeat].legend()
            ax[isub,ifeat].axvline(.0, color='k', linestyle='-')
            ax[isub,ifeat].set_title(suj + ' ' + dcd_list[ifeat])
            
            ax[isub,ifeat].set_ylim([0.4,1])
            ax[isub,ifeat].set_xlim([-0.2,1])
        

plt.show()