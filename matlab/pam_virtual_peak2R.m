clc;
clear;

alldata           	= [];

for nsuj = 2:21
    
    sujname         = ['yc' num2str(nsuj)];
    
    
    dir_data       	= '~/Dropbox/project_me/data/pam/peak/';
    fname_out      	= [dir_data sujname '.alpha.peak.1s.pre.mat'];
    fprintf('loading %s\n',fname_out);
    load(fname_out);
    
    alldata         = [alldata; peak_data];
    
end

keep alldata

writetable(alldata,'../doc/pam_alpha_peak.txt');