#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 14 19:51:59 2020

@author: heshamelshafei
"""

import os

if os.name == 'posix':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from scipy.io import (savemat,loadmat)
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,Vectorizer)

if os.name == 'posix':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

big_dir                                             = '/project/3015039.05/temp/nback/data/'
dir_data                                            = big_dir + 'prepro/stack/'

suj_list                                            = np.squeeze(loadmat('/home/mrphys/hesels/github/me/data/suj.list.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat')['good_list'])
ses_list                                            = ['1','2']

for isub in range(len(suj_list)):
    for ises in range(len(ses_list)):
        
        suj                                             = suj_list[isub]
        
        fname                                           = dir_data + 'sub'+ str(suj)+ '.sess'  + ses_list[ises] + '.stack.dwn100.mat'
        print('Handling '+ fname)
                
        epochs                                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', 
                                                                                    trialinfo_column=1)
            
        alldata                                         = epochs.get_data()
        allevents                                       = np.squeeze(epochs.events)[:,-1]
            
        time_axis                                       = epochs.times
                
        
        #choose time
        t1                                              = np.squeeze(np.where(time_axis == 2))
        t2                                              = np.squeeze(np.where(time_axis == 4))
        
        alldata                                         = np.squeeze(alldata[:,:,t1:t2])
        time_axis                                       = np.squeeze(time_axis[t1:t2])
        
        # remove mean
        #print('\ndemeaning')
        
        #for ntrial in range(np.shape(alldata)[0]):
        #    print('demeaning trial '+ str(ntrial) + ' of ' + str(np.shape(alldata)[0]))
        #    for ntime in range(np.shape(alldata)[2]):
        #        alldata[ntrial,:,ntime]                 = alldata[ntrial,:,ntime] - np.mean(alldata[ntrial,:,:],axis=1)
        
        print('\n')
        
        # make conditions to 0, 1 and 2
        allevents                                       = allevents - 4
        
        test_done                                       = np.transpose(np.array(([0,0,1],[1,2,2])))    
        test_name                                       = ["0v1B","0v2B","1v2B"]
        
        for xi in range(len(test_done)):
            
            dir_out                                     = '/project/3015039.05/temp/nback/data/coef/cond/'
            fname_out                                   = 'sub' + str(suj) + '.sess'  + ses_list[ises] +'.' + test_name[xi] + '.2ndwindow.sensor.coef.mat'
            
            if not os.path.exists(dir_out+fname_out):
                
                find_both                               = np.where((allevents == test_done[xi,0]) | (allevents == test_done[xi,1]))
                
                x                                       = np.squeeze(alldata[find_both,:,:])
                y                                       = np.squeeze(allevents[find_both])
                
                # make sure codes are ones and zeroes
                y[np.where(y == np.min(y))]             = 0
                y[np.where(y == np.max(y))]             = 1
                
                if np.size(np.squeeze(np.unique(y))) == 2:
                  
                    clf                                     = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                    
                    print('fitting model for '+fname_out)
                    clf.fit(x,y)
                    
                    print('extracting coefficients for '+fname_out)            
                    for name in('patterns_','filters_'):
                        coef                               = get_coef(clf,name,inverse_transform=True)
                    
                    
                    print('saving '+ fname_out + '\n')
                    savemat(dir_out+fname_out, mdict={'coef': coef,'time_axis':time_axis})
                    
                    del(coef,x,y)
        
        del(alldata,allevents)