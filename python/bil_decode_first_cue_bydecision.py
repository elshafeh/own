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


dcd_list                            = list(["iscorrect","ismatch"])

for isub in range(len(suj_list)):
    
    # change directory as function of os
    if os.name == 'nt':
        main_dir                    = 'P:/3015079.01/data/'
    else:
        main_dir                    = '/project/3015079.01/data/'
    
    suj                             = suj_list[isub]
    print('\nHandling '+ suj+'\n')
    
    ext_name                        = "_firstCueLock_ICAlean_finalrej"
    
    dir_data_in                     = main_dir + suj + '/preproc/'
    dir_data_out                    = main_dir + suj + '/decode/'
    
    # create directory
    if not os.path.exists(dir_data_out):
        os.mkdir(dir_data_out)
    
    fname                           = dir_data_in + suj + ext_name + '.mat'
    eventName                       = dir_data_in + suj + ext_name + '_trialinfo.mat'
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='dataPostICA_clean', trialinfo_column=0)
    epochs                          = epochs.copy().resample(100, npad='auto')

    allevents                       = loadmat(eventName)['index']
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
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
        
        fname_out                   = dir_data_out + suj + '.decodeRep.' + dcd_list[ifeat] + '.dwn100.all.auc.mat'
        
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