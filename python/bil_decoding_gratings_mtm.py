# -*- coding: utf-8 -*-
"""
Created on Sun Mar  1 16:23:03 2020

@author: hesels
"""

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

suj_list                                = list(["sub001","sub037","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036"])

dcd_list                                = list(["orientation","frequency","color"])

freq_list                               = np.squeeze(loadmat('P:/3015039.05/bil/tf/sub001.gratingCorrect.mtm4decode.freqlist.mat')['freq_axis'])

for isub in range(len(suj_list)):
    
    suj                                 = suj_list[isub]
    main_dir                            = 'P:/3015039.05/bil/'
    fname_check                         = main_dir+ 'tf/' +suj + '.gratingCorrect.mtm4decode.100Hz.mat'
    
    if not os.path.exists(fname_check):
            main_dir                    = 'P:/3015039.04/bil/'
    
    for ifreq in range(len(freq_list)):
        
        
        dir_data_in                     = main_dir + 'tf/'
        dir_data_out                    = 'J:/temp/bil/grating_mtm_auc/'
        
        fname                           = dir_data_in + suj + '.gratingCorrect.mtm4decode.' + str(freq_list[ifreq]) +'Hz.mat'
        eventName                       = dir_data_in + suj + '.gratingCorrect.mtm4decode.trialinfo.mat'
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        alldata[np.where(np.isnan(alldata))]    = 0
        time_axis                       = epochs.times
        
        print('\n')
        
        for ifeat in range(len(dcd_list)):
            
            x                           = alldata
            
            if ifeat == 0:
                # orientation
                mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] < 200),1])
                mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] > 200),3])
                y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
                y[np.where(y < 80)]     = 0
                y[np.where(y > 80)]     = 1
                
            elif ifeat == 1:
                # frequeny
                mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] < 200),2])
                mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] > 200),4])
                y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
                y[np.where(y < 0.4)]    = 0
                y[np.where(y > 0.4)]    = 1
                
            elif ifeat == 2:
                # colour
                y                       = allevents[:,11]
                y[np.where(y == 1)]     = 0
                y[np.where(y == 2)]     = 1
                
            fname_out                   = dir_data_out + suj + '.decodegrating.' + dcd_list[ifeat] + '.'+str(freq_list[ifreq]) +'Hz.correct.auc.mat'
            
            if not os.path.exists(fname_out):
                
                indx                    = 15
                find_trials             = np.where(allevents[:,indx]<2) # get all trials ; correct and incorrect
                time_axes               = epochs.times
                
                print('\nHandling '+ suj+ ' ' + str(freq_list[ifreq]) +'Hz ' +dcd_list[ifeat] + '\n')
                
                x                       = np.squeeze(x[find_trials,:,:])
                y                       = np.squeeze(y[find_trials])
                
                # increased no. iterations cause for some reason it wasn't "congerging"
                clf                     = make_pipeline(StandardScaler(), 
                                                        LinearModel(LogisticRegression(solver='lbfgs',max_iter=300))) # define model
                time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                scores                  = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
                scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                
                del(scores,x,y)
                print('done \n')
                
        del(alldata,allevents)