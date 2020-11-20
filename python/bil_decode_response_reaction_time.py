#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 09:44:35 2019

@author: heshamelshafei
"""

import os
if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')
    
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')
    
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                            = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])
    
    
lck_list                            = list(['1stcue.lock.theta.centered','1stcue.lock.alpha.centered',
                                            '1stcue.lock.beta.centered','1stcue.lock.gamma.centered'])
    
for isub in range(len(suj_list)):

    # change directory as function of os
    main_dir                       = 'F:/bil/'
    suj                            = suj_list[isub]
        
    dir_data_in                    = main_dir + 'preproc/'
    dir_data_out                   = main_dir + 'decode/'

    for ilock in range(len(lck_list)):    
        
        ext_name                    = '.'+ lck_list[ilock]
    
        fname                       = dir_data_in + suj + ext_name + '.mat'
        eventName                   = dir_data_in + suj + ext_name + '.trialinfo.mat'
        
        print('\nHandling '+ fname+'\n')
        
        epochs                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)    
        allevents                   = loadmat(eventName)['index']
        
        alldata                     = epochs.get_data() #Get all epochs as a 3D array.
        alldata[np.where(np.isnan(alldata))] = 0
        time_axis                   = epochs.times
        
        ## pick correct trials
        find_correct                = np.where(allevents[:,15] == 1)
        alldata                     = np.squeeze(alldata[find_correct,:,:])
        allevents                   = np.squeeze(allevents[find_correct,:])
        
        react_time_vct              = np.squeeze(allevents[:,13])
        median_rt                   = np.median(react_time_vct)
        
        categ_vct                   = np.zeros(np.shape(react_time_vct)[0])
        
        categ_vct[np.where(react_time_vct > median_rt)] = 1
        categ_vct[np.where(react_time_vct < median_rt)] = 2
        
        find_trials                 = np.where(categ_vct > 0)
        
        x                           = np.squeeze(alldata[find_trials,:,:])
        y                           = np.squeeze(categ_vct[find_trials])

        fname_out                   = dir_data_out + suj + ext_name + '.decodingresp.rt.auc.mat'
        
        if not os.path.exists(fname_out):
            
            # increased no. iterations cause for some reason it wasn't "congerging"
            clf                     = make_pipeline(StandardScaler(), 
                                                    LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
            time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            scores                  = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
            scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            print('\nsaving '+fname_out)
            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            
            # clean up
            del(scores,x,y,time_decod,fname_out,find_trials,react_time_vct,median_rt,categ_vct)