clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

suj_peaks                           = zeros(length(suj_list),4);

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    dir_data                        = '~/Dropbox/project_me/data/bil/virt/';
    
    fname                           = [dir_data subjectName '.mni.slct.alpha.beta.peak.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    suj_peaks(nsuj,1)               = 4;
    suj_peaks(nsuj,2:3)             = round(nanmean(allpeaks,1));
    suj_peaks(nsuj,4)               = 80;
    
end

keep suj_peaks suj_list

for nsuj = 1:length(suj_list)
    
    ext_virt                  	= 'wallis';
    
    subjectName               	= suj_list{nsuj};
    subject_folder            	= '~/Dropbox/project_me/data/bil/virt/'; %'I:/bil/virt/';
    fname                     	= [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    indx_rt                  	= data.trialinfo(:,14);
    indx_rt(indx_rt(:,1) < median(indx_rt(:,1)),2) = 1;
    indx_rt(indx_rt(:,1) > median(indx_rt(:,1)),2) = 2; %
    
    trialinfo               	= data.trialinfo;
    trialinfo                	= trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    trialinfo                	= [trialinfo indx_rt(:,2)]; % col.4 is RT:  1 (fast) and 2 (slow)
    trialinfo               	= [trialinfo [1:length(trialinfo)]']; % col 5 in index
    
    list_cond                	= {'pre' 'retro' 'correct' 'incorrect' 'fast' 'slow'};
    
    for ncue = 1:length(list_cond)
        
        cfg                     = [] ;
        cfg.output              = 'fourier';
        cfg.method              = 'mtmconvol';
        cfg.keeptrials          = 'yes';
        cfg.pad                 = 10;
        
        cfg.foi                 = suj_peaks(nsuj,:); %[1:40];
        cfg.tapsmofrq           = [1 1 2 20]; %0.1 *cfg.foi;
        
        cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
        cfg.toi                 = -1:0.05:6;
        cfg.taper               = 'hanning';
        
        switch list_cond{ncue}
            case 'pre'
                cfg.trials   	= trialinfo(trialinfo(:,2) == 1 & trialinfo(:,3) == 1,5); % correct only;
            case 'retro'
                cfg.trials   	= trialinfo(trialinfo(:,2) == 2 & trialinfo(:,3) == 1,5); % correct only;
            case 'correct'
                cfg.trials   	= trialinfo(trialinfo(:,3) == 1,5);
            case 'incorrect'
                cfg.trials   	= trialinfo(trialinfo(:,3) == 0,5);
            case 'fast'
                cfg.trials   	= trialinfo(trialinfo(:,4) == 1,5); 
            case 'slow'
                cfg.trials   	= trialinfo(trialinfo(:,4) == 2,5);
        end
        
        if ~isempty(cfg.trials)
            
            freq         	= ft_freqanalysis(cfg,data);
            freq         	= rmfield(freq,'cfg');
            
            for nmeth = {'coh' 'coh.imag' 'plv' 'ppc' 'amplcorr'}
                
                cfg            	= [];
                
                if strcmp(nmeth{:},'coh.imag')
                    cfg.method	= 'coh';
                    cfg.complex = 'imag';
                else
                    cfg.method	= nmeth{:};
                end
                
                coh           	= ft_connectivityanalysis(cfg, freq);
                coh         	= rmfield(coh,'cfg');
                
                ext_fname    	= list_cond{ncue};
                fname         	= '~/Dropbox/project_me/data/bil/virt/';
                fname         	= [fname subjectName '.' ext_virt '.' nmeth{:} '.' ext_fname '.mat'];
                fprintf('\nSaving %s\n',fname);
                tic;save(fname,'coh','-v7.3');toc;
                
            end
            
            clear freq coh;
            
        end
        
    end
end