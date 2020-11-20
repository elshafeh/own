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


#"sub001","sub003","sub004","sub006","sub008","sub009","sub010",
#                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
#                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
#                                            "sub025",

suj_list                                = list(["sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

lck_list                                = list(['1stcue.lock.broadband.centered',
                                                '1stcue.lock.theta.minus1f.centered',
                                                '1stcue.lock.alpha.minus1f.centered',
                                                '1stcue.lock.beta.minus1f.centered',
                                                '1stcue.lock.gamma.minus1f.centered'])
    
dcd_list                                = list(["button","match","correct"])

for isub in range(len(suj_list)):

    # change directory as function of os
    suj                                 = suj_list[isub]
        
    dir_data_in                         = 'P:/3015079.01/data/' + suj + '/preproc/'
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
    
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        alldata[np.where(np.isnan(alldata))] = 0
        time_axis                       = epochs.times

        for ifeat in [1,2]:
    
            x                           = alldata
            mini_sub                    = allevents
    
            if ifeat == 0:
                # button 1 vs button 2
                find_trials             = np.where((mini_sub[:,15] <2))
                y                       = np.zeros((len(mini_sub)))
                y[np.where((mini_sub[:,19] == 1) )]                          = 1
    
            elif ifeat == 1:
                # match vs no-match [for correct]
                find_trials             = np.where((mini_sub[:,15] == 1))
                y                       = np.squeeze(mini_sub[find_trials,5])
    
            elif ifeat == 2:
                # correct vs incorrect
                find_trials             = np.where((mini_sub[:,15] <2))
                y                       = mini_sub[:,15]
    
            fname_out                   = dir_data_out + suj + ext_name + '.decodingresp.' + dcd_list[ifeat] + '.auc.mat'
            
            if not os.path.exists(fname_out):
                x                       = np.squeeze(x[find_trials,:,:])
                
                # increased no. iterations cause for some reason it wasn't "congerging"
                clf                     = make_pipeline(StandardScaler(), 
                                                        LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                scores                  = cross_val_multiscore(time_decod, x, y, cv = 3, n_jobs = 1) # crossvalidate
                scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                print('\nsaving '+fname_out)
                savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                
                # clean up
                del(scores,x,y,time_decod,fname_out)