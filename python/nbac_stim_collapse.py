#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 29 13:07:01 2019

@author: hesels
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 15:10:06 2019

@author: heshamelshafei
"""
import os
#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')
import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from mne.decoding import GeneralizingEstimator
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import savemat


dir_data                                                                = '/Users/heshamelshafei/Dropbox/project_me/pjme_nback/data/prepro/no_rep/'

suj_list                                                                = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    
    suj                                                                 = suj_list[isub]
    
    fname                                                               = dir_data + 'data' + str(suj) + '.stack.noreplicate.60dwsmple.mat'
    eventName                                                           = dir_data + 'data' + str(suj) + '.stack.noreplicate.60dwsmple.trialinfo.mat'
    
    if os.path.exists(fname):
    
        epochs                                                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        alldata                                                         = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                                       = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
        
        time_axis                                                       = epochs.times
        
        print('\n Handling '+ fname+'\n')
        
        # remove mean
        print('\n demeaning')
        
        for ntrial in range(np.shape(alldata)[0]):
            for ntime in range(np.shape(alldata)[2]):
                alldata[ntrial,:,ntime]                                 = alldata[ntrial,:,ntime] - np.mean(alldata[ntrial,:,:],axis=1)
        
        print(' done')
        
        for nback in range(3):
            
            find_nback                                                  = np.where(allevents[:,3] == nback)
            data_nback                                                  = np.squeeze(alldata[find_nback,:,:])
            
            for stim_lock in range(0,3):
            
                evnt_nback                                              = np.squeeze(allevents[find_nback,stim_lock])
                
                for xi in range(1,11):
                    
                    dir_out                                             = '/Users/heshamelshafei/Dropbox/project_me/pjme_nback/data/decode_data/stim_stack/'
                    fname_out                                           = dir_out + 'sub' + str(suj) + '.stim' + str(xi) + '.' + str(nback) + 'back.'+ str(stim_lock)
                    nb_cv                                               = 2
                    
                    fname_out                                           = fname_out + 'lock.demean.' +str(nb_cv)+ 'cv.auc.collapse.mat'
                    
                    if not os.path.exists(fname_out):
                    
                        find_stim                                       = np.where((evnt_nback == xi))
                        
                        
                        
                        if np.shape(find_stim)[1] > nb_cv-1:
                        
                            x                                           = data_nback
                            
                            y                                           = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                                = 1
                            y                                           = np.squeeze(y)
                            
                            if np.shape(np.unique(y))[0] == 2:
                                
                                clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                                time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                                scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = nb_cv, n_jobs = 1) # crossvalidate
                                scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                                
                                print('\nsaving '+ fname_out + '\n')
                                scipy.io.savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                                
                                
                                del(scores,x,y)