# -*- coding: utf-8 -*-
"""
Created on Tue Apr 21 14:13:29 2020

@author: hesels
"""

import mne
import numpy as np
from scipy.io import (savemat,loadmat)
from tensorpac import EventRelatedPac


suj_list                                = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

cues                                    = ["pre","retro"]

for isub in range(len(suj_list)):
    
    sujname                             = suj_list[isub]
    fname                               = 'P:/3015079.01/data/'+ sujname +'/preproc/' + sujname + '_firstCueLock_ICAlean_finalrej.mat'
    eventName                           = 'P:/3015079.01/data/'+ sujname +'/preproc/' + sujname + '_firstCueLock_ICAlean_finalrej_trialinfo.mat'
    chan_name                           = 'F:/bil/pac/' + sujname + '.pac.chan.mat'

    print('\nloading '+fname)
    
    epochs                              = mne.read_epochs_fieldtrip(fname, None, data_name='dataPostICA_clean', trialinfo_column=0)
    allevents                           = loadmat(eventName)['index']
    pac_chan                            = np.squeeze(loadmat(chan_name)['pac_chan'])
    
    alldata                             = epochs.get_data() #Get all epochs as a 3D array.
    time_axis                           = epochs.times
    
    ## pick correct trials and time-window
    t1                                  = np.squeeze(np.where(np.round(time_axis,3) == np.round(-0.2,3)))
    t2                                  = np.squeeze(np.where(np.round(time_axis,3) == np.round(6,3)))
    time                                = np.squeeze(time_axis[t1:t2])
    
    for ncue in [0,1]:
        
        find_correct                    = np.squeeze(np.where((allevents[:,15] == 1) & (allevents[:,7]==ncue+1)))
        
        sf                              = 300
        x                               = alldata[:,pac_chan,t1:t2]
        x                               = x[find_correct,:,:]
        x                               = np.squeeze(np.mean(x,1))
        
        # define an ERPAC object
        p                               = EventRelatedPac(f_pha=[3, 5], f_amp=(5, 50, 1, 1))
        vec_amp                         = np.arange(5, 50, 1)[:-1]
        
        # extract phases and amplitudes
        pha                             = p.filter(sf, x, ftype='phase', n_jobs=1)
        amp                             = p.filter(sf, x, ftype='amplitude', n_jobs=1)
        
        # compute the erpac
        erpac                           = p.fit(pha, amp, method='gc', smooth=100, n_jobs=-1).squeeze()
        
        py_pac                          = {'powspctrm': erpac, 'freq':vec_amp, 'time':time}
        
        fname_out                       = 'F:/bil/pac/' + sujname + '.3t5Hz.gc.pac.'+ cues[ncue] +'.cue.maxchan.mat'        
        print('\nsaving '+fname_out+'\n')
        savemat(fname_out, {'py_pac':py_pac})
