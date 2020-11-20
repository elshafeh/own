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
from scipy.io import (savemat,loadmat)
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
        for ifreq in range(1,31):
        
            suj                                                     = suj_list[isub]
            
            fname                                                   = 'J:/temp/nback/data/tf/sub' + str(suj)+ '.sess' +str(ises) + '.orig.' + str(ifreq)+ 'Hz.mat'  
            ename                                                   = 'K:/nback/nback_' +str(ises) + '/data_sess' + str(ises) + '_s' +str(suj)+ '_trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            alldata                                                 = epochs_nback.get_data() #Get all epochs as a 3D array.
            
            allevents                                               = loadmat(ename)['index'][:,[0,2]]        
            allevents[:,0]                                          = allevents[:,0]-4
            
            time_axis                                               = epochs_nback.times
            
            for nback in range(3):
                
                find_nback                                          = np.where(allevents[:,0] == nback)
                
                if np.size(find_nback)>0:
                
                    data_nback                                      = np.squeeze(alldata[find_nback,:,:])
                    evnt_nback                                      = np.squeeze(allevents[find_nback,1])
                    
                    dir_out                                         = 'J:/temp/nback/data/stim_per_cond_mtm/'
                    fname_out                                       = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.' + str(nback) + 'back.'+ str(ifreq)+ 'Hz.first.auc.mat'
                    
                    if not os.path.exists(fname_out):
                        
                        if nback == 0:
                            #find_stim                               = np.where((evnt_nback == 1)) # find target stimulus
                            find_stim                               = np.where((evnt_nback == 0)) # find first stimulus
                        else:
                            #find_stim                               = np.where((evnt_nback == 2)) # find target stimulus
                            find_stim                               = np.where((evnt_nback == 1)) # find first stimulus
                            
                        if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                        
                            x                                       = data_nback
                            x[np.where(np.isnan(x))]                = 0
                            
                            y                                       = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                            = 1
                            y                                       = np.squeeze(y)
                            
                            clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                            time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                            scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                            scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                            
                            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                            
                            print('\nsaving '+ fname_out + '\n')
                            del(scores,x,y)