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



suj_list                                = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])


lck_list                                = list(['1stcue.lock.broadband.centered'])
    
dcd_list                                = list(["pre.vs.retro","pre.ori.vs.spa","retro.ori.vs.spa"])


for isub in range(len(suj_list)):

    suj                                 = suj_list[isub]
    dir_data_out                        = 'D:/Dropbox/project_me/data/bil/decode/'

    for ilock in range(len(lck_list)):
        
        
        dir_data_in                     = 'P:/3015079.01/data/' + suj + '/preproc/'
        ext_name                        = '.'+ lck_list[ilock]

        fname                           = dir_data_in + suj + ext_name + '.mat'
        print('\nHandling '+ fname+'\n')
        eventName                       = dir_data_in + suj + ext_name + '.trialinfo.mat'

        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)

        allevents                       = loadmat(eventName)['index']

        alldata                         = epochs.get_data() #Get all epochs as a 3D array.
        time_axis                       = epochs.times

        ## pick correct trials?
        #find_correct                    = np.where(allevents[:,15] == 1)
        #alldata                         = np.squeeze(alldata[find_correct,:,:])
        #allevents                       = np.squeeze(allevents[find_correct,:])
        ##

        alldata[np.where(np.isnan(alldata))] = 0


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

            # for the off-chance that some subject has no trials in a certain condition
            chk                         = len(np.unique(y))

            if chk == 2:
                fname_out               = dir_data_out + suj + ext_name + '.decodingcue.' + dcd_list[ifeat] + '.all.auc.mat'

                if not os.path.exists(fname_out):
                    x                   = np.squeeze(x[find_trials,:,:])

                    # increased no. iterations cause for some reason it wasn't "congerging"
                    clf                 = make_pipeline(StandardScaler(),
                                                            LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                    time_decod          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores              = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1) # crossvalidate
                    scores              = np.mean(scores, axis=0) # Mean scores across cross-validation splits

                    print('\nsaving '+fname_out)
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})

                    # clean up
                    del(scores,x,y,time_decod,fname_out)

                print('\n')
