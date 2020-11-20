clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

suj_peaks                       = zeros(length(suj_list),4);

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    dir_data                    = '~/Dropbox/project_me/data/bil/virt/';
    ext_virt                    = 'wallis';
    fname                       = [dir_data subjectName '.' ext_virt '.alpha.beta.peak.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    suj_peaks(nsuj,1)           = 4;
    suj_peaks(nsuj,2:3)         = round(nanmean(allpeaks,1));
    suj_peaks(nsuj,4)           = 80;
    
end

keep suj_peaks suj_list ext_virt

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    subject_folder              = '~/Dropbox/project_me/data/bil/virt/';
    fname                       = [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    alldata                     = data; clear data;
        
    list_cue                    = {'precue' 'retrocue'};
    
    for ncue = 1:2
        
        cfg                   	= [];
        cfg.trials            	= find(alldata.trialinfo(:,8) == ncue);
        data                  	= ft_selectdata(cfg,alldata);
        
        fname                	= [subject_folder subjectName '.' list_cue{ncue} 'lock.itc.incorrect.index.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nbin = [1 5]
            
            cfg               	= [] ;
            cfg.output      	= 'fourier';
            cfg.method       	= 'mtmconvol';
            cfg.keeptrials   	= 'yes';
            cfg.pad           	= 10;
            
            cfg.foi          	= suj_peaks(nsuj,:);
            cfg.tapsmofrq    	= [1 1 2 20];
            
            cfg.t_ftimwin     	= ones(length(cfg.foi),1).*0.5;
            cfg.toi           	= -1:0.05:6;
            cfg.taper         	= 'hanning';
            
            cfg.trials       	= bin_index(:,nbin);
            
            freq                = ft_freqanalysis(cfg,data);
            freq                = rmfield(freq,'cfg');
            
            for nmeth = {'coh.imag' 'plv'}
                
                cfg            	= [];
                
                if strcmp(nmeth{:},'coh.imag')
                    cfg.method	= 'coh';
                    cfg.complex = 'imag';
                else
                    cfg.method	= nmeth{:};
                end
                
                coh           	= ft_connectivityanalysis(cfg, freq);
                coh         	= rmfield(coh,'cfg');
                
                fname         	= ['~/Dropbox/project_me/data/bil/virt/' subjectName '.' ext_virt '.' list_cue{ncue} '.itcwithincorrect.bin' num2str(nbin) '.' nmeth{:} '.mat'];
                fprintf('\nSaving %s\n',fname);
                tic;save(fname,'coh','-v7.3');toc;
                
            end
            
            clear freq coh;
            
        end
        
        clear data;
        
    end
end