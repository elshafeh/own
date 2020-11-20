#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 23 15:22:50 2019

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

suj_list                                = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])


    
lck_list                                = list(['2ndgab.lock.beta.centered'])

dcd_list                                = list(["orientation","frequency","color"])

for isub in range(len(suj_list)):
    
    # change directory as function of os
    main_dir                            = 'F:/bil/'
    suj                                 = suj_list[isub]
        
    dir_data_in                         = main_dir + 'preproc/'
    dir_data_out                        = 'D:/Dropbox/project_me/data/bil/decode/'
    
    # create directory
    if not os.path.exists(dir_data_out):
        os.mkdir(dir_data_out)

    for ilock in range(len(lck_list)):    
        
        ext_name                        = '.'+ lck_list[ilock]
    
        fname                           = dir_data_in + suj + ext_name + '.mat'
        print('\nHandling '+ fname+'\n')
        eventName                       = dir_data_in + suj + ext_name + '.trialinfo.mat'
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        #epochs                          = epochs.apply_baseline(baseline=(-0.4,-0.2))
        #epochs                          = epochs.copy().resample(100, npad='auto')
        
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        time_axis                       = epochs.times
        
        ## pick correct trials?
        find_correct                    = np.where(allevents[:,15] == 1)
        alldata                         = np.squeeze(alldata[find_correct,:,:])
        allevents                       = np.squeeze(allevents[find_correct,:])
        ## 
        
        alldata[np.where(np.isnan(alldata))] = 0
        
        vctr                             =  np.arange(0,np.shape(allevents)[0])
        np.random.shuffle(vctr)
        
        list_perc                           = np.arange(0.1,1.1,0.1)
        
        for iper in range(len(list_perc)):
            
            lm1                             = 0
            lm2                             = np.int(np.round(list_perc[iper] * np.shape(allevents)[0]))
        
            for ifeat in [0,1]:
                
                x                           = np.squeeze(alldata[vctr[lm1:lm2],:,:])
                mini_sub                    = np.squeeze(allevents[vctr[lm1:lm2],:])
                
                chk_1st_or_2nd              = np.shape(np.where(mini_sub[:,-1] < 200))[1]
                
                if chk_1st_or_2nd != 0:
                    flg_gab = np.array([1,2]) # then u look for 1st gabor
                elif chk_1st_or_2nd == 0:
                    flg_gab = np.array([3,4]) # then u look for 2nd gabor
                
                if ifeat == 0:
                    # orientation
                    y = mini_sub[:,flg_gab[ifeat]]
                    y[np.where(y < 80)]     = 0
                    y[np.where(y > 80)]     = 1
                    
                elif ifeat == 1:
                    # frequeny
                    y = mini_sub[:,flg_gab[ifeat]]
                    y[np.where(y < 0.4)]    = 0
                    y[np.where(y > 0.4)]    = 1
                    
                elif ifeat == 2:
                    # colour
                    y                       = mini_sub[:,11]
                    y[np.where(y == 1)]     = 0
                    y[np.where(y == 2)]     = 1
                    
                
                time_axes               = epochs.times
                
                lm_time1                = np.squeeze(np.where(time_axes == -0.2))
                lm_time2                = np.squeeze(np.where(time_axes == 1))
                
                time_axis               = epochs.times
                time_axis               = np.squeeze(time_axes[lm_time1:lm_time2])
                                    
                fname_out               = dir_data_out + suj + ext_name + '.decodinggabor.' + dcd_list[ifeat] + '.correct.'
                fname_out               = fname_out + str(np.int(list_perc[iper]*100)) + 'perc.auc.mat'
                
                if not os.path.exists(fname_out):                
                    x                       = np.squeeze(x[:,:,lm_time1:lm_time2])
                    
                    # increased no. iterations cause for some reason it wasn't "congerging"
                    clf                     = make_pipeline(StandardScaler(), 
                                                            LinearModel(LogisticRegression(solver='lbfgs',max_iter=300))) # define model
                    time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores                  = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
                    scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    print('\nsaving '+fname_out)
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                    
                    del(scores,x,y)                
                