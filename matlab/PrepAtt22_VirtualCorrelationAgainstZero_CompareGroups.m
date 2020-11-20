clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% suj_group{1}       = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        ext_name2               = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked';
        list_ix                 = {''};
        
        for ncue          = 1:length(list_ix)
            
            fname_in                                    = ['../data/ageing_data/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            %             freq                                        = h_transform_freq(freq,{[1 2],[3 4],[5 6]},{'Visual','Auditory','Motor'});
            
            lmt1                                        = find(round(freq.time,3) == round(-0.6,3)); % baseline period
            lmt2                                        = find(round(freq.time,3) == round(-0.2,3)); % baseline period
            
            bsl                                         = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
            bsl                                         = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
            
            freq.powspctrm                              = freq.powspctrm ./ bsl ; clear bsl ;
            
            allsuj_data{ngroup}{sb,ncue,1}.powspctrm    = [];
            allsuj_data{ngroup}{sb,ncue,1}.dimord       = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ncue,1}.freq         = freq.freq ; %freq_list;
            allsuj_data{ngroup}{sb,ncue,1}.time         = freq.time ; %time_list;
            allsuj_data{ngroup}{sb,ncue,1}.label        = freq.label;
            
            list_ix_cue                                 = 0:2;
            list_ix_tar                                 = 1:4;
            list_ix_dis                                 = 0;
            [~,~,~,~,strial_rt]                         = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
            
            fprintf('Calculating Correlation for %s\n',suj)
            
            for nfreq = 1:length(freq.freq)
                for ntime = 1:length(freq.time)
                    
                    data    = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                    
                    %                     load ../data/yctot/rt/rt_cond_classified.mat
                    
                    [rho,p] = corr(data,strial_rt , 'type', 'Spearman');
                    
                    %                     mask    = p < 0.05;
                    %                     rho     = mask .* rho ; %% !!!!
                    
                    rhoF    = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ncue,1}.powspctrm(:,nfreq,ntime) = rhoF ; % !!!
                    
                    %                     clear rho p data ;
                    
                end
            end
            
            allsuj_data{ngroup}{sb,ncue,2}               = allsuj_data{ngroup}{sb,1};
            allsuj_data{ngroup}{sb,ncue,2}.powspctrm(:)  = 0;
            
        end
        
    end
end

clearvars -except allsuj_data ;

freq_lim                = [7 15];
time_lim                = [0.6 1];

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

cfg.avgovertime         = 'yes';

cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
cfg.ivar                = 1;

cfg.frequency           = freq_lim;
cfg.latency             = time_lim;

for ncue = 1:size(allsuj_data{1},2)
    stat{ncue}            = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue,1},allsuj_data{1}{:,ncue,1});
end

for ncue = 1:size(stat,2)
    [min_p(ncue), p_val{ncue}]  = h_pValSort(stat{ncue}) ;
end

clearvars -except allsuj_data stat min_p p_val *_lim;

figure;
i               = 0 ;
p_limit         = 0.05;

for ncue = 1:size(stat,2)
    
    stoplot             = stat{ncue};
    
    for nchan = 1:length(stoplot.label)
        
        i                   = i + 1;
        
        stoplot.mask        = stoplot.prob < p_limit;
        
        subplot(3,2,i)
        
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