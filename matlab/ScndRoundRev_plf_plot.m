clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;
addpath('DrosteEffect-BrewerMap-b6a6efc/');

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

ilu                         = 0;
list_evoked                 = {'wevoked'};

for sb = 1:21
    for nevo = 1:length(list_evoked)
        
            
        suj                     = suj_list{sb};
        fname                   = ['../../data/scnd_round/' suj '.DIS.PLF.' list_evoked{nevo} '.mat'];
        fprintf('Loading %20s\n',fname);
        load(fname);
        
        freq                    = phase_lock;
        freq                    = rmfield(freq,'rayleigh');
        freq                    = rmfield(freq,'p');
        freq                    = rmfield(freq,'sig');
        freq                    = rmfield(freq,'mask');

        allsuj_data{sb,nevo}    = freq; clear freq phase_lock;
        
    end
end

clearvars -except allsuj_data

for nevo = 1:size(allsuj_data,2)
    grandavearge{nevo} = ft_freqgrandaverage([],allsuj_data{:,nevo});
end

clearvars -except allsuj_data grandavearge

i                       = 0;

for nevo = 1:length(grandavearge)
    
    i = i + 1;
    subplot(2,3,i)
    
    zlim_list           = [0 0.15; 0 0.05];
    
    cfg                 = [];
    cfg.xlim            = [0 0.3];
    cfg.ylim            = [20 120];
    cfg.zlim            = zlim_list(nevo,:);
    ft_singleplotTFR(cfg,grandavearge{nevo});
    title('');
    
end