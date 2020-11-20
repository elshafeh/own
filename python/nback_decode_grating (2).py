#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 31 16:10:17 2019

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
import os



dir_data                                        = '/Users/heshamelshafei/Dropbox/project_me/nback/data/decode/grating/'
suj_list                                        = range(51)
all_scores                                      = np.zeros((len(suj_list),151,151))


for isub in range(len(suj_list)):
    
    suj                                         = suj_list[isub]+1
    
    fname                                       = dir_data + 'data' + str(suj) + '.grating.dwsmple.mat'
    eventName                                   = dir_data + 'data' + str(suj) + '.grating.dwsmple.trialinfo.mat'
    
    print('\nHandling '+ fname+'\n')
        
    epochs                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    x                                           = epochs.get_data() #Get all epochs as a 3D array.
    y                                           = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
    
    print('\n\n')
    
    #clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
    #time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
    #scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
    #scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
    
    clf                                         = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
    time_gen                                    = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
            
    # Fit classifiers on the epochs where the stimulus was presented to the left.
     # Note that the experimental condition y indicates auditory or visual
    time_gen.fit(X=x, y=y)
    scores                                      = time_gen.score(X=x, y=y)
    
    all_scores[isub,:,:]                        = scores
    
    del scores
    
    print('\n')

## PLOTTING ##
#fig, ax     = plt.subplots(1)
#col_pal     = list(["#1f78b4", "#b2df8a","#fb9a99","#1f78b2", "#b2df6a","#fb9a59"])
#    
#scores      = np.mean(all_scores,axis=0)
#
#ax.plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
#ax.axvline(.0, color='k', linestyle='-')
#
#x           = epochs.times
#y           = scores
#
#ax.fill_between(x, y, where=y>0.5, facecolor=col_pal[2], interpolate=True)
#ax.set_ylim([0.5,1])
#ax.set_xlim([-0.1,1])
    
fig, ax         = plt.subplots(1)
tmp             = np.mean(all_scores,axis = 0)
scores          = tmp
im              = ax.matshow(scores, vmin =0, vmax = 1, cmap='RdBu_r', origin='lower',extent=epochs.times[[0, -1, 0, -1]])

ax.axhline(0., color='k')
ax.axvline(0., color='k')

ax.set_ylim([-0.1,1])
ax.set_xlim([-0.1,1])

ax.xaxis.set_ticks_position('bottom')
ax.set_ylabel('Training Time (s)')
ax.set_xlabel('Testing Time (s)')
ax.set_title('Time Generalization Matrix')
plt.show()
plt.colorbar(im, ax=ax)

