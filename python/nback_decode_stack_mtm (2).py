#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 21 17:24:52 2019

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


#suj_list                                                = [1,2,3,4,5,6,7,8,9,10,
#                                                   11,12,13,14,15,16,17,18,19,20,
#                                                   21,22,23,24,25,26,27,28,29,
#                                                   30,31,32,33,35,36,38,39,40,
#                                                   41,42,43,44,46,47,48,49,
#                                                   50,51]

suj_list                                                = [26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]


freq_list                                               = list(range(1,51))
test_list                                               = list(["0v1","0v2","1v2"])


for isub in range(len(suj_list)):
    
    suj                                                 = suj_list[isub]

    for ifreq in range(len(freq_list)):
        
        dir_in                                          = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/mtm/'
        fname                                           = dir_in + 'data' + str(suj) + '.3stacked.dwsmple.' + str(freq_list[ifreq]) + 'Hz.mat'
        
        dir_in                                          = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/stack/'
        eventName                                       = dir_in + 'data' + str(suj) + '.3stacked.trialinfo.mat'
        
        print('Handling '+ fname)
            
        epochs                                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        alldata                                         = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                       = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
        
        os.remove(fname)
        
        test_done                                       = np.transpose(np.array(([0,0,1],[1,2,2])))
        
        if ifreq == 0:
            all_scores                                  = np.zeros((len(test_list),len(freq_list),np.shape(alldata)[2]))
        
        for xi in range(len(test_done)):
                    
            find_both                                   = np.where((allevents == test_done[xi,0]) | (allevents == test_done[xi,1]))
            
            x                                           = np.squeeze(alldata[find_both,:,:])
            y                                           = np.squeeze(allevents[find_both])
            
            # make sure codes are ones and zeroes
            y[np.where(y == np.min(y))]                 = 0
            y[np.where(y == np.max(y))]                 = 1
            
            clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
            scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            all_scores[xi,ifreq,:]                      = scores
            
            print('done with test ' + str(xi+1) + ' out of ' + str(len(test_done)) + ' for sub' + str(suj)+' '+ str(freq_list[ifreq]) +'Hz')
            del(scores,x,y)
        
        del(alldata,allevents)
    
    dir_out                                             = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/auc/'
    fname_out                                           = dir_out + 'data' + str(suj) + '.3stacked.dwsmple.freqbreak.auc.mat'
    scores                                              = all_scores
    
    scipy.io.savemat(fname_out, mdict={'scores': scores})
    
    del(all_scores,scores)
    