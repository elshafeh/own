clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

for sb = 1:21
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','fDIS'};
    
    for ncond = 1:length(list_cond)
        
        fname               = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.AudTPFC.1t120Hz.m200p800msCov.mgranger.mat'];
        
        fprintf('Loading %20s\n',fname); load(fname);
        
        %         mtrx{ncond}         = mpdc.pdcspctrm; clear mpdc;
        
        template                        = mgranger;
        allsujData{ncond}(sb,:,:,:)     = mgranger.grangerspctrm;
        
    end
    
    %     pdcspctrm                       = mtrx{1}-mtrx{2}; % (mtrx{1}-mtrx{2})./mtrx{2};
    %     allsujData{ncond}(sb,:,:,:)     = pdcspctrm; clear pdcspctrm mtrx;
    
end

clearvars -except allsujData template

for ncond = 1:2
    
    grandAverage{ncond}                     = template;
    grandAverage{ncond}.grangerspctrm       = squeeze(mean(allsujData{ncond},1));
    
end

cfg                         = [];
cfg.parameter               = 'grangerspctrm';
cfg.zlim                    = [0 0.15];
cfg.xlim                    = [0 100];
figure;ft_connectivityplot(cfg, grandAverage{1},grandAverage{2});