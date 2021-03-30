#!/home/brainrhythms/hesels/.conda/envs/mne_uwu/bin/ python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  3 15:34:08 2021

@author: hesels
"""

import os
import sys

os.chdir("/home/brainrhythms/hesels/.conda/envs/mne_uwu/lib/python3.8/site-packages/")
  
import mne
import numpy as np
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import  LogisticRegressionCV
from scipy.io import (savemat,loadmat)
from sklearn.model_selection import LeaveOneOut
from sklearn.metrics import roc_auc_score

                                            
lck_list                                            = list(['1stgab','2ndgab'])
dcd_list                                            = list(["orientation","frequency"])

suj                                                 = sys.argv[1]

dir_data_in                                         = '/project/3015079.01/data/' + suj + '/preproc/'
dir_data_ou                                         = '/project/3015079.01/data/' + suj + '/decode/'

for ilock in range(len(lck_list)): 

    ext_name                                        = '.' + lck_list[ilock] + '.lock.broadband.centered'

    fname                                           = dir_data_in + suj + ext_name + '.mat'
    print('\nHandling '+ fname+'\n')
    eventName                                       = dir_data_in + suj + ext_name + '.trialinfo.mat'

    epochs                                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    epochs                                          = epochs.apply_baseline(baseline=(-0.2,-0.1))
    
    broad_events                                    = loadmat(eventName)['index']
    broad_data                                      = epochs.get_data() #Get all epochs as a 3D array.
    broad_data[np.where(np.isnan(broad_data))]      = 0
    time_axis                                       = epochs.times
    
    if ilock == 0:
        flg_gab = np.array([1,2]) # then u look for 1st gabor
    else:
        flg_gab = np.array([3,4]) # then u look for 2nd gabor
    
    for ifeat in [0,1]:
        
        if ifeat == 0:
            # orientation
            y                                       = broad_events[:,flg_gab[ifeat]]
            y[np.where(y < 80)]                     = 0
            y[np.where(y > 80)]                     = 1
            
        elif ifeat == 1:
            # frequeny
            y                                       = broad_events[:,flg_gab[ifeat]]
            y[np.where(y < 0.4)]                    = 0
            y[np.where(y > 0.4)]                    = 1
    
        X                                           = broad_data
        y_p                                         = y
        
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
        
        savename                                    = dir_data_ou + suj + ext_name + '.decoding.' + dcd_list[ifeat] + '.leaveone.mat'

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
                    print(suj + ' ' + lck_list[ilock] + ' ' + dcd_list[ifeat] + ' '+ str(ich+1) + '/' + str(n_times) + 
                          ' timepoint, ' + str(test+1) +'/' + str(n_trials) + ' trial')
                    
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
