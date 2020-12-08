#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 24 22:53:45 2019

@author: heshamelshafei
"""

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
import scipy
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator

dir_data                            = '/Users/heshamelshafei/Dropbox/project_me/bil/meg/data/'

suj_list                            = list(['sub001','sub003','sub004'])
dcd_list                            = list(["orientation","frequency","color"])

all_scores                          = np.zeros((len(suj_list),len(dcd_list),201))

for isub in range(len(suj_list)):
    
    suj                             = suj_list[isub]
    
    print('\nHandling '+ suj+'\n')
    
    ext_name                        = ".mat" # "_headincorp.mat" "_planarcombined.mat"
    fname                           = dir_data + suj + '/preproc/' + suj + '_gratingLock_dwnsample100Hz' + ext_name
    
    eventName                       = dir_data + suj + '/preproc/' + suj + '_gratingLock_trialinfo.mat'
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    allevents                       = loadmat(eventName)['index']
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    
    print('\n')
    
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
            
            if len(allevents[1,:]) == 19:
                indx = -4
            elif len(allevents[1,:]) == 18:
                indx = -3
                
            find_trials             = np.where(allevents[:,indx]<3)
            x                       = np.squeeze(x[find_trials,:,:])
            y                       = np.squeeze(y[find_trials])
            
            clf                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            
            scores                  = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
            scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            all_scores[isub,ifeat,:] = scores
            
            del scores
            
            print('\n')
            
fig, ax        = plt.subplots(len(suj_list),len(dcd_list))

col_pal = list(["#1f78b4", "#b2df8a","#fb9a99"])

for isub in range(len(suj_list)):
    for ifeat in range(len(dcd_list)):
        
        tmp         = all_scores[isub,ifeat,:]
        scores      = tmp
                
        ax[isub,ifeat].plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
        
        # unify title
        if isub == 0:
            ax[isub,ifeat].set_title(dcd_list[ifeat])
        
        # unify x axes
        if isub == len(suj_list)-1:
            ax[isub,ifeat].set_xlabel('Times')
        
        # unify y axes
        if ifeat == 0:
            ax[isub,ifeat].set_ylabel('AUC')
        
        ax[isub,ifeat].axvline(.0, color='k', linestyle='-')
        
        x           = epochs.times
        y           = scores
        
        ax[isub,ifeat].fill_between(x, y, where=y>0.5, facecolor=col_pal[ifeat], interpolate=True)
        ax[isub,ifeat].set_ylim([0.5,1])
        
        ax[isub,ifeat].set_xlim([-0.1,1])