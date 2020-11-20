# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:00:37 2020

@author: hesels
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 15:10:06 2019

@author: heshamelshafei
"""

import os

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


dir_data                                                            = '/project/3015039.05/nback/'

suj_list                                                            = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    for ises in [1,2]:
        
        suj                                                         = suj_list[isub]
        
        if ises ==12:
            fname                                                       = dir_data + 'nback_' +str(ises) + '/sub' +str(suj) + '.sess'+ str(ises)  + '.mat'
            ename                                                       = dir_data + 'nback_' +str(ises) + '/sub' +str(suj) + '.sess'+ str(ises)  + '.trialinfo.mat'
        else:
            fname                                                       = dir_data + 'nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '.mat'
            ename                                                       = dir_data + 'nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
        
        print('Handling '+ fname)
            
        epochs_nback                                                = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        # down-sample
        epochs_nback                                                = epochs_nback.copy().resample(70, npad='auto')
        alldata                                                     = epochs_nback.get_data() #Get all epochs as a 3D array.
        
        # baseline
        epochs_nback                                                = epochs_nback.apply_baseline(baseline=(-0.2,0))
        
        allevents                                                   = loadmat(ename)['index'][:,[0,2,4]]        
        allevents[:,0]                                              = allevents[:,0]-4
        
        # to pass 0-back into comparison :)
        allevents[np.where((allevents[:,0] == 0) & (allevents[:,1]==0)),1]  = 2
        
        # !! exclude motor !! #
        trl         = np.squeeze(np.where(allevents[:,2] ==0))
        
        # sub-select time window
        t1                                                      = np.squeeze(np.where(epochs_nback.times == -0.5))
        t2                                                      = np.squeeze(np.where(epochs_nback.times == 2))
        
        alldata     = np.squeeze(alldata[trl,:,t1:t2])
        allevents   = np.squeeze(allevents[trl,:])
        
        time_axis                                                   = np.squeeze(epochs_nback.times[t1:t2])
        
        for nstim in [3]:
        
            list_stim                                               = ["first","target","all","nonrand"]
            
            if nstim ==3:
                find_stim                                           = np.where(allevents[:,1] < 10)
            elif nstim == 4:
                find_stim                                           = np.where(allevents[:,1] > 0)
            else:
                find_stim                                           = np.where(allevents[:,1] == nstim)
                
            data_stim                                               = np.squeeze(alldata[find_stim,:,:])
            evnt_stim                                               = np.squeeze(allevents[find_stim,0])
            
            for nback in [ises-1]:
                
                find_nback                                          = np.where(evnt_stim == nback)
                
                dir_out                                             = '/project/3015079.01/nback/sens_level_auc/cond/'
                fname_out                                           = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.decoding.' + str(nback) + 'back.'
                fname_out                                           = fname_out+ 'lockedon.' +list_stim[nstim-1]+ '.dwn70.bsl.excl.auc.coef.mat'
                
                fgen_out                                            = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.decoding.' + str(nback) + 'back.'
                fgen_out                                            = fgen_out + 'lockedon.' +list_stim[nstim-1]+ '.dwn70.bsl.excl.auc.timegen.mat'
                
                if np.size(find_nback)>0 and np.size(find_stim)>1 and np.size(find_nback)<np.size(evnt_stim):
                    if not os.path.exists(fgen_out):
                        
                        x                                           = data_stim
                        x[np.where(np.isnan(x))]                    = 0
                            
                        y                                           = np.zeros(np.shape(evnt_stim)[0])
                        y[find_nback]                               = 1
                        y                                           = np.squeeze(y)
                        
                        #clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                        #time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        #scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                        #scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                        
                        clf                                         = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                    
                        print('\nfitting model for '+fname_out)
                        clf.fit(x,y)
                        print('extracting coefficients for '+fname_out)            
                        for name in('patterns_','filters_'):
                            coef                                    = get_coef(clf,name,inverse_transform=True)
                        
                        savemat(fname_out, mdict={'scores': coef,'time_axis':time_axis})
                        print('\nsaving '+ fname_out + '\n')
                        
                        
                        print('\ncalculating timegen for '+fgen_out)
                        clf                                         = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                        time_gen                                    = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                        time_gen.fit(X=x, y=y)
                        scores                                      = time_gen.score(X=x, y=y)
                        savemat(fgen_out, mdict={'scores': scores,'time_axis':time_axis})
                        print('\nsaving '+ fname_out + '\n')
                        del(coef,scores,x,y)