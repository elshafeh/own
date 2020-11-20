function h_fieldtrip2tf(tf_file_name,tfavg)

% input1: filename 
% input2: output of ft_freqanalysis or h_plotStat

elec_file   = '/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.docs/PrepAtt20/Electrodes/elec.dat';
elec        = readtable(elec_file,'Delimiter',' ','ReadVariableNames',false);
elec        = table2array(elec(:,4));

v_Elec = [];

for n = 1:length(tfavg.label)
    x           = find(strcmp(tfavg.label{n},elec));
    x           = x(x>2000);
    v_Elec(n) = x ;
end

Fs = 600;

lm_z                = find(round(tfavg.time,3)==0);                 % find zero

if ~isempty(lm_z)
    
    s_Nb_Sample_PreStim = (avg.time(lm_z) - avg.time(1)) * Fs ;         % calculate number of samples before zero
    
else % if structure does not start at zero it will concatenate it to a zero matrix.
    
    s_Nb_Sample_PreStim = 0 ;
    
    tres        = tfavg.time(2) - tfavg.time(1) ;
    nw_time     = 0:tres:tfavg.time(1)-tres;
    
    zro2add = zeros(size(tfavg.powspctrm,1),size(tfavg.powspctrm,2),length(nw_time));
    
    tfavg.powspctrm = cat(3,zro2add,tfavg.powspctrm);
    tfavg.time = [nw_time tfavg.time];
    
end

mat2tf (tf_file_name, 1, 2, 1, 1,tfavg.powspctrm, v_Elec', tfavg.label, s_Nb_Sample_PreStim, 1/tres, 1, tfavg.freq, 7, 0, 0, 1, 0, 1, 0);