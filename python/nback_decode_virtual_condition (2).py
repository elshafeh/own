#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 21 11:56:29 2019

@author: heshamelshafei
"""

import os

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from mne.decoding import GeneralizingEstimator
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import savemat
from scipy.io import loadmat

big_dir                                                 = '/project/3015039.05/temp/nback/'
dir_data                                                = big_dir + 'data/source/virtual/0.5cm/'

suj_list                                                = np.squeeze(loadmat(big_dir + 'scripts/matlab/suj_list_peak.mat')['suj_list'])
frq_list                                                = ['brain0.5.beta4Hz.dwn60.virt']
                                                          
#frq_list                                                = ['brain0.5.alpha1Hz.dwn60.virt','brain0.5.alpha2Hz.dwn60.virt',
#                                                           'brain0.5.beta2Hz.dwn60.virt','brain0.5.beta3Hz.dwn60.virt'
#                                                           ,'brain0.5.beta4Hz.dwn60.virt']

ses_list                                                = ['session1','session2']


for isub in range(len(suj_list)):
    for ifreq in range(len(frq_list)):
        for ises in range(len(ses_list)):
    
            suj                                         = suj_list[isub]
            
            fname                                       = dir_data + 'sub' + str(suj) + '.' + ses_list[ises] + '.' + frq_list[ifreq] + '.mat'
            print('Handling '+ fname)
                
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
        
        # remove mean
        print('\ndemeaning')
        
        for ntrial in range(np.shape(alldata)[0]):
            print('demeaning trial '+ str(ntrial) + ' of ' + str(np.shape(alldata)[0]))
            for ntime in range(np.shape(alldata)[2]):
                alldata[ntrial,:,ntime]                 = alldata[ntrial,:,ntime] - np.mean(alldata[ntrial,:,:],axis=1)
        
        print('done\n')

        # remove evoked
        # alldata                                         = alldata - np.mean(alldata,axis=0)
        
        # make conditions to 0, 1 and 2
        allevents                                       = allevents - 4
        
        test_done                                       = np.transpose(np.array(([0,0,1],[1,2,2])))    
        test_name                                       = ["0v1B","0v2B","1v2B"]
        
        for xi in range(len(test_done)):
                
            find_both                                   = np.where((allevents == test_done[xi,0]) | (allevents == test_done[xi,1]))
            
            x                                           = np.squeeze(alldata[find_both,:,:])
            y                                           = np.squeeze(allevents[find_both])
            
            # make sure codes are ones and zeroes
            y[np.where(y == np.min(y))]                 = 0
            y[np.where(y == np.max(y))]                 = 1
            
            clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
            scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                        
            dir_out                                     = big_dir + 'data/decode/virt/'
            fname_out                                   =  dir_out + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + frq_list[ifreq] + '.demean.auc.mat'
            
            print('\nsaving '+ fname_out + '\n')
            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            
            del(scores,x,y)
        
        del(alldata,allevents)