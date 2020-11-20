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


suj_list                                = list(["sub001","sub037","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036"])


freq_list                               = np.squeeze(loadmat('P:/3015039.05/bil/tf/sub001.cueALL.mtm4decode.freqlist.mat')['freq_axis'])


dcd_list                                = list(["iscorrect","ismatch"])

for isub in range(len(suj_list)):
    
    suj                                 = suj_list[isub]
    main_dir                            = 'P:/3015039.05/bil/'
    fname_check                         = main_dir+ 'tf/' +suj + '.cueALL.mtm4decode.100Hz.mat'
    
    if not os.path.exists(fname_check):
            main_dir                    = 'P:/3015039.04/bil/'
    
    suj                                 = suj_list[isub]
    print('\nHandling '+ suj+'\n')
    
    dir_data_in                         = main_dir + 'tf/'
    dir_data_out                        = 'J:/temp/bil/resp_mtm_auc/'
    
    # create directory
    if not os.path.exists(dir_data_out):
        os.mkdir(dir_data_out)
    
    for ifreq in range(len(freq_list)):
        
        fname                           = dir_data_in + suj + '.cueALL.mtm4decode.' + str(freq_list[ifreq]) +'Hz.mat'
        eventName                       = dir_data_in + suj + '.cueALL.mtm4decode.trialinfo.mat'
        
        print('\nHandling '+ fname+'\n')
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        alldata[np.where(np.isnan(alldata))]    = 0
        time_axis                       = epochs.times
        
        # how trialinfo matrix is organized:    
        # 0            1 2   3 4    5     6     7   8       9       10     11   12   13      14          15
        # orig-code   target probe match task cue DurTar MaskCon DurCue color nbloc repRT repButton repCorrect
        
        for ifeat in range(len(dcd_list)):
            
            x                           = alldata
            mini_sub                    = allevents
            
            if ifeat == 0:
                # correct/incorrect
                find_trials             = np.where((mini_sub[:,15] <2))
                y                       = np.squeeze(mini_sub[:,15])
                
            elif ifeat == 1:
                # match/no-match
                find_trials             = np.where((mini_sub[:,15] == 1))
                y                       = np.squeeze(mini_sub[find_trials,5])
            
            fname_out                   = dir_data_out + suj + '.decRepCuelock.' + dcd_list[ifeat] + '.' +str(freq_list[ifreq]) +'Hz.auc.mat'
            
            if not os.path.exists(fname_out):
                x                       = np.squeeze(x[find_trials,:,:])
                # increased no. iterations cause for some reason it wasn't "congerging"
                clf                     = make_pipeline(StandardScaler(), 
                                                        LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                scores                  = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
                scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                print('\nsaving '+fname_out)
                savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                del(x,y,scores,mini_sub)