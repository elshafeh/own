clear ; clc ; dleiftrip_addpath;

for tpsm = 0:2
    
    
    for sb = 1:14
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))];
        load(['../data/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'])
        
        lst_chan = {{'maxLO','maxRO'},{'maxRO'},{'maxLO'} ...
            {'maxHL','maxSTL'},{'maxHR','maxSTR'},{'maxHL','maxSTL','maxHR','maxSTR'}};
        
        lst_freq    = [9 13];
        
        %         cfg                 = [];
        %         cfg.baseline        = [-0.6 -0.2];
        %         cfg.baselinetype    = 'relchange';
        %         freq                = ft_freqbaseline(cfg,freq);
        
        for c_chan = 1:length(lst_chan)
            for c_freq = 1:2
                cfg                                 = [];
                cfg.channel                         = lst_chan{c_chan};
                cfg.latency                         = [0.6 1];
                cfg.frequency                       = [lst_freq(c_freq)-tpsm lst_freq(c_freq)+tpsm];
                cfg.avgovertime                     = 'yes';
                cfg.avgoverfreq                     = 'yes';
                cfg.avgoverchan                     = 'yes';
                data                                = ft_selectdata(cfg,freq);
                big_data(c_chan,c_freq,:)           = data.powspctrm ;
            end
        end
        
        clc;
        
        load '../data/yctot/rt/rt_cond_classified.mat';
        
        lst_chan_compare = [1 4; 1 5 ;1 6; ...
            2 4; 2 5 ;2 6; ...
            3 4; 3 5 ;3 6;];
        
        for y = 1:size(lst_chan_compare,1)
            
            dataOcc     = squeeze(big_data(lst_chan_compare(y,1),2,:));
            dataAud     = squeeze(big_data(lst_chan_compare(y,2),1,:));
            
            dataMean    = mean([dataOcc dataAud],2);
            corrIndex   = (dataAud-dataOcc)./(dataMean);
            
            [rho,p]         = corr(corrIndex,rt_all{sb} , 'type', 'Spearman');
            rhoF            = .5.*log((1+rho)./(1-rho));
            corr2R(sb,y)    = rhoF;
            
        end
        
        clearvars -except sb corr2R p_val tpsm
        
    end
    
    ft_progress('init','text',    'Please wait...');
    
    for n = 1:size(corr2R,2)
        ft_progress(n/size(corr2R,2), 'Permuting Test %d out of %d\n', n, size(corr2R,2));
        %         p_val(tpsm+1,n) = permutation_test([corr2R(:,n) zeros(14,1)],10000);
        [h,p_val(tpsm+1,n)] = ttest(corr2R(:,n),zeros(14,1));
    end
    
    
end