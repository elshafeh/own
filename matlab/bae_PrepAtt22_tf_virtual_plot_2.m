clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'broadAreas.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrials';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
                
        list_ix_cue        = {2,1,0};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        list_ix            = {'R','L','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}) ; %
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            cfg                         = [];
            cfg.baseline                = [-0.6 -0.2];
            cfg.baselinetype            = 'relchange';
            new_freq                    = ft_freqbaseline(cfg, new_freq);
            
            for nchan = 1:length(new_freq.label)
                allsuj_data{ngroup}{sb,cnd,nchan}            = new_freq;
                allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm  = new_freq.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,cnd,nchan}.label      = new_freq.label(nchan);
            end
            
            clear new_freq cfg
            
        end
    end
end

clearvars -except allsuj_data

for ngroup = 1:length(allsuj_data)
    for cnd = 1:size(allsuj_data{ngroup},2)
        for nchan = 1:size(allsuj_data{ngroup},3)
            
            grand_avg{ngroup,cnd,nchan} = ft_freqgrandaverage([],allsuj_data{ngroup}{:,cnd,nchan});
            
        end
    end
end

clearvars -except allsuj_data grand_avg

i = 0 ;

for ngroup = 1:size(grand_avg,1)
    for nchan = 1:size(grand_avg,3)
        
        i = i + 1 ;
        subplot(2,4,i)
        hold on ;
        
        frq_win  = 4;
        frq_list = 7;
        
        y1       = find(round(grand_avg{ngroup,1,nchan}.freq)== round(frq_list));
        y2       = find(round(grand_avg{ngroup,1,nchan}.freq)== round(frq_list+frq_win));
        
        for ncue = 1:size(grand_avg,2)
            pow      = squeeze(mean(grand_avg{ngroup,ncue,nchan}.powspctrm(1,y1:y2,:),2));
            plot(grand_avg{ngroup,1,nchan}.time,pow,'LineWidth',2)
            xlim([-0.2 2])
            ylim([-0.35 0.35])
        end
        
        legend({'R','L','N'});
        
        %         pow      = squeeze(mean(grand_avg{ngroup,1,nchan}.powspctrm(1,y1:y2,:),2)) - squeeze(mean(grand_avg{ngroup,3,nchan}.powspctrm(1,y1:y2,:),2));
        %         plot(grand_avg{ngroup,1,nchan}.time,pow,'LineWidth',1)
        %         xlim([-0.2 2])
        %         ylim([-0.35 0.35])
        %         pow      = squeeze(mean(grand_avg{ngroup,2,nchan}.powspctrm(1,y1:y2,:),2)) - squeeze(mean(grand_avg{ngroup,4,nchan}.powspctrm(1,y1:y2,:),2));
        %         plot(grand_avg{ngroup,1,nchan}.time,pow,'LineWidth',1)
        %         xlim([-0.2 2])
        %         ylim([-0.35 0.35])
        %         legend({'RmNR','LmNL'})
        
        title(grand_avg{ngroup,ncue,nchan}.label);
        
    end
end

figure;
i = 0 ;

for nchan = 1:size(grand_avg,3)
    for ncue = 1:size(grand_avg,2)
        
        i = i + 1 ;
        subplot(4,4,i)
        hold on ;
        
        frq_win  = 8;
        frq_list = 7;
        
        y1       = find(round(grand_avg{ngroup,1,nchan}.freq)== round(frq_list));
        y2       = find(round(grand_avg{ngroup,1,nchan}.freq)== round(frq_list+frq_win));
        
        for ngroup = 1:size(grand_avg,1)
            pow      = squeeze(mean(grand_avg{ngroup,ncue,nchan}.powspctrm(1,y1:y2,:),2));
            plot(grand_avg{ngroup,1,nchan}.time,pow,'LineWidth',2)
            xlim([-0.2 2])
            ylim([-0.35 0.35])
        end
        
        list_cue = {'R','L','NR','NL','N'};
        title([grand_avg{ngroup,ncue,nchan}.label{:} ' ' list_cue{ncue} 'Cue']);
        %         legend({'Old','Young'});
        
    end
end