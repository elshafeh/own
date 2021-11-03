# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 10:24:43 2021

@author: hesels
"""

import os
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)



suj_list                                = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
                                           21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,38,39,40,
                                           41,42,43,44,46,47,48,49,50,51]

for nsub in range(len(suj_list)):
            
    suj                                 = suj_list[nsub]
    
    dir_dropbox                         = 'P:/3035002.01/nback/'
    dir_data_in                         = dir_dropbox + 'virt/'
    dir_data_out                        = dir_dropbox + 'virt_auc/'
    
    ext_name                            = dir_data_in + 'sub' + str(suj) + '.wallis'
    fname                               = ext_name + '.roi.mat'  
    ename                               = ext_name + '.trialinfo.mat'
    print('Handling '+ fname)
    
    epochs_nback                        = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    allchandata                         = epochs_nback.get_data() #Get all epochs as a 3D array.
    allevents                           = loadmat(ename)['index']  
    time_axis                           = epochs_nback.times
    
    n_trials,n_chs,n_times              = allchandata.shape
    ncv                                 = 4
    
    for nchan in range(n_chs):
    
        # Decode stim id
        stim_present                    = np.unique(allevents[:,2])
        X                               = allchandata[:,nchan,:]
        X                               = np.expand_dims(X, axis=1)
        
        for nstim in range(len(stim_present)):
            
            savename                    = dir_data_out + 'sub' + str(suj) +  '.virt.decoding.stim' + str(stim_present[nstim])
            savename                    = savename + '.chan' +  str(nchan+1) + '.cv' + str(ncv) + 'fold.auc.mat'
            
            find_stim                   = np.squeeze(np.where(allevents[:,2] == stim_present[nstim]))
            
            if np.size(find_stim)>ncv-1:
                if not os.path.exists(savename):
                
                    y                   = np.zeros(np.shape(allevents)[0])
                    y[find_stim]        = 1
                    
                    clf                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                    time_decod          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores              = cross_val_multiscore(time_decod, X, y=y, cv = ncv, n_jobs = 1) # crossvalidate
                    scores              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    savemat(savename, mdict={'scores': scores,'time_axis':time_axis})
                    print('\nsaving '+ savename + '\n')