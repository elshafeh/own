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

big_dir                                                 = '/Users/heshamelshafei/Dropbox/project_me/pjme_nback/'
dir_data                                                = big_dir + 'data/source/virtual/'

suj_list                                                = np.squeeze(loadmat(big_dir + 'scripts/suj_list_peak.mat')['suj_list'])
frq_list                                                = ['alpha1Hz','beta3Hz']
ses_list                                                = ['session1','session2']

for isub in range(len(suj_list)):
    for ifreq in range(len(frq_list)):
        for ises in range(len(ses_list)):
    
            suj                                         = suj_list[isub]
            
            fname                                       = dir_data + 'sub' + str(suj) + '.' + ses_list[ises] + '.brain.' + frq_list[ifreq] + '.virt.mat'
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
            for ntime in range(np.shape(alldata)[2]):
                alldata[ntrial,:,ntime]                 = alldata[ntrial,:,ntime] - np.mean(alldata[ntrial,:,:],axis=1)
        
        print('done\n')
        
        # keep conditions to 4 5 6
        allevents                                       = allevents
        
        test_done                                       = [4,5,6]    
        test_name                                       = ['0Ball','1Ball','2Ball']
        
        
        for xi in range(len(test_done)):
                
            find_stim                                   = np.squeeze(np.where(allevents == test_done[xi]))
            
            y                                           = np.zeros(np.shape(alldata)[0])
            y[find_stim]                                = 1
            
            number_trial                                = np.shape(alldata)[0]
            number_chan                                 = np.shape(alldata)[1]
            number_sample                               = np.shape(alldata)[2]
            scores                                      = np.zeros((number_chan,number_sample))
            
            for nchan in range(number_chan):
                print('\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for ' + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + frq_list[ifreq])
                
                x                                       = np.zeros((number_trial,1,number_sample))
                x[:,0,:]                                = alldata[:,nchan,:]  
                
                clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                tmp_scores                              = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                scores[nchan,:]                         = np.mean(tmp_scores, axis=0) # Mean scores across cross-validation splits
                
                del(x,tmp_scores)
                
            dir_out                                     = big_dir + 'data/decode_data/virt/'
            fname_out                                   =  dir_out + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + frq_list[ifreq] + '.virt.demean.auc.bychan.mat'
            
            print('\nsaving '+ fname_out + '\n')
            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            
            del(scores,y)
        
        del(alldata,allevents)