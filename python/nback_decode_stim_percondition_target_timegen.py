# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:00:37 2020

@author: hesels
"""


import os
os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import fnmatch
import warnings
import numpy as np
from scipy.io import (savemat,loadmat)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression


suj_list                                                        = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    for ises in [1,2]:
        
        suj                                                     = suj_list[isub]
        
        fname                                                   = '/project/3015039.05/nback/nback_' +str(ises) + '/data_sess' + str(ises) + '_s' +str(suj)+ '.mat'  
        ename                                                   = '/project/3015039.05/nback/nback_' +str(ises) + '/data_sess' + str(ises) + '_s' +str(suj)+ '_trialinfo.mat'
        print('Handling '+ fname)
            
        epochs_nback                                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        # down-sample
        epochs_nback                                            = epochs_nback.copy().resample(70, npad='auto')
        alldata                                                 = epochs_nback.get_data() #Get all epochs as a 3D array.
        
        allevents                                               = loadmat(ename)['index'][:,[0,2,4]]        
        allevents[:,0]                                          = allevents[:,0]-4
        
        time_axis                                               = epochs_nback.times
        
        # sub-select time window
        t1                                                      = np.squeeze(np.where(time_axis == -0.5))
        t2                                                      = np.squeeze(np.where(time_axis == 2))
        
        trl                                                     = np.squeeze(np.where(allevents[:,2] ==0))
            
        allevents                                               = np.squeeze(allevents[trl,:])
        alldata                                                 = np.squeeze(alldata[trl,:,t1:t2])        
        time_axis                                               = np.squeeze(time_axis[t1:t2])
        
        for nback in [0,1,2]:
            
            find_nback                                          = np.where(allevents[:,0] == nback)
            
            if np.size(find_nback)>0:
            
                data_nback                                      = np.squeeze(alldata[find_nback,:,:])
                evnt_nback                                      = np.squeeze(allevents[find_nback,1])
                
                list_stim                                       = list(['first','target'])
                
                for nstim in [1,2]:
                
                    dir_out                                         = '/project/3015039.05/nback/timegen_per_target/'
                    fname_out                                       = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.' + str(nback) + 'back.dwn70.excl.'+list_stim[nstim-1]+'.auc.timegen.mat'
                    
                    if not os.path.exists(fname_out):
                        
                        if nback == 0:
                            find_stim                               = np.where((evnt_nback == 1)) # find target stimulus
                        else:
                            find_stim                               = np.where((evnt_nback == nstim))
                            
                        if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                        
                            x                                       = data_nback
                            y                                       = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                            = 1
                            y                                       = np.squeeze(y)
                            
                            clf                                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                            time_gen                                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                            
                            time_gen.fit(X=x, y=y)
                            scores                                  = time_gen.score(X=x, y=y)
                            
                            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                            
                            print('\nsaving '+ fname_out + '\n')
                            del(scores,x,y)