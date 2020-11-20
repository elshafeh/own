# -*- coding: utf-8 -*-
"""
Created on Wed Mar  4 17:14:41 2020

@author: hesels
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


freq_list                               = np.squeeze(loadmat('P:/3015039.06/bil/tf/sub001.resplock.mtm4decode.freqlist.mat')['freq_axis'])


dcd_list                                = list(["button","match","correct"])


for isub in range(len(suj_list)):
    
    suj                                 = suj_list[isub]
    main_dir                            = 'P:/3015039.06/bil/'
    
    suj                                 = suj_list[isub]
    print('\nHandling '+ suj+'\n')
    
    dir_data_in                         = main_dir + 'tf/'
    dir_data_out                        = 'J:/temp/bil/resplock_mtm_auc/'
    
    # create directory
    if not os.path.exists(dir_data_out):
        os.mkdir(dir_data_out)
    
    for ifreq in range(len(freq_list)):
        
        fname                           = dir_data_in + suj + '.resplock.mtm4decode.' + str(freq_list[ifreq]) +'Hz.mat'
        eventName                       = dir_data_in + suj + '.resplock.mtm4decode.trialinfo.mat'
        
        print('\nHandling '+ fname+'\n')
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        alldata[np.where(np.isnan(alldata))]    = 0
        time_axis                       = epochs.times
        
        for ifeat in range(len(dcd_list)):

            x                           = alldata
            mini_sub                    = allevents
    
            if ifeat == 0:
                # button 1 vs button 2
                find_trials             = np.where((mini_sub[:,19] > 0))
                y                       = np.zeros((len(mini_sub)))
                y[np.where((mini_sub[:,19] == 1) )]                          = 1
    
            elif ifeat == 1:
                # match vs no-match [for correct]
                find_trials             = np.where((mini_sub[:,15] == 1))
                y                       = np.squeeze(mini_sub[find_trials,5])
    
            elif ifeat == 2:
                # correct vs incorrect
                find_trials             = np.where((mini_sub[:,19] > 0))
                y                       = mini_sub[:,15]
    
            fname_out                   = dir_data_out + suj + '.resplock.decode.' + dcd_list[ifeat] + '.'+str(freq_list[ifreq]) +'Hz.auc.mat'
            
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
                
                # clean up
                del(scores,x,y,time_decod,fname_out)