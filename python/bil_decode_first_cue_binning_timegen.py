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
#                                            "sub025","sub026",

suj_list                                        = list(["sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])


dcd_list                                        = list(["pre.vs.retro","pre.task","retro.task"])


for isub in range(len(suj_list)):

    suj                                         = suj_list[isub]
    dir_data_out                                = 'D:/Dropbox/project_me/data/bil/decode/'
    
    freq_list                                   = list(["theta","alpha","beta","gamma"])
    wind_list                                   = list(["preCue1","preCue2"])
    
    dir_data_in                                 = 'P:/3015079.01/data/' + suj + '/preproc/'
    ext_name                                    = '.1stcue.lock.broadband.centered'

    fname                                       = dir_data_in + suj + ext_name + '.mat'
    print('\nHandling '+ fname+'\n')
    eventName                                   = dir_data_in + suj + ext_name + '.trialinfo.mat'

    epochs                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    epochs                                      = epochs.apply_baseline(baseline=(-0.2,-0.1))
    
    broad_events                                = loadmat(eventName)['index']
    broad_data                                  = epochs.get_data() #Get all epochs as a 3D array.
    
    t1                                          = np.squeeze(np.where(np.round(epochs.times,2) == 0))
    t2                                          = np.squeeze(np.where(np.round(epochs.times,2) == 5.5))
    broad_data                                  = np.squeeze(broad_data[:,:,t1:t2])
    
    broad_data[np.where(np.isnan(broad_data))]  = 0
    time_axis                                   = epochs.times
    
    for ifreq in range(len(freq_list)):
        for iwind in range(len(wind_list)):
            
            fname_bin                           = 'P:/3015079.01/data/' + suj + '/tf/' + suj + '.allbandbinning.' + freq_list[ifreq] + '.band.'+ wind_list[iwind] + '.window.index.mat'
            print('\nLoading '+ fname_bin+'\n')
            bin_index                           = loadmat(fname_bin)['bin_index']
            
            for ibin in [0,4]: #range(5):
                
                find_bin                        = bin_index[:,ibin]-1
                alldata                         = np.squeeze(broad_data[find_bin,:,:])
                allevents                       = np.squeeze(broad_events[find_bin,:])
                
                del(find_bin)
            
                for ifeat in [1,2]:
            
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
            
            
                    fname_out                   = dir_data_out + suj + '.cuebroad.decodingcue.' +freq_list[ifreq] + '.band.'
                    fname_out                   = fname_out +wind_list[iwind] + '.window.bin' + str(ibin+1) + '.' + dcd_list[ifeat] + '.all.bsl.timegen.mat'
        
                    if not os.path.exists(fname_out):
                        
                        x                       = np.squeeze(x[find_trials,:,:])
        
                       # increased no. iterations cause for some reason it wasn't "congerging"
                        clf                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs',max_iter=250))
                        time_gen                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                                    
                        time_gen.fit(X=x, y=y)
                        scores                  = time_gen.score(X=x, y=y)
                        
                        print('\nsaving '+fname_out)
                        savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
        
                        # clean up
                        del(scores,x,y,fname_out)
