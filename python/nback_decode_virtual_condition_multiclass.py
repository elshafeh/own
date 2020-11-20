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



suj_list                                                    = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

freq_list                                                   = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]

for isub in range(len(suj_list)):
    
    suj                                                     = suj_list[isub]    
    
    for ifreq in range(len(freq_list)):
        for ises in [1,2]:
            
            fname                                           = 'J:/temp/nback/data/tf/sub' + str(suj)+'.sess'+str(ises) +'.orig.'+str(freq_list[ifreq])+'Hz.mat'
            ename                                           = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            # !! apply baseline !! #
            time_axis= np.arange(-1.5,2.02,0.02)
            b1 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))]
            b2 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(0,2)))]
            epochs_nback                                    = epochs_nback.apply_baseline(baseline=(b1,b2))
            
            tmp_data                                        = epochs_nback.get_data()
            tmp_evnt                                        = loadmat(ename)['index'][:,[0,2,4]]  
            
            # !! exclude motor !! #
            trl                                             = np.squeeze(np.where(tmp_evnt[:,2] ==0))
            
            tmp_data                                        = np.squeeze(tmp_data[trl,:,:])
            tmp_evnt                                        = np.squeeze(tmp_evnt[trl,:])
            
            if ises == 1:
                alldata                                     = tmp_data #Get all epochs as a 3D array
                allevents                                   = tmp_evnt
                del(tmp_data,tmp_evnt)
            else:
                alldata                                     = np.concatenate((alldata,tmp_data),axis=0)
                allevents                                   = np.concatenate((allevents,tmp_evnt),axis=0)
                del(tmp_data,tmp_evnt)
            
            del(fname,ename,epochs_nback,trl,b1,b2)
    
        # to pass 0-back (4) into comparison :)
        allevents[np.where((allevents[:,0] == 4) & (allevents[:,1]==0)),1]  = 2
        alldata[np.where(np.isnan(alldata))]                = 0
        
        for nstim in [1,2,3,4]:
            
            list_stim                                       = ["first","target","all","nonrand"]
            
            if nstim ==3:
                find_stim                                   = np.where(allevents[:,1] < 10)
            elif nstim == 4:
                find_stim                                   = np.where(allevents[:,1] > 0)
            else:
                find_stim                                   = np.where(allevents[:,1] == nstim)
            
            data_stim                                       = np.squeeze(alldata[find_stim,:,:])
            evnt_stim                                       = np.squeeze(allevents[find_stim,0])
                            
            dir_out                                         = 'J:/temp/nback/data/sens_level_auc/cond/'
            fscores_out                                     = dir_out + 'sub' + str(suj) + '.multiclass.decoding.'
            fscores_out                                     = fscores_out+ str(freq_list[ifreq]) + 'Hz.lockedon.' +list_stim[nstim-1]+ '.dwn70.bsl.excl.auc.mat'
                        
            if not os.path.exists(fscores_out):
                    
                x                                           = data_stim
                x[np.where(np.isnan(x))]                    = 0
                    
                y                                           = evnt_stim-4
                
                clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs',multi_class='ovr'))) # define model
                time_decod                                  = SlidingEstimator(clf, n_jobs=1)
        
                scores                                      = cross_val_multiscore(time_decod, x, y=y, cv = 3, n_jobs = 1) # crossvalidate
                scores                                      = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                
                savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                print('\nsaving '+ fscores_out + '\n')
                
                del(scores,x,y)
            del(find_stim,data_stim,evnt_stim)
        del(allevents,alldata)