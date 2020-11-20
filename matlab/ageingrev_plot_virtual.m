clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]                    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}                    = allsuj(2:15,1);
suj_group{1}                    = allsuj(2:15,2);

lst_group                       = {'Young','Old'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        ext_name                = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        list_ix                 = 'CnD';
        
        fname_in                = ['../../data/ageing_data/' suj '.' list_ix '.' ext_name '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        %         freq                    = h_transform_freq(freq,{[1 2],[3 4],[5 6]},{'Vis Cortex','Auditory Cortex','Motor Cortex'});
        
        cfg                     = [];
        cfg.baseline            = [-0.6 -0.2];
        cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        allsuj_data{sb,ngroup}  = freq; clear freq;

        
    end
end

for ngroup = 1:size(allsuj_data,2)
    grand_average{ngroup,1} = ft_freqgrandaverage([],allsuj_data{:,ngroup});
end

clearvars -except allsuj_data grand_average lst_group

i                           = 0;

for nchan = 1:length(grand_average{1,1}.label)
    for ngroup = 1:2
        
        i = i + 1;
        subplot(3,4,i)
        
        cfg                     = [];
        cfg.comment             = 'no';
        cfg.colorbar            = 'yes';
        cfg.zlim                = [-0.2 0.2];
        cfg.xlim                = [0 1.2];
        cfg.ylim                = [5 40];
        cfg.channel             = nchan;
        
        ft_singleplotTFR(cfg,grand_average{ngroup,1});clc;
        
        title([grand_average{1,1}.label{nchan} ' ' lst_group{ngroup}]);
        set(gca,'FontSize',16)
        
    end
end

