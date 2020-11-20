# -*- coding: utf-8 -*-
"""
Created on Mon Feb 10 15:15:00 2020

@author: hesels
"""

# -*- coding: utf-8 -*-
"""
Created on Sun Feb  2 13:35:48 2020

@author: hesels
"""

import os

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef,GeneralizingEstimator)

os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

suj_list                                                                    = [41,42,43,44,46,47,48,49,
                                                                       50,51]

#isub=1;ises=1;ifreq=1;

for isub in range(len(suj_list)):
    for ifreq in range(1,31):
        for ises in [0,1]:
        
            suj                                                             = suj_list[isub]
            
            fname                                                           = '/project/3015079.01/nback/vox_tf/sub' + str(suj)+ '.sess' +str(ises+1) + '.voxbrain.' + str(ifreq)+ 'Hz.mat'  
            ename                                                           = '/project/3015079.01/nback/vox_tf/sub' + str(suj)+ '.sess' +str(ises+1) + '.trialinfo.mat'
            print('Handling '+ fname)
                
            epochs_nback                                                    = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
            
            time_axis= np.arange(-1.5,2.02,0.02)
            b1 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(-0.5,2)))]
            b2 = epochs_nback.times[np.squeeze(np.where(np.round(time_axis,2) == np.round(0,2)))]
            
            t1 = np.squeeze(np.where(np.round(time_axis,2) == np.round(-1,2)))
            t2 = np.squeeze(np.where(np.round(time_axis,2) == np.round(2,2)))
            
            # apply baseline
            epochs_nback                                                    = epochs_nback.apply_baseline(baseline=(b1,b2))            
            alldata                                                         = epochs_nback.get_data() #Get all epochs as a 3D array.
            
            allevents                                                       = loadmat(ename)['index'][:,[0,2,4]]        
            allevents[:,0]                                                  = allevents[:,0]-4
            
            # exclude motor
            trl                                                             = np.squeeze(np.where(allevents[:,2] ==0))
            alldata                                                         = np.squeeze(alldata[trl,:,t1:t2])
            time_axis                                                       = np.squeeze(time_axis[t1:t2])
            allevents                                                       = np.squeeze(allevents[trl,:])
            
            # change trigerr values for 0-back
            allevents[np.where(allevents[:,0]==0),1]                        = allevents[np.where(allevents[:,0]==0),1]+1
            
            # remove nan
            alldata[np.where(np.isnan(alldata))] = 0
            
            # ~!~ decoding stimuli ~!~ #
            for nback in [0,1,2]:
                
                find_nback                                                  = np.where(allevents[:,0] == nback)
                
                if np.size(find_nback)>0:
                
                    data_nback                                              = np.squeeze(alldata[find_nback,:,:])
                    evnt_nback                                              = np.squeeze(allevents[find_nback,1])
                    
                    list_stim                                               = list(['first','target'])
                    
                    for nstim in [2]:
                        
                        dir_out                                             = '/project/3015079.01/nback/vox_auc/'
                        
                        fname_out                                           = dir_out + 'sub' + str(suj) + '.sess' + str(ises+1)  
                        fname_out                                           = fname_out+ '.voxbrain.' + str(nback) + 'back.'
                        fname_out                                           = fname_out + str(ifreq)+ 'Hz.decoding.' +list_stim[nstim-1]+ '.bsl.excl.bychan.auc.mat'
                        
                        fname_gen                                           = fname_out[0:np.size(fname_out)-5]
                        fname_gen                                           = fname_gen+'.timegen.mat'
                        
                        if not os.path.exists(fname_out):
                            
                            find_stim                                       = np.where((evnt_nback == nstim)) # target stimulus
                                
                            if np.size(find_stim)>1 and np.size(find_stim)<np.size(evnt_nback):
                                
                                number_chan                                 = np.shape(data_nback)[1]
                                number_sample                               = np.shape(data_nback)[2]
                                number_trial                                = np.shape(data_nback)[0]
                                
                                scores                                      = np.zeros((number_chan,number_sample))
                                scores_gen                                  = np.zeros((number_chan,number_sample,number_sample))
                                
                                for nchan in range(number_chan):
                                    
                                    print('\ndecoding auc channel '+ str(nchan) + ' out of ' +str(number_chan) + ' for '+ fname_out)
                                    
                                    x                                       = np.zeros((number_trial,1,number_sample))
                                    x[:,0,:]                                = data_nback[:,nchan,:]  
                                    
                                    y                                       = np.zeros(np.shape(evnt_nback)[0])
                                    y[find_stim]                            = 1
                                    y                                       = np.squeeze(y)
                                    
                                    clf                                     = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
                                    time_decod                              = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                                    tmp_sc                                  = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
                                    scores[nchan,:]                         = np.mean(tmp_sc, axis=0) # Mean scores across cross-validation splits
                                    
                                    #print('\ndecoding timegen channel '+ str(nchan) + ' out of ' +str(number_chan))
                                    #clf                                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
                                    #time_gen                                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
                                    #time_gen.fit(X=x, y=y)
                                    #scores_gen[nchan,:,:]                   = time_gen.score(X=x, y=y)
                                    
                                    del(tmp_sc,x,y)
                                
                                savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
                                print('\nsaving '+ fname_out + '\n')
                                
                                #savemat(fname_gen, mdict={'scores': scores_gen,'time_axis':time_axis})
                                #print('\nsaving '+ fname_gen + '\n')
            
            # ~!~ decoding conditions ~!~ #
            
