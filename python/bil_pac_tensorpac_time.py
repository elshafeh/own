# -*- coding: utf-8 -*-
"""
Created on Tue Apr 21 14:13:29 2020

@author: hesels
"""

import mne
import numpy as np
import matplotlib.pyplot as plt

from scipy.io import (savemat,loadmat)
from tensorpac import Pac
from tensorpac import EventRelatedPac


suj_list                            = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

for isub in range(len(suj_list)):
    
    sujname                         = suj_list[isub]
    fname                           = 'P:/3015079.01/data/'+ sujname +'/preproc/' + sujname + '_firstCueLock_ICAlean_finalrej.mat'
    eventName                       = 'P:/3015079.01/data/'+ sujname +'/preproc/' + sujname + '_firstCueLock_ICAlean_finalrej_trialinfo.mat'
    chan_name                       = 'F:/bil/pac/' + sujname + '.pac.chan.mat'

    print('\nloading '+fname)
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='dataPostICA_clean', trialinfo_column=0)
    allevents                       = loadmat(eventName)['index']
    pac_chan                        = np.squeeze(loadmat(chan_name)['pac_chan'])
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    time_axis                       = epochs.times
    
    ## pick correct trials and time-window
    t1                              = np.squeeze(np.where(np.round(time_axis,3) == np.round(-1,3)))
    t2                              = np.squeeze(np.where(np.round(time_axis,3) == np.round(6,3)))
    find_correct                    = np.squeeze(np.where(allevents[:,15] == 1))
    
    time                            = np.squeeze(time_axis[t1:t2])
    
    sf                              = 300
    x                               = alldata[:,pac_chan,t1:t2]
    x                               = x[find_correct,:,:]
    x                               = np.squeeze(np.mean(x,1))
    
    # define an ERPAC object
    p                               = EventRelatedPac(f_pha=[3, 5], f_amp=(5, 100, 1, 1))
    vec_amp                         = np.arange(5, 100, 1)[:-1]
    
    # extract phases and amplitudes
    pha                             = p.filter(sf, x, ftype='phase', n_jobs=1)
    amp                             = p.filter(sf, x, ftype='amplitude', n_jobs=1)
    
    # implemented ERPAC methods
    methods                         = ['circular', 'gc']
    
    for n_m, m in enumerate(methods):
        
        # compute the erpac
        erpac                       = p.fit(pha, amp, method=m, smooth=100, n_jobs=-1).squeeze()
        
        py_pac                      = {'powspctrm': erpac, 'freq':vec_amp, 'time':time}
        
        fname_out                   = 'F:/bil/pac/' + sujname + '.3t5Hz.' + methods[n_m] +'.pac.maxchan.mat'        
        print('\nsaving '+fname_out+'\n')
        savemat(fname_out, {'py_pac':py_pac})
    
    
#        plt.figure(figsize=(16, 8))
#    for n_m, m in enumerate(methods):
#        # compute the erpac
#        erpac = p.fit(pha, amp, method=m, smooth=100, n_jobs=-1).squeeze()
#    
#        # plot
#        plt.subplot(len(methods), 1, n_m + 1)
#        p.pacplot(erpac, time, p.yvec, xlabel='Time (second)' * n_m,
#                  cmap='Spectral_r', ylabel='Amplitude frequency', title=p.method,
#                  cblabel='ERPAC', vmin=0., rmaxis=True)
#        plt.axvline(0., linestyle='--', color='w', linewidth=2)
#    
#    p.show()
    
    
    
    