function [leadfield,combined_vol,combined_ses] = h_compute_meeg_leadfield(suj)

fname_in                                            = ['J:\temp\meeg\data/eegvol/' suj '.eegVolElecLead.mat'];
fprintf('\nLoading %50s\n',fname_in);
load(fname_in);

vol_eeg                                             = vol; clear vol leadfield grid;

fname_in                                            = ['J:\temp\meeg\data\headfield/' suj '.VolGrid.5mm.mat'];
fprintf('\nLoading %50s\n',fname_in);
load(fname_in);

vol_meg                                             = vol; clear vol;

x                                                   = 0;



