# -*- coding: utf-8 -*-
"""
Created on Fri Feb 21 15:41:26 2020

@author: hesels
"""
import os
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                                                            = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
        
        suj                                                         = suj_list[isub]
        fname                                                       = 'J:/temp/nback/data/fft/sub' + str(suj)+'.400t1400ms.fft.mat'
        ename                                                       = 'J:/temp/nback/data/fft/sub' + str(suj)+'.400t1400ms.fft.trialinfo.mat'
        
        print('Handling '+ fname)
            
        epochs_nback                                                = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        # !! apply baseline !! #
        time_axis                                                   = epochs_nback.times
        alldata                                                     = epochs_nback.get_data() #Get all epochs as a 3D array.
        
        allevents                                                   = loadmat(ename)['index'][:,[0,2,4]]        
        allevents[:,0]                                              = allevents[:,0]-4
        
        # to pass 0-back into comparison :)
        allevents[np.where((allevents[:,0] == 0) & (allevents[:,1]==0)),1]  = 2
        
        # exclude motor
        trl         = np.squeeze(np.where(allevents[:,2] ==0))
        alldata     = np.squeeze(alldata[trl,:,:])
        allevents   = np.squeeze(allevents[trl,:])
        
        alldata[np.where(np.isnan(alldata))]                    = 0
        
        for nstim in [2]:
            
            list_stim                                       = ["first","target","all","nonrand"]
            
            if nstim ==3:
                find_stim                                   = np.where(allevents[:,1] < 10)
            elif nstim == 4:
                find_stim                                   = np.where(allevents[:,1] > 0)
            else:
                find_stim                                   = np.where(allevents[:,1] == nstim)
            
            data_stim                                       = np.squeeze(alldata[find_stim,:,:])
            evnt_stim                                       = np.squeeze(allevents[find_stim,0])
            
            for nback in [0,1,2]:
                
                find_nback                                  = np.where(evnt_stim == nback)
                
                dir_out                                     = 'J:/temp/nback/data/fft/'
                fscores_out                                 = dir_out + 'sub' + str(suj) + '.decoding.' + str(nback) + 'back.'
                fscores_out                                 = fscores_out+ 'agaisnt.all.lockedon.' +list_stim[nstim-1]+ '.fft.auc.mat'
                            
                if np.size(find_nback)>0 and np.size(find_stim)>1 and np.size(find_nback)<np.size(evnt_stim):
                    if not os.path.exists(fscores_out):
                            
                        x                                   = data_stim
                        x[np.where(np.isnan(x))]            = 0
                            
                        y                                   = np.zeros(np.shape(evnt_stim)[0])
                        y[find_nback]                       = 1
                        y                                   = np.squeeze(y)
                        
                        clf                                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                        time_decod                          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        scores                              = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
                        scores                              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                        
                        savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                        print('\nsaving '+ fscores_out + '\n')
                        
                        del(scores,x,y)
        
        for nback in [0,1,2]:
            
            find_nback                                      = np.where(allevents[:,0] == nback)
                        
            data_nback                                      = np.squeeze(alldata[find_nback,:,:])
            evnt_nback                                      = np.squeeze(allevents[find_nback,1])
            
            ext_stim                                        = 'istarget'
            
            ftemplate                                       = 'J:/temp/nback/data/fft/sub' + str(suj) +'.'+str(nback)+'back.'+ext_stim+'.fft'
            fscores_out                                     = ftemplate + '.auc.mat'
            fcoef_out                                       = ftemplate + '.coef.mat'
            
            if not os.path.exists(fscores_out):
                
                if ext_stim == 'isfirst':
                    find_stim                               = np.where((evnt_nback == 1)) # find 1st-stim(1) or target(2) stimulus
                else:
                    if nback == 0:
                        find_stim                          = np.where((evnt_nback == 1)) # find other/target stimulus
                    else:
                        find_stim                           = np.where((evnt_nback == 2)) # find 1st-stim(1) or target(2) stimulus
                    
                if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                
                    x                                       = data_nback
                    y                                       = np.zeros(np.shape(evnt_nback)[0])
                    y[find_stim]                            = 1
                    y                                       = np.squeeze(y)
                    
                    clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                    time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
                    scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    print('\nsaving:'+fscores_out)
                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                    
                    del(scores)
                    
            