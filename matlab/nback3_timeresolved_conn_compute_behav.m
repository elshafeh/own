clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data                  	= '~/Dropbox/project_me/data/nback/peak/';
    
    fname_in                 	= [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.equalhemi.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allpeaks(nsuj,1)            = apeak;
    allpeaks(nsuj,2)            = bpeak;
    
end

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
        
        cfg                     = [] ;
        cfg.output              = 'fourier';
        cfg.method              = 'mtmconvol';
        cfg.keeptrials          = 'yes';
        cfg.pad                 = 5;
        
        cfg.foi                 = allpeaks(nsuj,:);
        cfg.tapsmofrq           = [1 2];
        
        cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
        cfg.toi                 = -1.5:0.01:2.5;
        cfg.taper               = 'hanning';
        
        cfg.trials              = index{ncond};
        
        freq                    = ft_freqanalysis(cfg,data);
        freq                    = rmfield(freq,'cfg');
        
        for nmeth = {'coh' 'coh.imag'}
            
            cfg            	= [];
            
            if strcmp(nmeth{:},'coh.imag')
                cfg.method	= 'coh';
                cfg.complex = 'imag';
            else
                cfg.method	= nmeth{:};
            end
            
            coh           	= ft_connectivityanalysis(cfg, freq);
            coh         	= rmfield(coh,'cfg');
            
            fname         	= '~/Dropbox/project_me/data/nback/conn/';
            fname         	= [fname subjectname '.' list_cond{ncond} '.wallis.' nmeth{:} '.connectivity.mat'];
            fprintf('\nSaving %s\n',fname);
            tic;save(fname,'coh','-v7.3');toc;
            
        end
        
        clear freq coh;
        
    end
    
end