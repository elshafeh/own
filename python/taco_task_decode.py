#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 11 01:27:13 2020

@author: heshamelshafei
"""

import os
import mne
import numpy as np
import matplotlib.pyplot as plt
from mne.decoding import (SlidingEstimator, LinearModel, cross_val_multiscore)
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                           = list(["tac001"])

for isub in range(len(suj_list)):

    suj                             = suj_list[isub]
    
    dir_data_in                     = '/Users/heshamelshafei/Dropbox/project_me/data/taco/preproc/'
    ext_name                        = '_gratinglock_dwnsample100Hz'

    fname                           = dir_data_in + suj + ext_name + '.mat'
    print('\nHandling '+ fname+'\n')
    

    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    eventName                       = dir_data_in + suj + ext_name + '_trialinfo.mat'
    index                           = loadmat(eventName)['index']
    
    data                            = epochs.get_data() #Get all epochs as a 3D array.
    time_axis                       = epochs.times
    events                          = epochs.events[:,-1]
    
    find_correct                    = np.where(index[:,15] == 1)
    x                               = np.squeeze(data[find_correct,:,:])
    events                          = np.squeeze(events[find_correct])
    
    clf                             = make_pipeline(StandardScaler(),LinearModel(LogisticRegression(solver='lbfgs',max_iter=300))) # define model
    time_decod                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
    
    
    fig, ax                         = plt.subplots(1,1)
    
    list_decode                     = list(["Spatial Frequency"])
    
    for ifeat in [0]:
    
        y                           = np.zeros(np.size(events))
        
        y[np.where(np.mod(events,2) ==1)]       = 1 
        y[np.where(np.mod(events,2) !=1)]       = 2
        
        scores                       = cross_val_multiscore(time_decod, x, y, cv = 10, n_jobs = 1) # crossvalidate
        scores                       = np.mean(scores, axis=0)
    
        ax.plot(time_axis, scores, label='score (crossval)', linewidth=2, color='black')
        ax.axhline(.5, color='r', linestyle='--', label='chance')
        ax.axhline(.55, color='k', linestyle=':')
        ax.axhline(.6, color='k', linestyle=':')
        ax.axhline(.65, color='k', linestyle=':')
        ax.axhline(.7, color='k', linestyle=':')
        ax.set_xlabel('Times')
        ax.set_ylabel('Decoding ß' + list_decode[ifeat])  # Area Under the Curve
        ax.legend()
        ax.axvline(.0, color='k', linestyle='-')
        ax.set_title('AUC')

        
    plt.show()
    
    
        
        
        
        