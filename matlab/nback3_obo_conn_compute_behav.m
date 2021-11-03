clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

addpath('/Users/heshamelshafei/github/obob/obob_ownft/');

cfg                             = [];
cfg.package.svs                 = 1;
cfg.package.gm2                 = 1;
cfg.ft_path                     = '/Users/heshamelshafei/github/fieldtrip/';
obob_init_ft(cfg);

suj_list                       	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_data                    = '~/Dropbox/project_me/data/nback/virt/';
    fname                       = [dir_data 'sub' num2str(suj_list(nsuj)) '.wallis.roi.mat'];
    fprintf('\nLoading %s\n',fname);
    load(fname);
    
    trialinfo                  	= [];
    trialinfo(:,1)            	= data.trialinfo(:,1);              % condition
    trialinfo(:,2)             	= data.trialinfo(:,3);              % stim category
    trialinfo(:,3)             	= rem(data.trialinfo(:,2),10)+1;    % stim identity
    trialinfo(:,4)            	= data.trialinfo(:,6);              % response
    trialinfo(:,5)             	= data.trialinfo(:,7);              % rt
    trialinfo(:,6)            	= 1:length(data.trialinfo);         % trial indices to match with bin
    
    
    list_cond                	= {'fast' 'slow'};
    stim_ext                  	= 'target';
    index                      	= nbk_infocut_rt(trialinfo,stim_ext);
    
    for ncond = [1 2]
        
        cfg                     = [];
        cfg.method              = 'mtmconvol';
        cfg.taper               = 'hanning';
        cfg.foi                 = 1:1:35;
        cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
        cfg.toi                 = -2:.05:2;
        cfg.pad                 = 10;
        cfg.output              = 'fourier'; % output fourier
        cfg.trials              = index{ncond};
        tf                      = ft_freqanalysis(cfg,data);
        
        %get pow from four
        tfpow                   = ft_freqdescriptives([], tf);
        
        % connectivity
        cfg                     = [];
        cfg.method              = 'icoh';
        cfg.trials              = 'all';
        coh                     = obob_gm2_calcsource_conn(cfg, tf);
        
        coh.cohspctrm            =abs(coh.cohspctrm);
        
        fname                   = '~/Dropbox/project_me/data/nback/conn/';
        fname                   = [fname subjectname '.' list_cond{ncond} '.wallis.obob.connectivity.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'coh','-v7.3');toc;
        
        
    end
    
end