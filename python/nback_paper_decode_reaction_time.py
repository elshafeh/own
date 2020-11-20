# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 17:12:21 2020

@author: hesels
"""

import os
#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/'
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)



suj_list                                                   = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]



for isub in range(len(suj_list)):
    
    suj                                                     = suj_list[isub]    
    
    for ises in [1,2]:
        
        fname                                               = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '.mat'
        ename                                               = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
        print('Handling '+ fname)
            
        epochs_nback                                        = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        
        # baseline and downsample
        epochs_nback                                        = epochs_nback.copy().resample(70, npad='auto')
        epochs_nback                                        = epochs_nback.apply_baseline(baseline=(-0.2,0))
        
        tmp_data                                            = epochs_nback.get_data()
        tmp_evnt                                            = loadmat(ename)['index'][:,[0,2,4]]  
        time_axis                                           = epochs_nback.times
        
        if ises == 1:
            alldata                                         = tmp_data #Get all epochs as a 3D array
            allevents                                       = tmp_evnt
            del(tmp_data,tmp_evnt)
        else:
            alldata                                         = np.concatenate((alldata,tmp_data),axis=0)
            allevents                                       = np.concatenate((allevents,tmp_evnt),axis=0)
            del(tmp_data,tmp_evnt)
        
        del(fname,ename,epochs_nback)
        
        
    t1                                                      = np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.2,2)))
    t2                                                      = np.squeeze(np.where(np.round(time_axis,2) == np.round(2,2)))
        
    alldata                                                 = np.squeeze(alldata[:,:,t1:t2])
    time_axis                                               = np.squeeze(time_axis[t1:t2])
    
    ename                                                   = 'D:/Dropbox/project_me/data/nback/rt_bins/sub' + str(suj) + '.rt.2bins.mat'
    rt_bins                                                 = loadmat(ename)['index_trials'] 
    
    for nback in [0,1,2]:
        
        dir_out                                             = 'J:/temp/nback/data/sens_level_auc/rt/'
        #fscores_out                                         = dir_out + 'sub' + str(suj) + '.decoding.rt.' + str(nback) + 'back.dwn70.bsl.auc.mat'
        fcoef_out                                           = dir_out + 'sub' + str(suj) + '.decoding.rt.' + str(nback) + 'back.dwn70.bsl.coef.mat'
                
        if not os.path.exists(fcoef_out):
        
            find_nback_rt                                   = np.squeeze(np.where(rt_bins[:,0] == nback+4))
            find_nback_data                                 = rt_bins[find_nback_rt,2]-1
            
            x                                               = np.squeeze(alldata[find_nback_data,:,:])
            y                                               = rt_bins[find_nback_rt,1]-1
            
                
#            clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
#            time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
#            scores                                          = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
#            scores                                          = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            clf                                             = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # 
            print('\nfitting model for '+fcoef_out)
            clf.fit(x,y)
            print('extracting coefficients for '+fcoef_out)        
            for name in('patterns_','filters_'):
                coef                                = get_coef(clf,name,inverse_transform=True)
            
            savemat(fcoef_out, mdict={'scores': coef,'time_axis':time_axis})
            print('\nsaving '+ fcoef_out + '\n')
        
        
    