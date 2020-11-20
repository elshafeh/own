suj_list                                    = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 1:length(suj_list)
    
    suj                                     = suj_list{sb};
    
    for cond_main                           = {'CnD'}
        
        dir_data                        = '../data/paper_data/';
        
        fname_in                        = [dir_data suj '.CnD.prep21.maxAVMsepVoxels.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        freq                            = h_transform_freq(freq,{1:5,6:10,[11:15 21:25],[16:20 26:30]},{'occ_L','occ_R','aud_L','aud_R'});
        
        cfg                             = [];
        cfg.baseline                    = [-0.6 -0.2];
        cfg.baselinetype                = 'relchange';
        freq                            = ft_freqbaseline(cfg,freq);
        
        allsuj_data{sb,1}               = freq;
        
        fname_in                        = [dir_data suj '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                             = [];
        cfg.baseline                    = [-0.6 -0.2];
        cfg.baselinetype                = 'relchange';
        freq                            = ft_freqbaseline(cfg,freq);
        
        allsuj_data{sb,2}               = freq;
        
    end
end

clearvars -except allsuj_data ;

for calc_type = 1:2
    grand_average{calc_type} = ft_freqgrandaverage([],allsuj_data{:,calc_type});
end

clearvars -except allsuj_data grand_average;

figure;
i = 0;

list_freq   = [7 11; 11 15];
list_title  = {'7-11Hz','11-15Hz'};

for nfreq = 1:2
    for nchan = 1:4
        
        i = i + 1;
        subplot(2,4,i)
        hold on
        
        for ntype = 1:2
            cfg                 = [];
            cfg.frequency       = [list_freq(nfreq,1) list_freq(nfreq,2)];
            cfg.avgoverfreq     = 'yes';
            data                = ft_selectdata(cfg,grand_average{ntype});
            
            plot(data.time,squeeze(data.powspctrm(nchan,:,:)),'LineWidth',2);
            xlim([-0.2 2])
            ylim([-0.3 0.3])
            hline(0,'--k');
            
        end
        
        title([list_title{nfreq} ' ' data.label{nchan}]);
        legend({'average after ff','average before ff'});
    
    end
    
end
