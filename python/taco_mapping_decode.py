#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 11 12:30:41 2020

@author: heshamelshafei
"""

import mne
import numpy as np
import matplotlib.pyplot as plt
from mne.decoding import (SlidingEstimator, LinearModel, cross_val_multiscore)
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (loadmat)

suj_list                           = list(["tac001"])

for isub in range(len(suj_list)):

    suj                             = suj_list[isub]
    
    dir_data_in                     = '/Users/heshamelshafei/Dropbox/project_me/data/taco/preproc/'
    ext_name                        = '_responselock_dwnsample100Hz'

    fname                           = dir_data_in + suj + ext_name + '.mat'
    print('\nHandling '+ fname+'\n')
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    eventName                       = dir_data_in + suj + ext_name + '_trialinfo.mat'
    index                           = loadmat(eventName)['index']
    
    data                            = epochs.get_data()
    data[np.where(np.isnan(data))]  = 0
    
    time_axis                       = epochs.times
    
    clf                             = make_pipeline(StandardScaler(),LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
    time_decod                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
    
    fig, ax                         = plt.subplots(1)
    
    list_decode                     = list(["Button"])
    
    for ifeat in [0]:
        
        if ifeat == 0:
            
            find_cond_1             = np.where((index[:,0] == 1))
            find_cond_2             = np.where((index[:,0] == 8))
        
        indx_1                      = np.repeat(1,np.size(find_cond_1))
        indx_2                      = np.repeat(2,np.size(find_cond_2))
        find_trials                 = np.squeeze(np.hstack((find_cond_1,find_cond_2)))
        
        y                           = np.hstack((indx_1,indx_2))
        x                           = np.squeeze(data[find_trials,:,:])
        
        scores                      = cross_val_multiscore(time_decod, x, y, cv = 10, n_jobs = 1) # crossvalidate
        scores                      = np.mean(scores, axis=0)
    
        ax.plot(time_axis, scores, label='score (crossval)', linewidth=2, color='black')
        ax.axhline(.5, color='r', linestyle='--', label='chance')
        ax.axhline(.3, color='k', linestyle=':')
        ax.axhline(.7, color='k', linestyle=':')
        ax.set_xlabel('Times')
        ax.set_ylabel('Decoding ' + list_decode[ifeat])  # Area Under the Curve
        ax.legend()
        ax.axvline(.0, color='k', linestyle='-')
        #ax.set_title('AUC')
        
    plt.show()