clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                 = suj_list{sb};
        
        dir_data                            = '../data/ageing_data/';
        
        fname_in                            = [dir_data suj '.CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        freq                                = h_transform_freq(freq,{[1 2],[3 4]},{'Visual','Auditory'});
                
        vis_pow                             = freq.powspctrm(1,:,:);
        aud_pow                             = freq.powspctrm(2,:,:);
        
        lIdx                                = (aud_pow-vis_pow) ./ (aud_pow+vis_pow);
        %         lIdx                                = (vis_pow-aud_pow) ./ (aud_pow+vis_pow);
        %         lIdx                                = (aud_pow-vis_pow)./vis_pow;

        new_freq                            = freq;
        new_freq.label                      = {'alpha_index'};
        new_freq.powspctrm                  = lIdx;
        
        %         cfg                                 = [];
        %         cfg.baseline                        = [-0.6 -0.2];
        %         cfg.baselinetype                    = 'relchange';
        %         new_freq                            = ft_freqbaseline(cfg,new_freq);
        
        allsuj_data{sb,ngroup}              = new_freq; clear data ;
        
    end
end

clearvars -except allsuj_data ;

for ngroup = 1:size(allsuj_data,2)
    grand_average{ngroup,1} = ft_freqgrandaverage([],allsuj_data{:,ngroup});
end

clearvars -except allsuj_data grand_average

list_freq   = [7 11; 11 15];

for ngroup = 1:size(grand_average,1)
    
    subplot(1,2,ngroup)
    
    list_legend = {};
    i           = 0;

    for nfreq = 1:2
        
        hold on;
        
        lmf1 = find(round(grand_average{ngroup,1}.freq) == round(list_freq(nfreq,1)));
        lmf2 = find(round(grand_average{ngroup,1}.freq) == round(list_freq(nfreq,2)));
        
        data = squeeze(nanmean(grand_average{ngroup,1}.powspctrm(1,lmf1:lmf2,:),2));
        
        
        if nfreq == 1
            plot(grand_average{ngroup,1}.time,data,'-b','LineWidth',3);
        else
            plot(grand_average{ngroup,1}.time,data,'--b','LineWidth',3);
        end
        
        xlim([-0.2 2]);
        ylim([0 0.5]);
        
        vline(1.2,'--k');
        
        list_name_freq          = {'7t11Hz','11t15Hz'};
        
        i                       = i + 1;
        list_legend{i}          = [grand_average{ngroup,1}.label{1} '.' list_name_freq{nfreq}];
        
    end
    
    legend(list_legend);
    drawaxis(gca, 'x', 0, 'movelabel', 1)
    
end