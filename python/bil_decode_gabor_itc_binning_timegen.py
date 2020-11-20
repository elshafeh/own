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



suj_list                                        = list([ "sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024","sub025","sub026",
                                                            "sub027","sub028","sub029","sub031","sub032","sub033","sub034","sub035","sub036","sub037"])


lck_list                                        = list(['1stgab','2ndgab'])
dcd_list                                        = list(["orientation","frequency","color"])
freq_list                                       = list(["theta.minus1f","alpha.minus1f","beta.minus1f","broadband"])

for isub in range(len(suj_list)):
    
    suj                                         = suj_list[isub]
    dir_data_in                                 = 'P:/3015079.01/data/' + suj + '/preproc/'
    dir_data_out                                = 'D:/Dropbox/project_me/data/bil/decode/'
    
    # create directory
    if not os.path.exists(dir_data_out):
        os.mkdir(dir_data_out)

    for ilock in [0]:    
        for ifreq in range(len(freq_list)):
            
            ext_name                            = '.' + lck_list[ilock] + '.lock.' +freq_list[ifreq]+ '.centered'
            fname                               = dir_data_in + suj + ext_name + '.mat'
            print('\nHandling '+ fname+'\n')
            eventName                           = dir_data_in + suj + ext_name + '.trialinfo.mat'
            
            epochs                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            epochs                              = epochs.apply_baseline(baseline=(-0.2,-0.1))
            
            broad_events                        = loadmat(eventName)['index']
            
            broad_data                          = epochs.get_data() #Get all epochs as a 3D array.
            broad_data[np.where(np.isnan(broad_data))]  = 0
            time_axis                           = epochs.times
            
            fname_bin                           = 'P:/3015079.01/data/' + suj + '/tf/' + suj + '.itc.incorrect.index.mat'
            print('\nLoading '+ fname_bin+'\n')
            bin_index                           = loadmat(fname_bin)['bin_index']
            
            ## -- fix trial indices for these subjects -- ##
            if suj == "sub023":
                [f_row,f_col]                   = np.where(bin_index == 281)
                bin_index                       = np.delete(bin_index,f_row,0)
                bin_index[np.where(bin_index > 281)]    = bin_index[np.where(bin_index > 281)]-1
            
            if suj == "sub004":
                [f_row,f_col]                   = np.where(bin_index == 381)
                bin_index                       = np.delete(bin_index,f_row,0)
                [f_row,f_col]                   = np.where(bin_index == 382)
                bin_index                       = np.delete(bin_index,f_row,0)
                bin_index[np.where(bin_index > 382)]    = bin_index[np.where(bin_index > 382)]-2
            ## -- ##
        
            for ibin in [0,4]:
                
                find_bin                        = bin_index[:,ibin]-1
                alldata                         = np.squeeze(broad_data[find_bin,:,:])
                allevents                       = np.squeeze(broad_events[find_bin,:])
            
                for ifeat in [0,1]:
                    
                    x                           = alldata
                    chk_1st_or_2nd              = np.shape(np.where(allevents[:,-1] < 200))[1]
                    
                    if chk_1st_or_2nd != 0:
                        flg_gab = np.array([1,2]) # then u look for 1st gabor
                    elif chk_1st_or_2nd == 0:
                        flg_gab = np.array([3,4]) # then u look for 2nd gabor
                    
                    if ifeat == 0:
                        # orientation
                        y = allevents[:,flg_gab[ifeat]]
                        
                        y[np.where(y < 80)]     = 0
                        y[np.where(y > 80)]     = 1
                        
                    elif ifeat == 1:
                        # frequeny
                        y = allevents[:,flg_gab[ifeat]]
                        
                        y[np.where(y < 0.4)]    = 0
                        y[np.where(y > 0.4)]    = 1
                        
                    elif ifeat == 2:
                        # colour
                        y                       = allevents[:,11]
                        y[np.where(y == 1)]     = 0
                        y[np.where(y == 2)]     = 1
                        
                    
                    time_axes                   = epochs.times
                    
                    lm_time1                    = np.squeeze(np.where(time_axes == -0.2))
                    lm_time2                    = np.squeeze(np.where(time_axes == 4))
                    
                    time_axis                   = epochs.times
                    time_axis                   = np.squeeze(time_axes[lm_time1:lm_time2])
                    
                    fname_out                   = dir_data_out + suj + '.decodinggabor' + ext_name
                    fname_out                   = fname_out + '.itc.bin' + str(ibin+1) + '.' + dcd_list[ifeat] + '.all.bsl.timegen.mat'
                    
                    if not os.path.exists(fname_out):
                    
                        x                       = np.squeeze(x[:,:,lm_time1:lm_time2])                            

                       # increased no. iterations cause for some reason it wasn't "congerging"
                        clf                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs',max_iter=250))
                        time_gen                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                                    
                        time_gen.fit(X=x, y=y)
                        scores                  = time_gen.score(X=x, y=y)
                        
                        print('\nSaving '+ fname_out+ '\n')
                        savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                        
                        del(scores,x,y)                
                