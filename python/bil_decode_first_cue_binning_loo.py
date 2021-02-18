#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 09:44:35 2019

@author: heshamelshafei
"""

import os
if os.name != 'nt':
    os.chdir('/home/brainrhythms/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
#from mne.decoding import ( cross_val_multiscore)

if os.name != 'nt':
    os.chdir('/home/brainrhythms/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import  LogisticRegressionCV
from scipy.io import (savemat,loadmat)
from sklearn.model_selection import LeaveOneOut
from sklearn.metrics import roc_auc_score


##"sub001","sub003","sub004","sub006","sub008","sub009","sub010",
#                                            "sub011","sub012",
                                            
suj_list                                        = list(["sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024"])
    
    
#suj_list                                        = list(["sub025","sub026","sub027","sub028","sub029","sub031","sub032",
#                                            "sub033","sub034","sub035","sub036","sub037"])


dcd_list                                        = list(["pre.task","retro.task"])

for isub in range(len(suj_list)):

    suj                                         = suj_list[isub]
    
    cue_list                                    = list(["1stcue","2ndcue"])
    wind_list                                   = list(["preCue1","preCue2"])
    
    dir_data_in                                 = '/project/3015079.01/data/' + suj + '/preproc/'
    dir_data_ou                                 = '/project/3015079.01/data/' + suj + '/decode/'

    for icue in range(len(cue_list)): 
    
        ext_name                                = '.' + cue_list[icue] + '.lock.broadband.centered'
    
        fname                                   = dir_data_in + suj + ext_name + '.mat'
        print('\nHandling '+ fname+'\n')
        eventName                               = dir_data_in + suj + ext_name + '.trialinfo.mat'
    
        epochs                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        epochs                                  = epochs.apply_baseline(baseline=(-0.2,-0.1))
        
        broad_events                            = loadmat(eventName)['index']
        broad_data                              = epochs.get_data() #Get all epochs as a 3D array.
        broad_data[np.where(np.isnan(broad_data))]  = 0
        time_axis                               = epochs.times
        
        if icue == 0:
            # pre cue
            find_trials                         = np.where((broad_events[:,0] < 13)) # pre are coded 11 and 12
        else:
            find_trials                         = np.where((broad_events[:,0] > 12))
        
        X                                       = np.squeeze(broad_data[find_trials,:,:])
        y_p                                     = np.squeeze(broad_events[find_trials,6]) - 1
        
        n_trials, n_chs,n_times                 = X.shape
        
        # initialize arrays
        y_array                                 = np.zeros((n_times,n_trials))
        yhat_array                              = np.zeros((n_times,n_trials))
        maxyproba_array                         = np.zeros((n_times,n_trials))
        yproba_array                            = np.zeros((n_times,n_trials))
        
        yhat_H0_array                           = np.zeros((n_times,n_trials))
        yproba_H0_array                         = np.zeros((n_times,n_trials))
        maxyproba_H0_array                      = np.zeros((n_times,n_trials))
        
        auc_array                               = np.zeros((n_times,n_trials))
        auc_H0_array                            = np.zeros((n_times,n_trials))
        
        e_array                                 = np.zeros((n_times,n_trials))
        e_H0_array                              = np.zeros((n_times,n_trials))
        
        clf                                     = make_pipeline(StandardScaler(), 
                                                                LogisticRegressionCV(max_iter = 2000, 
                                                                                     solver='lbfgs',cv=3))   
        
        savename                                = dir_data_ou + suj + ext_name + '.decoding.' + dcd_list[icue] + '.leaveone.mat'

        if not os.path.exists(savename):
            for ich in range(n_times):
            
                X_c_p                               = np.squeeze(X[:, :, ich]) # trials x channels
                # cross validation loop
                #            n_trials, n_times                   = X_c_p.shape
                #            y_hat                               = np.zeros((n_trials,))
                #            y_proba                             = np.zeros((n_trials,))
            
                loo                                 = LeaveOneOut()
                loo.get_n_splits(X_c_p)
                
                for train, test in loo.split(X_c_p):     
                    
                    #TRAIN
                    clf.fit(X_c_p[train], y_p[train])
                    
                    auc_array[ich,test]             = roc_auc_score(y_p[train], clf.predict_proba(X_c_p[train])[:,1])
                    e_array[ich,test]               = np.average(np.max(clf.predict_proba(X_c_p[train]),axis=1)) #  maximum value of each prediction  - regardless whether decoder
                    # is correct or not -- proxy to the decoder's confidence
                    
                    #TEST
                    print(suj + ' ' + cue_list[icue] + ' '+ str(ich+1) + '/' + str(n_times) + 
                          ' timepoint, ' + str(test+1) +'/' + str(n_trials) + ' trial')
                    
                    X_test                          = X_c_p[test]
                    y_array[ich,test]               = y_p[test]
                    yhat_array[ich,test]            = clf.decision_function(X_test)
                    #maximum evidence regardless of choice
                    maxyproba_array[ich,test]       = max(clf.predict_proba(X_test)[0,:])
                    yproba_array[ich,test]          = clf.predict_proba(X_test)[0,1] # prob that stim feature is present / prediction of classifier
                                  
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
