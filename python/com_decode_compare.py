#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 14 13:46:38 2019

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

dir_data                                            = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/nback/'

suj_list                                            = [1,2,3,4,8,9,10,11,12,13,14,15,16,17]
data_list                                           = list(['eeg','meg'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                         = 'yc'+ str(suj_list[isub])
        
        if idata == 0:
            
            fname                                   = '/Volumes/h128ssd/alpha_compare/preproc_data/' + suj + '.CnD.' + data_list[idata] + '.sngl.dwn100.mat'
            print('Handling '+ fname)
            
            epochs                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            alldata                                 = epochs.get_data() #Get all epochs as a 3D array.
            allevents                               = epochs.events[:,-1]
        
        elif idata == 1:
            
            for nprt in range(1,4):
                
                fname                                   = '/Volumes/h128ssd/alpha_compare/preproc_data/' + suj + '.pt'+ str(nprt) +'.CnD.' + data_list[idata] + '.sngl.dwn100.mat'
                print('Handling '+ fname)
                
                epochs                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
                tmp_data                                = epochs.get_data() #Get all epochs as a 3D array.
                tmp_evnt                                = epochs.events[:,-1]
                
                if nprt == 1:
                    alldata                             = tmp_data
                    allevents                           = tmp_evnt
                    
                    del(tmp_data,tmp_evnt)
                    
                elif nprt > 1:
                    alldata                             = np.concatenate((alldata,tmp_data),axis=0)
                    allevents                           = np.concatenate((allevents,tmp_evnt),axis=0)
        
        lm1                                             = np.squeeze(np.array(np.where(epochs.times == -0.1)))
        lm2                                             = np.squeeze(np.array(np.where(epochs.times == 2)))
        
        alldata                                         = alldata[:,:,lm1:lm2]
        allcodes                                        = allevents - 1000
        
        
#        find_trials                                     = np.where(allcodes > 100) # inf
#        find_trials                                     = np.where(allcodes < 0) # unf
        find_trials                                     = np.where(allcodes > 0) # all trials
        
        alldata                                         = np.squeeze(alldata[find_trials,:,:])
        allcodes                                        = np.squeeze(allcodes[find_trials])
        
        allcues                                         = np.floor(allcodes/100)
        
        
        allinf                                          = allcues
        allinf[np.where(allinf > 0)]                    = 1
        
        allstim                                         = allcodes - allcues*100
        
        allsides                                        = np.mod(allstim,2)
        
        allpitch                                        = allstim
        allpitch[np.where(allpitch < 3)]                = 0
        allpitch[np.where(allpitch > 2)]                = 1
        
        
        if isub == 0:
            all_scores                                  = np.zeros((len(suj_list),len(data_list),np.shape(alldata)[2]))
        
        x                                               = np.squeeze(alldata)
        
        y                                               = np.squeeze(allpitch)        
        
        clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
        time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
        scores                                          = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
        scores                                          = np.mean(scores, axis=0) # Mean scores across cross-validation splits
        
        all_scores[isub,idata,:]                        = scores
        del(scores,x,y)
        
fig, ax        = plt.subplots(1,len(data_list))
col_pal = list(["#1f78b4","#fb9a99"])

for idata in range(len(data_list)):
    
    tmp         = np.mean(all_scores[:,idata,:],axis = 0)
    scores      = tmp
    
    time_axs    = epochs.times[lm1:lm2]
    
    ax[idata].plot(time_axs, scores, label='score (crossval)', linewidth=2, color='black')
    
    ax[idata].set_xlabel('Times')
    ax[idata].set_ylabel('AUC - ' + data_list[idata])

    
    ax[idata].axvline(.0, color='k', linestyle='-')
    
    x           = time_axs
    y           = scores
    
    ax[idata].fill_between(x, y, where=y>0.5, facecolor=col_pal[idata], interpolate=True)
    ax[idata].set_ylim([0.5,0.7])
    ax[idata].set_xlim([-0.1,2])
    