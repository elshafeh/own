function h_fieldtrip2tf(tf_file_name,tfavg,Fs)

% function to convert fieldtrip structures back to élan
% Note that you must have a Zero point (stimulus onset) in your time dimension; otherwise Elan can’t understand.
% input1: filename with avg.tf extension 
% input2: fieldtrip freq structure
% input3: Original frequency sampling of your data

elec_file   = '/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.docs/PrepAtt20/Electrodes/elec.dat';
elec        = readtable(elec_file,'Delimiter',' ','ReadVariableNames',false);
elec        = table2array(elec(:,4));

v_Elec = [];

for n = 1:length(tfavg.label)
    x           = find(strcmp(tfavg.label{n},elec));
    x           = x(x>2000);
    v_Elec(n) = x ;
end

lm_z    = find(round(tfavg.time,3)==0);                 % find zero
tres    = tfavg.time(2) - tfavg.time(1) ;
nw_Fs 	= 1/tres; % calculates new sampling frequency according to distance between two consecutive samples


if ~isempty(lm_z)   
    
    s_Nb_Sample_PreStim     = lm_z-1 ;         % calculate number of samples before zero
    
else % if structure does not start at zero it will concatenate it to a zero matrix.
    
    s_Nb_Sample_PreStim 	= 0 ;
    nw_time                 = 0:tres:tfavg.time(1)-tres;
    zro2add                 = zeros(size(tfavg.powspctrm,1),size(tfavg.powspctrm,2),length(nw_time));
    tfavg.powspctrm 		= cat(3,zro2add,tfavg.powspctrm);
    tfavg.time              = [nw_time tfavg.time];
    
end


mat2tf (tf_file_name, 1, 2, 1, 1,tfavg.powspctrm(:,:,:), v_Elec', tfavg.label, ...
    s_Nb_Sample_PreStim, nw_Fs, 1, tfavg.freq, repmat(7,length(tfavg.freq),1), ...
    1, Fs/nw_Fs, ...
    1,0, 1, 0);