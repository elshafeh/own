#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 13 10:32:16 2020

@author: heshamelshafei
"""

import os

#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

suj_list                                            = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

stim_list                                           = [1,2,3,4,5,6,7,8,9,10]

for isub in range(len(suj_list)):
    for ises in [1,2]:
        
        suj                                             = suj_list[isub]
        fname                                           = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '.mat'
        ename                                           = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
        print('Handling '+ fname)
        
        
        epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        epochs_nback                                    = epochs_nback.copy().resample(70, npad='auto')
        epochs_nback                                    = epochs_nback.apply_baseline(baseline=(-0.2,0))
        
        alldata                                         = epochs_nback.get_data() #Get all epochs as a 3D array.
        allevents                                       = loadmat(ename)['index'][:,1]
        allevents                                       = np.squeeze(allevents-(np.floor(allevents/10)*10)) + 1
        
        # sub-select time window
        t1                                              = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(-0.2,2)))
        t2                                              = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(1,2)))
        alldata                                         = np.squeeze(alldata[:,:,t1:t2])
        
        time_axis                                       = np.squeeze(epochs_nback.times[t1:t2])
        
        for xi in range(len(stim_list)):
            
            fscores_out                                 = 'J:/temp/nback/data/stim_ag_all/sub' + str(suj) + '.sess'+str(ises)+'.stim' + str(stim_list[xi])  + '.against.all.bsl.dwn70.auc.mat'
            fcoef_out                                   = 'J:/temp/nback/data/stim_ag_all/sub' + str(suj) + '.sess'+str(ises)+'.stim' + str(stim_list[xi])  + '.against.all.bsl.dwn70.coef.mat'
            
            find_stim                                   = np.squeeze(np.where(allevents == stim_list[xi]))  
            
            if np.size(find_stim)>1:
                if not os.path.exists(fscores_out):
                      
                    x                                   = alldata
                    
                    # make sure codes are ones and zeroes
                    y                                   = np.zeros(np.size(np.squeeze(allevents)))
                    y[find_stim]                        = 1
                    
                    clf                                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                    time_decod                          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores                              = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                    scores                              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                    
                    del(scores)
                    
                    clf                                 = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # 
                    print('\nfitting model for '+fcoef_out)
                    clf.fit(x,y)
                    print('extracting coefficients for '+fcoef_out)        
                    for name in('patterns_','filters_'):
                        coef                            = get_coef(clf,name,inverse_transform=True)
                    
                    savemat(fcoef_out, mdict={'scores': coef,'time_axis':time_axis})
                    
                    del(coef,x,y)