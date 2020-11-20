clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]                  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                        = suj_list(2:22);

for sb = 20:length(suj_list)
    
    suj                         = suj_list{sb};
    
    for cond_main               = {'nDT'}
        
        cond_ix_sub             = {'Lo','Hi'};
        
        cond_ix_cue             = {0:2,0:2};
        cond_ix_dis             = {0,0};
        cond_ix_tar             = {[1 2],[3 4]};
        
        dir_data                = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
        
        ext_name                = '';
        
        fname_in                = [dir_data suj '.' cond_main{:} ext_name '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        for xcon = 1:length(cond_ix_sub)
            
            trial_choose        = h_chooseTrial(data_elan,cond_ix_cue{xcon},cond_ix_dis{xcon},cond_ix_tar{xcon});
            
            cfg                 = [];
            cfg.trials          = trial_choose ;
            cfg.latency         = [-2 2];
            data_select         = ft_selectdata(cfg,data_elan);
            
            tfr_name_out        = ['../data/pitch_data/' suj '.' cond_ix_sub{xcon} cond_main{:}];
            
            in_function_computeTFR(data_select,tfr_name_out,'wavelet','pow','no',7,4,-2:0.01:2,[1:40 40:5:110],'yes');
            
            %             cfg                 = [];
            %             cfg.bpfilter        = 'yes';
            %             cfg.bpfreq          = [0.5 20];
            %             cfg.bpfiltord       = 2;
            %             data_preproc        = ft_preprocessing(cfg,data_select);
            %             extension_preproc   = ['bpOrder' num2str(cfg.bpfiltord) 'Filt' num2str(cfg.bpfreq(1)) 't' num2str(cfg.bpfreq(2)) 'Hz'];
            %
            %             data_pe             = ft_timelockanalysis([],data_preproc);
            %             data_pe             = rmfield(data_pe,'cfg');
            %
            %             dir_data            = '../data/pitch_data/';
            %
            %             fname_out           = [dir_data suj '.' cond_ix_sub{xcon} cond_main{:} ext_name '.' extension_preproc '.pe.mat'];
            %
            %             fprintf('Saving %s\n',fname_out);
            %
            %             save(fname_out,'data_pe','-v7.3');
            
            clear data_pe trial_choose
            
        end
        
    end
    
    clearvars -except sb suj_list
    
end