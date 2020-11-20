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
from mne.time_frequency import tfr_morlet

if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')
    
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                                     = list(['sub017','sub018','sub020','sub021','sub022','sub024',
                                                   'sub025','sub026','sub027','sub028','sub029','sub030'])
    
dcd_list                                    = list(['decodCue','decodStim','decodCorrect'])
gab_list                                    = list(["stimLock","cueLock"])

for isub in range(len(suj_list)):
    
    suj                                     = suj_list[isub]
    main_dir                                = '/project/3015039.06/hesham/eyes/preproc/'
    dir_data_out                            = '/project/3015039.06/hesham/eyes/decode/'
    
    for ngab in range(len(gab_list)):
        
        freqs                               = np.arange(30,101,2)[1:]
        check_file                          = dir_data_out + suj + '.' + gab_list[ngab] + '.decodCorrect.' + str(freqs[-1]) + 'Hz.auc.mat'
        
        if not os.path.exists(check_file):
        
            fname                           = main_dir + suj + '.' + gab_list[ngab] + '.dwn200.mat'
            eventName                       = main_dir + suj + '.' + gab_list[ngab] + '.trialinfo.mat'
            
            # load in data and trailinfo
            epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            epochs                          = epochs.crop(tmin=-2,tmax=2)
            allevents                       = loadmat(eventName)['index']
            
            # Compute TFR
            
            print('\nComputing TFRs for '+fname)
            
            n_cycles                        = freqs / 4.  # different number of cycle per frequency
            power                           = tfr_morlet(epochs, freqs=freqs, n_cycles=n_cycles,
                                                         use_fft=True,return_itc=False, average = False,
                                                         decim=3, n_jobs=1)
            #power.apply_baseline((-0.2,0),mode = 'mean')
            
            time_axis                       = power.times
            alldata                         = power.data
            
            ## pick trialswith response
            find_resp                       = np.where(allevents[:,8] != 0)
            alldata                         = np.squeeze(alldata[find_resp,:,:])
            allevents                       = np.squeeze(allevents[find_resp,:])
            
            # how trialinfo matrix is organized:    
            # 3 eyes
            # 5 cue
            # 6 stim (low/high)
            # 8 correct
            
            indx_dcd                            = np.array([5,6,8])
            
            for ifreq in range(len(freqs)):
                for ifeat in range(len(dcd_list)):
                                
                    x                           = np.squeeze(alldata[:,:,ifreq,:])
                    y                           = np.squeeze(allevents[:,indx_dcd[ifeat]])
                    
                    unique_y                    = np.unique(y)
                    y[np.where(y == unique_y[0])] = 0
                    y[np.where(y == unique_y[1])] = 1
                    
                    fname_out                   = dir_data_out + suj + '.' + gab_list[ngab]
                    fname_out                   = fname_out + '.' + dcd_list[ifeat] + '.' + str(freqs[ifreq]) + 'Hz.auc.mat'
    
                    if not os.path.exists(fname_out):
                        
                        # increased no. iterations cause for some reason it wasn't "congerging"
                        clf                     = make_pipeline(StandardScaler(), 
                                                                LinearModel(LogisticRegression(solver='lbfgs',max_iter=500))) # define model
                        time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        scores                  = cross_val_multiscore(time_decod, x, y, cv = 3, n_jobs = 1) # crossvalidate
                        scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                        
                        print('\nsaving '+fname_out)
                        savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                        
                        # clean up
                        del(scores,x,y,fname_out)
                    
            del(alldata,allevents,time_axis,epochs)
            os.remove(fname)