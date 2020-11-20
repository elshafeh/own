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
    for ises in [1,2]:
        
        suj                                             = suj_list[isub]   
        
        fname                                           = 'J:/nback/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '.mat'
        ename                                           = 'J:/nback/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
        
        print('Handling '+ fname)
            
        epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        epochs_nback                                    = epochs_nback.copy().resample(70, npad='auto')
        epochs_nback                                    = epochs_nback.apply_baseline(baseline=(-0.5,0))
        
        time_axis                                       = epochs_nback.times
        
        
        tmp_data                                        = epochs_nback.get_data()
        tmp_evnt                                        = loadmat(ename)['index'][:,[0,2,4]]  
        
        # !! exclude motor !! #
        trl                                             = np.squeeze(np.where(tmp_evnt[:,2] ==0))
        # sub-select time window
        t1                                              = np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))
        t2                                              = np.squeeze(np.where(np.round(time_axis,2) == np.round(1.5,2)))
        
        tmp_data                                        = np.squeeze(tmp_data[trl,:,t1:t2])
        tmp_evnt                                        = np.squeeze(tmp_evnt[trl,:])
        time_axis                                       = np.squeeze(time_axis[t1:t2])
        
        if ises == 1:
            alldata                                     = tmp_data #Get all epochs as a 3D array
            allevents                                   = tmp_evnt
            del(tmp_data,tmp_evnt)
        else:
            alldata                                     = np.concatenate((alldata,tmp_data),axis=0)
            allevents                                   = np.concatenate((allevents,tmp_evnt),axis=0)
            del(tmp_data,tmp_evnt)
        
        del(fname,ename,epochs_nback,trl)

    alldata[np.where(np.isnan(alldata))]                    = 0
    
    for nback in [1,2]:
        
        find_nback                                          = np.where(allevents[:,0] == nback+4)
        
        if np.size(find_nback)>0:
        
            data_nback                                      = np.squeeze(alldata[find_nback,:,:])
            evnt_nback                                      = np.squeeze(allevents[find_nback,1])
            
            ext_stim                                        = 'istarget'
            
            ftemplate                                       = 'J:/nback/sens_level_auc/coef/sub' + str(suj) +'.'+str(nback)+'back.'+ext_stim+'.bsl.exl.dwn70'
            fscores_out                                     = ftemplate + '.auc.mat'
            fcoef_out                                       = ftemplate + '.coef.mat'
            
            if not os.path.exists(fscores_out):
                
                if ext_stim == 'isfirst':
                    find_stim                               = np.where((evnt_nback == 1)) # find 1st-stim(1) or target(2) stimulus
                else:
                    if nback == 0:
                        find_stim                           = np.where((evnt_nback == 1)) # find other/target stimulus
                    else:
                        find_stim                           = np.where((evnt_nback == 2)) # find 1st-stim(1) or target(2) stimulus
                    
                if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                
                    x                                       = data_nback
                    y                                       = np.zeros(np.shape(evnt_nback)[0])
                    y[find_stim]                            = 1
                    y                                       = np.squeeze(y)

                    
                    clf                                     = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # 
                    print('\nfitting model for '+fcoef_out)
                    clf.fit(x,y)
                    print('extracting coefficients for '+fcoef_out)        
                    for name in('patterns_','filters_'):
                        coef                                = get_coef(clf,name,inverse_transform=True)
                    
                    savemat(fcoef_out, mdict={'scores': coef,'time_axis':time_axis})
                    
                    del(coef,x,y)