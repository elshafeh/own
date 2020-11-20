# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:00:37 2020

@author: hesels
"""

import os
import mne
import numpy as np
from mne.decoding import (GeneralizingEstimator,SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,Vectorizer)
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)


suj_list                                                            = [1,2,3,4,5,6,7,8,9,10,
                                                   11,12,13,14,15,16,17,18,19,20,
                                                   21,22,23,24,25,26,27,28,29,
                                                   30,31,32,33,35,36,38,39,40,
                                                   41,42,43,44,46,47,48,49,
                                                   50,51]

freq_list                                                           = [1,2,3,4,5,6,7,8,9,10,
                                                                   11,12,13,14,15,16,17,18,19,20,
                                                                   21,22,23,24,25,26,27,28,29,30]

for ifreq in range(len(freq_list)):
    for isub in range(len(suj_list)):
        for ises in [1,2]:
            
            suj                                                     = suj_list[isub]
            
            fname                                                   = 'J:/temp/nback/data/tf/sub' + str(suj)+'.sess'+str(ises) +'.orig.'+str(freq_list[ifreq])+'Hz.mat'
            ename                                                   = 'J:/temp/nback/data/nback_' +str(ises) + '/data_sess' +str(ises) + '_s'+ str(suj)  + '_trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                            = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            # !! apply baseline !! #
            time_axis= np.arange(-1.5,2.02,0.02)
            b1 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))]
            b2 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(0,2)))]
            epochs_nback                                            = epochs_nback.apply_baseline(baseline=(b1,b2))
            
            alldata                                                 = epochs_nback.get_data()
            allevents                                               = loadmat(ename)['index'][:,[0,2,4]]  
            
            # !! exclude motor !! #
            trl                                                     = np.squeeze(np.where(allevents[:,2] ==0))
            
            alldata                                                 = np.squeeze(alldata[trl,:,:])
            allevents                                               = np.squeeze(allevents[trl,:])
            print('Handling '+ fname)
            
            for nback in [0,1,2]:
                
                find_nback                                          = np.where(allevents[:,0] == nback+4)
                
                if np.size(find_nback)>0:
                
                    data_nback                                      = np.squeeze(alldata[find_nback,:,:])
                    evnt_nback                                      = np.squeeze(allevents[find_nback,1])
                    
                    dir_out                                         = 'J:/temp/nback/data/sens_level_auc/cond/sub'
                    fscores_out                                     = dir_out + str(suj) + '.sess' + str(ises) + '.' + str(nback)+'back.'
                    #fscores_out                                     = fscores_out + str(freq_list[ifreq]) + 'Hz.istarget.bsl.dwn70.excl.auc.mat'
                    fscores_out                                     = fscores_out + str(freq_list[ifreq]) + 'Hz.isfirst.bsl.dwn70.excl.auc.mat'
                    
                    
                    if not os.path.exists(fscores_out):
                        
                        find_stim                                   = np.where((evnt_nback == 1))
                        
                        #if nback == 0:
                        #    find_stim                               = np.where((evnt_nback == 1)) # find other/target stimulus
                        #else:
                        #    find_stim                               = np.where((evnt_nback == 2)) # find 1st-stim(1) or target(2) stimulus
                            
                        if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                        
                            x                                       = data_nback
                            x[np.where(np.isnan(x))]                = 0
                            
                            y                                       = np.zeros(np.shape(evnt_nback)[0])
                            y[find_stim]                            = 1
                            y                                       = np.squeeze(y)
                            
                            clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                            time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                            scores                                  = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                            scores                                  = np.mean(scores, axis=0) # Mean scores across cross-validation splits
                            
                            print('\nsaving '+ fscores_out + '\n')
                            savemat(fscores_out, mdict={'scores': scores,'time_axis':time_axis})
                            
                            del(scores)
                            
#                            clf                                 = make_pipeline(Vectorizer(),StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # 
#                            print('\nfitting model for '+fcoef_out)
#                            clf.fit(x,y)
#                            print('extracting coefficients for '+fcoef_out)        
#                            for name in('patterns_','filters_'):
#                                coef                            = get_coef(clf,name,inverse_transform=True)
#                            
#                            savemat(fcoef_out, mdict={'scores': coef,'time_axis':time_axis})
#                            
#                            del(coef,x,y)