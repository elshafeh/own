clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_list(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    list_time       = {'p350p650'};
    list_lo_freq    = {'7t13Hz'};
    list_hi_freq    = {'60t100Hz'};
    list_cnd_cue    = {'1fDIS','1DIS'};
    
    for ncue = 1:length(list_cnd_cue)
        for ntime = 1:length(list_time)
            for nhigh = 1:length(list_hi_freq)
                
                ext_source          = '.OriginalPCCHanningMinEvoked0.5cm.mat';
                
                fname               = ['../data/' suj '/field/' suj '.' list_cnd_cue{ncue} '.' list_time{ntime} '.' list_hi_freq{nhigh} ext_source];
                fprintf('Loading %s\n',fname)
                load(fname);
                
                source_ampli        = source;
                
                for nlow = 1:length(list_lo_freq)
                    
                    fname           = ['../data/' suj '/field/' suj '.' list_cnd_cue{ncue} '.' list_time{ntime} '.' list_lo_freq{nlow} ext_source];
                    fprintf('Loading %s\n',fname)
                    load(fname);
                    
                    source_phase    = source;
                    
                    source_MI       = h_compute_source_pac(source_ampli,source_phase);
                    
                    fname           = ['../data/' suj '/field/' suj '.' list_cnd_cue{ncue} '.' list_time{ntime} '.' list_lo_freq{nlow} 'and' list_hi_freq{nhigh} '.all' ext_source];
                    
                    fprintf('Saving %s\n\n',fname)
                    save(fname,'source_MI','-v7.3');
                    
                    clear source source_phase source_MI fname
                    
                end
                
                clear ext_source source_ampli
                
            end
        end
    end
    
    clearvars -except suj_list sb
    
end