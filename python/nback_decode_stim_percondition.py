# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:00:37 2020

@author: hesels
"""

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
        
        suj                                                     = suj_list[isub]
        
        fname                                                   = 'K:/nback/nback_' +str(ises) + '/data_sess' + str(ises) + '_s' +str(suj)+ '.mat'  
        ename                                                   = 'K:/nback/nback_' +str(ises) + '/data_sess' + str(ises) + '_s' +str(suj)+ '_trialinfo.mat'
        print('Handling '+ fname)
            
        epochs_nback                                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        # down-sample
        epochs_nback                                            = epochs_nback.copy().resample(70, npad='auto')
        alldata                                                 = epochs_nback.get_data() #Get all epochs as a 3D array.
        
        allevents                                               = loadmat(ename)['index'][:,[0,1,4,2]]        
        allevents[:,0]                                          = allevents[:,0]-4
        allevents[:,1]                                          = np.mod(allevents[:,1] ,10)+1
        
        time_axis                                               = epochs_nback.times
        
        # sub-select time window 
        
        t1                                                      = np.squeeze(np.where(time_axis == -1))
        t2                                                      = np.squeeze(np.where(time_axis == 2))
        
        trl                                                     = np.squeeze(np.where(allevents[:,3] == 1))

        alldata                                                 = np.squeeze(alldata[trl,:,t1:t2])
        allevents                                               = np.squeeze(allevents[trl,:])
        
        time_axis                                               = np.squeeze(time_axis[t1:t2])
        
        for nback in range(3):
            
            find_nback                                          = np.where(allevents[:,0] == nback)
            
            if np.size(find_nback)>0:
            
                data_nback                                      = np.squeeze(alldata[find_nback,:,:])
                evnt_nback                                      = np.squeeze(allevents[find_nback,1])
                
                for xi in range(1,11):
                    
                    dir_out                                     = 'K:/nback/stim_per_cond/'
                    fname_out                                   = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.stim' + str(xi) + '.' + str(nback) + 'back.dwn70.1st.auc.mat'
                    
                    if not os.path.exists(fname_out):
                    
                        find_stim                               = np.where((evnt_nback == xi))
                        
                        if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                        
                            x                                   = data_nback
                            y                                   = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                        = 1
                            y                                   = np.squeeze(y)
                            
                            clf                                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                            time_decod                          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                            scores                              = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                            scores                              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                            
                            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                            
                            print('\nsaving '+ fname_out + '\n')
                            del(scores,x,y)