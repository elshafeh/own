# -*- coding: utf-8 -*-
"""
Created on Fri Jun  5 11:47:48 2020

@author: hesels
"""

import os
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator)
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

#suj_list                                                    = [1,2,3,4,5,6,7,8,9,10,
#                                                   11,12,13,14,15,16,17,18,19,20,
#                                                   21,22,23,24,25]


suj_list                                                    = [26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

freq_list                                                   = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]

for isub in range(len(suj_list)):
    
    suj                                                     = suj_list[isub]    
    
    for ifreq in range(len(freq_list)):
            
        fname                                               = 'J:/nback/tf/sub' + str(suj)+'.sess2.orig.'+str(freq_list[ifreq])+'Hz.mat'
        ename                                               = 'J:/nback/nback_2/data_sess2_s'+ str(suj)  + '_trialinfo.mat'
        print('Loading '+ fname)
        epochs_nback                                        = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        time_axis                                           = np.arange(-1.5,2.02,0.02)
        
        alldata                                             = epochs_nback.get_data()
        allevents                                           = loadmat(ename)['index'][:,[0,2,4]]  
        
        # !! exclude motor !! #
        trl                                                 = np.squeeze(np.where(allevents[:,2] ==0))
        alldata                                             = np.squeeze(alldata[trl,:,:])
        allevents                                           = np.squeeze(allevents[trl,:])
        
        # !! exclude all stim but first and target !! #
        trl                                                 = np.squeeze(np.where((allevents[:,1] ==1) | (allevents[:,1]==2)))
        alldata                                             = np.squeeze(alldata[trl,:,:])
        allevents                                           = np.squeeze(allevents[trl,:])
        
        allevents[:,0]                                      = allevents[:,0] -4
        alldata[np.where(np.isnan(alldata))]                = 0
        
        ## first decode target or first
        for nback in [1,2]:
            
            col_split                                       = 0
            col_decode                                      = 1
            
            find_stim                                       = np.squeeze(np.where(allevents[:,col_split] == nback))
            data_stim                                       = np.squeeze(alldata[find_stim,:,:])
            evnt_stim                                       = np.squeeze(allevents[find_stim,col_decode])
            
            dir_out                                         = 'J:/nback/kia/'
            fscores_out                                     = dir_out + 'sub' + str(suj) + '.kiadecoding.firstortarget'
            fscores_out                                     = fscores_out+ '.'+ str(freq_list[ifreq]) + 'Hz.lockedon.' +str(nback)+ 'back.nobsl.excl.auc.mat'
                            
            if not os.path.exists(fscores_out):
                
                x                                           = data_stim
                y                                           = evnt_stim
                
                clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 4, n_jobs = 1) # crossvalidate
                scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                print('\nsaving '+ fscores_out + '\n')
                del(x,y,clf,time_decod,scores)
                
            del(find_stim,data_stim,evnt_stim)
            
        ## Then decode 0 or 1 back
        for nstim in [1,2]:
            
            col_split                                       = 1
            col_decode                                      = 0
            
            list_stim                                       =["","first","target"]
            
            find_stim                                       = np.squeeze(np.where(allevents[:,col_split] == nstim))
            data_stim                                       = np.squeeze(alldata[find_stim,:,:])
            evnt_stim                                       = np.squeeze(allevents[find_stim,col_decode])
            
            dir_out                                         = 'J:/nback/kia/'
            fscores_out                                     = dir_out + 'sub' + str(suj) + '.kiadecoding.1backor2back'
            fscores_out                                     = fscores_out+ '.'+ str(freq_list[ifreq]) + 'Hz.lockedon.' +list_stim[nstim]+ '.nobsl.excl.auc.mat'
                            
            if not os.path.exists(fscores_out):
                
                x                                           = data_stim
                y                                           = evnt_stim
                
                clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 4, n_jobs = 1) # crossvalidate
                scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                print('\nsaving '+ fscores_out + '\n')
                del(x,y,clf,time_decod,scores)
                
            del(find_stim,data_stim,evnt_stim)