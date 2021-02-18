#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 17:27:36 2020

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
    ext_name                        = '_localizerlock_dwnsample100Hz'

    fname                           = dir_data_in + suj + ext_name + '.mat'
    print('\nHandling '+ fname+'\n')
    

    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    data                            = epochs.get_data() #Get all epochs as a 3D array.
    time_axis                       = epochs.times
    
    eventName                       = dir_data_in + suj + ext_name + '_trialinfo.mat'
    index                           = loadmat(eventName)['index']
    
    x                               = data
    clf                             = make_pipeline(StandardScaler(),LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
    time_decod                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        
    index_color                     = index[:,3]
    index_spatial                   = index[:,2]
    index_spatial[np.where(index_spatial < 0.5)] = 1
    index_spatial[np.where(index_spatial == 0.5)] = 2
    
    events                          = np.vstack((index_spatial,index_color))
    
    fig, ax                         = plt.subplots(2,1)
    
    list_decode                     = list(["Spatial Frequency","Color"])
    
    for ifeat in [0,1]:
        
        y                           = events[ifeat,:]
        
        scores                      = cross_val_multiscore(time_decod, x, y, cv = 8, n_jobs = 1) # crossvalidate
        scores                      = np.mean(scores, axis=0)
    
        ax[ifeat].plot(time_axis, scores, label='score (crossval)', linewidth=2, color='black')
        ax[ifeat].axhline(.5, color='r', linestyle='--', label='chance')
        ax[ifeat].axhline(.55, color='k', linestyle=':')
        ax[ifeat].axhline(.6, color='k', linestyle=':')
        ax[ifeat].axhline(.65, color='k', linestyle=':')
        ax[ifeat].axhline(.7, color='k', linestyle=':')
        ax[ifeat].set_xlabel('Times')
        ax[ifeat].set_ylabel('Decoding ß' + list_decode[ifeat])  # Area Under the Curve
        ax[ifeat].legend()
        ax[ifeat].axvline(.0, color='k', linestyle='-')
        ax[ifeat].set_title('AUC')

        
        
    plt.show()
    
    
        
        
        
        