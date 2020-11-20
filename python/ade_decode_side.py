#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 11 16:21:46 2019

@author: heshamelshafei
"""

import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
import os
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator

dir_data            = '/Users/heshamelshafei/Dropbox/project_me/pjme_ade/data/preproc/'
dir_evnt            = '/Users/heshamelshafei/Dropbox/project_me/pjme_ade/data/trialinfo/'

list_file           = os.listdir('/Users/heshamelshafei/Dropbox/project_me/pjme_ade/data/preproc/')
list_feat           = ["noise.side","noise.left.type","noise.right.type"]


for ifile in range(12,len(list_file)):
    
    if list_file[ifile][0:3] == 'sub':
    
        suj_name        = list_file[ifile][0:6]
        mod_name        = list_file[ifile][7:10]
        
        fname           = dir_data + list_file[ifile]
        eventName       = dir_evnt + suj_name + '.' + mod_name +  '.trialinfo.mat'
        
        print('\nHandling '+ fname+'\n')
        
        epochs          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        alldata         = epochs.get_data()
        
        time_axis       = epochs.times
        
        #0 1   2    3   4    5        6        7   8       9       10         11
        #n mod nois sid stim beh_corr beh_conf RT response mapping difference nb_bloc
        
        allevents       = loadmat(eventName)['index']
        
        ix              = np.where(allevents[:,2]==1) # keep only noise-y
        
        alldata         = np.squeeze(alldata[ix,:,:])
        allevents       = np.squeeze(allevents[ix,:])
        
        bloc_list       = np.unique(allevents[:,-1])
        
        for ibloc in range(len(bloc_list)):
            
            ix          = np.where(allevents[:,-1] == bloc_list[ibloc])
            
            sub_data    = np.squeeze(alldata[ix,:,:])
            sub_evnt    = np.squeeze(allevents[ix,:])
            
            for ifeat in range(len(list_feat)):
                
                if ifeat == 0:
                    ## side
                    x                               = sub_data
                    y                               = sub_evnt[:,3]
                    
                elif ifeat == 1:
                    ## type -left-
                    find_trials                     = np.where((sub_evnt[:,5]==1) & (sub_evnt[:,2]==1) & (sub_evnt[:,3]==0)) # choise only noisy left correct
                    x                               = np.squeeze(sub_data[find_trials,:,:])
                    y                               = np.squeeze(sub_evnt[find_trials,4])
                    
                
                elif ifeat == 2:
                    # type -right-
                    find_trials                     = np.where((sub_evnt[:,5]==1) & (sub_evnt[:,2]==1) & (sub_evnt[:,3]==1)) # choise only noisy right correct
                    x                               = np.squeeze(sub_data[find_trials,:,:])
                    y                               = np.squeeze(sub_evnt[find_trials,4])
                
                # check there are enough trials
                if (np.shape(np.where(y==1))[1] > 2) & (np.shape(np.where(y==0))[1] > 2):
                
                    clf                                 = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                    time_decod                          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    
                    scores                              = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
                    scores                              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    dir_out                             = '/Users/heshamelshafei/Dropbox/project_me/pjme_ade/data/decode/'
                    fname_out                           =  dir_out + suj_name + '.' + mod_name  + '.b' +str(np.int(bloc_list[ibloc])) +'.'+ list_feat[ifeat] + '.auc.mat'
        
                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                    print('\nsaving '+ fname_out + '\n')