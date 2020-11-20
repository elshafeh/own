clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngroup = 1:length(suj_group)
    
    list_ix  = {''};
    suj_list = suj_group{ngroup};
    
    for ncue = 1:length(list_ix)
        
        for sb = 1:length(suj_list)
            
            suj                     = suj_list{sb};
            cond_main               = 'CnD';
            ext_name2               = 'broadAreas.50t120Hz.m800p2000msCov.waveletPOW.50t110Hz.m1000p2000.KeepTrialsMinEvoked10MStep80Slct';
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                    = ft_freqdescriptives([],freq);
            
            cfg                     = [];
            cfg.baseline            = [-0.3 -0.1];
            cfg.baselinetype        = 'relchange';
            allsuj_data{sb,ncue}    = ft_freqbaseline(cfg,freq);
            
            
        end
        
        grandAverage{ngroup,ncue}   = ft_freqgrandaverage([],allsuj_data{:,ncue});
        
    end
end

clearvars -except allsuj_data grandAverage ;

i = 0 ;

for ngroup = 1:size(grandAverage,1)
    for ncue = 1:size(grandAverage,2)
        
        for nchan = 1:length(grandAverage{ngroup,ncue}.label)
            
            i = i + 1;
            
            subplot(2,2,i)
            
            cfg                             = [];
            cfg.xlim                        = [-0.3 2];
            cfg.channel                     = nchan;
            cfg.ylim                        = [50 100];
            cfg.colorbar                    = 'no';
            cfg.zlim                        = [-0.05 0.05];
            ft_singleplotTFR(cfg,grandAverage{ngroup,ncue});
            
            vline(0,'--k','Cue Onset');
            vline(1.2,'--k','Target Onset');
            
            %             colormap(redblue)
            
            list_group = {'Old','Young'};
            list_chan  = {'Left Auditory' , ' Right Auditory'};
            
            title([list_group{ngroup} ' ' list_chan{nchan}],'FontSize',18);
            
        end
    end
end