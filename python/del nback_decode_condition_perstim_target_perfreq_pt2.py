#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 30 16:43:36 2020

@author: hesels
"""

import os

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator)

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

suj_list                                                            = [25,26,27,28,29,
                                                                       30,31,32,33,35,36,38,39,40,
                                                                       41,42,43,44,46,47,48,49,
                                                                       50,51]

isub=1;ises=1;ifreq=1;

for isub in range(len(suj_list)):
    for ises in range(1,3):
        for ifreq in range(1,31):
        
            suj                                                         = suj_list[isub]
            
            fname                                                       = '/project/3015079.01/nback/tf/sub' + str(suj)+ '.sess' +str(ises) + '.orig.' + str(ifreq)+ 'Hz.mat'  
            ename                                                       = '/project/3015079.01/nback/trialinfo/data_sess' + str(ises) + '_s' +str(suj)+ '_trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                                = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            time_axis= np.arange(-1.5,2.02,0.02)
            b1 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))]
            b2 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(0,2)))]
            
            
            # !! apply baseline !! #
            epochs_nback                                                =epochs_nback.apply_baseline(baseline=(b1,b2))
            # !! apply baseline !! #
            
            alldata                                                     = epochs_nback.get_data() #Get all epochs as a 3D array.
            
            allevents                                                   = loadmat(ename)['index'][:,[0,2]]        
            allevents[:,0]                                              = allevents[:,0]-4
            
            time_axis                                                   = epochs_nback.times
            
            for nstim in [1,2]:
                
                list_stim                                               = ["first","target"]
                
                # to pass 0-back into comparison :)
                if nstim == 2:
                    allevents[np.where(allevents[:,0] == 0),1]          = 2
                
                find_stim                                               = np.where(allevents[:,1] == nstim)
                data_stim                                               = np.squeeze(alldata[find_stim,:,:])
                evnt_stim                                               = np.squeeze(allevents[find_stim,0])
                    
                for nback in range(3):
                    
                    find_nback                                          = np.where(evnt_stim == nback)
                    
                    dir_out                                             = '/project/3015079.01/nback/auc/cond/'
                    fname_out                                           = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.decoding.' + str(nback) + 'back.'
                    fname_out                                           = fname_out+ str(ifreq)+ 'Hz.lockedon.' +list_stim[nstim-1]+ '.bsl.auc.mat'
                
                    if np.size(find_nback)>0 and np.size(find_stim)>1 and np.size(find_nback)<np.size(evnt_stim):
                        if not os.path.exists(fname_out):
                            
                            x                                       = data_stim
                            x[np.where(np.isnan(x))]                = 0
                                
                            y                                       = np.zeros(np.shape(evnt_stim)[0])
                            y[find_nback]                           = 1
                            y                                       = np.squeeze(y)
                            
                            clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                            time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                            scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                            scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                            
                            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                            print('\nsaving '+ fname_out + '\n')
                            del(scores,x,y)