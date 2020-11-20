%Template for PXXX_SYY_ZZ_info.mat
%This file needs to be stored in the EEG preprocessed data folder for each
%participant.
part.safe_ID=1705301714; %Participant safe ID, 10 digits (year, month, day, hour, minute)
part.number=16;%Number, needs to match particpant number (XXX)
part.session=1;%Number, needs to match session number (YY)
part.ID='EC'; %Participant ID,2 letters, need to match file ID
part.Bad_channel={'C6','T8','T7'}; %Names of electrodes presenting problems, separate them by ; (Case sensitive!!!) For instance: {'Fz';'POz'}.
part.ref_chan  = {'LM', 'RM'};%Allowed values: {'LM','RM'} (Default) / {'all'} (In case any of the mastoids presents problems)
part.layout='ActiCap64_MM_PO.lay';%Name of the layout file used in the EEG recording session
part.comment='CP6 T8 T7 high impedence, but nice signal. ';%Anything you believe is important do add
part.IAF=12.75 ;%Position of the peak (dB) 
part.IAFdB=8.18 ;%Height of the peak (dB) 
part.file_ID='P016_S01_EC_1705301714' ;%Prefix for acessing files 
