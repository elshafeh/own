#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  2 17:32:02 2019

@author: hesels
"""

import os

if os.name == 'posix':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import fnmatch
import warnings
import numpy as np
from scipy.io import savemat
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

if os.name == 'posix':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

suj_list                                                                    = [1,2,3,4,8,9,10,11,12,13,14,15,16,17]
data_list                                                                   = list(['CnD.brain1vox.dwn60.eeg','CnD.brain1vox.dwn60.meg'])
feat_list                                                                   = list(['inf.unf','left.right']) #,'left.inf','right.inf'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                                 = 'yc'+ str(suj_list[isub])
        
        dir_in                                                              = 'J:/temp/meeg/data/voxbrain/tf/'
        dir_out                                                             = 'J:/temp/meeg/data/voxbrain/auc/'
        
        # Make new director for output data
        if not os.path.exists(dir_out):
            os.mkdir(dir_out)
        
        for ifreq in range(1,31):
            
            fname                                                           = dir_in + suj + '.' + data_list[idata] + '.' + str(ifreq) +'Hz.mtm.mat'
            
            if os.path.exists(fname):
            
                print('Handling '+ fname)
                    
                epochs                                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
                alldata                                                     = epochs.get_data() #Get all epochs as a 3D array.
                
                allevents                                                   = epochs.events[:,-1]
                allcodes                                                    = allevents - 1000
                
                for ifeat in range(len(feat_list)):
                    
                    fname_out                                               =  dir_out + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.' + str(ifreq) + 'Hz.auc.bychan.mat'
                    
                    if not os.path.exists(fname_out):
                    
                        if ifeat == 0:
                            find_trials                                     = np.where(allcodes > 0) # all trials
                        elif ifeat == 1:
                            find_trials                                     = np.where(allcodes > 100)
                        elif ifeat == 2:
                            find_trials                                     = np.where(allcodes < 200)
                        elif ifeat == 3:
                            find_trials                                     = np.where((allcodes < 10) | (allcodes>200))
                        
                        sub_data                                            = np.squeeze(alldata[find_trials,:,:])
                        sub_code                                            = np.squeeze(allcodes[find_trials])
                        
                        allinf                                              = np.floor(sub_code/100)
                        
                        if np.shape(np.unique(allinf))[0] > 2:
                            allinf[np.where(allinf > 0)]                    = 1
                        
                        number_chan                                         = np.shape(sub_data)[1]
                        number_trial                                        = np.shape(sub_data)[0]
                        number_sample                                       = np.shape(sub_data)[2]
                        
                        scores                                              = np.zeros((number_chan,number_sample))
                        
                        for nchan in range(number_chan):
                                
                            print('\n\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for ' + suj + '-' + data_list[idata] + '-' + feat_list[ifeat] + '-' + str(ifreq) + 'Hz')
                            
                            x                                               = np.zeros((number_trial,1,number_sample))
                            x[:,0,:]                                        = sub_data[:,nchan,:]  
                            x[np.where(np.isnan(x))]                        = 0
                            
                            y                                               = np.squeeze(allinf)        
                            
                            clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                            time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                            tmp_scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                            scores[nchan,:]                                 = np.mean(tmp_scores, axis=0) # Mean scores across cross-validation splits
                            
                            del(tmp_scores,x,y)
                            
                        savemat(fname_out, mdict={'scores': scores})
                        print('\nsaving '+ fname_out + '\n')
                            
                        del(scores)
                    
                os.remove(fname)