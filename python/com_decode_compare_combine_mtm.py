#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 09:31:46 2019

@author: heshamelshafei
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 13:46:05 2019

@author: heshamelshafei
"""

import mne
import fnmatch
import warnings
import numpy as np
import os
from scipy.io import savemat
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

suj_list                                                                = [1,2,3,4,8,9,10,11,12,13,14,15,16,17] #
data_list                                                               = list(['CnD.eeg','pt1.CnD.meg','pt2.CnD.meg','pt3.CnD.meg'])
feat_list                                                               = list(['inf.unf','left.right'])#,'left.inf','right.inf'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                             = 'yc'+ str(suj_list[isub])
        
        dir_in                                                          = '/Users/heshamelshafei/Dropbox/project_me/meeg_compare/data/mtm/' + suj + '/'
        dir_out                                                         = dir_in
        
        # Make new director for output data
        if not os.path.exists(dir_out):
            os.mkdir(dir_out)
        
        for ifreq in range(1,20):
            
            fname                                                       = dir_in + suj + '.' + data_list[idata] + '.' + str(ifreq) +'Hz.mat'
            
            if os.path.exists(fname):
            
                print('Handling '+ fname)
                    
                epochs                                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
                alldata                                                 = epochs.get_data() #Get all epochs as a 3D array.
                allevents                                               = epochs.events[:,-1]
                
                allcodes                                                = allevents - 1000
                
                time_axis                                               = np.squeeze(epochs.times)
                
                for ifeat in range(len(feat_list)):
                    
                    fname_out                                           =  dir_out + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.' + str(ifreq) + 'Hz.auc.mat'
                    
                    if not os.path.exists(fname_out):
                    
                        if ifeat == 0:
                            find_trials                                 = np.where(allcodes > 0) # all trials
                        elif ifeat == 1:
                            find_trials                                 = np.where(allcodes > 100)
                        elif ifeat == 2:
                            find_trials                                 = np.where(allcodes < 200)
                        elif ifeat == 3:
                            find_trials                                 = np.where((allcodes < 10) | (allcodes>200))
                        
                        sub_data                                        = np.squeeze(alldata[find_trials,:,:])
                        sub_code                                        = np.squeeze(allcodes[find_trials])
                        
                        allinf                                          = np.floor(sub_code/100)
                        
                        if np.shape(np.unique(allinf))[0] > 2:
                            allinf[np.where(allinf > 0)]                = 1
                        
                        x                                               = np.squeeze(sub_data)
                        y                                               = np.squeeze(allinf)        
                        
                        clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                        time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        scores                                          = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                        scores                                          = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                        
                        savemat(fname_out, mdict={'scores': scores})
                        print('\nsaving '+ fname_out + '\n')
                        
                        del(scores,x,y)
                    
                os.remove(fname)