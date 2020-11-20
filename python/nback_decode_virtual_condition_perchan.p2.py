#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 18 12:29:54 2019

@author: hesels
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

big_dir                                                 = '/project/3015039.05/temp/nback/data/'
dir_data                                                = big_dir + 'tf/'

suj_list                                                = np.squeeze(loadmat('/project/3015039.05/temp/nback/scripts/matlab/suj_list_peak.mat')['suj_list'])
frq_list                                                = ['brainbroadband.mtmavg.beta2Hz.bslcorrected']

for isub in range(22,44): #len(suj_list)):
    for ifreq in range(len(frq_list)):
    
        suj                                             = suj_list[isub]
        
        #fname                                           = dir_data + 'sub' + str(suj) + '.broadband.bslcorr.' + str(frq_list[ifreq]) + 'Hz.mat'
        fname                                           = dir_data + 'sub' + str(suj) + '.' + frq_list[ifreq] + '.mat'
        
        if os.path.isfile(fname):
            print('Loading '+ fname)
                
            epochs                                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', 
                                                                                    trialinfo_column=1)
            
            alldata                                         = epochs.get_data()
            allevents                                       = np.squeeze(epochs.events)[:,-1]
            
            time_axis                                       = epochs.times
    
            print('Handling '+ fname)
    
            
            # change to 0 1 2
            allevents                                       = allevents - 4
            
            test_done                                       = np.transpose(np.array(([0,0,1],[1,2,2])))    
            test_name                                       = ["0v1B","0v2B","1v2B"]
            
            for xi in range(len(test_name)):
                    
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
                
                dir_out                                     = big_dir + 'decode/new_virt/'
                fname_out                                   =  dir_out + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + frq_list[ifreq] + '.auc.bychan.mat'
                
                if not os.path.isfile(fname_out):
                
                    for nchan in range(number_chan):
                        print('\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for ' + 'sub' + str(suj) + '.' + test_name[xi]  + '.' + str(frq_list[ifreq]) + 'Hz')
                        
                        x                                       = np.zeros((number_trial,1,number_sample))
                        x[:,0,:]                                = sub_data[:,nchan,:]  
                        x[np.where(np.isnan(x))]                = 0
                        
                        clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                        time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        tmp_scores                              = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                        scores[nchan,:]                         = np.mean(tmp_scores, axis=0) # Mean scores across cross-validation splits
                        
                        del(x,tmp_scores)
                    
                    print('\nsaving '+ fname_out + '\n')
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                    
                    del(scores,y,sub_data,find_both)
            
            os.remove(fname)
            del(alldata,allevents)