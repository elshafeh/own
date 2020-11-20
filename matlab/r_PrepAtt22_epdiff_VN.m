clear ; clc ; close all;

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
data = {'meg'};
ext  = '.lb.gfp' ;
condname = 'target';
condlist = {'nDT'};
% cond_pre = {'V','N'};
cond_pre = {'V','N'}

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    
    for d = 1:length(data) %eeg ou meg
        
        for c = 1:length(condlist)
            
            cd(['../data/' suj '/erp/' data{d} '/' condname]);
            
            system('rm batch.epdiff');
            
            epfileIN1  = [ suj '.pat22.' cond_pre{1} condlist{c} ext];
            epfileIN2  = [ suj '.pat22.' cond_pre{2} condlist{c} ext];
            epfileOUT  = [ suj '.pat22.' condlist{c}  ext '.' cond_pre{1} '-' cond_pre{2}];
            
            ligne      = ['rm ' epfileOUT '.p']
            system(ligne)
            
            FicName     = 'batch.epdiff';
            fid         = fopen(FicName,'w+');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'\n');
            fprintf(fid,'epdiff<<!\n');
            fprintf(fid,'%s\n',epfileIN1);
            fprintf(fid,'%s\n',epfileIN2);
            fprintf(fid,'%s\n',epfileOUT);
            fprintf(fid,'\n\n');
            fprintf(fid,'!\n');
            fclose(fid);
            
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
            
            cd ../../../../../scripts.m
        end
                
    end
    
end