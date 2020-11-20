clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'Old','Young'};

clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
lst_group       = {'Old','Young'};

fOUT            = '../documents/4R/PrepAtt22_gfp2R_CnD_p600p1100_slidWindows.txt';
fid             = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE','CUE_CAT','TAR_SIDE','TIME','AVG');

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        
        cond_sub            = {'R','L','NR','NL'};
        cond_tag            = {'Inf','Inf','Unf','Unf'};
        cond_side           = {'R','L','R','L'};
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD')
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            else
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            end
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_gfp                            = ft_globalmeanfield(cfg,data_pe);
            
            %             list_time                           = [0.08 0.12; 0.16 0.2; 0.22 0.26; 0.3 0.6];
            
            list_time                           = [0.5 0.6; 0.6 0.7; 0.7 0.8; 0.8 0.9; 0.9 1; 1 1.1];
            
            for ntime = 1:size(list_time,1)
                
                x1      = find(round(data_gfp.time,4)==round(list_time(ntime,1),4));
                x2      = find(round(data_gfp.time,4)==round(list_time(ntime,2),4));

                avg     = mean(data_gfp.avg(:,x1:x2));
                
                extime1 = ['p' num2str(list_time(ntime,1)*1000)];
                extime2 = ['p' num2str(list_time(ntime,2)*1000)];
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,lst_group{ngrp},cond_sub{ncue},cond_tag{ncue},cond_side{ncue},[num2str(ntime) extime1 extime2],avg);
                
            end
                
        end
        
    end
    
end

fclose(fid);
clear;