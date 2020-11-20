#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  6 19:42:03 2019

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 09:44:35 2019

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

suj_list                            = list([1,3,4,8,9,10,11,12,13,14])
dcd_list                            = list(["pre-vs-retro","pre ori-vs-spa","retro ori-vs-spa"])

all_scores                          = np.zeros((len(suj_list),len(dcd_list),52))

for isub in range(len(suj_list)):
    
    if suj_list[isub] < 10:
        suj                         = 'sub00' + str(suj_list[isub])
    elif suj_list[isub] >= 10:
        suj                         = 'sub0' + str(suj_list[isub])
        
    
    print('\nHandling '+ suj+'\n')
    
    ext_name                        = "_firstcuelock_dwnsample100Hz_first_cue_freqbreak"
    
    fname                           = dir_data + suj + '/preproc/' + suj + ext_name + '.mat'
    eventName                       = dir_data + suj + '/preproc/' + suj + ext_name + '_trialinfo.mat'
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    allevents                       = loadmat(eventName)['index']
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    
    ## pick correct trials
    find_correct                    = np.where(allevents[:,1] == 1)
    alldata                         = np.squeeze(alldata[find_correct,:,:])
    allevents                       = np.squeeze(allevents[find_correct,:])
    ## 
    
    print('\n')
    
    for ifeat in range(len(dcd_list)):
        
        x                           = alldata
        mini_sub                    = allevents
        
        if ifeat == 0:
            
            # reto vs pre
            find_trials             = np.where((mini_sub[:,0] >0))
            
            y                       = np.zeros((len(mini_sub)))
            y[np.where((mini_sub[:,0] > 20) )]                          = 1
            
        elif ifeat == 1:
            # pre ori - vs spa
            find_trials             = np.where((mini_sub[:,0] < 20))
            mini_sub                = np.squeeze(mini_sub[find_trials,0])
            y                       = mini_sub - 11
            
        elif ifeat == 2:
            # ret ori - vs spa
            find_trials             = np.where((mini_sub[:,0] > 20))
            mini_sub                = np.squeeze(mini_sub[find_trials,0])
            y                       = mini_sub - 21
            
        chk                         = len(np.unique(y))
        
        if chk == 2:
            x                       = np.squeeze(x[find_trials,:,:])
            
            clf                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            
            scores                  = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
            scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            all_scores[isub,ifeat,:] = scores
            
            del scores
            
            print('\n')
            
fig, ax        = plt.subplots(len(dcd_list))

col_pal = list(["#1f78b4", "#b2df8a","#fb9a99"])

for ifeat in range(len(dcd_list)):
        
    tmp         = np.mean(all_scores[:,ifeat,:],axis = 0)
    scores      = tmp
            
    ax[ifeat].plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
    ax[ifeat].set_title(dcd_list[ifeat])
    
    if ifeat == 2:
        ax[ifeat].set_xlabel('Frequency Hz')
    
    if ifeat == 1:
        ax[ifeat].set_ylabel('AUC')
        
    x           = epochs.times * 100
    y           = scores
    
    #ax[ifeat].fill_between(x, y, where=y>0.5, facecolor=col_pal[ifeat], interpolate=True)
    #ax[ifeat].set_ylim([0.5,0.8])
    
    #ax[ifeat].set_xlim([1,50])
    #ax[ifeat].axvline(.0, color='k', linestyle='-')
        
