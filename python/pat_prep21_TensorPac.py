#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr  3 11:37:22 2018

@author: heshamelshafei
"""

# -*- coding: utf-8 -*-
"""
Spyder Editor

"""

# !pip install tensorpac

import numpy as np
import scipy
import joblib
import h5py
import tensorpac
import matplotlib.pyplot as plt
import scipy.io as sio
import pickle
import math

from decimal import Decimal
from tensorpac import Pac # data = trials by time

suj_list     = np.array([1,2,3,4,8,9,10,11,12,13,14,15,16,17]) # !! 

time1_list   = np.array([-0.6,0.6])
time1_wind   = np.array([0.4,0.4])

ix_suj       = -1;

list_chan    = sio.loadmat('/Volumes/heshamshung/Fieldtripping6Dec2018/data/paper_data/prep21_sepvox_chan_list.mat', squeeze_me=True, struct_as_record=False)
list_chan    = list_chan['chan_list']
list_cue     = ['NCnD','LCnD','RCnD']

for s in suj_list:
    
    suj                         = "yc" + str(s)
    
    ext_dir                     = '/Volumes/heshamshung/Fieldtripping6Dec2018/data/paper_data/'
    
    mat_name                    = ext_dir+suj+'.CnD.prep21.maxAVMsepVoxels.1t20Hz.m800p2000msCov.mat'
    low_freq                    = h5py.File(mat_name,'r')
    
    mat_name                    = ext_dir+suj+'.CnD.prep21.maxAVMsepVoxels.50t120Hz.m800p2000msCov.mat'
    high_freq                   = h5py.File(mat_name,'r')
    
    ntrial                      = len(low_freq['virtsens/trial'])
    trialen                     = len(low_freq[low_freq['virtsens/trial'][0][0]])
    nchan                       = len(low_freq[low_freq['virtsens/trial'][0][0]][0])
    time_axis                   = np.array(low_freq[low_freq['virtsens/time'][0][0]])
    time_axis                   = np.round(time_axis,3)
    low_freq_data               = np.empty([ntrial, nchan,trialen],dtype=float)
    high_freq_data              = np.empty([ntrial, nchan,trialen],dtype=float)
    
    trial_info                  = np.round(np.array(low_freq['virtsens/trialinfo'][0]-1000)/100)
    
    print('Importing Phase and Amplitude Data for '+suj)
                
    for i in range(0,ntrial):
        
        low_freq_data[:,:,:]    = np.transpose(np.array(low_freq[low_freq['virtsens/trial'][i][0]]))
        high_freq_data[:,:,:]   = np.transpose(np.array(high_freq[high_freq['virtsens/trial'][i][0]]))
    
    chan_interest               = np.array([10,11,12,13,14,20,21,22,23,24,15,16,17,18,19,25,26,27,28,29])
    
    list_method                 = np.array(['MVL','KLD','HR','ndPAC','PhaSyn']) #The ndPAC uses a p-value computed as 1/nperm.
    list_surr                   = np.array(['NoSurr','SwPhAmp','SwAmp','ShuAmp','TLag'])
    list_norm                   = np.array(['NoNorm','SubMean','DivMean','SubDivMean','Zscore'])
    
    for n_method in np.array([1,2,3,5]): 
        for ncue in range(0,3):
            for nti in range(0,len(time1_list)):
                
                pha_beg     = 1
                pha_end     = 20
                pha_stp     = 2
                
                amp_beg     = 40
                amp_end     = 120
                amp_stp     = 5
                
                vec_pha     = np.arange(pha_beg, pha_end, pha_stp)[:-1]
                vec_amp     = np.arange(amp_beg, amp_end, amp_stp)[:-1]
                
                data_pac    = np.empty([len(chan_interest), len(vec_amp),len(vec_pha)],dtype=float)
                data_pac    = np.empty([len(chan_interest), len(vec_amp),len(vec_pha)],dtype=float)
                
                for xi_chan in range(0,len(chan_interest)):
                
                    tbeg        = time1_list[nti]
                    tend        = tbeg + time1_wind[nti]
            
                    if tbeg<0:
                        nbeg = 'm'+np.str(np.round(np.abs(tbeg)*1000))
                        nbeg = nbeg.rstrip('0').rstrip('.')
                    else:
                        nbeg = 'p'+np.str(np.round(np.abs(tbeg)*1000))
                        nbeg = nbeg.rstrip('0').rstrip('.')
                    
                    if tend<0:
                        nend = 'm'+np.str(np.round(np.abs(tend)*1000))
                        nend = nend.rstrip('0').rstrip('.')
                    else:
                        nend = 'p'+np.str(np.round(np.abs(tend)*1000))
                        nend = nend.rstrip('0').rstrip('.')   
            
                    period_name = nbeg+nend
                    
                    t1          = float('%.3f'%(time1_list[nti]))
                    t2          = float('%.3f'%(np.round(time1_list[nti]+time1_wind[nti],1)))
                    
                    lm1         = np.int(np.where(time_axis==t1)[0])
                    lm2         = np.int(np.where(time_axis==t2)[0])
                    
                    data_pha    = np.squeeze(low_freq_data[np.where(trial_info == ncue),chan_interest[xi_chan],:])
                    data_pha    = data_pha[:,range(lm1,lm2)]
                    
                    data_amp    = np.squeeze(high_freq_data[np.where(trial_info == ncue),chan_interest[xi_chan],:])
                    data_amp    = data_amp[:,range(lm1,lm2)]
                    
                    data_pha    = data_pha - np.mean(data_pha,0)
                    data_amp    = data_amp - np.mean(data_amp,0)
                    
                    n_surr      = 1
                    n_norm      = 3

                    p           = Pac(idpac=(n_method, n_surr, n_norm), fpha=(pha_beg, pha_end, pha_stp, pha_stp), famp=(amp_beg, amp_end, amp_stp, amp_stp),
                        dcomplex='wavelet',width=7) # start, stop, width, step
                    
                    sf          = 600
                    n_perm      = 200
                    
                    xpac        = p.filterfit(sf,data_pha, xamp=data_amp,axis=1, nperm=n_perm, get_pval=True,get_surro=True,njobs=1)
                    xpac        = xpac[0]
                    #xpac            = 0.5 * (np.log((1+xpac)/(1-xpac)))
                    xpac        = np.mean(xpac,-1)
                    
                    data_pac[xi_chan,:,:]   = xpac 
                    #data_pval[xi_chan,:,:]  = pval 
                    #data_surr[xi_chan,:,:]  = xsurr
                    
                    del xpac
                    
                
                fname_out       = ext_dir + suj + '.' + list_cue[ncue] + '.' + period_name
                fname_out       = fname_out + '.' + list_method[n_method-1] + '.' +list_surr[n_surr] + '.' + list_norm[n_norm-1] + '.NonZTransMinEvokedSepTensorPac.mat'
                
                print('Saving '+fname_out)
                
                py_pac          = {'powspctrm': data_pac,'time':vec_pha,'freq':vec_amp,'label':list_chan[chan_interest],'dimord':'chan_freq_time'}
                
                sio.savemat(fname_out, {'py_pac':py_pac})
                
                del py_pac 
                del data_pac
    
    del low_freq_data       
    del high_freq_data   
             
#for n_surr in range(0,1):
#for n_norm in range(0,1): #range(0,5):
  
#if n_norm==0 or n_method==4:
#pval        = 0
#py_pac      = {'xpac': xpac, 'pval': pval,'vec_pha':vec_pha,'vec_amp':vec_amp,'trialinfo':trial_info,'label':list_chan}
#else:
#    xpac, pval  = p.filterfit(sf,data_pha, xamp=data_amp,axis=2, nperm=n_perm, get_pval=True)

#fname_out   = ext_dir + suj + '.' + list_cue[ncue] + '.' + period_name
#fname_out   = fname_out + '.' + list_method[n_method-1] + '.' +list_surr[n_surr-1] + '.' + list_norm[n_norm] + '.tensorpac200perm.pckl'

#f           = open('store.pckl', 'wb')
#pickle.dump(py_pac, f)
#f.close()            
#xpac[pval>0.05] = 0
#gavg_pac[ix_suj,:,:,:] = np.mean(xpac,axis=2)
#gavg_pval[ix_suj,:,:,:] = np.mean(pval,axis=2)
#print('Done')

#new_pac = np.mean(gavg_pac,axis=0)
#p.comodulogram(new_pac[:,:,1], title='Right AcX',cmap='gnuplot',vmin=0, vmax=0.5,plotas='contour', ncontours=10)
#p.comodulogram(new_pac[:,:,0], title='Left AcX',cmap='gnuplot',vmin=0, vmax=0.5,plotas='contour', ncontours=10)

#fname_out = '/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/data/frompython.mat'
#sio.savemat(fname_out, {'new_pac':new_pac})

#plt.subplot(2,1,1)
#plt.subplot(2,1,2)
#p.comodulogram(new_pac[:,:,1], title='Right AcX',vmin=0, vmax=2,cmap='Spectral_r', plotas='contour', ncontours=5)