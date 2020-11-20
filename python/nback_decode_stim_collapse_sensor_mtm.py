#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 29 13:07:01 2019

@author: hesels
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 15:10:06 2019

@author: heshamelshafei
"""
import os

if os.name == 'posix':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from scipy.io import (savemat,loadmat)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,Vectorizer)

if os.name == 'posix':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression


dir_data                                                                            = '/project/3015039.05/temp/nback/data/decode/stim_break/'

suj_list                                                                            = [22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

#,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,

for isub in range(len(suj_list)):
    for ises in range(1,3):
        for ifreq in range(1,31):
            
            suj                                                                     = suj_list[isub]
            fname                                                                   = dir_data + 'decode/mtm/sub' + str(suj) + '.sess' + str(ises) + '.stack.' + str(ifreq) +'Hz.mat'
            eventName                                                               = dir_data + 'decode/mtm/sub' + str(suj) + '.sess' + str(ises) + '.stack.' + str(ifreq) +'Hz.trialinfo.mat'
            fname                                                                   = dir_data + 'sub' + str(suj) + '.sess' + str(ises) + '.stack.' + str(ifreq) +'Hz.mat'
            eventName                                                               = dir_data + 'sub' + str(suj) + '.sess' + str(ises) + '.stack.' + str(ifreq) +'Hz.trialinfo.mat'
    
            if os.path.exists(fname):
            
            if os.path.isfile(fname):
                
                                    
                epochs                                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
                
                alldata                                                             = epochs.get_data() #Get all epochs as a 3D array.
                allevents                                                           = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
                
                # adjust condition triggers
                allevents[:,1]                                                      = allevents[:,1]-4
                # adjust stim triggers
                allevents[:,2]                                                      = allevents[:,2] - (np.floor(allevents[:,2]/10)*10) + 1
                allevents[:,13]                                                     = allevents[:,13] - (np.floor(allevents[:,13]/10)*10) + 1
                allevents[:,24]                                                     = allevents[:,24] - (np.floor(allevents[:,24]/10)*10) + 1
                
                allevents                                                           = allevents[:,[1,2,13,24]]
                time_axis                                                           = epochs.times
                
                print('\nHandling '+ fname+'\n')
                

                for nback in range(3):
                    
                    find_nback                                                      = np.where(allevents[:,0] == nback)
                    
                    # to avoid missing conditions in different sessions
                    if np.size(np.squeeze(find_nback)) > 0:
                    
                        data_nback                                                  = np.squeeze(alldata[find_nback,:,:])
                        
                        for stim_lock in range(1,4):
                        
                            evnt_nback                                              = np.squeeze(allevents[find_nback,stim_lock])
                            
                            for xi in range(1,11):
                                
                                dir_out                                             = dir_data
                                fname_out                                           = 'sub' + str(suj) + '.sess' + str(ises) + '.stim' + str(xi) + '.' + str(nback) + 'back.'+ str(stim_lock)
                                fname_out                                           = fname_out + 'lock.'+str(ifreq) + 'Hz.auc.collapse.mat'
                                
                                if not os.path.isfile(fname_out):
                                
                                    find_stim                                       = np.where((evnt_nback == xi))
                                    
                                    if np.shape(find_stim)[1] > 2:
                                    
                                        x                                           = data_nback
                                        x[np.where(np.isnan(x))]                    = 0
                                        
                                        y                                           = np.zeros(np.shape(evnt_nback)[0])
                                        y[find_stim]                                = 1
                                        y                                           = np.squeeze(y)
                                        
                                        if np.shape(np.unique(y))[0] == 2:
                                            
                                            clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                                            time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                                            scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                                            scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                                            
                                            print('\nsaving '+ fname_out + '\n')
                                            savemat(dir_out+fname_out, mdict={'scores': scores,'time_axis':time_axis})
                                            
                                            del(scores,x,y)
                                            
                os.remove(fname)
                os.remove(eventName)