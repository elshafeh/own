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
from mne.decoding import (SlidingEstimator, LinearModel, cross_val_multiscore)

if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


#

suj_list                                   = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

dcd_list                                     = list(["pre.vs.retro","pre.task","retro.task"])


for isub in range(len(suj_list)):

    suj                                     = suj_list[isub]
    dir_data_in                             = 'D:/Dropbox/project_me/data/bil/mtm/in/'
    dir_data_out                            = 'D:/Dropbox/project_me/data/bil/mtm/out/'
    
    freq_list                               = np.arange(1,41)
    
    for ifreq in range(len(freq_list)):
        for ibin in [0,4]:
                        
            ext_name                        = '.cue.itcbin' + str(ibin+1) + '.mtm4decode.' + str(freq_list[ifreq]) + 'Hz'
            fname                           = dir_data_in + suj + ext_name + '.mat'
            print('\nHandling '+ fname+'\n')
            
            eventName                       = dir_data_in + suj + '.cue.itcbin' + str(ibin+1) + '.mtm4decode.trialinfo.mat'
        
            epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            epochs                          = epochs.apply_baseline(baseline=(-0.4,-0.2))
            
            allevents                       = loadmat(eventName)['index']
            alldata                         = epochs.get_data() #Get all epochs as a 3D array.
            alldata[np.where(np.isnan(alldata))]  = 0
            time_axis                       = epochs.times
            
            for ifeat in [1,2]:
        
                x                           = alldata
                mini_sub                    = allevents
        
                if ifeat == 0:
                    # reto vs pre
                    find_trials             = np.where((mini_sub[:,0] >0))
                    y                       = mini_sub[:,7]-1
        
                elif ifeat == 1:
                    # pre ori - vs spa
                    find_trials             = np.where((mini_sub[:,0] < 13)) # pre are coded 11 and 12
                    mini_sub                = np.squeeze(mini_sub[find_trials,6])
                    y                       = mini_sub-1
        
                elif ifeat == 2:
                    # ret ori - vs spa
                    find_trials             = np.where((mini_sub[:,0] > 12)) # retro is coded 13
                    mini_sub                = np.squeeze(mini_sub[find_trials,6])
                    y                       = mini_sub-1
        
                fname_out                   = dir_data_out + suj + '.decodingcue.itcbin' + str(ibin+1) + '.'+str(freq_list[ifreq]) + 'Hz.'
                fname_out                   = fname_out + dcd_list[ifeat] + '.all.bsl.auc.mat'
    
                if not os.path.exists(fname_out):
                    x                       = np.squeeze(x[find_trials,:,:])
    
                    # increased no. iterations cause for some reason it wasn't "congerging"
                    clf                     = make_pipeline(StandardScaler(),
                                                            LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                    time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores                  = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
                    scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
    
                    print('\nsaving '+fname_out)
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
    
                    # clean up
                    del(scores,x,y,time_decod,fname_out)
                    
            os.remove(fname)    
