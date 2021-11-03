# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 10:24:43 2021

@author: hesels
"""

import os
import sys

#os.chdir("/home/brainrhythms/hesels/.conda/envs/mne_uwu/lib/python3.8/site-packages/")

import mne
import numpy as np
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import  LogisticRegressionCV
from scipy.io import (savemat,loadmat)
from sklearn.model_selection import LeaveOneOut
from sklearn.metrics import roc_auc_score


suj_list                                        = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
                                           21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,38,39,40,
                                           41,42,43,44,46,47,48,49,50,51]

for nsub in range(len(suj_list)):

    suj                                             = suj_list[nsub]
            
    dir_dropbox                                     = '/project/3035002.01/nback/'#/Users/heshamelshafei/'
    
    dir_data_in                                     = 'D:/Dropbox/project_me/data/nback/bin_decode/preproc/'
    dir_data_out                                    = 'D:/Dropbox/project_me/data/nback/bin_decode/auc/'
    
    ext_demean                                      = 'nodemean'
    ext_name                                        = dir_data_in + 'sub' + str(suj)+ '.0back.broadband.' + ext_demean
    fname                                           = ext_name + '.mat'  
    ename                                           = ext_name + '.trialinfo.mat'
    print('Handling '+ fname)
    
    epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    alldata                                         = epochs_nback.get_data() #Get all epochs as a 3D array.
    allevents                                       = loadmat(ename)['index']  
    time_axis                                       = epochs_nback.times
    
    X                                               = alldata
    
    # Decode stim id
    stim_present                                    = np.unique(allevents[:,2])
    
    for nstim in range(len(stim_present)):
        
        find_stim                                   = np.squeeze(np.where(allevents[:,2] == stim_present[nstim]))
        y_p                                         = np.zeros(np.shape(allevents)[0])
        y_p[find_stim]                              = 1
    
        n_trials, n_chs,n_times                     = X.shape
        
        # initialize arrays
        y_array                                     = np.zeros((n_times,n_trials))
        yhat_array                                  = np.zeros((n_times,n_trials))
        maxyproba_array                             = np.zeros((n_times,n_trials))
        yproba_array                                = np.zeros((n_times,n_trials))
        
        yhat_H0_array                               = np.zeros((n_times,n_trials))
        yproba_H0_array                             = np.zeros((n_times,n_trials))
        maxyproba_H0_array                          = np.zeros((n_times,n_trials))
        
        auc_array                                   = np.zeros((n_times,n_trials))
        auc_H0_array                                = np.zeros((n_times,n_trials))
        
        e_array                                     = np.zeros((n_times,n_trials))
        e_H0_array                                  = np.zeros((n_times,n_trials))
        
        clf                                         = make_pipeline(StandardScaler(), 
                                                                LogisticRegressionCV(max_iter = 3000, 
                                                                                     solver='lbfgs',cv=3))   
        
        savename                                    = dir_data_out + 'sub' + str(suj) +  '.0back.decoding.stim' + str(stim_present[nstim]) + '.' + ext_demean + '.leaveone.mat'
    
        if not os.path.exists(savename):
            for ich in range(n_times):
                
                X_c_p                               = np.squeeze(X[:, :, ich]) # trials x channels
                
                loo                                 = LeaveOneOut()
                loo.get_n_splits(X_c_p)
                
                for train, test in loo.split(X_c_p):     
                    
                    #TRAIN
                    clf.fit(X_c_p[train], y_p[train])
                    
                    auc_array[ich,test]             = roc_auc_score(y_p[train], clf.predict_proba(X_c_p[train])[:,1])
                    e_array[ich,test]               = np.average(np.max(clf.predict_proba(X_c_p[train]),axis=1))
                    
                    #TEST
                    print('sub' + str(suj) + ' decoding stim' + str(stim_present[nstim]) + ' ' + str(ich+1) + '/' + str(n_times) + ' timepoint, ' + str(test+1) +'/' + str(n_trials) + ' trial')
                    
                    X_test                          = X_c_p[test]
                    y_array[ich,test]               = y_p[test]
                    yhat_array[ich,test]            = clf.decision_function(X_test)
                    #maximum evidence regardless of choice
                    maxyproba_array[ich,test]       = max(clf.predict_proba(X_test)[0,:])
                    yproba_array[ich,test]          = clf.predict_proba(X_test)[0,1]
                                  
                    ####H0###
                    clf.fit(X_c_p[train[np.random.permutation(len(train))]], y_p[train])
                    
                    auc_H0_array[ich,test]          = roc_auc_score(y_p[train], clf.predict_proba(X_c_p[train])[:,1])
                    e_H0_array[ich,test]            = np.average(np.max(clf.predict_proba(X_c_p[train]),axis=1))    
                    yhat_H0_array[ich,test]         = clf.decision_function(X_test)
                    maxyproba_H0_array[ich,test]    = clf.predict_proba(X_test)[0, 1]
                    yproba_H0_array[ich,test]       = max(clf.predict_proba(X_test)[0,:])
            
            
            print('\nsaving '+savename)
            
            savemat(savename, {'auc_H0_array':auc_H0_array,'e_H0_array':e_H0_array, 'auc_array':auc_array,
                               'e_array':e_array,'y_array':y_array,'maxyproba_array':maxyproba_array,
                               'yproba_array':yproba_array, 'yproba_H0_array':yproba_H0_array, 
                               'yhat_array':yhat_array, 'yhat_H0_array':yhat_H0_array, 
                               'maxyproba_H0_array':maxyproba_H0_array,
                               'time_axis':time_axis})
        
        