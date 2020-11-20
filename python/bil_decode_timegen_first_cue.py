#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 11 19:55:15 2019

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 09:44:35 2019

@author: heshamelshafei
"""

# if running in cluster
# cd /home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/

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

dir_data                            = '/project/3015079.01/data/'

suj_list                            = list([1,3,4,8,9,10,11,12,13,14])
dcd_list                            = list(["pre-vs-retro","pre task","retro task"])

all_scores                          = np.zeros((len(suj_list),len(dcd_list),800,800))

for isub in range(len(suj_list)):
    
    if suj_list[isub] < 10:
        suj                         = 'sub00' + str(suj_list[isub])
    elif suj_list[isub] >= 10:
        suj                         = 'sub0' + str(suj_list[isub])
        
    
    print('\nHandling '+ suj+'\n')
    
    ext_name                        = "_firstcuelock_dwnsample100Hz"
    fname                           = dir_data + suj + '/preproc/' + suj + ext_name + '.mat'
    eventName                       = dir_data + suj + '/preproc/' + suj + ext_name + '_trialinfo.mat'
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    allevents                       = loadmat(eventName)['index']
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    
    ## pick correct trials
    find_correct                    = np.where(allevents[:,1] == 1)
    alldata                         = np.squeeze(alldata[find_correct,:,:])
    allevents                       = np.squeeze(allevents[find_correct,:])
    ## 
    
    print('\n')
    
    for ifeat in range(1,3): #range(len(dcd_list)):
        
        print('\npreparing for ' +  suj + ' ' + dcd_list[ifeat] + ' decoding \n')
        
        x                           = alldata
        mini_sub                    = allevents
        
        if ifeat == 0:
            
            # reto vs pre
            find_trials             = np.where((mini_sub[:,0] >0))
            
            y                       = np.zeros((len(mini_sub)))
            y[np.where((mini_sub[:,0] > 20) )]                          = 1
            
        elif ifeat == 1:
            # pre ori - vs spa
            find_trials             = np.where((mini_sub[:,0] < 20))
            mini_sub                = np.squeeze(mini_sub[find_trials,0])
            y                       = mini_sub - 11
            
        elif ifeat == 2:
            # ret ori - vs spa
            find_trials             = np.where((mini_sub[:,0] > 20))
            mini_sub                = np.squeeze(mini_sub[find_trials,0])
            y                       = mini_sub - 21
            
        chk                         = len(np.unique(y))
        
        if chk == 2:
            x                       = np.squeeze(x[find_trials,:,:])
            
            clf                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
            time_gen                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
            
            # Fit classifiers on the epochs where the stimulus was presented to the left.
            # Note that the experimental condition y indicates auditory or visual
            time_gen.fit(X=x, y=y)
            scores                  = time_gen.score(X=x, y=y)
            
            all_scores[isub,ifeat,:,:] = scores
            
            del scores
            
            print('\n')

for ifeat in range(1,3): #range(len(dcd_list)):

    fig, ax         = plt.subplots(1)
    tmp             = np.mean(all_scores[:,ifeat,:,:],axis = 0)
    scores          = tmp
    im              = ax.matshow(scores, vmin =0, vmax = 1, cmap='RdBu_r', origin='lower',extent=epochs.times[[0, -1, 0, -1]])

    ax.axhline(0., color='k')
    ax.axvline(0., color='k')
    
    ax.xaxis.set_ticks_position('bottom')
    ax.set_ylabel('Training Time (s)')
    ax.set_xlabel('Testing Time (s)')
    ax.set_title('Generalization ' + dcd_list[ifeat])
    
    plt.colorbar(im, ax=ax)
    plt.show()
        
