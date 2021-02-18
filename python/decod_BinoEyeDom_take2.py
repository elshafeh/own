#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat May 26 21:23:27 2018

@author: b1023336
"""

# decod_BinoEyeDom_take2

from fieldtrip2mne import read_epoched
from sklearn.pipeline import (make_pipeline, Pipeline)
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import (LogisticRegression, SGDClassifier)
from sklearn.svm import SVC
#from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as lda
#from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis as qda
from mne.decoding import (SlidingEstimator, GeneralizingEstimator, get_coef,
                          cross_val_multiscore, LinearModel, Vectorizer, CSP,
                          UnsupervisedSpatialFilter)
from sklearn import svm
import matplotlib.pyplot as plt
import numpy as np
from os import listdir
#from sklearn.svm import LinearSVC
import mne
from scipy.io import savemat


#%% 

data_path = '/mnt/obob/staff/eelrassi/Bino_EyeDominance/take2/epoch_hilbert/'
outfolder = '/mnt/obob/staff/eelrassi/Bino_EyeDominance/take2/mne_decod/'
subs = listdir(data_path)
nsubs = len(subs)  
#sub_id = 0;
subs_idx = range(0, nsubs)

for id in subs_idx :

    filename = data_path + subs[id];


#% read epochs
#epochs = read_epoched(filename, 'data_bb')
    epochs = mne.read_epochs_fieldtrip(filename, None, data_name = 'data4mne', trialinfo_column = 11)
#epochs_beta = read_epoched(filename, 'data_beta')

    evt_id = {'Train/Left': 1, 'Train/Right': 2,
          'Test/Left' : 3, 'Test/Right' : 4}

    epochs.event_id = evt_id

#% create Xs and ys               

    X_train = epochs['Train'].get_data()
    y_train = epochs['Train'].events[:, 2]  
#
    X_test =  epochs['Test'].get_data()  
    y_test = epochs['Test'].events[:, 2]

#X = epochs.get_data()
#y = epochs.events[:,2]

#% decoding pipeline
#clf = make_pipeline(StandardScaler(), UnsupervisedSpatialFilter(SlidingEstimator) )      # here we specify the model    
#time_decod =  SlidingEstimator(clf,  n_jobs=1, scoring='roc_auc') 


    clf = make_pipeline(StandardScaler(),LinearModel(LogisticRegression()))      # here we specify the model    
    #time_decod =  SlidingEstimator(clf,  n_jobs=1, scoring='roc_auc') 
    time_decod_inv =  SlidingEstimator(clf,  n_jobs=1, scoring='roc_auc') 
    #time_decod_train =  SlidingEstimator(clf,  n_jobs=1, scoring='roc_auc') 
    #time_decod_test =  SlidingEstimator(clf,  n_jobs=1, scoring='roc_auc') 


#% decode!
    #scores = time_decod.fit(X_train, y_train).score(X_test, y_test)
## and decode in reverse direction
    scores_inv = time_decod_inv.fit(X_test, y_test).score(X_train, y_train)
# and crossval
    #scores_crossval_train = cross_val_multiscore(time_decod_train, X_train, y_train, cv=6, n_jobs=1)               # crossvalidate x6
    #scores_crossval_train = np.mean(scores_crossval_train, axis=0)

    #scores_crossval_test = cross_val_multiscore(time_decod_test, X_test, y_test, cv=6, n_jobs=1)               # crossvalidate x6
    #scores_crossval_test = np.mean(scores_crossval_test, axis=0)
    
    savemat(outfolder + subs[id][0:5] + '_scores_inv.mat', dict(scores_inv = scores_inv)) #, dict(scores_inv = scores_inv),)

#scores_crossval_all = cross_val_multiscore(time_decod, X, y, cv=6, n_jobs=1)               # crossvalidate x6
#scores_crossval_all = np.mean(scores_crossval_all, axis=0)
#%% and plot

# Plot
fig, ax = plt.subplots()
ax.plot(epochs.times, scores, linewidth=2, color='red', label='train mono / test bino')
ax.plot(epochs.times, scores_crossval_train, linewidth=2, color='purple', label='crossvalidation mono')
ax.plot(epochs.times, scores_crossval_test, linewidth=2, color='green', label='crossvalidation bino')
#ax.plot(epochs.times, scores_all, linewidth=2, color='black', label='crossvalidation all')
ax.plot(epochs.times, scores_inv, linewidth=2, color='blue', label='train bino / test mono')
ax.axhline(.5, color='k', linestyle='--') #, label='chance')
ax.set_xlabel('Times')
ax.set_ylabel('AUC')  # Area Under the Curve
ax.legend()
ax.axvline(0, color='k', linestyle='-')
ax.set_title('Sensor space decoding: alpha')
#ax.fill_between(epochs.times, ci_up, ci_low, alpha=0.3)
plt.show()

#%% get coefs
#coef = get_coef(time_decod, 'patterns_', inverse_transform=True)
#evoked = EvokedArray(coef, epochs.info, tmin=epochs.tmin)
#evoked.plot_joint()

#coef_inv = get_coef(time_decod_inv, 'patterns_', inverse_transform=True)
#evoked_inv = EvokedArray(coef_inv, epochs.info, tmin=epochs.tmin)
#evoked.plot_joint()