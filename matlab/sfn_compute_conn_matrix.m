clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

suj_list           = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj             = ['yc' num2str(suj_list(sb))] ;
    ext_data        = 'CnD.PaperAudVisTD.1t20Hz.m800p2000msCov';
    
    fname           = ['../data/conn/' suj '.' ext_data '.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    channel_cmb     = {};
    ix              = 0;
    
    for nseed = 1:3
        for ntarget = 1:length(virtsens.label)
            if nseed ~= ntarget
                
                ix                = ix + 1;
                
                channel_cmb{ix,1} = virtsens.label{nseed};
                channel_cmb{ix,2} = virtsens.label{ntarget};
                
            end
        end
    end
    
    cond_ix_sub             = {'N','L','R',''};
    cond_ix_cue             = {0,1,2,0:2};
    cond_ix_dis             = {0,0,0,0};
    cond_ix_tar             = {1:4,1:4,1:4,1:4};
    
    for ncue = 1:length(cond_ix_sub)
        
        cfg                 = [];
        cfg.trials          = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
        data                = ft_selectdata(cfg,virtsens);
        data                = h_removeEvoked(data);
        
        list_time           = 0.6;
        tpad                = 0.025;
        twin                = 0.4;
        
        for ntime = 1:length(list_time)
            
            if list_time(ntime) < 0
                ext_time        = ['m' num2str(abs(list_time(ntime))*1000) 'm' num2str(abs(list_time(ntime)+twin)*1000)];
            else
                ext_time        = ['p' num2str(abs(list_time(ntime))*1000) 'p' num2str(abs(list_time(ntime)+twin)*1000)];
            end
            
            cfg             = [];
            cfg.latency     = [list_time(ntime)-tpad list_time(ntime)+tpad+twin];
            data_select     = ft_selectdata(cfg,data);
            
            cfg             = [];
            cfg.method      = 'mtmfft';
            cfg.taper       = 'dpss';
            cfg.output      = 'fourier';
            cfg.foilim      = [2 20];
            cfg.tapsmofrq   = 2;
            freq            = ft_freqanalysis(cfg, data_select);
            
            %% imag coh
            
            cfg             = [];
            cfg.method      = 'coh';
            cfg.complex     = 'imag';
            cfg.channelcmb  = channel_cmb;
            freq_con        = ft_connectivityanalysis(cfg, freq);
            
            freq_con.connspctrm = freq_con.cohspctrm;
            freq_con        = rmfield(freq_con,'cohspctrm');
            
            fname_out       = ['../data/conn/' suj '.' cond_ix_sub{ncue} ext_data '.' cfg.method cfg.complex '.' ext_time '.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'freq_con','-v7.3');
            
            %% wPLI
            
            cfg             = [];
            cfg.method      = 'wpli_debiased';
            cfg.channelcmb  = channel_cmb;
            freq_con        = ft_connectivityanalysis(cfg, freq);
            
            freq_con.connspctrm = freq_con.wpli_debiasedspctrm;
            freq_con        = rmfield(freq_con,'wpli_debiasedspctrm');
            
            fname_out       = ['../data/conn/' suj '.' cond_ix_sub{ncue} ext_data '.' cfg.method '.' ext_time '.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'freq_con','-v7.3');
            
            %% Granger
            
            cfg             = [];
            cfg.order       = 5;
            cfg.toolbox     = 'bsmart';
            mdata           = ft_mvaranalysis(cfg, data_select);
            
            cfg             = [];
            cfg.method      = 'mvar';
            mfreq           = ft_freqanalysis(cfg, mdata);
            
            cfg             = [];
            cfg.method      = 'granger';
            freq_con        = ft_connectivityanalysis(cfg, mfreq);
            
            cfg             = [];
            cfg.frequency   = [2 20];
            freq_con        = ft_selectdata(cfg,freq_con);
            
            freq_con.connspctrm = freq_con.grangerspctrm;
            freq_con        = rmfield(freq_con,'grangerspctrm');
            
            fname_out       = ['../data/conn/' suj '.' cond_ix_sub{ncue} ext_data '.granger.' ext_time '.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'freq_con','-v7.3');
            
        end
    end
end