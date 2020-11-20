#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 15:10:06 2019

@author: heshamelshafei
"""

import mne
import fnmatch
import warnings
import numpy as np
import os
from scipy.io import savemat
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression


dir_data                                                        = 'K:/nback/'

suj_list                                                        = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    for ises in range(1,3):
        for nback in range(3):
        
            suj                                                     = suj_list[isub]
            
            fname                                                   = 'K:/nback/nback_' +str(ises) + '/data_sess' + str(ises) + '_s' +str(suj)+ '.mat'            
            print('Handling '+ fname)
                
            epochs_nback                                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            epochs_stim                                             = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=1)
            
            # down-sample
            epochs_nback                                            = epochs_nback.copy().resample(60, npad='auto')
            alldata                                                 = epochs_nback.get_data() #Get all epochs as a 3D array.
            
            allevents                                               = np.transpose(np.vstack((epochs_nback.events[:,-1]-4,np.mod(epochs_stim.events[:,-1],10)+1)))
            time_axis                                               = epochs_nback.times
            
            t1                                                      = np.squeeze(np.where(time_axis == -0.5))
            t2                                                      = np.squeeze(np.where(time_axis == 2))
            
            # sub-select time window 
            alldata                                                 = np.squeeze(alldata[:,:,t1:t2])
            time_axis                                               = np.squeeze(time_axis[t1:t2])
            
            for nback in range(3):
                
                find_nback                                          = np.where(allevents[:,0] == nback)
                
                if np.size(find_nback)>0:
                
                    data_nback                                      = np.squeeze(alldata[find_nback,:,:])
                    evnt_nback                                      = np.squeeze(allevents[find_nback,1])
                    
                    for xi in range(1,11):
                        
                        dir_out                                     = 'K:/nback/timegen/'
                        fname_out                                   = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.stim' + str(xi) + '.' + str(nback) + 'back.dwn60.auc.timegen.mat'
                        
                        if not os.path.exists(fname_out):
                        
                            find_stim                               = np.where((evnt_nback == xi))
                            
                            x                                       = data_nback
                            
                            y                                       = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                            = 1
                            y                                       = np.squeeze(y)
                            
                            clf                                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                            time_gen                                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                            time_gen.fit(X=x, y=y)
                            scores                                  = time_gen.score(X=x, y=y)
                            
                            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                            
                            print('\nsaving '+ fname_out + '\n')
                            del(scores,x,y)