clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

list_measure    = {'cohimag','wpli_debiased'};
list_cue        = {'RCnD','LCnD','NCnD'};
list_time       = {'m600m200','p600p1000'};

for ncue = 1:length(list_cue)
    
    suj_list            = [1:4 8:17] ;
    
    for sb = 1:length(suj_list)
        
        suj             = ['yc' num2str(suj_list(sb))] ;
        
        for ntime = 1:length(list_time)
            
            fname       = ['../data/conn/' suj '.' list_cue{ncue} '.PaperAudVisTD.1t20Hz.m800p2000msCov.' list_time{ntime} '.itc.mat'];
            load(fname);
            fprintf('Loading %s\n',fname);
            
            template    = itc;
            data_mat    = itc.powspctrm;
            tmp{ntime}  = data_mat;
            
        end
        
        sub_data(sb,:,:) = tmp{2}; % -tmp{1})./tmp{1}; clear tmp;
        
    end
    
    gavg_data{1,ncue}                = template;
    gavg_data{1,ncue}.powspctrm      = squeeze(mean(sub_data,1)); clear sub_data;
    
end

clearvars -except gavg_data list_cue;

for nchan = 1:length(gavg_data{1}.label)
    
    subplot(4,4,nchan);
    
    cfg             = [];
    cfg.channel     = nchan;
    cfg.ylim        = [0 .1];

    ft_singleplotER(cfg,gavg_data{:});
    
    legend(list_cue);grid;
    
end