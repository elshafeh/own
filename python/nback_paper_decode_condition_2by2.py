# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:00:37 2020

@author: hesels
"""

import os

import mne
import numpy as np
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,Vectorizer)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                                                = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    
    suj                                                 = suj_list[isub]    
    
    for ises in [1,2]:
        
        fname                                           = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '.mat'
        ename                                           = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
        print('Handling '+ fname)
            
        epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        #downsample and baseline correct
        epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        epochs_nback                                    = epochs_nback.copy().resample(70, npad='auto')
        epochs_nback                                    = epochs_nback.apply_baseline(baseline=(-0.2,0))
        
        tmp_data                                        = epochs_nback.get_data()
        tmp_evnt                                        = loadmat(ename)['index'][:,[0,2,4]]  
        
        # !! exclude motor !! #
        trl                                             = np.squeeze(np.where(tmp_evnt[:,2] ==0))
        # sub-select time window
        t1                                              = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(-0.2,2)))
        t2                                              = np.squeeze(np.where(np.round(epochs_nback.times,2) == np.round(2,2)))
        
        tmp_data                                        = np.squeeze(tmp_data[trl,:,t1:t2])
        tmp_evnt                                        = np.squeeze(tmp_evnt[trl,:])
        
        if ises == 1:
            alldata                                     = tmp_data #Get all epochs as a 3D array
            allevents                                   = tmp_evnt
            del(tmp_data,tmp_evnt)
        else:
            alldata                                     = np.concatenate((alldata,tmp_data),axis=0)
            allevents                                   = np.concatenate((allevents,tmp_evnt),axis=0)
        
        
        time_axis                                       = np.squeeze(epochs_nback.times[t1:t2])
        
        del(fname,ename,epochs_nback,trl,t1,t2)
    
    
    # to pass 0-back (4) into comparison :)
    allevents[np.where((allevents[:,0] == 4) & (allevents[:,1]==0)),1]  = 2
    
    for nstim in [1,2,3,4]:
        
        list_stim                                       = ["first","target","all","nonrand"]
        
        if nstim ==3:
            find_stim                                   = np.where(allevents[:,1] < 10)
        elif nstim == 4:
            find_stim                                   = np.where(allevents[:,1] > 0)
        else:
            find_stim                                   = np.where(allevents[:,1] == nstim)
        
        data_stim                                       = np.squeeze(alldata[find_stim,:,:])
        evnt_stim                                       = np.squeeze(allevents[find_stim,0])
        
        test_done                                       = np.transpose(np.array(([4,4,5],[5,6,6])))    
        test_name                                       = ["0Bv1B","0Bv2B","1Bv2B"]
        
        for ntest in [0,1,2]:
            
            find_both                                   = np.where((evnt_stim == test_done[ntest,0]) | (evnt_stim == test_done[ntest,1]))
            
            dir_out                                     = 'J:/temp/nback/data/sens_level_auc/cond/'
            fscores_out                                 = dir_out + 'sub' + str(suj) + '.decoding.' +test_name[ntest]
            fscores_out                                 = fscores_out+ '.' +list_stim[nstim-1]+ '.dwn70.bsl.excl.auc.mat'
                        
            if not os.path.exists(fscores_out):
                    
                x                                       = np.squeeze(data_stim[find_both,:,:])
                x[np.where(np.isnan(x))]                = 0
                    
                y                                       = np.squeeze(evnt_stim[find_both])
                y[np.where(y == np.min(y))]             = 0
                y[np.where(y == np.max(y))]             = 1
                
                clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                print('\nsaving '+ fscores_out + '\n')
                
                del(scores,x,y)
                    
            del(find_both)
        del(find_stim,data_stim,evnt_stim)
    del(allevents,alldata)