clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    cond_main               = 'CnD';
    i                       = 0;
    
    for ext_name            = {'MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvokedMotor', ...
            'MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked'}
        
        fname_in                = ['../data/paper_data/' suj '.CnD.' ext_name{:} '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        i                       = i + 1;
        tmp{i}                  = freq; clear freq;
        
    end
    
    cfg                         = [];
    cfg.parameter               = 'powspctrm';
    freq                        = ft_appendfreq(cfg,tmp{:}); clear tmp ;
    
    freq                        = h_transform_freq(freq,{[1 2],[3 4],[5 6]},{'Motor','Visual','Auditory'});
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    allsuj_data{sb,1}           = freq;
    
end

clearvars -except allsuj_data ;

grand_average                   = ft_freqgrandaverage([],allsuj_data{:});

figure;
i = 0;

list_freq   = [7 11; 11 15];
list_title  = {'7-11Hz','11-15Hz'};
list_chan   = [1 3 5; 2 4 6];

for nfreq = 1:2
    
    %     for nhemi = 1:2
    
    i = i + 1;
    
    subplot(1,2,i)
    hold on
    
    for nchan = 1:3
        
        cfg                 = [];
        cfg.frequency       = [list_freq(nfreq,1) list_freq(nfreq,2)];
        cfg.avgoverfreq     = 'yes';
        data                = ft_selectdata(cfg,grand_average);
        
        %         plot(data.time,squeeze(data.powspctrm(list_chan(nhemi,nchan),:,:)),'LineWidth',2);
        plot(data.time,squeeze(data.powspctrm(nchan,:,:)),'LineWidth',2);

        xlim([-0.2 1.2])
        ylim([-0.25 0.25])
        hline(0,'--k');
        
    end
    
    %     legend(grand_average.label(list_chan(nhemi,:)));
    legend(grand_average.label);
    
    title(list_title{nfreq});
    
    %     end
    
end

saveas(gcf,'~/GoogleDrive/PhD/Publications/Papers/alpha2017/eNeuro/prep/compare_auditory_visual_motor.svg')
close all;
