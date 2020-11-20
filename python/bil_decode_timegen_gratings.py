import mne
import fnmatch
import warnings
import numpy as np
import matplotlib.pyplot as plt
import scipy
from os import listdir
from scipy.io import loadmat
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
from scipy.io import savemat
from mne.decoding import GeneralizingEstimator

dir_data                            = '/Users/heshamelshafei/Dropbox/project_me/bil/meg/data/'

suj_list                            = list([1,3,4,8,9,10,11,12,13,14])
dcd_list                            = list(["ORI","FREQ","COL"])

all_scores                          = np.zeros((len(suj_list),len(dcd_list),200,200))

for isub in range(len(suj_list)):
    
    if suj_list[isub] < 10:
        suj                         = 'sub00' + str(suj_list[isub])
    elif suj_list[isub] >= 10:
        suj                         = 'sub0' + str(suj_list[isub])
    
    print('\nHandling '+ suj+'\n')
    
    fname                           = dir_data + suj + '/preproc/' + suj + '_gratinglock_dwnsample100Hz.mat'
    eventName                       = dir_data + suj + '/preproc/' + suj + '_gratingLock_trialinfo.mat'
    
    epochs                          = mne.read_epochs_fieldtrip(fname, None, data_name='data', trialinfo_column=0)
    allevents                       = loadmat(eventName)['index']
    
    alldata                         = epochs.get_data() #Get all epochs as a 3D array.
    
    print('\n')
    
    for ifeat in range(len(dcd_list)):
        
        x                           = alldata
        
        if ifeat == 0:
            # orientation
            mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] < 200),1])
            mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] > 200),3])
            y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
            y[np.where(y < 80)]     = 0
            y[np.where(y > 80)]     = 1
            
        elif ifeat == 1:
            # frequeny
            mini_trg                = np.transpose(allevents[np.where(allevents[:,-1] < 200),2])
            mini_prb                = np.transpose(allevents[np.where(allevents[:,-1] > 200),4])
            y                       = np.concatenate((mini_trg,mini_prb),axis = 0)
            y[np.where(y < 0.4)]    = 0
            y[np.where(y > 0.4)]    = 1
            
        elif ifeat == 2:
            # colour
            y                       = allevents[:,11]
            y[np.where(y == 1)]     = 0
            y[np.where(y == 2)]     = 1
            
        chk                         = len(np.unique(y))
        
        if chk == 2:
            

            indx                    = 15
                
            find_trials             = np.where(allevents[:,indx]==1)
            
            time_axes               = epochs.times
            lm_time1                = np.squeeze(np.where(time_axes == -1))
            lm_time2                = np.squeeze(np.where(time_axes == 1))
            
            x                       = np.squeeze(x[find_trials,:,lm_time1:lm_time2])
            y                       = np.squeeze(y[find_trials])

            clf                     = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
            time_gen                = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)
            
            # Fit classifiers on the epochs where the stimulus was presented to the left.
            # Note that the experimental condition y indicates auditory or visual
            time_gen.fit(X=x, y=y)
            scores                  = time_gen.score(X=x, y=y)
            
            all_scores[isub,ifeat,:,:] = scores
            
            print('done\n')
            
            del(scores,x,y)
            
fig, ax         = plt.subplots(1)
ifeat           = 0
tmp             = np.mean(all_scores[:,ifeat,:,:],axis = 0)
scores          = tmp
im              = ax.matshow(scores, vmin =0, vmax = 1, cmap='RdBu_r', origin='lower',extent=epochs.times[[0, -1, 0, -1]])
ax.axhline(0., color='k')
ax.axvline(0., color='k')
ax.set_ylim([-0.2,1])
ax.set_xlim([-0.2,1])
ax.xaxis.set_ticks_position('bottom')
ax.set_ylabel('Training Time (s)')
ax.set_xlabel('Testing Time (s)')
ax.set_title('Generalization ' + dcd_list[ifeat])
plt.show()
plt.colorbar(im, ax=ax)

fig, ax         = plt.subplots(1)
ifeat           = 1
tmp             = np.mean(all_scores[:,ifeat,:,:],axis = 0)
scores          = tmp
im              = ax.matshow(scores, vmin =0, vmax = 1, cmap='RdBu_r', origin='lower',extent=epochs.times[[0, -1, 0, -1]])
ax.axhline(0., color='k')
ax.axvline(0., color='k')
ax.set_ylim([-0.2,1])
ax.set_xlim([-0.2,1])
ax.xaxis.set_ticks_position('bottom')
ax.set_ylabel('Training Time (s)')
ax.set_xlabel('Testing Time (s)')
ax.set_title('Generalization ' + dcd_list[ifeat])
plt.show()
plt.colorbar(im, ax=ax)

fig, ax         = plt.subplots(1)
ifeat           = 2
tmp             = np.mean(all_scores[:,ifeat,:,:],axis = 0)
scores          = tmp
im              = ax.matshow(scores, vmin =0, vmax = 1, cmap='RdBu_r', origin='lower',extent=epochs.times[[0, -1, 0, -1]])
ax.axhline(0., color='k')
ax.axvline(0., color='k')
ax.set_ylim([-0.2,1])
ax.set_xlim([-0.2,1])
ax.xaxis.set_ticks_position('bottom')
ax.set_ylabel('Training Time (s)')
ax.set_xlabel('Testing Time (s)')
ax.set_title('Generalization ' + dcd_list[ifeat])
plt.show()
plt.colorbar(im, ax=ax)