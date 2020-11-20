#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov  7 20:08:11 2019

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


suj_list                                = list(["sub001","sub037","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036"])

dcd_list                                = list(["pre.vs.retro","pre.ori.vs.spa","retro.ori.vs.spa"])

freq_list                           = np.squeeze(loadmat('P:/3015039.05/bil/tf/sub001.cueALL.mtm4decode.freqlist.mat')['freq_axis'])

for isub in range(len(suj_list)):
    
    suj                               = suj_list[isub]
    main_dir                            = 'P:/3015039.05/bil/'
    fname_check                         = main_dir+ 'tf/' +suj + '.cueALL.mtm4decode.100Hz.mat'
    
    if not os.path.exists(fname_check):
            main_dir                    = 'P:/3015039.04/bil/'
    
    suj                             = suj_list[isub]
    print('\nHandling '+ suj+'\n')
    
    dir_data_in                     = main_dir + 'tf/'
    dir_data_out                    = 'J:/temp/bil/cue_mtm_auc/'
    
    for ifreq in range(len(freq_list)):
        
        fname                           = dir_data_in + suj + '.cueALL.mtm4decode.' + str(freq_list[ifreq]) +'Hz.mat'
        eventName                       = dir_data_in + suj + '.cueALL.mtm4decode.trialinfo.mat'
        
        print('\nHandling '+ fname+'\n')
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        alldata[np.where(np.isnan(alldata))]    = 0
        time_axis                       = epochs.times
        
        # exclude incorrect trials :) 
        find_correct                    = np.where(allevents[:,15]==1)
        alldata                         = np.squeeze(alldata[find_correct,:,:])
        allevents                       = np.squeeze(allevents[find_correct,:])
        
        for ifeat in range(len(dcd_list)):
            
            x                           = alldata
            mini_sub                    = allevents
            
            if ifeat == 0:
                
                # reto vs pre
                find_trials             = np.where((mini_sub[:,0] >0))
                y                       = mini_sub[:,7]-1
                
            elif ifeat == 1:
                # pre ori - vs spa
                find_trials             = np.where((mini_sub[:,0] < 13)) # pre are coded 11 and 12 
                mini_sub                = np.squeeze(mini_sub[find_trials,6])
                y                       = mini_sub-1
                
            elif ifeat == 2:
                # ret ori - vs spa
                find_trials             = np.where((mini_sub[:,0] > 12)) # retro is coded 13
                mini_sub                = np.squeeze(mini_sub[find_trials,6])
                y                       = mini_sub-1
            
            # for the off-chance that some subject has no trials in a certain condition
            chk                         = len(np.unique(y))
            
            if chk == 2:
                
                fname_out               = dir_data_out + suj + '.decodecue.' + dcd_list[ifeat] + '.' +str(freq_list[ifreq]) +'Hz.correct.auc.mat'
                
                if not os.path.exists(fname_out):
                    x                   = np.squeeze(x[find_trials,:,:])
                    
                    # increased no. iterations cause for some reason it wasn't "congerging"
                    clf                 = make_pipeline(StandardScaler(), 
                                                            LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                    time_decod          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores              = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
                    scores              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    print('\nsaving '+fname_out)
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                    
                    # clean up
                    del(scores,x,y,time_decod,fname_out)
                
                print('\n')
            
        del(alldata,allevents)