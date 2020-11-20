#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  6 23:48:48 2019

@author: heshamelshafei
"""
import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator

dir_data                            = '/Volumes/heshamshung/bil_decode_data/'

suj_list                            = list([1,3,4,8,9,10,11,12,13,14])

dcd_list                            = list(["pre_retro","pre_task","retro_task"])



#flt_list                            = list(['1t2Hz','3t4Hz','5t6Hz','7t8Hz','9t10Hz',
#                                            '11t12Hz','13t14Hz','15t16Hz','17t18Hz','19t20Hz',
#                                            '21t22Hz','23t24Hz','25t26Hz','27t28Hz','29t30Hz',
#                                            '31t32Hz','33t34Hz','35t36Hz','37t38Hz','39t40Hz'])


flt_list                            = list(['41t42Hz','43t44Hz','45t46Hz','47t48Hz'])


for isub in range(len(suj_list)):
    for ifilt in range(len(flt_list)):
        
        if suj_list[isub] < 10:
            suj                         = 'sub00' + str(suj_list[isub])
        elif suj_list[isub] >= 10:
            suj                         = 'sub0' + str(suj_list[isub])


        ext_name                        = "_firstcueLock_dwnsample100Hz"
        fname                           = dir_data  + suj + ext_name + '_' + flt_list[ifilt] +'.mat'
        eventName                       = '/Users/heshamelshafei/Dropbox/project_me/bil/meg/data/' + suj + '/preproc/' + suj + ext_name + '_trialinfo.mat'
        
        
        print('\nHandling '+ fname+'\n')
        
        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        allevents                       = loadmat(eventName)['index']

        alldata                         = epochs.get_data() #Get all epochs as a 3D array.

        ## pick correct trials
        find_correct                    = np.where(allevents[:,1] == 1)
        alldata                         = np.squeeze(alldata[find_correct,:,:])
        allevents                       = np.squeeze(allevents[find_correct,:])
        ##

        print('\n')

        for ifeat in range(len(dcd_list)):

            x                           = alldata
            mini_sub                    = allevents

            if ifeat == 0:

                # reto vs pre
                find_trials             = np.where((mini_sub[:,0] >0))

                y                       = np.zeros((len(mini_sub)))
                y[np.where((mini_sub[:,0] > 20) )]                          = 1

            elif ifeat == 1:
                # pre ori - vs spa
                find_trials             = np.where((mini_sub[:,0] < 20))
                mini_sub                = np.squeeze(mini_sub[find_trials,0])
                y                       = mini_sub - 11

            elif ifeat == 2:
                # ret ori - vs spa
                find_trials             = np.where((mini_sub[:,0] > 20))
                mini_sub                = np.squeeze(mini_sub[find_trials,0])
                y                       = mini_sub - 21

            chk                         = len(np.unique(y))

            if chk == 2:
                
                x                       = np.squeeze(x[find_trials,:,:])

                clf                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                time_decod              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')

                scores                  = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
                scores                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits

                fname_out               = '/Volumes/heshamshung/bil_py_data/' + suj + '_AUCdata_' + flt_list[ifilt] + '_' + dcd_list[ifeat] + '.mat'

                scipy.io.savemat(fname_out, mdict={'scores': scores})

                del scores

                print('\n')
