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
feat_list                                                   = list(['inf.unf','left.right','left.inf','right.inf'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                 = 'yc'+ str(suj_list[isub])
            
        fname                                               = '/Users/heshamelshafei/Dropbox/project_me/meeg_compare/data/preproc_data/' 
        #fname                                               = '/Volumes/heshamshung/alpha_compare/preproc_data/'
        fname                                               = fname + suj + '.' + data_list[idata] + '.sngl.dwn100.mat'
        
        print('Handling '+ fname)
            
        epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                           = epochs.events[:,-1]
        
        lm1                                                 = np.squeeze(np.array(np.where(epochs.times == -0.1)))
        lm2                                                 = np.squeeze(np.array(np.where(epochs.times == 2)))
        
        alldata                                             = alldata[:,:,lm1:lm2]
        allcodes                                            = allevents - 1000
        
        time_axis                                           = np.squeeze(epochs.times[lm1:lm2])
        
        for ifeat in range(len(feat_list)):
            
            if ifeat == 0:
                find_trials                                 = np.where(allcodes > 0) # all trials
            elif ifeat == 1:
                find_trials                                 = np.where(allcodes > 100)
            elif ifeat == 2:
                find_trials                                 = np.where(allcodes < 200)
            elif ifeat == 3:
                find_trials                                 = np.where((allcodes < 10) | (allcodes>200))
            
            sub_data                                        = np.squeeze(alldata[find_trials,:,:])
            sub_code                                        = np.squeeze(allcodes[find_trials])
            
            allinf                                          = np.floor(sub_code/100)
            
            if np.shape(np.unique(allinf))[0] > 2:
                allinf[np.where(allinf > 0)]                = 1            
            
            x                                               = np.squeeze(sub_data)
            y                                               = np.squeeze(allinf)        
            
            clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            scores                                          = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
            scores                                          = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            fname_out                                       =  '/Users/heshamelshafei/Dropbox/project_me/meeg_compare/data/auc/'
            fname_out                                       =  fname_out + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.auc.mat'

            scipy.io.savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            print('\nsaving '+ fname_out + '\n')
            
            del(scores,x,y,allinf,sub_data,sub_code,find_trials)