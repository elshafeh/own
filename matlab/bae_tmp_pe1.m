clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    for cond_main       = {'DIS.eeg','fDIS.eeg'}
            
        cond_ix_sub     = {'','V','N','L','R'};
        
        cond_ix_cue     = {0:2,[1 2],0,1,2};
        
        cond_ix_dis     = {1:2,1:2,1:2,1:2,1:2};
        
        cond_ix_tar     = {1:4,1:4,1:4,1:4,1:4};
        
        fname_in        = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.latency             = [-2 2];
        data_elan               = ft_selectdata(cfg,data_elan);
        
        cfg                     = [];
        cfg.bpfilter            = 'yes';
        
        if strcmp(cond_main{:},'CnD') || strcmp(cond_main{:},'CnD.eeg')
        cfg.bpfreq              = [0.2 20];
        else
            cfg.bpfreq          = [0.5 20];
        end
        
        cfg.bpfiltord           = 2;
        data_elan               = ft_preprocessing(cfg,data_elan);
        
        extension_preproc       = ['bpOrder' num2str(cfg.bpfiltord) 'Filt' num2str(cfg.bpfreq(1)) 't' num2str(cfg.bpfreq(2)) 'Hz'];
        
        for xcon = 3% 1:length(cond_ix_sub)
            
            trial_choose        = h_chooseTrial(data_elan,cond_ix_cue{xcon},cond_ix_dis{xcon},cond_ix_tar{xcon});
            
            cfg                 = [];
            cfg.trials          = trial_choose ;
            data_pe             = ft_timelockanalysis(cfg,data_elan);
            data_pe             = rmfield(data_pe,'cfg');
            
            fname_out           = ['../data/' suj '/field/' suj '.' cond_ix_sub{xcon} cond_main{:} '.' extension_preproc '.pe.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'data_pe','-v7.3');
            
            clear data_pe trial_choose
            
        end
        
    end
    
    clearvars -except sb suj_list
    
end