# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 17:12:21 2020

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


freq_list                                                           = [5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]

for isub in range(len(suj_list)):
    
    suj                                                             = suj_list[isub]    
    
    for ifreq in range(len(freq_list)):
        for ises in [1,2]:
            
            fname                                                   = 'J:/nback/tf/sub' + str(suj)+'.sess'+str(ises) +'.orig.'+str(freq_list[ifreq])+'Hz.mat'
            ename                                                   = 'J:/nback/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            # !! apply baseline !! #
            time_axis                                               = np.squeeze(loadmat('J:/nback/tf/time_axis.mat')['time_axis'])
            find_t1                                                 = np.squeeze(np.where(np.round(time_axis,3) == np.round(-0.5,3)))
            find_t2                                                 = np.squeeze(np.where(np.round(time_axis,3) == np.round(0,3)))
            
            b1                                                      = epochs_nback.times[find_t1]
            b2                                                      = epochs_nback.times[find_t2]
            epochs_nback                                            = epochs_nback.apply_baseline(baseline=(b1,b2))
            
            tmp_data                                                = epochs_nback.get_data()
            tmp_evnt                                                = loadmat(ename)['index'][:,[0,2,4,7]]  
            tmp_evnt[:,-1]                                          = np.squeeze(tmp_evnt[:,-1]-(np.floor(tmp_evnt[:,-1]/10)*10)) + 1
            
            # !! exclude motor !! #
            trl                                                     = np.squeeze(np.where(tmp_evnt[:,2] ==0))
            # sub-select time window
            t1                                                      = np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))
            t2                                                      = np.squeeze(np.where(np.round(time_axis,2) == np.round(2,2)))
            
            tmp_data                                                = np.squeeze(tmp_data[trl,:,t1:t2])
            tmp_evnt                                                = np.squeeze(tmp_evnt[trl,:])
            time_axis                                               = np.squeeze(time_axis[t1:t2])
            
            alldata                                                 = tmp_data #Get all epochs as a 3D array
            allevents                                               = tmp_evnt
            
            del(tmp_data,tmp_evnt,fname,ename,epochs_nback,trl,b1,b2)
    
            for nlock in [1,2]:
                for nback in [1,2]:
                    
                    list_lock                                       = ["","first","target"]
                    find_lock                                       = np.where((allevents[:,1] == nlock)  & (allevents[:,0] == nback+4))
                    
                    data_stim                                       = np.squeeze(alldata[find_lock,:,:])
                    evnt_stim                                       = np.squeeze(allevents[find_lock,-1])
                    
                    list_stim                                       = np.unique(evnt_stim)
                
                    for nstim in range(len(list_stim)):
                        
                        find_stim                                   = np.where(evnt_stim == list_stim[nstim])
                        find_not_stim                               = np.where(evnt_stim != list_stim[nstim])
                        
                        print(str(np.shape(find_stim)[1]) + ' trials found')
                        
                        dir_out                                     = 'J:/nback/sens_level_auc/kia/'
                        fscores_out                                 = dir_out + 'sub' + str(suj)  + '.sess'+ str(ises)+'.' +str(nback) + 'back.'+ str(freq_list[ifreq]) + 'Hz.lockedon.' +list_lock[nlock]
                        fscores_out                                 = fscores_out + '.decoding.stim' + str(list_stim[nstim]) + '.agaisnt.all.bsl.excl.timegen.mat'
                                
                        if np.size(find_stim)>1:
                            if np.size(find_not_stim)>1:
                                if not os.path.exists(fscores_out):
                                        
                                    x                               = data_stim
                                    x[np.where(np.isnan(x))]        = 0
                                        
                                    y                               = np.zeros(np.shape(evnt_stim)[0])
                                    y[find_stim]                    = 1
                                    y                               = np.squeeze(y)
                                    
                                   # increased no. iterations cause for some reason it wasn't "congerging"
                                    clf                             = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs',max_iter=250))
                                    time_gen                        = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                                                
                                    time_gen.fit(X=x, y=y)
                                    scores                          = time_gen.score(X=x, y=y)
                                    
                                    print('\nsaving '+ fscores_out + '\n')
                                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                                    
                                    del(scores,x,y)
                                    
                                else:
                                    print(fscores_out + ' exists\n')