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

dir_data                                                = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/stack/'

suj_list                                                = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    
    suj                                                 = suj_list[isub]
    
    fname                                               = dir_data + 'data' + str(suj) + '.stack.noreplicate.60dwsmple.mat'
    eventName                                           = dir_data + 'data' + str(suj) + '.stack.noreplicate.60dwsmple.trialinfo.mat'
    
    print('Handling '+ fname)
        
    epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
    allevents                                           = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
    
    test_done                                           = np.squeeze(loadmat('/Users/heshamelshafei/Dropbox/project_me/nback/scripts/decode_stim_mtrx.mat')['test_done']) 
    
    for nback in range(3):
        
        find_nback                                      = np.where(allevents[:,3] == nback)
        data_nback                                      = np.squeeze(alldata[find_nback,:,:])
        evnt_nback                                      = np.squeeze(allevents[find_nback,0])
        
        for xi in range(1,11):
            
            dir_out                                     = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/timegen/'
            fname_out                                   = dir_out + 'sub' + str(suj) + '.stim' + str(xi) + '.' + str(nback) + 'back.decode.auc.mat'
            
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
                
                scipy.io.savemat(fname_out, mdict={'scores': scores})
                
                print('\nsaving '+ fname_out + '\n')
                del(scores,x,y)