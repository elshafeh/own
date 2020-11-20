clear; clc ; dleiftrip_addpath ;

cnd_list = {'CnD'};

for cnd = 1:length(cnd_list)
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        suj = ['yc' num2str(suj_list(sb))];
        
        ext_essai   = 'MaxAudVizMotor.BigCov.VirtTimeCourse';
        
        fname_in = [suj '.' cnd_list{cnd} '.' ext_essai];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(['../data/pe/' fname_in '.mat'])
        
        nw_chn  = [1 1;2 2; 3 5; 4 6];
        nw_lst  = {'occ.L','occ.R','aud.L','aud.R'};
        
        for l = 1:size(nw_chn,1)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwdata{l}        = ft_selectdata(cfg,virtsens);
            nwdata{l}.label  = nw_lst(l);
        end
        
        virtsens            = ft_appenddata([],nwdata{:});
        
        for cnd_cue         = 1
            
            cfg                 = [];
            cfg.method          = 'wavelet';
            cfg.output          = 'pow';
            cfg.width           =  7 ;
            cfg.gwidth          =  4 ;
            cfg.toi             = -3:0.05:3;
            cfg.foi             =  1:1:20;
            cfg.keeptrials      = 'no';
            
            %             if cnd_cue          < 3
            %                 cfg.trials          = h_chooseTrial(virtsens,cnd_cue,0,1:4);
            %             elseif cnd_cue == 3
            %                 cfg.trials          = h_chooseTrial(virtsens,0,0,[1 3]);
            %             else
            %                 cfg.trials          = h_chooseTrial(virtsens,0,0,[2 4]);
            %         end
            
            cfg.trials          = h_chooseTrial(virtsens,cnd_cue-1,0,1:4);

            freq                = ft_freqanalysis(cfg,virtsens);
            freq                = rmfield(freq,'cfg');
            
            if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
            if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
            
            ext_time            = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
            ext_freq            = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
            
            sub_list            = {'N'}; %{'L','R','NL','NR'};
            
            ext_cnd             = [sub_list{cnd_cue} cnd_list{cnd}] ;
            fname_out           = ['../data/tfr/' suj '.' ext_cnd '.' ext_essai '.' ext_trials '.' ext_method '.WithEvoked.' ext_freq '.' ext_time '.mat'];
            
            fprintf('\nSaving %50s \n\n',fname_out);
            save(fname_out,'freq','-v7.3');
            
            clear freq
        end
        
        clear virtsens;clc;
        
    end
end