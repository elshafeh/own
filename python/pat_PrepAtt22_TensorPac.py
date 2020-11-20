"# -*- coding: utf-8 -*-
"""
Spyder Editor

"""
import numpy as np
import scipy
import joblib
import h5py
import tensorpac
import matplotlib.pyplot as plt
import scipy.io as sio

from tensorpac import Pac

#suj_list    = np.concatenate((np.arange(1,22), np.arange(8,18)), axis=0)
#gavg_pac    = np.empty([14,13,9,2],dtype=float) #suj * amp Hz * pha Hz
#gavg_pval   = gavg_pac


suj_list     = np.arange(2,22) # !! 
list_cue     = np.array(['RCnD','LCnD','NCnD'])

time1_list   = np.array([-1,0.2])
time1_wind   = 0.8

ix_suj      = -1;

for s in suj_list:

    ix_suj = ix_suj + 1
    ix_tst = 0

    for ncue in range(0,len(list_cue)):
    
        for nti in range(0,len(time1_list)):
        
            tbeg = time1_list[nti]
            tend = tbeg + time1_wind
    
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
    
            period_name     = nbeg+nend
            
            suj             = "yc" + str(s)
            ext_dir         = '/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/data/'
            mat_name        = ext_dir+'new_rama_data/'+suj+'.'+list_cue[ncue]+'.NewRama.1t20Hz.m800p2000msCov.audR.mat'
            mat_content     = h5py.File(mat_name,'r')
        
            print('Importing Phase Data for '+suj)
        
            ntrial      = len(mat_content['virtsens/trial'])
            trialen     = len(mat_content[mat_content['virtsens/trial'][0][0]])
            nchan       = len(mat_content[mat_content['virtsens/trial'][0][0]][0])
            time_axis   = np.array(mat_content[mat_content['virtsens/time'][0][0]])
            time_axis = np.round(time_axis,3)
            data        = np.empty([ntrial, nchan,trialen],dtype=float)
            
            for i in range(0,len(mat_content['virtsens/trial'])):
            
                data[:,:,:] = np.transpose(np.array(mat_content[mat_content['virtsens/trial'][i][0]]))
             
            t1  = float('%.3f'%(time1_list[nti]))
            t2  = float('%.3f'%(np.round(time1_list[nti]+time1_wind,1)))
            
            lm1 = np.int(np.where(time_axis==t1)[0])
            lm2 = np.int(np.where(time_axis==t2)[0])
                        
            data_pha    = data[:,:,range(lm1,lm2)]
            
            #del data
            
            mat_name    = ext_dir+'new_rama_data/'+suj+'.'+list_cue[ncue]+'.NewRama.50t120Hz.m800p2000msCov.audR.mat'
            mat_content = h5py.File(mat_name,'r')

            print('Importing Amplitude Data for '+suj)
            
            ntrial      = len(mat_content['virtsens/trial'])
            trialen     = len(mat_content[mat_content['virtsens/trial'][0][0]])
            nchan       = len(mat_content[mat_content['virtsens/trial'][0][0]][0])
            time_axis   = np.array(mat_content[mat_content['virtsens/time'][0][0]])
            time_axis   = np.round(time_axis,3)
            data        = np.empty([ntrial, nchan,trialen],dtype=float)
            
            for i in range(0,len(mat_content['virtsens/trial'])):
            
                data[:,:,:] = np.transpose(np.array(mat_content[mat_content['virtsens/trial'][i][0]]))
                        
            data_amp    = data[:,:,range(lm1,lm2)]
            
            #del data
            
            for n_method in range(1,6):
                
                for n_surr in range(3,4):
                    
                    for n_norm in range(0,2):
                
                        p           = Pac(idpac=(n_method, n_surr, n_norm), fpha=(7, 13, 1, 1), famp=(50, 115, 5, 5),
                            dcomplex='wavelet',width=7) #start, stop, width, step
                    
                        ix_tst = ix_tst+ 1
                        
                        #print('Calculating PAC for '+suj+' Test '+ str(ix_tst) + ' out of 8')
                        
                        vec_pha     = np.arange(7, 13, 1)[:-1]
                        vec_amp     = np.arange(50, 115, 5)[:-1]
                    
                        sf          = 600
                        n_perm      = 100

                        if n_norm==0 or n_method==4:
                            xpac   = p.filterfit(sf,data_pha, xamp=data_amp,axis=2, nperm=n_perm, get_pval=True)
                            pval   = 0
                            py_pac = {'xpac': xpac, 'pval': pval,'vec_pha':vec_pha,'vec_amp':vec_amp}
                        else:
                            xpac, pval  = p.filterfit(sf,data_pha, xamp=data_amp,axis=2, nperm=n_perm, get_pval=True)
                            py_pac      = {'xpac': xpac, 'pval': pval,'vec_pha':vec_pha,'vec_amp':vec_amp}

                        list_method = np.array(['MVL','KLD','HR','ndPAC','PhaSyn']) #The ndPAC uses a p-value computed as 1/nperm.
                        list_surr   = np.array(['SwPhAmp','SwAmp','ShuAmp','TLag'])
                        list_norm   = np.array(['NoNorm','SubMean','DivMean','SubDivMean','Zscore'])
                        
                        fname_out   = ext_dir + 'python_data/' + suj + '.' + list_cue[ncue] + '.' + period_name
                        fname_out   = fname_out + '.' + list_method[n_method-1] + '.' +list_surr[n_surr-1] + '.' + list_norm[n_norm] + '.100perm.mat'
                        
                        print('Saving '+fname_out)
                        
                        sio.savemat(fname_out, {'py_pac':py_pac})
                        
                        #xpac[pval>0.05] = 0
                        #gavg_pac[ix_suj,:,:,:] = np.mean(xpac,axis=2)
                        #gavg_pval[ix_suj,:,:,:] = np.mean(pval,axis=2)
                        #print('Done')
                        
                        del pval 
                        del xpac
    

#new_pac = np.mean(gavg_pac,axis=0)
#p.comodulogram(new_pac[:,:,1], title='Right AcX',cmap='gnuplot',vmin=0, vmax=0.5,plotas='contour', ncontours=10)
#p.comodulogram(new_pac[:,:,0], title='Left AcX',cmap='gnuplot',vmin=0, vmax=0.5,plotas='contour', ncontours=10)

#fname_out = '/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/data/frompython.mat'
#sio.savemat(fname_out, {'new_pac':new_pac})

#plt.subplot(2,1,1)
#plt.subplot(2,1,2)
#p.comodulogram(new_pac[:,:,1], title='Right AcX',vmin=0, vmax=2,cmap='Spectral_r', plotas='contour', ncontours=5)