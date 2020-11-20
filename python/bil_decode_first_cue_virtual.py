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



suj_list                          = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

dcd_list                            = list(["pre.vs.retro","pre.ori.vs.spa","retro.ori.vs.spa"])


for isub in range(len(suj_list)):

    suj                             = suj_list[isub]
    dir_data_out                    = 'J:/bil/decode/'
    
    dir_data_in                     = 'P:/3015079.01/data/' + suj + '/preproc/'
    dir_data_out                    = 'D:/Dropbox/project_me/data/bil/virt/'
    ext_virtual                     = 'wallis'
    
    fname                           = 'I:/bil/virt/' + suj+'.virtualelectrode.' +ext_virtual +'.mat'
    eventName                       = 'P:/3015079.01/data/' + suj + '/preproc/' + suj  + '_firstCueLock_ICAlean_finalrej_trialinfo.mat'
    
    print('\nHandling '+ fname)
    print('\nHandling '+ eventName+'\n')
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    epochs                          = epochs.copy().resample(70, npad='auto')
    epochs                          = epochs.copy().crop(tmin=-0.5, tmax=6)
    # epochs                          = epochs.copy().apply_baseline(baseline=(-0.1,0))
    
    allevents                       = loadmat(eventName)['index']

    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    time_axis                       = epochs.times
    chan_label                      = epochs.ch_names

    ## pick correct trials?
    find_correct                    = np.where(allevents[:,15] == 1)
    alldata                         = np.squeeze(alldata[find_correct,:,:])
    allevents                       = np.squeeze(allevents[find_correct,:])
    ##
    
    # how trialinfo matrix is organized:
    # 0            1 2   3 4    5     6     7   8       9       10     11   12   13      14          15
    # orig-code   target probe match task cue DurTar MaskCon DurCue color nbloc repRT repButton repCorrect

    print('\n')

    for ifeat in range(len(dcd_list)):

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


        fname_out                   = dir_data_out + suj + '.' + ext_virtual + '.decodingcue.' + dcd_list[ifeat] + '.correct.auc.mat'
        
        nb_chan                     = np.shape(alldata)[1]
        nb_time                     = np.shape(alldata)[2]
        scores                      = np.zeros([nb_chan,nb_time])
        
        if not os.path.exists(fname_out):
            
#            x                   = np.squeeze(x[find_trials,:,:])
#            
##            sub_x               = x[find_trials,nchan,:]
##            sub_x               = np.transpose(sub_x,[1,0,2])
#            
#            # increased no. iterations cause for some reason it wasn't "congerging"
#            clf                 = make_pipeline(StandardScaler(),
#                                                    LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
#            time_decod          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
#            tmp                 = cross_val_multiscore(time_decod, x, y, cv = 3, n_jobs = 1) # crossvalidate
#            scores              = np.mean(tmp, axis=0) # Mean scores across cross-validation splits
#            
#            print('\nsaving '+fname_out)
#            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
#            del(scores,fname_out)
            
            for nchan in range(nb_chan):
                
                print('\nDecoding channel '+ str(nchan))
                
                sub_x               = x[find_trials,nchan,:]
                sub_x               = np.transpose(sub_x,[1,0,2])
                
                # increased no. iterations cause for some reason it wasn't "congerging"
                clf                 = make_pipeline(StandardScaler(),
                                                        LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                time_decod          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                tmp                 = cross_val_multiscore(time_decod, sub_x, y, cv = 3, n_jobs = 1) # crossvalidate
                scores[nchan,:]     = np.mean(tmp, axis=0) # Mean scores across cross-validation splits
                
                # clean up
                del(tmp,sub_x,time_decod)
                
            print('\nsaving '+fname_out)
            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            del(scores,fname_out)