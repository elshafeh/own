#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 14:56:21 2019

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
data_list                                                   = list(['CnD.eeg','pt1.CnD.meg','pt2.CnD.meg','pt3.CnD.meg'])
feat_list                                                   = list(['inf.unf','left.right'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                 = 'yc'+ str(suj_list[isub])
                    
        fname                                               = '/Volumes/heshamshung/alpha_compare/preproc_data/' + suj + '.' + data_list[idata] + '.sngl.dwn100.mat'
        print('\nHandling '+ fname)
        
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
            
            
            number_chan                                     = np.shape(sub_data)[1]
            number_trial                                    = np.shape(sub_data)[0]
            number_sample                                   = np.shape(sub_data)[2]
            scores                                          = np.zeros((number_chan,number_sample))
            
            for nchan in range(number_chan):
            
                print('\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for ' + suj + '-' + data_list[idata] + '-' + feat_list[ifeat])
                
                x                                           = np.zeros((number_trial,1,number_sample))
                x[:,0,:]                                    = sub_data[:,nchan,:]  
            
                y                                           = np.squeeze(allinf)        
                
                clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                tmp_scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
                scores[nchan,:]                             = np.mean(tmp_scores, axis=0) # Mean scores across cross-validation splits
            
            fname_out   =  '/Volumes/heshamshung/alpha_compare/decode/topo/' + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.auc.topo.mat'
            scipy.io.savemat(fname_out, mdict={'scores': scores})
            print('\nsaving '+ fname_out + '\n')
                
            del(scores,x,y)