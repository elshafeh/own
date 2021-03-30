#!/home/brainrhythms/hesels/.conda/envs/mne_uwu/bin/ python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  3 15:34:08 2021

@author: hesels
"""

import os
import sys

#os.chdir("/home/brainrhythms/hesels/.conda/envs/mne_uwu/lib/python3.8/site-packages/")
  
import mne
import numpy as np

from sklearn.pipeline import (make_pipeline)
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import (LogisticRegression)

from mne.decoding import (SlidingEstimator,LinearModel)
from scipy.io import (savemat,loadmat)

suj_list                                                = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

for isub in range(len(suj_list)):

    suj                                                 = suj_list[isub]

    cue_list                                            = list(["1stcue","2ndcue"])
    dcd_list                                            = list(["pre.task","retro.task"])
    band_list                                           = list(["theta","alpha","beta"])
    
    dir_data_in                                         = '/project/3015079.01/data/' + suj + '/preproc/'
    dir_data_tf                                         = '/project/3015079.01/data/' + suj + '/tf/'
    dir_data_ou                                         = '/project/3015079.01/data/' + suj + '/decode/'
    
    
    for icue in range(len(cue_list)): 
    
        ext_name                                        = '.' + cue_list[icue] + '.lock.broadband.centered'
    
        fname                                           = dir_data_in + suj + ext_name + '.mat'
        print('\nHandling '+ fname+'\n')
        eventName                                       = dir_data_in + suj + ext_name + '.trialinfo.mat'
        
        epochs                                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
        epochs                                          = epochs.apply_baseline(baseline=(-0.2,-0.1))
        
        broad_events                                    = loadmat(eventName)['index']
        broad_data                                      = epochs.get_data() #Get all epochs as a 3D array.
        broad_data[np.where(np.isnan(broad_data))]      = 0
        time_axis                                       = epochs.times
        
        if icue == 0:
            # pre cue
            find_trials                                 = np.where((broad_events[:,0] < 13)) # pre are coded 11 and 12
        else:
            find_trials                                 = np.where((broad_events[:,0] > 12))
            
        X_all                                           = np.squeeze(broad_data[find_trials,:,:])
        y_all                                           = np.squeeze(broad_events[find_trials,6]) - 1
        
        for nband in range(len(band_list)):
                
                binfile                                 = dir_data_tf + suj + '.' + cue_list[icue] + '.lock.allbandbinning.' + band_list[nband] + '.band.prestim.window.index.mat'
                print('\nloading'+ binfile+'\n')
                bin_index                               = loadmat(binfile)['bin_index']
                bin_index                               = bin_index-1
                
                n_trials, n_bins                        = bin_index.shape
                n_shuffle                               = 10
                shuffle_matrix                          = np.arange(n_trials)
    
                for nshu in range(n_shuffle):
                    
                    find_shuff                          = 0
                    n_attempt                           = 0
                    
                    while find_shuff != 1:
                        
                        np.random.shuffle(shuffle_matrix)
                    
                        len_trl_train                   = np.int(np.round(len(shuffle_matrix)/n_shuffle) * (n_shuffle-1))
                        len_trl_test                    = np.int(np.round(len(shuffle_matrix)/n_shuffle) * 1)
                        
                        index_train                     = np.unique(bin_index[shuffle_matrix[0:len_trl_train],:])
                        
                        X_train                         = np.squeeze(X_all[index_train,:,:])
                        y_train                         = np.squeeze(y_all[index_train])
                        
                        check_shuffle                   = 0
                        
                        for nb in [0,4]:
                            t1                          = np.int(len_trl_train+1)
                            t2                          = np.int(t1+len_trl_test)
                            index_train                 = bin_index[shuffle_matrix[t1:t2],nb]
                            y_test                      = np.squeeze(y_all[index_train])
                            check_shuffle               = check_shuffle + len(np.unique(y_test))
                            
                        if check_shuffle == 4:
                            find_shuff              = 1
                            print('found a good shuffle')
                        else:
                            n_attempt += 1
                            print('still looking for a good shuffle, attempt #' + str(n_attempt))
                    
                    for nbin in [0,4]: #range(n_bins):
                        
                        fname_out                       = dir_data_ou + suj + '.' + cue_list[icue] + '.lock.decoding.' + dcd_list[icue] + '.' + band_list[nband] 
                        fname_out                       = fname_out + '.bin' + str(nbin+1) + '.' + str(n_shuffle) + 'shuffle' + str(nshu+1) + '.crossone.mat'
                                            
                        if not os.path.exists(fname_out):
                            i1                          = np.int(len_trl_train+1)
                            i2                          = np.int(i1+len_trl_test)
        
                            index_train                 = bin_index[shuffle_matrix[i1:i2],nbin]
                            
                            X_test                      = np.squeeze(X_all[index_train,:,:])
                            y_test                      = np.squeeze(y_all[index_train])
                            
                            class_check                 = np.unique(y_test)
    #                        print('nb events found in bin' + str(nbin+1) + ' test data: '+str(len(class_check)))
                                                        
                            print('\nbuilding model')
                            clf                     = make_pipeline(StandardScaler(),LinearModel(LogisticRegression(max_iter = 2000)))      # here we specify the model
                            time_decod_inv          = SlidingEstimator(clf,  n_jobs=1, scoring='roc_auc') 
                            
                            print('scoring')
                            scores                  = time_decod_inv.fit(X_train, y_train).score(X_test, y_test)
                            
                            print('\nsaving '+fname_out)
                            savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})