#            ext_stim                                                    = "all"
#            find_stim                                                   = np.where(allevents[:,1] < 10)
#            
#            data_stim                                                   = np.squeeze(alldata[find_stim,:,:])
#            evnt_stim                                                   = np.squeeze(allevents[find_stim,0])
#            
#            # one decoding per session
#            nback =ises
#                
#            find_nback                                              = np.where(evnt_stim == nback)
#            
#            dir_out                                                 = 'P:/3015079.01/nback/vox_auc/'
#            fname_out                                               = dir_out + 'sub' + str(suj) + '.sess' + str(ises+1) + '.voxbrain.decoding.' + str(nback) + 'back.'
#            fname_out                                               = fname_out+ str(ifreq)+ 'Hz.lockedon.' +ext_stim+ '.bsl.excl.bychan.auc.mat'
#        
#            if np.size(find_nback)>0 and np.size(find_stim)>1 and np.size(find_nback)<np.size(evnt_stim):
#                if not os.path.exists(fname_out):
#                    
#                    number_chan                                     = np.shape(data_stim)[1]
#                    number_sample                                   = np.shape(data_stim)[2]
#                    number_trial                                    = np.shape(data_stim)[0]
#                    scores                                          = np.zeros((number_chan,number_sample))
#                    
#                    for nchan in range(number_chan):
#                        
#                        print('\ndecoding channel '+ str(nchan) + ' out of ' +str(number_chan))
#                    
#                        x                                           = np.zeros((number_trial,1,number_sample))
#                        x[:,0,:]                                    = data_stim[:,nchan,:]  
#                        x[np.where(np.isnan(x))]                    = 0
#                            
#                        y                                           = np.zeros(np.shape(evnt_stim)[0])
#                        y[find_nback]                               = 1
#                        y                                           = np.squeeze(y)
#                        
#                        clf                                         = make_pipeline(StandardScaler(), LinearModel(LogisticRegression(solver='lbfgs'))) # define model
#                        time_decod                                  = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
#                        
#                        tmp_sc                                      = cross_val_multiscore(time_decod, x, y=y, cv = 2, n_jobs = 1) # crossvalidate
#                        scores[nchan,:]                             = np.mean(tmp_sc, axis=0) # Mean scores across cross-validation splits
#                        
#                        del(tmp_sc,x,y)
#                        
#                        
#                    savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
#                    print('\nsaving '+ fname_out + '\n')
                            

                                