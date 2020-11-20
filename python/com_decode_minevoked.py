#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 13:46:05 2019

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

suj_list                                                    = [1,2,3,4,8,9,10,11,12,13,14,15,16,17]
data_list                                                   = list(['pt1.CnD.meg','pt2.CnD.meg','pt3.CnD.meg','CnD.eeg'])
feat_list                                                   = list(['inf','lr'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                 = 'yc'+ str(suj_list[isub])
            
        fname                                               = '/Users/heshamelshafei/Dropbox/project_me/meeg_compare/data/preproc_data/'
        fname                                               = fname + suj + '.' + data_list[idata] + '.minus.evoked.mat'
        print('Handling '+ fname)
            
        epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                           = epochs.events[:,-1]
        
        lm1                                                 = np.squeeze(np.array(np.where(epochs.times == -0.2)))
        lm2                                                 = np.squeeze(np.array(np.where(epochs.times == 2)))
        
        time_axis                                           = epochs.times[lm1:lm2]
        
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
            
            fname_out   =  '/Users/heshamelshafei/Dropbox/project_me/meeg_compare/decode/' + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.minus.evoked.auc.mat'
            scipy.io.savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            print('\nsaving '+ fname_out + '\n')
            
            del(scores,x,y)