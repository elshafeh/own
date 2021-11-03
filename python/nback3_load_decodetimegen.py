#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 19 18:36:28 2021

@author: heshamelshafei
"""

import mne
import os
import numpy as np
import sys

from mne.decoding import (GeneralizingEstimator, SlidingEstimator, cross_val_multiscore, LinearModel)
from mne.datasets import sample

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj                                     = sys.argv[1]


dir_dropbox                             = '/project/3035002.01/nback/'

dir_data_in                             = dir_dropbox + 'preproc/'
dir_data_out                            = dir_dropbox + 'timegen/'

ext_demean                              = 'nodemean'
ext_name                                = dir_data_in + 'sub' + str(suj)+ '.broadband.' + ext_demean
fname                                   = ext_name + '.mat'  
ename                                   = ext_name + '.trialinfo.mat'
print('Handling '+ fname)

epochs_nback                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
epochs_nback                            = epochs_nback.resample(50)


alldata                                 = epochs_nback.get_data() #Get all epochs as a 3D array.
allevents                               = loadmat(ename)['index']  

t1                                      = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(-0.2,2)))
t2                                      = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(2,2)))

time_axis                               = np.squeeze(epochs_nback.times[t1:t2])
alldata                                 = np.squeeze(alldata[:,:,t1:t2])

list_nback                              = list(["1back","2back"])
list_stim                               = list(["first","target","all"])

for nback in range(len(list_nback)):
    for nstim in range(len(list_stim)):
    
        if nstim == 0:
            index                        = np.where((allevents[:,0] == nback+5) & (allevents[:,1] == 1))
        elif nstim == 1:
            index                        = np.where((allevents[:,0] == nback+5) & (allevents[:,1] == 2))
        else:
            index                        = np.where(allevents[:,0] == nback+5)
            
        print('\n' 'sub' + str(suj)+ ' ' + list_nback[nback] + ' ' + list_stim[nstim])
        print('found '+ str(np.size(index)) + ' trials \n')
        
        x                               = np.squeeze(alldata[index,:,:])
        sub_events                      = np.squeeze(allevents[index,:])
        
        ext_auc                         = '.' + ext_demean + '.auc.timegen.mat'
        ext_name                        = dir_dropbox + 'timegen/' + 'sub' + str(suj)+ '.' + list_nback[nback] + '.' + list_stim[nstim]
       
        # Decode stim identity
        stim_present                    = np.unique(sub_events[:,2])
        
        for nstim in range(len(stim_present)):
            
            fscores_out                 = ext_name + '.decoding.stim' + str(stim_present[nstim]) + ext_auc
            
            if not os.path.exists(fscores_out):
                
                find_stim               = np.squeeze(np.where(sub_events[:,2] == stim_present[nstim]))
                    
                if np.size(find_stim)>0:
                
                    y                   = np.zeros(np.shape(sub_events)[0])
                    y[find_stim]        = 1
                    
                    clf                 = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                    time_gen             = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                    time_gen.fit(X=x, y=y)
                    scores                = time_gen.score(X=x, y=y)
                    
                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                    print('\nsaving '+ fscores_out + '\n')
       
   