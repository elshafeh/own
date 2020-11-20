#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb  7 13:03:13 2020

@author: hesels
"""

import os

#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator,Vectorizer)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                                                                    = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

freq_list                                                               = [2,3,4,5]
        
# 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]

for isub in range(len(suj_list)):
    for ifreq in range(len(freq_list)):
        for ises in [1,2]:
            
            suj                                                         = suj_list[isub]
            fname                                                       = 'J:/temp/nback/data/tf/sub' + str(suj)+'.sess'+str(ises) +'.orig.'+str(freq_list[ifreq])+'Hz.mat'
            ename                                                       = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
            
            print('Handling '+ fname)
                
            epochs_nback                                                = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            # !! apply baseline !! #
            time_axis= np.arange(-1.5,2.02,0.02)
            b1 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))]
            b2 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(0,2)))]
            
            
            epochs_nback                                                = epochs_nback.apply_baseline(baseline=(b1,b2))
            alldata                                                     = epochs_nback.get_data() #Get all epochs as a 3D array.
            
            allevents                                                   = loadmat(ename)['index'][:,[0,2,4]]        
            allevents[:,0]                                              = allevents[:,0]-4
            
            # to pass 0-back into comparison :)
            allevents[np.where((allevents[:,0] == 0) & (allevents[:,1]==0)),1]  = 2
            
            # exclude motor
            trl         = np.squeeze(np.where(allevents[:,2] ==0))
            alldata     = np.squeeze(alldata[trl,:,:])
            allevents   = np.squeeze(allevents[trl,:])
            
            alldata[np.where(np.isnan(alldata))]                    = 0
            
#            nstim       = 3
#            list_stim   = ["first","target","all","nonrand"]
#            
#            if nstim ==3:
#                find_stim                                           = np.where(allevents[:,1] < 10)
#            elif nstim == 4:
#                find_stim                                           = np.where(allevents[:,1] > 0)
#            else:
#                find_stim                                           = np.where(allevents[:,1] == nstim)
#                
#            data_stim                                               = np.squeeze(alldata[find_stim,:,:])
#            evnt_stim                                               = np.squeeze(allevents[find_stim,0])
            
#            for nback in [ises-1]:
#                
#                find_nback                                          = np.where(evnt_stim == nback)
#                
#                dir_out                                             = '/project/3015079.01/nback/coef_mtm/'
#                fname_out                                           = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.' + str(nback) + 'back'
#                fname_out                                           = fname_out+ '.'+str(freq_list[ifreq])+'Hz.' +list_stim[nstim-1]+ '.4cond.coef.mat'
#                
#                if np.size(find_nback)>0 and np.size(find_stim)>1 and np.size(find_nback)<np.size(evnt_stim):
#                    if not os.path.exists(fname_out):
#                        
#                        x                                           = data_stim
#                        x[np.where(np.isnan(x))]                    = 0
#                            
#                        y                                           = np.zeros(np.shape(evnt_stim)[0])
#                        y[find_nback]                               = 1
#                        y                                           = np.squeeze(y)
#                        
#                        clf                                         = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
#                    
#                        print('\nfitting model for '+fname_out)
#                        clf.fit(x,y)
#                        print('extracting coefficients for '+fname_out)            
#                        for name in('patterns_','filters_'):
#                            coef                                    = get_coef(clf,name,inverse_transform=True)
#                        
#                        savemat(fname_out, mdict={'scores': coef,'time_axis':time_axis})
#                        print('\nsaving '+ fname_out + '\n')
                        
            
            for nback in [0,1,2]:
            
                find_nback                                          = np.where(allevents[:,0] == nback)
                
                if np.size(find_nback)>0:
                
                    data_nback                                      = np.squeeze(alldata[find_nback,:,:])
                    evnt_nback                                      = np.squeeze(allevents[find_nback,1])
                    
                    dir_out                                         = 'J:/temp/nback/data/coef_mtm/'
                    fname_out                                       = dir_out + 'sub' + str(suj) + '.sess' + str(ises) + '.' + str(nback) + 'back'
                    fname_out                                       = fname_out+ '.'+str(freq_list[ifreq])+'Hz.target.4stim.coef.mat'
                    
                    if not os.path.exists(fname_out):
                        
                        if nback == 0:
                            find_stim                               = np.where((evnt_nback == 1)) # find other/target stimulus
                        else:
                            find_stim                               = np.where((evnt_nback == 2)) # find 1st-stim(1) or target(2) stimulus
                            
                        if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                        
                            x                                       = data_nback
                            y                                       = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                            = 1
                            y                                       = np.squeeze(y)
                            
                            clf                                     = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                        
                            print('\nfitting model for '+fname_out)
                            clf.fit(x,y)
                            print('extracting coefficients for '+fname_out)            
                            for name in('patterns_','filters_'):
                                coef                               = get_coef(clf,name,inverse_transform=True)
                            
                            
                            savemat(fname_out, mdict={'scores': coef,'time_axis':time_axis})