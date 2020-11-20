#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 15:17:57 2019

@author: heshamelshafei
"""

import os

#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')
#os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

dir_data                                        = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/nback/'

suj_list                                        = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

for isub in range(len(suj_list)):
    for ises in [0,1]:
        
        suj                                         = suj_list[isub]
        fname                                       = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '.mat'
        ename                                       = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
        print('Handling '+ fname)
                    
        epochs                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        
        alldata                                     = epochs.get_data() #Get all epochs as a 3D array.
        allevents                                   = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
        
        test_done                                   = np.squeeze(loadmat('/Users/heshamelshafei/Dropbox/project_me/nback/scripts/decode_stim_mtrx.mat')['test_done']) 
        
        if isub == 0:
            all_scores                              = np.zeros((len(suj_list),len(test_done),np.shape(alldata)[2]))
        
        for xi in range(len(test_done)):
                
            find_both                               = np.where((allevents[:,0] == test_done[xi,0]) | (allevents[:,0] == test_done[xi,1]))
            
            x                                       = np.squeeze(alldata[find_both,:,:])
            y                                       = np.squeeze(allevents[find_both,0])
            
            # make sure codes are ones and zeroes
            y[np.where(y == np.min(y))]             = 0
            y[np.where(y == np.max(y))]             = 1
            
            clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
            time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
            scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
            scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
            
            all_scores[isub,xi,:]                   = scores
            
            print('done with test ' + str(xi) + ' out of ' + str(len(test_done)) + ' for sub' + str(suj))
            del(scores,x,y)

#dir_out                                         = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/stim/'
#fname_out                                       = dir_out + 'alldata.stim.decode.auc.mat'
#scores                                          = all_scores
#scipy.io.savemat(fname_out, mdict={'scores': scores})
#
#for itest in range(np.shape(all_scores)[1]):
#    
#    fig, ax     = plt.subplots(1)
#    
#    col_pal     = list(["#1f78b4", "#b2df8a","#fb9a99","#1f78b2", "#b2df6a","#fb9a59"])
#    
#    scores      = np.mean(np.squeeze(all_scores[:,itest,:]),axis=0)
#    
#    ax.plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
#    ax.axvline(.0, color='k', linestyle='-')
#    
#    x           = epochs.times
#    y           = scores
#    
#    ax.fill_between(x, y, where=y>0.5, facecolor=col_pal[np.random.randint(5)], interpolate=True)
#    ax.set_ylim([0.5,0.7])
#    ax.set_xlim([-0.1,1])