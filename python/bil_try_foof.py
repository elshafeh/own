# -*- coding: utf-8 -*-
"""
Created on Wed Jun  2 15:18:34 2021

@author: hesels
"""

import os
if os.name != 'nt':
    os.chdir('/home/mrphys/hesels/.conda/envs/mne_final/lib/python3.5/site-packages/')

import mne
import numpy as np

from matplotlib import cm, colors, colorbar

# Import MNE, as well as the MNE sample dataset
from mne import io
from mne.datasets import sample
from mne.viz import plot_topomap
from mne.time_frequency import psd_welch

# FOOOF imports
from fooof import FOOOFGroup, FOOOF
from fooof.bands import Bands
from fooof.analysis import get_band_peak_fg
from fooof.plts.spectra import plot_spectrum


suj_list        = list(["sub001"])

for isub in range(len(suj_list)):

    suj         = suj_list[isub]
    fname       = 'P:/3015079.01/data/' + suj + '/preproc/' + suj + '_firstCueLock_ICAlean_finalrej.mat'
    epochs      = mne.read_epochs_fieldtrip(fname, None, data_name='dataPostICA_clean', trialinfo_column=0)
            
    spectra, freqs = psd_welch(epochs, fmin=1, fmax=40, tmin=1000, tmax=0,
                           n_overlap=150, n_fft=300)
    
    
    fg = FOOOFGroup(peak_width_limits=[1, 6], min_peak_height=0.15,
                peak_threshold=2., max_n_peaks=6, verbose=False)

    # Define the frequency range to fit
    freq_range = [1, 30]

    # Fit the power spectrum model across all channels
    fg.fit(freqs, spectra, freq_range)
    
    