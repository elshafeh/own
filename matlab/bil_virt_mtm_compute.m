clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:9 % 10:length(suj_list)
    
    ext_virt          	= 'wallis';
    
    subjectName      	= suj_list{nsuj};
    subject_folder   	= 'I:/bil/virt/'; 
    fname            	= [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    indx_rt           	= data.trialinfo(:,14);
    indx_rt(indx_rt(:,1) < median(indx_rt(:,1)),2) = 1;
    indx_rt(indx_rt(:,1) > median(indx_rt(:,1)),2) = 2;
    
    trialinfo         	= data.trialinfo;
    trialinfo(trialinfo(:,16) == 0,16)     = 2; % change correct to 1(corr) and 2(incorr)
    trialinfo         	= trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    trialinfo        	= [trialinfo indx_rt(:,2)]; % col.4 is RT
    trialinfo        	= [trialinfo [1:length(trialinfo)]']; % col 5 in index
    
    list_cue         	= {'pre','retro'};
    list_corr        	= {'correct','incorrect'};
    list_rt           	= {'fast','slow'};
    
    for ncue = 1:2
        for ncorrect = 1:2
            for nrt = 1:2
                
                cfg                 = [] ;
                cfg.output          = 'pow';
                cfg.method          = 'mtmconvol';
                cfg.keeptrials      = 'no';
                cfg.pad             = 10;
                cfg.foi             = [1:1:40 42:2:100];
                cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
                cfg.toi             = -1:0.02:7;
                cfg.taper           = 'hanning';
                cfg.tapsmofrq    	= 0.1 *cfg.foi;
                cfg.trials          = trialinfo(trialinfo(:,2) == ncue & trialinfo(:,3) == ncorrect & trialinfo(:,4) == nrt,5);

                if ~isempty(cfg.trials)
                    freq         	= ft_freqanalysis(cfg,data);
                    freq         	= rmfield(freq,'cfg');
                    ext_fname    	= [list_cue{ncue} '.' list_corr{ncorrect} '.' list_rt{nrt}];
                    fname         	= ['D:\Dropbox\project_me\data\bil\virt\' subjectName '.' ext_virt '.mtm.1t100Hz.' ext_fname '.mat'];
                    fprintf('\nSaving %s\n',fname);
                    tic;save(fname,'freq','-v7.3');toc;
                    clear freq;
                end
                
            end
        end
    end
end