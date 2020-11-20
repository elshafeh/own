# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 13:18:53 2020

@author: hesels
"""
import os
import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator)
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)



#suj_list                                                    = [1,2,3,4,5,6,7,8,9,10,
#                                                   11,12,13,14,15,16,17,18,19,20,
#                                                   21,22,23,24,25]


suj_list                                                    = [26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

freq_list                                                   = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]

for isub in range(len(suj_list)):
    
    suj                                                     = suj_list[isub]    
    
    for ifreq in range(len(freq_list)):
        for ises in [2]:
            
            fname                                           = 'J:/nback/tf/sub' + str(suj)+'.sess'+str(ises) +'.orig.'+str(freq_list[ifreq])+'Hz.mat'
            ename                                           = 'J:/nback/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            time_axis= np.arange(-1.5,2.02,0.02)
            
            tmp_data                                        = epochs_nback.get_data()
            tmp_evnt                                        = loadmat(ename)['index'][:,[0,2,4]]  
            
            # !! exclude motor !! #
            trl                                             = np.squeeze(np.where(tmp_evnt[:,2] ==0))
            
            tmp_data                                        = np.squeeze(tmp_data[trl,:,:])
            tmp_evnt                                        = np.squeeze(tmp_evnt[trl,:])
            
            alldata                                         = tmp_data #Get all epochs as a 3D array
            allevents                                       = tmp_evnt
            (tmp_data,tmp_evnt)
    
        # to pass 0-back (4) into comparison :)
        allevents[np.where((allevents[:,0] == 4) & (allevents[:,1]==0)),1]  = 2
        alldata[np.where(np.isnan(alldata))]                    = 0
        
        for nstim in [1,2]:
            
            list_stim                                       = ["first","target","all","nonrand"]
            
            if nstim ==3:
                find_stim                                   = np.where(allevents[:,1] < 10)
            elif nstim == 4:
                find_stim                                   = np.where(allevents[:,1] > 0)
            else:
                find_stim                                   = np.where(allevents[:,1] == nstim)
            
            data_stim                                       = np.squeeze(alldata[find_stim,:,:])
            evnt_stim                                       = np.squeeze(allevents[find_stim,0])
            
            test_done                                       = np.transpose(np.array(([4,4,5],[5,6,6])))    
            test_name                                       = ["0Bv1B","0Bv2B","1Bv2B"]
            
            for ntest in [2]:
                
                find_both                                   = np.where((evnt_stim == test_done[ntest,0]) | (evnt_stim == test_done[ntest,1]))
                
                dir_out                                     = 'J:/nback/sens_level_auc/cond/'
                fscores_out                                 = dir_out + 'sub' + str(suj) + '.decoding.' +test_name[ntest]
                fscores_out                                 = fscores_out+ '.'+ str(freq_list[ifreq]) + 'Hz.lockedon.' +list_stim[nstim-1]+ '.dwn70.nobsl.excl.auc.mat'
                            
                if not os.path.exists(fscores_out):
                    
                    x                                       = np.squeeze(data_stim[find_both,:,:])
                    x[np.where(np.isnan(x))]                = 0
                        
                    y                                       = np.squeeze(evnt_stim[find_both])
                    y[np.where(y == np.min(y))]             = 0
                    y[np.where(y == np.max(y))]             = 1
                    
                    clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                    time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                    scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
                    scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                    
                    savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                    print('\nsaving '+ fscores_out + '\n')
                    
                    del(scores,x,y)
                        
                del(find_both)
            del(find_stim,data_stim,evnt_stim)
        del(allevents,alldata)
