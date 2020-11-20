#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 09:44:35 2019

@author: heshamelshafei
"""

import os
if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np
from mne.decoding import (SlidingEstimator, LinearModel, cross_val_multiscore)

if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')

from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from scipy.io import (savemat,loadmat)

#"sub001","sub003","sub004","sub006","sub008","sub009","sub010",
#                                            "sub011","sub012",

suj_list                                = list(["sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])


lck_list                                = list(['1stcue.lock.broadband.centered',
                                                '1stcue.lock.theta.minus1f.centered',
                                                '1stcue.lock.alpha.minus1f.centered',
                                                '1stcue.lock.beta.minus1f.centered',
                                                '1stcue.lock.gamma.minus1f.centered'])
    
dcd_list                                = list(["pre.vs.retro","pre.task","retro.task"])


for isub in range(len(suj_list)):
    for ilock in range(len(lck_list)):
        
        suj                             = suj_list[isub]
        dir_data_in                     = 'P:/3015079.01/data/' + suj + '/preproc/'
        dir_data_out                    = 'D:/Dropbox/project_me/data/bil/decode/'
        
        ext_name                        = '.'+ lck_list[ilock]

        fname                           = dir_data_in + suj + ext_name + '.mat'
        print('\nHandling '+ fname+'\n')
        eventName                       = dir_data_in + suj + ext_name + '.trialinfo.mat'

        epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)

        big_events                       = loadmat(eventName)['index']

        big_data                         = epochs.get_data() #Get all epochs as a 3D array.
        big_data[np.where(np.isnan(big_data))] = 0

        time_axis                       = epochs.times
        
        vct_rt                          = big_events[:,13]
        median_rt                       = np.median(vct_rt)
        find_fast                       = np.where(vct_rt < median_rt)
        find_slow                       = np.where(vct_rt > median_rt)
        
        find_incorrect_pre_ori          = np.transpose(np.array(np.where((big_events[:,15] == 0) & (big_events[:,7] == 1) & (big_events[:,6] == 1))))
        find_incorrect_pre_frq          = np.transpose(np.array(np.where((big_events[:,15] == 0) & (big_events[:,7] == 1) & (big_events[:,6] == 2))))
        find_incorrect_rtr_ori          = np.transpose(np.array(np.where((big_events[:,15] == 0) & (big_events[:,7] == 2) & (big_events[:,6] == 1))))
        find_incorrect_rtr_frq          = np.transpose(np.array(np.where((big_events[:,15] == 0) & (big_events[:,7] == 2) & (big_events[:,6] == 2))))
        
        cap_pre_ori                     = np.shape(find_incorrect_pre_ori)[0]
        cap_pre_frq                     = np.shape(find_incorrect_pre_frq)[0]
        cap_rtr_ori                     = np.shape(find_incorrect_rtr_ori)[0]
        cap_rtr_frq                     = np.shape(find_incorrect_rtr_frq)[0]
        
        find_correct_pre_ori            = np.transpose(np.array(np.where((big_events[:,15] == 1) & (big_events[:,7] == 1) & (big_events[:,6] == 1))))
        find_correct_pre_frq            = np.transpose(np.array(np.where((big_events[:,15] == 1) & (big_events[:,7] == 1) & (big_events[:,6] == 2))))
        find_correct_rtr_ori            = np.transpose(np.array(np.where((big_events[:,15] == 1) & (big_events[:,7] == 2) & (big_events[:,6] == 1))))
        find_correct_rtr_frq            = np.transpose(np.array(np.where((big_events[:,15] == 1) & (big_events[:,7] == 2) & (big_events[:,6] == 2))))
        
        np.random.shuffle(find_correct_pre_ori)
        np.random.shuffle(find_correct_pre_frq)
        np.random.shuffle(find_correct_rtr_ori)
        np.random.shuffle(find_correct_rtr_frq)
        
        find_correct_pre_ori            = find_correct_pre_ori[0:cap_pre_ori]
        find_correct_pre_frq            = find_correct_pre_frq[0:cap_pre_frq]
        find_correct_rtr_ori            = find_correct_rtr_ori[0:cap_rtr_ori]
        find_correct_rtr_frq            = find_correct_rtr_frq[0:cap_rtr_frq]
        
        find_incorrect                  = np.concatenate((find_incorrect_pre_ori,find_incorrect_pre_frq,
                                                          find_incorrect_rtr_ori,find_incorrect_rtr_frq),axis=0)
        
        find_correct                    = np.concatenate((find_correct_pre_ori,find_correct_pre_frq,
                                                          find_correct_rtr_ori,find_correct_rtr_frq),axis=0)
        
        del(find_incorrect_pre_ori,find_incorrect_pre_frq,find_incorrect_rtr_ori,find_incorrect_rtr_frq)
        del(find_correct_pre_ori,find_correct_pre_frq,find_correct_rtr_ori,find_correct_rtr_frq)
        del(cap_pre_ori,cap_pre_frq,cap_rtr_ori,cap_rtr_frq)
        
        beh_list                        = list(["slow","fast","correct","incorrect"])
        
        for nbeh in range(len(beh_list)):
            
            if beh_list[nbeh]=="slow":
                indx = find_slow
            elif beh_list[nbeh] == "fast":
                indx = find_fast
            elif beh_list[nbeh]=="incorrect":
                indx = find_incorrect
            elif beh_list[nbeh]=="correct":
                indx = find_correct
            
            ## pick correct trials?
            alldata                         = np.squeeze(big_data[indx,:,:])
            allevents                       = np.squeeze(big_events[indx,:])
            ##
            
            del(indx)
            
    
            # how trialinfo matrix is organized:
            # 0            1 2   3 4    5     6     7   8       9       10     11   12   13      14          15
            # orig-code   target probe match task cue DurTar MaskCon DurCue color nbloc repRT repButton repCorrect
    
            for ifeat in [1,2]:
    
                x                           = alldata
                mini_sub                    = allevents
    
                if ifeat == 0:
                    # reto vs pre
                    find_trials             = np.where((mini_sub[:,0] >0))
                    y                       = mini_sub[:,7]-1
    
                elif ifeat == 1:
                    # pre ori - vs spa
                    find_trials             = np.where((mini_sub[:,0] < 13)) # pre are coded 11 and 12
                    mini_sub                = np.squeeze(mini_sub[find_trials,6])
                    y                       = mini_sub-1
    
                elif ifeat == 2:
                    # ret ori - vs spa
                    find_trials             = np.where((mini_sub[:,0] > 12)) # retro is coded 13
                    mini_sub                = np.squeeze(mini_sub[find_trials,6])
                    y                       = mini_sub-1
    
                fname_out                   = dir_data_out + suj + ext_name + '.decodingcue.' + dcd_list[ifeat] + '.'+beh_list[nbeh]+'.trials.auc.mat'
                
                fnd_x   = np.shape(np.where(y == 1))[1]
                fnd_y   = np.shape(np.where(y == 0))[1]
                chk     = np.min([fnd_x,fnd_y])
                
                if chk > 1:
                    if not os.path.exists(fname_out):
                        x                   = np.squeeze(x[find_trials,:,:])
    
                        # increased no. iterations cause for some reason it wasn't "congerging"
                        clf                 = make_pipeline(StandardScaler(),
                                                                LinearModel(LogisticRegression(solver='lbfgs',max_iter=250))) # define model
                        time_decod          = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')
                        scores              = cross_val_multiscore(time_decod, x, y, cv = 2, n_jobs = 1) # crossvalidate
                        scores              = np.mean(scores, axis=0) # Mean scores across cross-validation splits
    
                        print('\nsaving '+fname_out)
                        savemat(fname_out, mdict={'scores': scores,'time_axis':time_axis})
    
                        # clean up
                        del(scores,x,y,time_decod,fname_out,mini_sub)
        
                        print('\n')
                    
            del(alldata,allevents)
