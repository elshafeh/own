function mat2tf (tf_file_name, s_type_tfmoy, s_type_1_tfmoy, s_type_2_tfmoy, s_type_signal,m_Data_TF, v_Elec, v_Channels_Label, s_Nb_Sample_PreStim, s_Sampling_Frequency, s_Wavelet_Type, v_Frequency_Bins, v_Wavelet_m_parameter, s_Blackman_Window_Size, s_DownSampling_Step, v_Nb_Evt_per_Chan, s_corr_BL, s_smooth_tf, s_Avg_Chan)
%% function mat2tf (tf_file_name, s_type_tfmoy, s_type_1_tfmoy, s_type_2_tfmoy, s_type_signal,m_Data_TF, v_Elec, v_Channels_Label, s_Nb_Sample_PreStim, s_Sampling_Frequency, s_Wavelet_Type, v_Frequency_Bins, v_Wavelet_m_parameter, s_Blackman_Window_Size, s_DownSampling_Step, v_Nb_Evt_per_Chan, s_corr_BL, s_smooth_tf, s_Avg_Chan)
%
%
%
% Write *tf file
% With
%       tf_file_name            : Output *.tf file name 
%       s_type_tfmoy            : *.tf file type
%                                   = 1    elementary time-frequency       (avg.tf)
%                                   = 2    computed from evoked potentials (ep.tf)
%                                   = 3    phase                           (pl.tf)
%                                   = 6    statistics                      (XX.stat.tf)   
%                                   = 10   Synchrony                       (ph.tf)        
%
%       s_type_1_tfmoy          : *.tf file origin 
%                                   = 1    no specific operation
%                                   = 2    mean of tfmoy
%                                   = 3    median of tfmoy
%                                   = 4    difference between tfmoy
%                                   = 5    weighted mean of tfmoy
%                                   = 6    sum of tfmoy
%                                   = 7    Z of tfmoy
%                                   = 8    P of tfmoy
%                                   = 9    synchrony of tfmoy 
%
%       s_type_2_tfmoy          : If Statistics, statistics type
%                                   = 1    no statistic
%                                   = 2    F Quade
%                                   = 3    T Conover
%                                   = 4    Z sign
%                                   = 5    P sign
%                                   = 6    n + signe
%                                   = 7    n - signe
%                                   = 8    Z Wilcoxon
%                                   = 9    standard deviation
%                                   = 10   upper confidence bound
%                                   = 11   lower confidence bound
%                                   = 12   synchrony randomization
%                                   = 13   amplitude randomization
%
%       s_type_signal           :   Original Signal type
%                                   = 1     potential 
%                                   = 2     SCD 
%
%
%       m_Data_TF               : Time Frequency Data (s_Nb_Channels x s_Nb_Frequencies x s_Nb_Samples)
%       v_Elec                  : Channel number in elec.dat
%       v_Channels_Label        : Channel Label
%       s_Nb_Sample_PreStim     : Number of samples for prestimulus
%       s_Sampling_Frequency    : Sampling Frequency (Hz)
%       s_Wavelet_Type          : Wavelet Type (1 : Morlet, 2 : Gabor)
%       v_Frequency_Bins        : Frequency bins values (Hz)
%       v_Wavelet_m_parameter   : m parameter for the Wavelet
%       s_Blackman_Window_Size   : Number of samples of Blackman window 
%                                   default   => Number of samples of Blackman window (tf_nb_sample_blackman)
%                                   Smooth    => 0
%                                   Wilcoxon  => tf_nb_sample_blackman * Te_Orig_sig(ms) / tfstat_time_step (ms)
%
%       s_DownSampling_Step     : DownSampling Step
%       v_Nb_Evt_per_Chan       : Number of averaged TF par Channel
%       s_corr_BL               : Type of Baseline correction
%                                   = 0   None
%                                   = 1   LB_MOYENNE
%                                   = 2   LB_MEDIANE
%                                   = 3   LB_MOYENNE_NORM
%                                   = 4   LB_MEDIANE_NORM
%                                   = 5   LB_RMS_NORM
%                                   = 6   LB_MAX_NORM
%                                   = 101 LB_MOYENNE_FIC
%                                   = 102 LB_MEDIANE_FIC
%                                   = 103 LB_MOYENNE_NORM_FIC
%                                   = 104 LB_MEDIANE_NORM_FIC
%                                   = 105 LB_RMS_NORM_FIC
%                                   = 106 LB_MAX_NORM_FIC
%                                   = 201 LB_SIGNE_MOY
%                                   = 202 LB_SIGNE_MED
%                                   = 203 LB_SIGNE_TOUS
%
%       s_smooth_tf               : Smoothing TF Flag
%                                   = 0   None
%                                   = 1   Smoothing
%       s_Avg_Chan                : Grand-average across-channels  Flag
%                                   = 0   None
%                                   = 1   Grand-average
%
%
%
% v 1.00 02-11-2009 Pierre-Emmanuel Aguera, Emmanuel Maby
% v 1.01 09-08-2010 Pierre-Emmanuel Aguera : minor changes (variable names).
%%


%************************************
% Opening *.tf ELAN file.
fid=fopen(tf_file_name,'wb', 'b');

% 1st header
%-----------
version=1;
fwrite(fid, version, 'uchar');
entete = 0;
fwrite(fid, entete, 'int16');
adrdonnees = 0;
fwrite(fid, adrdonnees, 'int32');
type_data = 1;
fwrite(fid, type_data, 'int16');
dum=[0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
fwrite(fid, dum, 'char');

% 2nd header
%-----------

fwrite(fid, s_type_tfmoy, 'int16');
fwrite(fid, s_type_1_tfmoy, 'int16');
fwrite(fid, s_type_2_tfmoy, 'int16');
fwrite(fid, s_type_signal, 'int16');

type_event = 1;
fwrite(fid, type_event, 'int16');

s_Nb_Channels       = size(m_Data_TF,1);
s_Nb_Frequencies    = size(m_Data_TF,2);
s_Nb_Samples        = size(m_Data_TF,3);

fwrite(fid, s_Nb_Channels, 'int32');
fwrite(fid, v_Elec, 'int16');

for i=1:s_Nb_Channels
  fwrite(fid, v_Channels_Label{i,:}, '5*char');
end

fwrite(fid, s_Nb_Samples, 'int32');
fwrite(fid, s_Nb_Sample_PreStim, 'int32');
fwrite(fid, s_Sampling_Frequency, 'float32');
fwrite(fid, s_Nb_Frequencies, 'int32');
fwrite(fid, s_Wavelet_Type, 'int16');
fwrite(fid, v_Frequency_Bins, 'float32');
fwrite(fid, v_Wavelet_m_parameter, 'float32');
fwrite(fid, s_Blackman_Window_Size, 'float32');
fwrite(fid, s_DownSampling_Step, 'int16');
fwrite(fid, v_Nb_Evt_per_Chan, 'int32');
fwrite(fid, s_corr_BL, 'int16');
fwrite(fid, s_smooth_tf, 'int16');
fwrite(fid, s_Avg_Chan, 'int16');

% Writing header size values and data adress 
adrdonnees = ftell(fid);
entete = adrdonnees - 32;
fseek(fid, 1, 'bof');
fwrite(fid, entete, 'int16');
fwrite(fid, adrdonnees, 'int32');

%Repositioning the pointer on the end header
fseek(fid, adrdonnees, 'bof');


% Data
%-----
for i=1:s_Nb_Channels
  for j=1:s_Nb_Frequencies
    fwrite(fid, m_Data_TF(i, j, :), 'float32');
  end
end

fclose(fid);