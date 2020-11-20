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
    
dcd_list                            = list(["button","match","correct","rt"])

for isub in range(len(suj_list)):

    # change directory as function of os
    main_dir                            = 'F:/bil/'
    suj                                 = suj_list[isub]
        
    dir_data_in                         = main_dir + 'preproc/'
    dir_data_out                        = 'I:/bil/decode/'
    
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
        
        # sub-select time window: from 2nd cue till the end
        t1                              = np.squeeze(np.where(np.round(time_axis,2) == np.round(3,2)))
        t2                              = np.squeeze(np.where(np.round(time_axis,2) == np.round(7,2)))
        alldata                         = np.squeeze(alldata[:,:,t1:t2])
        time_axis                       = np.squeeze(time_axis[t1:t2])
        
        
        for ifeat in [1,2,3]:
    
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
                
            elif ifeat ==3:
                # fast vs slow RT
                find_trials             = np.where((mini_sub[:,15] == 1))
                react_time_vct          = np.squeeze(allevents[find_trials,13])
                median_rt               = np.median(react_time_vct)
                categ_vct               = np.zeros(np.shape(react_time_vct)[0])
                categ_vct[np.where(react_time_vct > median_rt)] = 1
                y                       = categ_vct
    
            fname_out                   = dir_data_out + suj + ext_name + '.decodingresp.' + dcd_list[ifeat] + '.coef.mat'
            
            if not os.path.exists(fname_out):
                
                x                       = np.squeeze(x[find_trials,:,:])
                
                clf                     = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs',max_iter=200))) # 
                print('\nfitting model for '+fname_out)
                clf.fit(x,y)
                print('extracting coefficients for '+fname_out)        
                for name in('patterns_','filters_'):
                    coef                = get_coef(clf,name,inverse_transform=True)
                
                print('\nsaving '+fname_out)
                savemat(fname_out, mdict={'coef': coef,'time_axis':time_axis})
                
                # clean up
                del(coef,x,y,fname_out)