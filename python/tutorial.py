#!/usr/bin/env python
# coding: utf-8

# In[20]:


#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jul 22 23:18:26 2019

@author: b1023336
"""

# haegenslab decoding tutorial

#%% init

import mne
from os import listdir
import fnmatch
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from mne.decoding import (SlidingEstimator, cross_val_multiscore, LinearModel, get_coef)
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import savemat
import warnings

warnings.filterwarnings('ignore')


data_path = '/Users/heshamelshafei/Desktop/' # path where data is
subs = listdir(data_path)                                                                   #list files in that folder
subs = fnmatch.filter(subs, '*mat')                                                         # take only mat files
nsubs = len(subs)

outfolder = '/Users/heshamelshafei/Desktop/'                       

subs_idx = range(0, nsubs)

#%% start with 1 subj
id = 1

#%% convert from ft to mne
filename        = data_path + subs[id]


# In[32]:
epochs          = mne.read_epochs_fieldtrip(filename, None, data_name = 'data', trialinfo_column = 0)

#%% define x and y
x               = epochs.get_data()
y               = epochs.events[:,2]

#%% define model
clf             = make_pipeline(StandardScaler(), LinearModel(LogisticRegression()))
time_decod      = SlidingEstimator(clf, n_jobs=1, scoring = 'roc_auc')

#%% crossvalidate
scores          = cross_val_multiscore(time_decod, x, y, cv = 4, n_jobs = 1)

# Mean scores across cross-validation splits
scores          = np.mean(scores, axis=0)

#%% plot result

fig, ax         = plt.subplots()
ax.plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
ax.axhline(.5, color='k', linestyle='--', label='chance')
ax.set_xlabel('Times')
ax.set_ylabel('AUC')  # Area Under the Curve
ax.legend()
ax.axvline(.0, color='k', linestyle='-')
ax.set_title('Sensor space decoding _ all chans')
#ax.fill_between(epochs.times, ci_up, ci_low, alpha=0.3)
plt.show()
    
#%%  get the coefficients

time_decod.fit(x, y)

y_hat = time_decod.decision_function(x)
y_hat_avg = np.mean(y_hat,axis=1) # this is getting rid of the time dimension
y_proba = time_decod.predict_proba(x)
y_proba_avg = np.mean(y_proba,axis=1) # this is getting rid of the time dimension
    
# coef = get_coef(time_decod,'patterns_',inverse_transform=True)


#%% plot coefficients

# evoked = mne.EvokedArray(coef, epochs.info, tmin=epochs.tmin)
# evoked.roc_auc=scores
# evoked.plot_joint()


# In[33]:


for i in range(len(y_hat_avg)):
    if y_hat_avg[i] <= 0:
        y_hat_avg[i] = 0
    elif y_hat_avg[i] > 0:
        y_hat_avg[i] = 1
print(y_hat_avg[:20])


# In[34]:


y[:20] - 1


# In[31]:


plt.hist(y_hat_avg,bins=50);
plt.show()
plt.hist(y_proba_avg[:,0],bins=100);


# In[6]:


plt.hist(y);


# In[7]:


# AUC curve
fig, ax = plt.subplots()
ax.plot(epochs.times, scores, label='score (crossval)', linewidth=2, color='black')
ax.axhline(.5, color='k', linestyle='--', label='chance')
ax.set_xlabel('Times')
ax.set_ylabel('AUC')  # Area Under the Curve
ax.legend()
ax.axvline(.0, color='k', linestyle='-')
ax.set_title('Sensor space decoding _ all chans')
#ax.fill_between(epochs.times, ci_up, ci_low, alpha=0.3)
plt.show()


# In[8]:


from mne.decoding import GeneralizingEstimator
#epochs.filter(1.,30.,fir_design='firwin')


# In[9]:


from mne.decoding import GeneralizingEstimator

clf         = make_pipeline(StandardScaler(), LogisticRegression(solver='lbfgs'))
time_gen    = GeneralizingEstimator(clf, scoring='roc_auc', n_jobs=1,verbose=True)

# Fit classifiers on the epochs where the stimulus was presented to the left.
# Note that the experimental condition y indicates auditory or visual
time_gen.fit(X=x, y=y)

scores = time_gen.score(X=x, y=y)


# In[10]:


fig, ax = plt.subplots(1)
im = ax.matshow(scores, vmin=0, vmax=1., cmap='RdBu_r', origin='lower',
                extent=epochs.times[[0, -1, 0, -1]])
ax.axhline(0., color='k')
ax.axvline(0., color='k')
ax.xaxis.set_ticks_position('bottom')
ax.set_xlabel('Testing Time (s)')
ax.set_ylabel('Training Time (s)')
ax.set_title('Generalization across time and condition')
plt.colorbar(im, ax=ax)
plt.show()


# In[11]:


y_proba = time_decod.predict_proba(x)


# Testing on other participant

# In[15]:


id = 0
filename = data_path + subs[id]


# In[16]:


epochs.times.shape


# In[17]:


epochs = mne.read_epochs_fieldtrip(filename, None, data_name = 'data', trialinfo_column = 0)

#%% define x and y

x1 = epochs.get_data()
y1 = epochs.events[:,2]

score_sub2 = time_decod.fit(x,y).score(x1,y1)


# In[ ]:


fig, ax = plt.subplots()
ax.plot(epochs.times, score_sub2, label='score (train - test)', linewidth=2, color='black')
ax.axhline(.5, color='k', linestyle='--', label='chance')
ax.set_xlabel('Times')
ax.set_ylabel('AUC')  # Area Under the Curve
ax.legend()
ax.axvline(.0, color='k', linestyle='-')
ax.set_title('Sensor space decoding _ all chans')
#ax.fill_between(epochs.times, ci_up, ci_low, alpha=0.3)
plt.show()

