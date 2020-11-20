clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                 = suj_list{sb};
        
        dir_data                            = '../data/ageing_data/';
        
        fname_in                            = [dir_data suj '.CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        freq                                = ft_freqdescriptives([],freq);
        freq                                = h_transform_freq(freq,{[1 2],[3 4]},{'Visual','Auditory'});
        
        cfg                                 = [];
        cfg.latency                         = [0.6 1];
        cfg.avgovertime                     = 'yes';
        cfg.avgoverfreq                     = 'yes';
        cfg.frequency                       = [8 10];
        cfg.channel                         = 1;
        vfreq                               = ft_selectdata(cfg,freq);
        
        cfg.channel                         = 2;
        cfg.frequency                       = [12 14];
        afreq                               = ft_selectdata(cfg,freq);
        
        vis_pow                             = vfreq.powspctrm;
        aud_pow                             = afreq.powspctrm;
        
        lIdx                                = (aud_pow-vis_pow) ./ (aud_pow+vis_pow);
        
        allsuj_data{ngroup}(sb,1)           = lIdx;
        
        [allsuj_data{ngroup}(sb,2),~,~,~,~] = h_new_behav_eval(suj,0:2,0,1:4); clc ;
    end
end

clearvars -except allsuj_data ;

for ngroup = 1:2
    
    [rho_corr(ngroup),p_corr(ngroup)] = corr(allsuj_data{ngroup}(:,1),allsuj_data{ngroup}(:,2) , 'type', 'Pearson');
    [rho_sper(ngroup),p_sper(ngroup)] = corr(allsuj_data{ngroup}(:,1),allsuj_data{ngroup}(:,2) , 'type', 'Spearman');

end