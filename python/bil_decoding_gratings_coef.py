#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 23 15:22:50 2019

@author: heshamelshafei
"""

import os
if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')
    
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')
    
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

suj_list                                = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])


    
lck_list                                = list(['1stgab.lock.theta.centered','1stgab.lock.alpha.centered','1stgab.lock.beta.centered',
                                                '2ndgab.lock.theta.centered','2ndgab.lock.alpha.centered','2ndgab.lock.beta.centered'])

dcd_list                                = list(["orientation","frequency"])

for isub in range(len(suj_list)):
    
    # change directory as function of os
    main_dir                            = 'F:/bil/'
    suj                                 = suj_list[isub]
    
    ext_name                            = "_firstCueLock_ICAlean_finalrej"
    
    dir_data_in                         = main_dir + 'preproc/'
    dir_data_out                        = 'J:/temp/bil/decode/'
    
    # create directory
    if not os.path.exists(dir_data_out):
        os.mkdir(dir_data_out)

    for ilock in range(len(lck_list)):    
        
        ext_name                        = '.'+ lck_list[ilock]
    
        fname                           = dir_data_in + suj + ext_name + '.mat'
        print('\nHandling '+ fname+'\n')
        eventName                       = dir_data_in + suj + ext_name + '.trialinfo.mat'
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        allevents                       = loadmat(eventName)['index']
        
        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        time_axis                       = epochs.times
        
        ## pick correct trials?
        find_correct                    = np.where(allevents[:,15] == 1)
        alldata                         = np.squeeze(alldata[find_correct,:,:])
        allevents                       = np.squeeze(allevents[find_correct,:])
        ## 
        
        # sub-select time window:0 to second gabor
        t1                              = np.squeeze(np.where(np.round(time_axis,3) == np.round(-0.5,3)))
        t2                              = np.squeeze(np.where(np.round(time_axis,3) == np.round(1.5,3)))
        alldata                         = np.squeeze(alldata[:,:,t1:t2])
        time_axis                       = np.squeeze(time_axis[t1:t2])
        
        print('t1 at ' +str(np.squeeze(t1)))
        print('t2 at ' +str(np.squeeze(t2)))
        
        alldata[np.where(np.isnan(alldata))] = 0
    
        for ifeat in range(len(dcd_list)):
            
            x                           = alldata
            
            chk_1st_or_2nd              = np.shape(np.where(allevents[:,-1] < 200))[1]
            
            if chk_1st_or_2nd != 0:
                flg_gab = np.array([1,2]) # then u look for 1st gabor
            elif chk_1st_or_2nd == 0:
                flg_gab = np.array([3,4]) # then u look for 2nd gabor
            
            if ifeat == 0:
                # orientation
                y = allevents[:,flg_gab[ifeat]]
                #mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] < 200),1])
                #mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] > 200),3])
                #y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
                y[np.where(y < 80)]     = 0
                y[np.where(y > 80)]     = 1
                
            elif ifeat == 1:
                # frequeny
                y = allevents[:,flg_gab[ifeat]]
                #mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] < 200),2])
                #mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] > 200),4])
                #y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
                y[np.where(y < 0.4)]    = 0
                y[np.where(y > 0.4)]    = 1
                
            elif ifeat == 2:
                # colour
                y                       = allevents[:,11]
                y[np.where(y == 1)]     = 0
                y[np.where(y == 2)]     = 1
                
            
            fname_out               = dir_data_out + suj + ext_name + '.decodinggabor.' + dcd_list[ifeat] + '.correct.coef.mat'
            clf                     = make_pipeline(Vectorizer(),StandardScaler(), 
                                                    LinearModel(LogisticRegression(solver='lbfgs',max_iter=200))) # 
            
            print('\nfitting model for '+fname_out)
            clf.fit(x,y)
            print('extracting coefficients for '+fname_out)        
            for name in('patterns_','filters_'):
                coef                = get_coef(clf,name,inverse_transform=True)
            
            print('\nsaving '+fname_out)
            savemat(fname_out, mdict={'coef': coef,'time_axis':time_axis})

            # clean up
            del(coef,x,y,fname_out)
                
                