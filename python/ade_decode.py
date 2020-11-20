#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 25 15:57:25 2019

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

dir_data                                        = '/Users/heshamelshafei/Dropbox/project_me/pjme_ade/data/preproc/'

#suj_list                                        = list(["sub006_aud","sub007_aud","sub008_aud","sub010_aud","sub012_aud","sub015_aud","sub017_aud"])
bin_list                                        = list([1,2,3])
feat_list                                       = list([0,1,2])

all_scores                                      = np.zeros((len(suj_list),len(bin_list),len(feat_list),121))

# 0 1   2    3   4    5        6        7   8        9       10
# n mod nois sid stim beh_corr beh_conf RT response mapping difference

for isub in range(len(suj_list)):
    
    suj                                         = suj_list[isub]
    
    for ibin in range(len(bin_list)):
    
        ext_data                                = '_sfn_dwnsample'
        
        fname                                   = dir_data + suj + ext_data + '.BigB' + str(bin_list[ibin]) + '.mat'
        
        print('\nHandling '+ fname+'\n')
        
        eventName                               = dir_data + suj + ext_data + '_trialinfo.BigB' +  str(bin_list[ibin]) + '.mat'
        
        epochs                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        allevents                               = loadmat(eventName)['index']
        
        alldata                                 = epochs.get_data() #Get all epochs as a 3D array.
        
        print('\n')
        
        for ifeat in range(len(feat_list)):
            
            if ifeat == 0:
                ## side
                x                               = alldata
                y                               = allevents[:,3]
                find_trials                     = np.where(allevents[:,2]==1) # choise only noisy
                
            elif ifeat == 1:
                ## type 1
                x                               = alldata
                y                               = allevents[:,4]
                find_trials                     = np.where((allevents[:,5]==1) & (allevents[:,2]==1) & (allevents[:,3]==0)) # choise only noisy left correct
            
            elif ifeat == 2:
                x                               = alldata
                y                               = allevents[:,4]
                find_trials                     = np.where((allevents[:,5]==1) & (allevents[:,2]==1) & (allevents[:,3]==1)) # choise only noisy right correct
                
            x                                   = np.squeeze(x[find_trials,:,:])
            y                                   = np.squeeze(y[find_trials])
            
            clf                                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            
            scores                              = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
            scores                              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            all_scores[isub,ibin,ifeat,:]       = scores
            
            del scores
            
            print('\n')

scipy.io.savemat(dir_data + suj_list[0][7:10] + 'allscores_3bins.mat', mdict={'all_scores': all_scores})

## PLOTTING ##

fig, ax             = plt.subplots(2,len(bin_list))
col_pal             = list(["#1f78b4", "#b2df8a","#fb9a99","#1f78b2", "#b2df6a","#fb9a59"])
              
for ibin in range(len(bin_list)):
    for ifeat in range(2):
        
        if ifeat == 0:
            tmp         = np.mean(all_scores[:,ibin,ifeat,:],axis = 0)
        elif ifeat > 0:
            
            tmp1            = np.transpose(np.mean(all_scores[:,ibin,1,:],axis = 0))
            tmp2            = np.transpose(np.mean(all_scores[:,ibin,2,:],axis = 0))
            
            tmp             = (tmp1+tmp2)/2
            
        scores      = tmp
        
        ax[ifeat,ibin].plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
        
        ax[ifeat,ibin].set_title('B' + str(bin_list[ibin]))
        
        ax[ifeat,ibin].axvline(.0, color='k', linestyle='-')
        
        x           = epochs.times
        y           = scores
        
        ax[ifeat,ibin].fill_between(x, y, where=y>0.5, facecolor=col_pal[ibin], interpolate=True)
        
        if ifeat == 0:
            ax[ifeat,ibin].set_ylim([0.5,1])
        elif ifeat > 0:
            ax[ifeat,ibin].set_ylim([0.5,0.7]) 
        
        
        ax[ifeat,ibin].set_xlim([-0.1,1])