#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 09:22:31 2019

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

dir_data                                                    = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/nback/'

suj_list                                                    = [1,2,3,4,8,9,10,11,12,13,14,15,16,17]
data_list                                                   = list(['eeg','meg'])
feat_list                                                   = list(['inf.unf','left.right'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                 = 'yc'+ str(suj_list[isub])
        fname                                               = '/Volumes/heshamshung/alpha_compare/lcmv/' + suj + '.CnD.com90roi.' + data_list[idata] + '.mat'
        
        print('Handling '+ fname)
            
        epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                           = epochs.events[:,-1]
        
        lm1                                                 = np.squeeze(np.array(np.where(epochs.times == -0.1)))
        lm2                                                 = np.squeeze(np.array(np.where(epochs.times == 2)))
        
        alldata                                             = alldata[:,:,lm1:lm2]
        allcodes                                            = allevents - 1000
        
        for ifeat in range(len(feat_list)):
            
            if ifeat == 0:
                find_trials                                 = np.where(allcodes > 0) # all trials
            else:
                find_trials                                 = np.where(allcodes > 100)
            
            sub_data                                        = np.squeeze(alldata[find_trials,:,:])
            allcodes                                        = np.squeeze(allcodes[find_trials])
            
            allcues                                         = np.floor(allcodes/100)
            allinf                                          = allcues
            
            if np.shape(np.unique(allinf))[0] > 2:
                allinf[np.where(allinf > 0)]                = 1            
            
            if isub == 0:
                all_scores                                  = np.zeros((len(suj_list),len(data_list),np.shape(sub_data)[2]))
            
            x                                               = np.squeeze(sub_data)
            y                                               = np.squeeze(allinf)        
            
            clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            scores                                          = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
            scores                                          = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            fname_out   =  '/Volumes/heshamshung/alpha_compare/decode/source/' + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.90source.auc.collapse.mat'
            scipy.io.savemat(fname_out, mdict={'scores': scores})
            print('\nsaving '+ fname_out + '\n')
            
            del(scores,x,y)