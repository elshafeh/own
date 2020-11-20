#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 13 10:32:16 2020

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 15:17:57 2019

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
from scipy.io import savemat

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,Vectorizer)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator
import os

dir_data                                                = '/Users/heshamelshafei/Dropbox/project_me/pjme_nback/data/prepro/nback_dwn/'

suj_list                                                = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

stim_list                                               = [1,2,3,4,5,6,7,8,9,10]

for isub in range(len(suj_list)):
    
    suj                                                 = suj_list[isub]
    
    fname                                               = dir_data + 'data' + str(suj) + '.nback.dwsmple.mat'
    eventName                                           = dir_data + 'data' + str(suj) + '.nback.dwsmple.trialinfo.mat'
    
    print('Handling '+ fname)
        
    epochs                                              = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    
    alldata                                             = epochs.get_data() #Get all epochs as a 3D array.
    allevents                                           = np.squeeze(loadmat(eventName)['index']) # has to be 1dimension
    
    time_axis                                           = epochs.times               
    
    for nsess in range(1,3):
        for xi in range(len(stim_list)):
            
            dir_out                                     = '/Users/heshamelshafei/Dropbox/project_me/pjme_nback/data/coef/stim/'
            fname_out                                   = 'sub' + str(suj) + '.stim' + str(stim_list[xi])  + '.session' + str(nsess) + '.ag.all.coef.mat'
            
            if not os.path.exists(dir_out+fname_out):
            
                indx_ses                                = np.where(allevents[:,1] == nsess)
                
                sub_data                                = np.squeeze(alldata[indx_ses,:,:])
                sub_events                              = np.squeeze(allevents[indx_ses,0])
                
                x                                       = sub_data
                
                find_stim                               = np.where(sub_events == stim_list[xi])
                
                # make sure codes are ones and zeroes
                y                                       = np.zeros(np.size(sub_events))
                y[find_stim]                            = 1
                
                clf                                     = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                clf.fit(x,y)
                    
                for name in('patterns_','filters_'):
                    coef                                = get_coef(clf,name,inverse_transform=True)
                
                print('saving '+ fname_out)
                
                savemat(dir_out+fname_out, mdict={'coef': coef,'time_axis':time_axis})
                
                del(coef,x,y)
