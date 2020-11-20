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
    t1                              = np.squeeze(np.where(np.round(time_axis,3) == np.round(0,3)))
    t2                              = np.squeeze(np.where(np.round(time_axis,3) == np.round(6,3)))
    find_correct                    = np.squeeze(np.where(allevents[:,15] == 1))
    
    data                            = alldata[:,pac_chan,t1:t2]
    data                            = data[find_correct,:,:]
    data                            = np.squeeze(np.mean(data,1))
    
    p                               = Pac(idpac=(2, 2, 3), f_pha=(1, 10, 1, 1), f_amp=(8, 50, 2, 2))
    xpac                            = p.filterfit(300, data, n_perm=100, p=.05)
    pval                            = p.pvalues
        
    vec_pha                         = np.arange(1, 10, 1)[:-1]
    vec_amp                         = np.arange(8, 50, 2)[:-1]
    
    #    p.comodulogram(xpac.mean(-1), title=str(p), cmap='Spectral_r', vmin=0.,
    #                   pvalues=pval, levels=.05)
    #    
    #    p.show()
    
    py_pac                          = {'xpac': xpac, 'pval':pval, 'vec_pha':vec_pha,'vec_amp':vec_amp}
    
    fname_out                       = 'F:/bil/pac/' + sujname + '.KLD.ShuAmp.SubDivMean.100perm.pac.maxchan.mat'        
    print('\nsaving '+fname_out+'\n')
    savemat(fname_out, {'py_pac':py_pac})
    
    del(data,p,py_pac,alldata,allevents,pval,xpac,vec_pha,vec_amp,t1,t2,find_correct)

