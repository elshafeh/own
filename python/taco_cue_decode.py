#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 11 11:53:21 2020

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
    ext_name                        = '_cuelock_dwnsample100Hz'

    fname                           = dir_data_in + suj + ext_name + '.mat'
    print('\nHandling '+ fname+'\n')
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    epochs.crop(tmin = -0.1 , tmax = 1)
    
    eventName                       = dir_data_in + suj + ext_name + '_trialinfo.mat'
    index                           = loadmat(eventName)['index']
    
    data                            = epochs.get_data()
    time_axis                       = epochs.times
    
    clf                             = make_pipeline(StandardScaler(),LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
    time_decod                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
    
    fig, ax                         = plt.subplots(4)
    
    list_decode                     = list(["One vs Two" , "Inf vs Unf" , "One vs Unf" , "Two vs Unf"])
    
    for ifeat in [0,1,2,3]:
        
        if ifeat == 0:
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 1) & (index[:,2] == 1))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 2) & (index[:,2] == 1))
            find_cond_1             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 1) & (index[:,2] == 2))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 2) & (index[:,2] == 2))
            find_cond_2             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
        elif ifeat ==1:
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 1))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 2))
            find_cond_1             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 2))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 1))
            find_cond_2             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
        elif ifeat ==2:
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 1) & (index[:,2] == 1))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 2) & (index[:,2] == 1))
            find_cond_1             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 2))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 1))
            find_cond_2             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
        elif ifeat == 3:
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 1) & (index[:,2] == 2))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 2) & (index[:,2] == 2))
            find_cond_2             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
            tmp_1                   = np.where((index[:,0] == 1) & (index[:,1] == 2))
            tmp_2                   = np.where((index[:,0] == 2) & (index[:,1] == 1))
            find_cond_2             = np.hstack((tmp_1,tmp_2))
            del(tmp_1,tmp_2)
            
            
        indx_1                      = np.repeat(1,np.size(find_cond_1))
        indx_2                      = np.repeat(2,np.size(find_cond_2))
        find_trials                 = np.squeeze(np.hstack((find_cond_1,find_cond_2)))
        
        y                           = np.hstack((indx_1,indx_2))
        x                           = np.squeeze(data[find_trials,:,:])
        
        scores                      = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
        scores                       = np.mean(scores, axis=0)
    
        ax[ifeat].plot(time_axis, scores, label='score (crossval)', linewidth=2, color='black')
        ax[ifeat].axhline(.5, color='r', linestyle='--', label='chance')
        ax[ifeat].axhline(.4, color='k', linestyle=':')
        ax[ifeat].axhline(1, color='k', linestyle=':')
        ax[ifeat].set_xlabel('Times')
        ax[ifeat].set_ylabel('Decoding ' + list_decode[ifeat])  # Area Under the Curve
        ax[ifeat].legend()
        ax[ifeat].axvline(.0, color='k', linestyle='-')
        #ax.set_title('AUC')
        
    plt.show()

    
    