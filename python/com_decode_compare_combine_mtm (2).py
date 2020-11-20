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

suj_list                                                            = [12,13,14,15,16,17] # 1,2,3,4,8,9,10,11,
data_list                                                           = list(['CnD.eeg','pt1.CnD.meg','pt2.CnD.meg','pt3.CnD.meg'])
feat_list                                                           = list(['inf.unf','left.right'])

for isub in range(len(suj_list)):
    for idata in range(len(data_list)):
    
        suj                                                         = 'yc'+ str(suj_list[isub])
        
        dir_in                                                      = '/project/3015039.05/temp/meeg/data/mtm_decode/' + suj + '/'
        dir_out                                                     = '/project/3015039.05/temp/meeg/data/res/' + suj + '/'
        
        # Make new director for output data
        if not os.path.exists(dir_out):
            os.mkdir(dir_out)
        
        for ifreq in range(1,41):
            
            fname                                                   = dir_in + suj + '.' + data_list[idata] + '.' + str(ifreq) +'Hz.mat'
            
            if os.path.exists(fname):
            
                print('Handling '+ fname)
                    
                epochs                                                  = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
                alldata                                                 = epochs.get_data() #Get all epochs as a 3D array.
                allevents                                               = epochs.events[:,-1]
                
                allcodes                                                = allevents - 1000
                
                for ifeat in range(len(feat_list)):
                    
                    fname_out                                           =  dir_out + suj + '.' + data_list[idata] + '.' + feat_list[ifeat] + '.' + str(ifreq) + 'Hz.AuCollapse.mat'
                    
                    if not os.path.exists(fname_out):
                    
                        if ifeat == 0:
                            find_trials                                 = np.where(allcodes > 0) # all trials
                        else:
                            find_trials                                 = np.where(allcodes > 100)
                        
                        sub_data                                        = np.squeeze(alldata[find_trials,:,:])
                        allcodes                                        = np.squeeze(allcodes[find_trials])
                        
                        allcues                                         = np.floor(allcodes/100)
                        allinf                                          = allcues
                        
                        if np.shape(np.unique(allinf))[0] > 2:
                            allinf[np.where(allinf > 0)]                = 1
                        
                        x                                               = np.squeeze(sub_data)
                        y                                               = np.squeeze(allinf)        
                        
                        clf                                             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression())) # define model
                        time_decod                                      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        scores                                          = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
                        scores                                          = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                        
                        savemat(fname_out, mdict={'scores': scores})
                        print('\nsaving '+ fname_out + '\n')
                        
                        del(scores,x,y)
                    
                os.remove(fname)