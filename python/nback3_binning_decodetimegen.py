#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 19 18:36:28 2021

@author: heshamelshafei
"""

import mne
import os
import numpy as np
from mne.decoding import (GeneralizingEstimator, SlidingEstimator, cross_val_multiscore, LinearModel)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                                    = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
                                           21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,38,39,40,
                                           41,42,43,44,46,47,48,49,50,51]

band_list                                   = list(["alpha","beta"]) # ,"gamma1","gamma2","slow",list(["broadband"]) #s
list_bin                                    = list(["3binsb1","3binsb2","3binsb3"])

for nsub in range(len(suj_list)):
    for nband in range(len(band_list)):
        for nbin in range(len(list_bin)):
            
            dir_dropbox                     = 'D:/'#/Users/heshamelshafei/'
            
            dir_data_in                     = dir_dropbox + 'Dropbox/project_me/data/nback/bin_decode/preproc/'
            dir_data_out                    = dir_dropbox + 'Dropbox/project_me/data/nback/bin_decode/auc/'
            
            ext_demean                      = 'nodemean'
            ext_name                        = dir_data_in + 'sub' + str(suj_list[nsub])+ '.' + band_list[nband] + '.' + list_bin[nbin] + '.4binningdecoding' + '.' + ext_demean
            fname                           = ext_name + '.mat'  
            ename                           = ext_name + '.trialinfo.mat'
            print('Handling '+ fname)
            
            epochs_nback                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            alldata                         = epochs_nback.get_data() #Get all epochs as a 3D array.
            allevents                       = loadmat(ename)['index']  
                        
            t1                              = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(-0.2,2)))
            t2                              = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(2,2)))
            
            time_axis                       = np.squeeze(epochs_nback.times[t1:t2])
            alldata                         = np.squeeze(alldata[:,:,t1:t2])
            
            x                               = alldata
            ext_auc                         = '.auc.timegen.mat'

            # Decode stim category
            list_stim                       = list(['first','target'])
            for nstim in [1,2]:
                
                fscores_out                 = ext_name + '.decoding.' + list_stim[nstim-1] + ext_auc
                
                if not os.path.exists(fscores_out):
                    find_stim                   = np.squeeze(np.where(allevents[:,1] == nstim))
                    y                           = np.zeros(np.shape(allevents)[0])
                    y[find_stim]                = 1
                        
                    clf                         = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                    time_gen                    = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                    time_gen.fit(X=x, y=y)
                    scores                      = time_gen.score(X=x, y=y)
                    
                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                    print('\nsaving '+ fscores_out + '\n')
                
            # Decode stim identity
            stim_present                        = np.unique(allevents[:,2])
            
            for nstim in range(len(stim_present)):
                
                fscores_out                     = ext_name + '.decoding.stim' + str(stim_present[nstim]) +  ext_auc
                
                if not os.path.exists(fscores_out):
                    
                    find_stim                   = np.squeeze(np.where(allevents[:,2] == stim_present[nstim]))
                        
                    y                           = np.zeros(np.shape(allevents)[0])
                    y[find_stim]                = 1
                    
                    clf                         = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                    time_gen                    = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                    time_gen.fit(X=x, y=y)
                    scores                      = time_gen.score(X=x, y=y)
                    
                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                    print('\nsaving '+ fscores_out + '\n')
                
            
            
            