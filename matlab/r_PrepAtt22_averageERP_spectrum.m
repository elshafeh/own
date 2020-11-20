clear ; clc ; close all;

list_mig    = {'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19'};
list_ctl    = {'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc16' 'yc18' 'yc4'};

load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);
%ext         = '.lb';
ext         = '.lb.gfp';


meeg = {'meg';'eeg'};

mkdir('../data/avg_mig/');
mkdir('../data/avg_mig/spectrum');

cd(['../data/avg_mig/spectrum'])

system(['rm ???.restingstate_???_spectrum.253.s1'])
system('rm ERP.list')

for d = 1:length(meeg)
    
    data = meeg{d};
    
    %%ctl
    FicName     = 'ERP.list';
    fid         = fopen(FicName,'w+');
    epfileOUT   = ['ctl.restingstate_' data '_spectrum.253.s1'];
    fprintf(fid,'%s\n\n',epfileOUT);
    
    for sb = 1:length(list_ctl)
        suj      = list_ctl{sb};
        epfileIN = ['../../' suj '/meeg/restingstate_' data '_spectrum.253.s1'];
        fprintf(fid,'%s\n',epfileIN);
    end
    
    fprintf(fid,'%s\n\n','');
    fprintf(fid,'%s','!');
    fclose(fid);
    
    ligne = 'epavg <ERP.list';
    system(ligne)
    system('rm ERP.list')
    
    %%mig
    FicName     = 'ERP.list';
    fid         = fopen(FicName,'w+');
    epfileOUT   = ['mig.restingstate_' data '_spectrum.253.s1'];
    fprintf(fid,'%s\n\n',epfileOUT);
    
    for sb = 1:length(list_mig)
        suj      = list_mig{sb};
        epfileIN = ['../../' suj '/meeg/restingstate_' data '_spectrum.253.s1'];
        fprintf(fid,'%s\n',epfileIN);
    end
    
    fprintf(fid,'%s\n\n','');
    fprintf(fid,'%s','!');
    fclose(fid);
    
    ligne = 'epavg <ERP.list';
    system(ligne)
    system('rm ERP.list')
    
    
    cd ../../../scripts.m
    
end


