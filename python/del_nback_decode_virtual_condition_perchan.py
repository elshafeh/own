#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 18 12:22:46 2019

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 13 14:33:03 2019

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 21 11:56:29 2019

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
import seaborn as sns

big_dir                                                 = '/projects/3015039.05/temp/nback/'
dir_data                                                = big_dir + 'data/source/virtual/'

suj_list                                                = np.squeeze(loadmat(big_dir + 'scripts/suj_list_peak.mat')['suj_list'])
frq_list                                                = ['alpha1Hz.virt','beta3Hz.virt']#,'alpha1Hz.virt.hilbert','beta3Hz.virt.hilbert']
ses_list                                                = ['session1','session2']

for isub in range(len(suj_list)):
    for ifreq in range(len(frq_list)):
        for ises in range(len(ses_list)):
    
            suj                                         = suj_list[isub]
            
            fname                                       = dir_data + 'sub' + str(suj) + '.' + ses_list[ises] + '.brain.' + frq_list[ifreq] + '.mat'
            print('Loading '+ fname)
                
            epochs                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', 
                                                                                    trialinfo_column=1)
            
            tmp_data                                    = epochs.get_data()
            tmp_evnt                                    = np.squeeze(epochs.events)[:,-1]
            
            time_axis                                   = epochs.times
            
            if ises == 0:
                alldata                                 = tmp_data #Get all epochs as a 3D array.
                allevents                               = tmp_evnt
            else:
                alldata                                 = np.concatenate((alldata,tmp_data),axis=0)
                allevents                               = np.concatenate((allevents,tmp_evnt),axis=0)
        
        del(ises,tmp_data,tmp_evnt)
        
        fname                                           = dir_data + 'sub' + str(suj) + '.brain.' + frq_list[ifreq] + '.virt.mat'
        print('Handling '+ fname)
        
        # remove mean
        print('\ndemeaning')
        
        for ntrial in range(np.shape(alldata)[0]):
            print('demeaning trial '+ str(ntrial) + ' of ' + str(np.shape(alldata)[0]))
            for ntime in range(np.shape(alldata)[2]):
                alldata[ntrial,:,ntime]                 = alldata[ntrial,:,ntime] - np.mean(alldata[ntrial,:,:],axis=1)
        
        print('done\n')
        
        # keep conditions to 4 5 6
        allevents                                       = allevents
        
        test_done                                       = np.transpose(np.array(([0,0,1],[1,2,2])))    
        test_name                                       = ["0v1B","0v2B","1v2B"]
        
        for xi in range(len(test_done)):
                
            find_both                                   = np.where((allevents == test_done[xi,0]) | (allevents == test_done[xi,1]))
            
            sub_data                                    = np.squeeze(alldata[find_both,:,:])
            y                                           = np.squeeze(allevents[find_both])
            
            # make sure codes are ones and zeroes
            y[np.where(y == np.min(y))]                 = 0
            y[np.where(y == np.max(y))]                 = 1
                        
            number_trial                                = np.shape(sub_data)[0]
            number_chan                                 = np.shape(sub_data)[1]
            number_sample                               = np.shape(sub_data)[2]
            scores                                      = np.zeros((number_chan,number_sample))
            
            for nchan in range(number_chan):
                print('\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for ' + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + frq_list[ifreq])
                
                x                                       = np.zeros((number_trial,1,number_sample))
                x[:,0,:]                                = sub_data[:,nchan,:]  
                
                clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                tmp_scores                              = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                scores[nchan,:]                         = np.mean(tmp_scores, axis=0) # Mean scores across cross-validation splits
                
                del(x,tmp_scores)
                
            dir_out                                     = big_dir + 'data/decode_data/virt/'
            fname_out                                   =  dir_out + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + frq_list[ifreq] + '.demean.auc.bychan.mat'
            
            print('\nsaving '+ fname_out + '\n')
            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            
            del(scores,y,sub_data,find_both)
        
        del(alldata,allevents)