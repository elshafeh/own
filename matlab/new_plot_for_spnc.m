clear ; clc ; addpath(genpath('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/fieldtrip-20151124/'));

addpath('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/scripts_field/');

suj_group{1}    = {'oc1','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9','oc10','oc11','oc12','oc13','oc14'};
suj_group{2}    = {'yc12','yc11','yc10','yc15','yc4','yc13','yc19','yc18','yc16','yc14','yc2','yc1','yc7','yc5'};

lst_group       = {'old','young'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'NewHighAlphaAgeContrast.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrials';
        
        fname_in                = ['age_data/' suj '.' cond_main '.' ext_name2 '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        list_ix_cue        = {2,1,0,0};
        list_ix_tar        = {[2 4],[1 3],[2 4],[1 3]};
        list_ix_dis        = {0,0,0,0};
        list_ix            = {'R','L','NR','NL'};
        
        load(['age_data/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}) ; % trial_array{cnd};%
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
        end
        
        for cnd =1:length(list_ix)
            
            cfg                                 = [];
            
            if strcmp(ext_name1,'20t50Hz')
                cfg.baseline                        = [-0.4 -0.2];
            elseif strcmp(ext_name1,'1t20Hz')
                cfg.baseline                        = [-0.6 -0.2];
            elseif strcmp(ext_name1,'50t120Hz')
                cfg.baseline                        = [-0.2 -0.1];
            end
            
            cfg.baselinetype              = 'relchange';
            allsuj_data{ngroup}{sb,cnd}   = ft_freqbaseline(cfg,new_freq);
            
        end
    end
    
    clc ;
    
    for cnd = 1:size(allsuj_data{ngroup},2)
        gavg_data{ngroup,cnd} = ft_freqgrandaverage([],allsuj_data{ngroup}{:,cnd});
    end
    
end

clearvars -except gavg_data ;

list_frequency             = {[7 11],[11 15]};
list_channel               = {1:4,5:11};
list_title1                = {'auditory','occipital'};
list_title2                = {'lowAlpha','HighAlpha'};

i       = 0 ;
t_limit = [-0.1 1.2];
z_limit = [-0.4 0.4];

for nfreq = 2%1:2
    for nchan = 2;%1:2
        
        i = i + 1;
        %         subplot(2,2,i)
        hold on
        
        for ngroup = 1:2
            
            cfg             = [];
            cfg.frequency   = list_frequency{nfreq};
            cfg.avgoverfreq = 'yes';
            cfg.avgoverchan = 'yes';
            cfg.channel     = list_channel{nchan};
            temp            = ft_selectdata(cfg,gavg_data{ngroup,1});
            
            plot(temp.time,squeeze(temp.powspctrm),'LineWidth',2);
            xlim(t_limit);
            ylim(z_limit);
            
            drawaxis(gca, 'x', 0, 'movelabel', 1)
            drawaxis(gca, 'y', 0, 'movelabel', 1)
            
            set(gca,'XColor',[0.9400    0.9400    0.9400],'YColor',[0.9400    0.9400    0.9400],'TickDir','out')
                        
        end
        
        title([list_title1{nchan} '.' list_title2{nfreq}]);
        legend({'Old','Young'});
        
    end
end

saveas(gcf,'age_high_alpha_occipital.svg') ;  
saveas(gcf,'age_high_alpha_occipital.png') ; close all; 