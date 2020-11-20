#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  5 11:09:41 2019

@author: hesels
"""

import os

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from mne.decoding import GeneralizingEstimator
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import savemat

suj_list                                                    = [1,10,11,12,13,14,15,16,17,2,3,4,8,9]
#data_list                                                   = list(['pt1.CnD.meg','pt2.CnD.meg','pt3.CnD.meg','CnD.eeg'])
data_list                                                   = list(['CnD.com90roi.meg','CnD.com90roi.eeg'])
feat_list                                                   = list(['inf.unf','left.right'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                 = 'yc'+ str(suj_list[isub])
            
        fname                                               = '/project/3015039.05/temp/meeg/data/lcmv/' + suj + '.' + data_list[idata] + '.mat'
        print('Handling '+ fname)
            
        epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                           = epochs.events[:,-1]
        
        lm1                                                 = np.squeeze(np.array(np.where(epochs.times == -0.1)))
        lm2                                                 = np.squeeze(np.array(np.where(epochs.times == 2)))
        
        alldata                                             = alldata[:,:,lm1:lm2]
        allcodes                                            = allevents - 1000
        
        time_axis                                           = epochs.times[lm1:lm2]
        
        for ifeat in range(len(feat_list)):
            
            if ifeat == 0:
                find_trials                                 = np.where(allcodes > 0) # all trials
            else:
                find_trials                                 = np.where(allcodes > 100)
            
            sub_data                                        = np.squeeze(alldata[find_trials,:,:])
            allcodes                                        = np.squeeze(allcodes[find_trials])
            
            allcues                                         = np.floor(allcodes/100)
            allinf                                          = allcues
            
            if np.shape(np.unique(allinf))[0] > 2:
                allinf[np.where(allinf > 0)]                = 1            
            
            if isub == 0:
                all_scores                                  = np.zeros((len(suj_list),len(data_list),np.shape(sub_data)[2]))
            
            x                                               = np.squeeze(sub_data)
            y                                               = np.squeeze(allinf)        
            
            clf                                             = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
            time_gen                                        = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
            time_gen.fit(X=x, y=y)
            scores                                          = time_gen.score(X=x, y=y)
            
            fname_out   =  '/project/3015039.05/temp/meeg/data/timegen/' + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.timegen.mat'
            scipy.io.savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
            print('\nsaving '+ fname_out + '\n')
            
            del(scores,x,y)
            
    os.remove(fname)