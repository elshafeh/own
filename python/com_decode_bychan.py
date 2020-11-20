#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 26 15:48:49 2019

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 14 13:46:38 2019

@author: heshamelshafei
"""

import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator
import os

suj_list                                                = [8,9,10,11,12,13,14,15,16,17] # 1,2,3,4,
data_list                                               = list(['eeg','meg'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                             = 'yc'+ str(suj_list[isub])
        
        if idata == 0:
            
            fname                                       = '/Volumes/heshamshung/alpha_compare/preproc_data/' + suj + '.CnD.' + data_list[idata] + '.sngl.dwn100.mat'
            print('Handling '+ fname)
            
            epochs                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            alldata                                     = epochs.get_data() #Get all epochs as a 3D array.
            allevents                                   = epochs.events[:,-1]
        
        elif idata == 1:
            
            for nprt in range(1,4):
                
                fname                                   = '/Volumes/heshamshung/alpha_compare/preproc_data/' + suj + '.pt'+ str(nprt) +'.CnD.' + data_list[idata] + '.sngl.dwn100.mat'
                print('Handling '+ fname)
                
                epochs                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
                tmp_data                                = epochs.get_data() #Get all epochs as a 3D array.
                tmp_evnt                                = epochs.events[:,-1]
                
                if nprt == 1:
                    alldata                             = tmp_data
                    allevents                           = tmp_evnt
                    
                    del(tmp_data,tmp_evnt)
                    
                elif nprt > 1:
                    alldata                             = np.concatenate((alldata,tmp_data),axis=0)
                    allevents                           = np.concatenate((allevents,tmp_evnt),axis=0)
                    
        
        lm1                                             = np.squeeze(np.array(np.where(epochs.times == -0.1)))
        lm2                                             = np.squeeze(np.array(np.where(epochs.times == 2)))
        
        alldata                                         = alldata[:,:,lm1:lm2]
        allcodes                                        = allevents - 1000
        
        #find_trials                                     = np.where(allcodes > 0) # all trials
        find_trials                                     = np.where(allcodes > 100) # inf trials
        
        alldata                                         = np.squeeze(alldata[find_trials,:,:])
        allcodes                                        = np.squeeze(allcodes[find_trials])
        
        allcues                                         = np.floor(allcodes/100)
        
        allinf                                          = allcues
        
        if np.shape(np.unique(allinf))[0] > 2:
            allinf[np.where(allinf > 0)]                = 1
        
        allstim                                         = allcodes - allcues*100
        
        allsides                                        = np.mod(allstim,2)
        
        allpitch                                        = allstim
        allpitch[np.where(allpitch < 3)]                = 0
        allpitch[np.where(allpitch > 2)]                = 1
        
        number_chan                                     = np.shape(alldata)[1]
        number_trial                                    = np.shape(alldata)[0]
        number_sample                                   = np.shape(alldata)[2]
        scores                                          = np.zeros((number_chan,number_sample))
    
        for nchan in range(number_chan):
            
            print('\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for ' + suj + '-' + data_list[idata])
            
            x                                           = np.zeros((number_trial,1,number_sample))
            x[:,0,:]                                    = alldata[:,nchan,:]  
            
            y                                           = np.squeeze(allinf)
            decode_ext_name                             = 'LRinf'
        
            clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            tmp_scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
            scores[nchan,:]                             = np.mean(tmp_scores, axis=0) # Mean scores across cross-validation splits
            
            del x
    
        fname_out   =  '/Volumes/heshamshung/alpha_compare/decode/' + suj + '.' + data_list[idata] + '.' + decode_ext_name + '.auc.topo.mat'
        scipy.io.savemat(fname_out, mdict={'scores': scores})
        print('\nsaving '+ fname_out + '\n')
        
        del scores