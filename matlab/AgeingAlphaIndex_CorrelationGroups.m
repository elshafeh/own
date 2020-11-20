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
        
        freq                                = h_transform_freq(freq,{[1 2],[3 4]},{'Visual','Auditory'});
        
        vis_pow                             = freq.powspctrm(:,1,:,:);
        aud_pow                             = freq.powspctrm(:,2,:,:);
        
        lIdx                                = (aud_pow-vis_pow) ./ (aud_pow+vis_pow);
        new_freq                            = freq;
        new_freq.label                      = {'alpha_index'};
        new_freq.powspctrm                  = lIdx;
        
        freq                                = new_freq; clear new_freq;
        
        allsuj_data{ngroup}{sb,1}           = freq;
        allsuj_data{ngroup}{sb,1}.powspctrm = zeros(length(freq.label),length(freq.freq),length(freq.time));
        
        allsuj_data{ngroup}{sb,2}           = allsuj_data{ngroup}{sb,1};
        
        [~,~,~,~,new_strl_rt]               = h_new_behav_eval(suj,0:2,0,1:4); clc ;
        
        for nfreq = 1:length(freq.freq)
            for ntime = 1:length(freq.time)
                
                data    = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                
                [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                
                rhoF    = .5.*log((1+rho)./(1-rho));
                
                allsuj_data{ngroup}{sb,1}.powspctrm(:,nfreq,ntime) = rhoF ; % !!!
                
            end
        end
    end
end

clearvars -except allsuj_data ;

freq_lim                = [7 15];
time_lim                = [0.2 1.2];

nsuj                    = size(allsuj_data{1},1);
[~,neighbours]          = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'indepsamplesT';

cfg.correctm            = 'fdr';

cfg.neighbours          = neighbours;
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;

cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
cfg.ivar                = 1;

cfg.frequency           = freq_lim;
cfg.latency             = time_lim;

stat                    = ft_freqstatistics(cfg, allsuj_data{2}{:,1},allsuj_data{1}{:,1});

[min_p, p_val]          = h_pValSort(stat) ;

clearvars -except allsuj_data stat min_p p_val *_lim;

figure;
i               = 0 ;
p_limit         = 0.05;

for ncue = 1:size(stat,2)
    
    stoplot             = stat;
    
    for nchan = 1:length(stoplot.label)
        
        i                   = i + 1;
        
        stoplot.mask        = stoplot.prob < p_limit;
        
        [x_ax,y_ax,z_ax]    = size(stoplot.stat);
        
        if y_ax == 1
            
            plot(stoplot.time,squeeze(stoplot.mask(nchan,:,:) .* stoplot.stat(nchan,:,:)));
            ylim([-3 3]);
            xlim([stoplot.time(1) stoplot.time(end)])
            
        elseif z_ax == 1
            
            plot(stoplot.freq,squeeze(stoplot.mask(nchan,:,:) .* stoplot.stat(nchan,:,:)));
            ylim([-3 3]);
            xlim([stoplot.freq(1) stoplot.freq(end)])
            
        else
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.colorbar                    = 'no';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.zlim                        = [-2 2];
            ft_singleplotTFR(cfg,stoplot);
            
        end
        
        title(stoplot.label{nchan});
        
    end
end