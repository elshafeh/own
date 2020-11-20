function [s_Nb_Frequencies, v_Frequency_Bins, s_Nb_Samples, s_Nb_Channels, s_Sampling_Frequency, s_Nb_Sample_PreStim, s_Wavelet_Type, s_Blackman_Window_Size,...
    s_DownSampling_Step, v_Channels_Label, v_Elec, v_Wavelet_m_parameter, v_Nb_Evt_per_Chan, m_Data_TF] = tf2mat(tf_file_name,varargin)


%% function
%[s_Nb_Frequencies, v_Frequency_Bins, s_Nb_Samples, s_Nb_Channels, s_Sampling_Frequency, s_Nb_Sample_PreStim, s_Wavelet_Type, s_Blackman_Window_Size, s_DownSampling_Step, v_Channels_Label, v_Elec, v_Wavelet_m_parameter, v_Nb_Evt_per_Chan, m_Data_TF]  =  tf2mat (tf_file_name,varargin)
%
% Read *tf file
% With
%       tf_file_name            : input filename '.tf' with the complete path
%
% OPTIONAL :
%          *  'save',  mat_name : to save all the results in a .mat file named mat_name.mat
%
%
%   s_Nb_Channels               : Total number of channels
%   v_Elec                      : Channel number in elec.dat
%   v_Channels_Label            : Channel Label
%   s_Nb_Samples                : Total number of samples in time domain
%   s_Nb_Sample_PreStim         : Number of samples for prestimulus
%   s_Sampling_Frequency        : Sampling Frequency (Hz)
%   s_Nb_Frequencies            : Total number of frequencies
%   s_Wavelet_Type              : Wavelet Type (1 : Morlet, 2 : Gabor)
%   v_Frequency_Bins            : Frequency bins values (Hz)
%   v_Wavelet_m_parameter       : m parameter for the Wavelet
%   s_Blackman_Window_Size       : Number of sample of Blackman window
%   s_DownSampling_Step         : DownSampling Step
%   v_Nb_Evt_per_Chan           : Number of averaged TF per Channel
%
%   m_Data_TF                   : Time Frequency Data (s_Nb_Channels x s_Nb_Frequencies x s_Nb_Samples)
%
%--------------------------------------------------------
% v 1.00 31-10-2009 Pierre-Emmanuel Aguera, Emmanuel Maby
% v 1.01 09-08-2010 Pierre-Emmanuel Aguera : change s_Wavelet_Window_Size to
% s_Blackman_Window_Size.
%%






flag_save = 0;
if ~isempty(varargin)
    for i_arg=1:length(varargin)
        if strcmpi(varargin{i_arg},'save');
            flag_save = 1;
            mat_name = varargin{i_arg+1};
        end
    end
end









%***************************************************
%             TF file Version
%***************************************************
fid=fopen(tf_file_name,'rb', 'b');
version = fread(fid, 1, 'uchar');
fclose(fid);

%**********************************
%           File Reading
%**********************************
if (version == 1)

    %********************************
    % Binary Version 1.0
    %********************************
    fid=fopen(tf_file_name,'rb', 'b');
    fseek(fid, 3, 'bof');
    Data_adress = fread(fid, 1, 'int32');
    fseek(fid, 32+10, 'bof');
    s_Nb_Channels = fread(fid, 1, 'int32');

    for i=1:s_Nb_Channels
        v_Elec(i) = fread(fid, 1, 'int16');
    end;
    for i=1:s_Nb_Channels
        for (j=1:5)
            v_Channels_Label(i,j) = fread(fid, 1, 'char');
            if (v_Channels_Label(i,j)==0)
                v_Channels_Label(i,j)=' ';
            end;
        end;
    end;
    
    
    v_Channels_Label        =   char(v_Channels_Label);

    s_Nb_Samples            =   fread(fid, 1, 'int32');
    s_Nb_Sample_PreStim     =   fread(fid, 1, 'int32');
    s_Sampling_Frequency    =   fread(fid, 1, 'float32');
    s_Nb_Frequencies        =   fread(fid, 1, 'int32');
    s_Wavelet_Type          =   fread(fid, 1, 'int16');
    clear v_Frequency_Bins;
    for i=1:s_Nb_Frequencies
        v_Frequency_Bins(i) = fread(fid, 1, 'float32');
    end;
    v_Wavelet_m_parameter   = fread(fid, s_Nb_Frequencies, 'float32');
    s_Blackman_Window_Size     = fread(fid, 1, 'float32');
    s_DownSampling_Step       = fread(fid, 1, 'int16');
    if (s_DownSampling_Step == 0) % From Text file 
        s_DownSampling_Step = 1;
    end;
    clear v_Nb_Evt_per_Chan;
    for i=1:s_Nb_Channels
        v_Nb_Evt_per_Chan(i) = fread(fid, 1, 'int32');
    end;

    %*********************************
    % End Reading of the Binary File V1.0
    %*********************************

elseif (version>=32)
    %********************************
    % Text Version 0.0
    %********************************
    printf('Erreur : version ou format de fichier non supporte.\n');
    return;
end;

m_Data_TF = zeros(s_Nb_Channels, s_Nb_Frequencies, s_Nb_Samples);

for num_chan = 1:s_Nb_Channels
    fseek(fid, Data_adress+((num_chan-1) * s_Nb_Frequencies * s_Nb_Samples * 4), 'bof');   % *4 pour taille float32
    for i=1:s_Nb_Frequencies
        m_Data_TF(num_chan,i,:) = fread(fid, [1,s_Nb_Samples], 'float32');
    end;
end;

fclose(fid);


% save data if necessary
if flag_save == 1
    save(mat_name ,'s_Nb_Frequencies', 'v_Frequency_Bins', 's_Nb_Samples', 's_Nb_Channels', 's_Sampling_Frequency', 's_Nb_Sample_PreStim', 's_Wavelet_Type', 's_Blackman_Window_Size', 's_DownSampling_Step', 'v_Channels_Label', 'v_Elec', 'v_Wavelet_m_parameter', 'v_Nb_Evt_per_Chan', 'm_Data_TF');
end
