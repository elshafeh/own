#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Virtual Data
"""
# Tools > preferences > IPython console > Graphics > Graphics backend > Backend: Automatic

import mne

from mne import io
from mne.connectivity import spectral_connectivity

import h5py
import numpy as np
import scipy.io as sio
from mne.time_frequency import tfr_morlet  # noqa
import matplotlib.pyplot as plt
import locale 
from mne.datasets import sample
from mne.preprocessing import create_ecg_epochs, create_eog_epochs

plt.ion()


locale.setlocale(locale.LC_ALL, "fr_FR")

mat_name        = 'raw/sub1.RawData4Decode.mat'
mat             = sio.loadmat(mat_name, squeeze_me=True, struct_as_record=False)


data            = mat['data_raw']
events          = mat['data_events']

events[np.where(events[:,2] < 1100),2]          = 1
events[np.where(events[:,2] > 1200),2]          = 3
events[np.where(events[:,2] > 4),2]             = 2

event_id = dict(unf=1, left=2, right=3)

info = mne.create_info(ch_names=tuple(mat['data_ch_names']),ch_types=mat['data_ch_type'],sfreq=mat['data_sfreq'][0])

tmin = mat['data_time_axe'][0]

epochs = mne.EpochsArray(data, info, events, tmin,event_id)


fmin, fmax = 3., 9.
sfreq = mat['data_sfreq'] # the sampling frequency
tmin = 0.0  # exclude the baseline period
con, freqs, times, n_epochs, n_tapers = spectral_connectivity(
    epochs, method='pli', mode='multitaper', sfreq=sfreq, fmin=fmin, fmax=fmax,
    faverage=True, tmin=tmin, mt_adaptive=False, n_jobs=1)


# freqs       = np.arange(1,40, 1)  # frequencies of interest
# n_cycles    = 2

# power, itc = tfr_morlet(epochs, freqs=freqs, n_cycles=n_cycles,return_itc=True,picks= [0,1,2,3])

# fig, axis = plt.subplots(2, 2)
# itc.plot([itc.ch_names.index('visR')], axes = axis[0], show=False)
# itc.plot([itc.ch_names.index('visR')], axes = axis[1], show=False)
# itc.plot([itc.ch_names.index('audL')], axes = axis[2], show=False)
# itc.plot([itc.ch_names.index('audR')], axes = axis[3], show=False)

# mne.viz.tight_layout()
# plt.show()

# (epochs.copy().pick_types(meg='grad')
#            .del_proj(0)
#            .plot( remove_dc=False))


"""
DS Data
"""

ds_file_name    = '/Users/heshamelshafei/Desktop/yc1.pat2.b1.thirdOrder.deljump.retraitOffset.ds'
ds_data         = mne.io.read_raw_ctf(ds_file_name)

"""
Sample Data
"""

#data_path = sample.data_path()
#raw_fname = data_path + '/MEG/sample/sample_audvis_raw.fif'
#raw = mne.io.read_raw_fif(raw_fname, preload=True)
#
##(raw.copy().pick_types(meg='mag')
##           .del_proj(0)
##           .plot(duration=60, n_channels=5, remove_dc=False))
##
##raw.plot_psd(tmax=np.inf, fmax=250)
#
#average_ecg = create_ecg_epochs(raw).average()
#print('We found %i ECG events' % average_ecg.nave)
#joint_kwargs = dict(ts_args=dict(time_unit='s'),
#                    topomap_args=dict(time_unit='s'))
#average_ecg.plot_joint(**joint_kwargs)
#
#average_eog = create_eog_epochs(raw).average()
#print('We found %i EOG events' % average_eog.nave)
#joint_kwargs = dict(ts_args=dict(time_unit='s'),
#                    topomap_args=dict(time_unit='s'))
#average_eog.plot_joint(**joint_kwargs)

fname   = data_path + '/MEG/sample/sample_audvis-ave.fif'
evoked  = mne.read_evokeds(fname, condition='Left Auditory',baseline=(None, 0))

# restrict the evoked to EEG and MEG channels
evoked.pick_types(meg=True, eeg=True, exclude=[])

# plot with bads
evoked.plot(exclude=[], time_unit='s')

print(evoked.info['bads'])

evoked.interpolate_bads(reset_bads=False, verbose=False)
evoked.plot(exclude=[], time_unit='s')

eog_events = mne.preprocessing.find_eog_events(raw)
n_blinks = len(eog_events)
# Center to cover the whole blink with full duration of 0.5s:
onset = eog_events[:, 0] / raw.info['sfreq'] - 0.25
duration = np.repeat(0.5, n_blinks)
raw.annotations = mne.Annotations(onset, duration, ['bad blink'] * n_blinks,
                                  orig_time=raw.info['meas_date'])
print(raw.annotations)  # to get information about what annotations we have
raw.plot(events=eog_events)  # To see the annotated segments.