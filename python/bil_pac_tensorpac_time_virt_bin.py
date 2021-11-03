# -*- coding: utf-8 -*-
"""
Created on Tue Apr 21 14:13:29 2020

@author: hesels
"""


import os
# if os.name != 'nt':
#     os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')
    
import mne
import numpy as np
from scipy.io import (savemat,loadmat)
from tensorpac import EventRelatedPac

# if os.name != 'nt':
#     os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/')
    

suj_list                                        = list(["sub001","sub003","sub004","sub006","sub008","sub009","sub010",
                                            "sub011","sub012","sub013","sub014","sub015","sub016","sub017",
                                            "sub018","sub019","sub020","sub021","sub022","sub023","sub024",
                                            "sub025","sub026","sub027","sub028","sub029","sub031","sub032",
                                            "sub033","sub034","sub035","sub036","sub037"])

for isub in range(len(suj_list)):
    
    suj                                         = suj_list[isub]
    
    dir_data_in                                 = 'P:/3015079.01/data/' + suj + '/virt/'
    dir_data_out                                = 'P:/3015079.01/data/' + suj + '/pac/'
    ext_virtual                                 = 'wallis'
    
    fname                                       = dir_data_in + suj+'.virtualelectrode.' +ext_virtual +'.mat'
    eventName                                   = 'P:/3015079.01/data/' + suj + '/preproc/' + suj  + '_firstCueLock_ICAlean_finalrej_trialinfo.mat'
    binName                                     = 'P:/3015079.01/data/' + suj + '/tf/' + suj  + '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'
    
    print('\nHandling '+ fname)
    print('\nHandling '+ eventName+'\n')
    
    epochs                                      = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)

    allevents                                   = loadmat(eventName)['index']
    alldata                                     = epochs.get_data() #Get all epochs as a 3D array.
    time_axis                                   = epochs.times
    
    # pick correct trials
    find_correct                                = np.where(allevents[:,15] == 1)
    alldata                                     = np.squeeze(alldata[find_correct,:,:])
    allevents                                   = np.squeeze(allevents[find_correct,:])
        
    bin_index                                   = loadmat(binName)['bin_index']-1
    
    for nbin in [0,4]:
    
        ## pick bin trials and time-window
        
        find_correct                            = bin_index [:,nbin]
        t1                                      = np.squeeze(np.where(np.round(time_axis,3) == np.round(-1,3)))
        t2                                      = np.squeeze(np.where(np.round(time_axis,3) == np.round(6,3)))
        
        time                                    = np.squeeze(time_axis[t1:t2])
        
        sf                                      = 300
        
        for nchan in range(np.shape(alldata)[1]):
            for nlow in [2]:
                
                nwidth                          = 4
                
                x                               = np.squeeze(alldata[:,:,t1:t2])
                x                               = np.squeeze(x[find_correct,:,:])
                x                               = np.squeeze(x[:,nchan,:])
                            
                # define an ERPAC object
                p                               = EventRelatedPac(f_pha=[nlow, nlow+nwidth], f_amp=(5, 50, 1, 1))
                vec_amp                         = np.arange(5, 50, 1)[:-1]
                
                # extract phases and amplitudes
                pha                             = p.filter(sf, x, ftype='phase', n_jobs=1)
                amp                             = p.filter(sf, x, ftype='amplitude', n_jobs=1)
                
                # implemented ERPAC methods
                methods                         = ['gc']
                
                for n_m, m in enumerate(methods):
                    
                    fname_out                   = dir_data_out + suj + '.'+ ext_virtual + '.' +str(nlow) + 't'+ str(nlow+nwidth)+'Hz'
                    fname_out                   = fname_out + '.chan' +str(nchan+1) + '.'+ methods[n_m] + '.bin' +str(nbin+1) +'.pac.mat'  
                    
                    if not os.path.exists(fname_out):
                        # compute the erpac
                        erpac                   = p.fit(pha, amp, method=m, smooth=100, n_jobs=-1).squeeze()
                        py_pac                  = {'powspctrm': erpac, 'freq':vec_amp, 'time':time}
                              
                        print('\nsaving '+fname_out+'\n')
                        savemat(fname_out, {'py_pac':py_pac})
                    else:
                        print(fname_out+' already exists\n')

