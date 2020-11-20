#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 09:44:35 2019

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


suj_list                                    = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])


cue_list                                    = list(["cue.pre.ori" ,"cue.pre.ori" ,
                                            "cue.pre.freq","cue.pre.freq",
                                            "cue.retro.ori" ,"cue.retro.ori", 
                                            "cue.retro.freq","cue.retro.freq"])

feat_list                                   = list(["ori" ,"freq" ,
                                            "ori","freq",
                                            "ori" ,"freq", 
                                            "ori","freq"])
    
gab_list                                    = list(["1stgab","2ndgab"])

freq_list                                   = list(["broadband","theta.minus1f","alpha.minus1f","beta.minus1f","gamma.minus1f"])


for isub in range(len(suj_list)):
    for ifreq in range(len(freq_list)):
        
        # change directory as function of os
        main_dir                            = 'F:/bil/'
        suj                                 = suj_list[isub]
        
        ext_name                            = '.1stgab.lock.' + freq_list[ifreq] + '.centered'
        
        dir_data_in                         = 'P:/3015079.01/data/' + suj + '/preproc/'
        dir_data_out                        = 'D:/Dropbox/project_me/data/bil/decode/'
        
        fname                               = dir_data_in + suj + ext_name + '.mat'
        eventName                           = dir_data_in + suj + ext_name + '.trialinfo.mat'
        
        epochs                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        epochs                              = epochs.apply_baseline(baseline=(-0.4,-0.2))
        
        alldata                             = epochs.get_data() #Get all epochs as a 3D array.
        allevents                           = loadmat(eventName)['index']
    
        time_axis                           = epochs.times
        
        ## pick correct trials
        find_correct                        = np.where(allevents[:,15] == 1)
        alldata                             = np.squeeze(alldata[find_correct,:,:])
        allevents                           = np.squeeze(allevents[find_correct,:])
        alldata[np.where(np.isnan(alldata))] = 0
        
        for ngab in [0]: 
            
            #range(len(gab_list)):
            # how trialinfo matrix is organized:    
            # 0            1 2    3 4       5     6     7   8       9       10     11   12   13      14          15
            # orig-code   1st-gab 2nd-gab   match task cue DurTar MaskCon DurCue color nbloc repRT repButton repCorrect
            
            print('\n')
            
            indx_task                       = np.array([1,1,2,2,1,1,2,2])
            indx_cue                        = np.array([1,1,1,1,2,2,2,2])
            indx_feat                       = np.array([1,2,1,2,1,2,1,2])
            
            for ifeat in range(len(cue_list)):
                
                filter_cue                  = indx_cue[ifeat]
                filter_task                 = indx_task[ifeat]
                filter_gabor                = indx_feat[ifeat]
                
                # choose trials according to cue
                filter_trials               = np.where((allevents[:,6]==filter_task) & (allevents[:,7]==filter_cue))
                
                print(str(np.shape(filter_trials)[1]) + ' trials found')
                
                x                           = np.squeeze(alldata[filter_trials,:,:])
                mini_sub                    = np.squeeze(allevents[filter_trials])
                
                fname_out                   = dir_data_out + suj + ext_name + '.' + cue_list[ifeat] 
                fname_out                   = fname_out + '.decoding.' + gab_list[ngab] + '.' + feat_list[ifeat] + '.correct.ninjauc.bsl.mat'
                
                del(filter_trials)
                
                if filter_gabor == 1:
                    # orientation
                    list_index              = np.array([1,3])
                    
                    y                       = mini_sub[:,list_index[ngab]]
                    y[np.where(y < 90)]     = 0
                    y[np.where(y > 90)]     = 1
                    
                elif filter_gabor == 2:
                    # freqeuncy
                    list_index              = np.array([2,4])
                    
                    y                       = mini_sub[:,list_index[ngab]]
                    y[np.where(y < 0.4)]    = 0
                    y[np.where(y > 0.4)]    = 1
                    
                elif filter_gabor == 3:
                    # colour
                    y                       = mini_sub[:,11]
                    y[np.where(y == 1)]     = 0
                    y[np.where(y == 2)]     = 1
                
                if not os.path.exists(fname_out):
                    
                    # increased no. iterations cause for some reason it wasn't "congerging"
                    clf                     = make_pipeline(StandardScaler(), 
                                                            LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                    time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores                  = cross_val_multiscore(time_decod, x, y, cv = 3, n_jobs = 1) # crossvalidate
                    scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    print('\nsaving '+fname_out)
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                    
                    # clean up
                    del(scores,x,y,time_decod,fname_out)
                    
                    print('\n')