function h_fieldtrip2ep(filename_out,avg)

% Input:
% filename_out = name of outpuet ep file
% avg = output of ft_timelockanalysis

Fs = 600;

lm_z                = find(round(avg.time,3)==0);               % find zero
s_Nb_Sample_PreStim = (avg.time(lm_z) - avg.time(1)) * Fs ;    % calculate number of samples before zero

elec_file   = '/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.docs/PrepAtt20/Electrodes/elec.dat';
elec        = readtable(elec_file,'Delimiter',' ','ReadVariableNames',false);
elec        = table2array(elec(:,4));

v_Elec = [];

for n = 1:length(avg.label)
    x           = find(strcmp(avg.label{n},elec));
    x           = x(x>2000);
    v_Elec(n) = x ;
end

mat2ep(filename_out, 1, Fs, s_Nb_Sample_PreStim, v_Elec', 1, avg.avg')