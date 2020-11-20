clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(sb))];
    list_cond               = {'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked'}; % ,...
        %'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsWithEvoked'};
    
    for ncue = 1:length(list_cond)
        
        ext_name            = 'mat';
        fname_in            = ['../data/paper_data/' suj '.' list_cond{ncue} '.' ext_name];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        freq                = h_transform_freq(freq,{[1 2],[3 4]},{'Visual','Auditory'});
        
        cfg                  = [];
        cfg.baseline         = [-0.6 -0.2];
        cfg.baselinetype     = 'relchange';
        freq                 = ft_freqbaseline(cfg,freq);
        
        allsuj_data{sb,ncue} = freq; clear freq; 
        
    end
end

clearvars -except allsuj_data

for ncue = 1:size(allsuj_data,2)
    grand_average{ncue,1} = ft_freqgrandaverage([],allsuj_data{:,ncue});
end

clearvars -except allsuj_data grand_average

list_title = {'Minus Evoked'};

for ncue = 1:size(grand_average,1)
    
    figure;
    hold on;
    
    list_freq = [7 11; 11 15];
    
    i         = 0;
    
    for nfreq = 1:2
        for nchan = [2 1]
            
            lmf1 = find(round(grand_average{ncue,1}.freq) == round(list_freq(nfreq,1)));
            lmf2 = find(round(grand_average{ncue,1}.freq) == round(list_freq(nfreq,2)));
            
            data = squeeze(nanmean(grand_average{ncue,1}.powspctrm(nchan,lmf1:lmf2,:),2));
            
            if nchan == 2
                if nfreq == 1
                    plot(grand_average{ncue,1}.time,data,'-r','LineWidth',3);
                else
                    plot(grand_average{ncue,1}.time,data,'--r','LineWidth',3);
                end
            else
                if nfreq == 1
                    plot(grand_average{ncue,1}.time,data,'-b','LineWidth',3);
                else
                    plot(grand_average{ncue,1}.time,data,'--b','LineWidth',3);
                end
            end
            
            xlim([-0.2 2]);
            ylim([-0.3 0.3]);
            
            vline(1.2,'--k');
            
            list_name_freq       = {'7t11Hz','11t15Hz'};
            
            i               = i + 1;
            list_legend{i}  = [grand_average{ncue,1}.label{nchan} '.' list_name_freq{nfreq}];

        end
    end
    
    legend(list_legend);
    drawaxis(gca, 'x', 0, 'movelabel', 1)
    title(list_title{ncue});
    saveas(gcf,'~/GoogleDrive/PhD/Publications/Papers/alpha2017/eNeuro/prep/new_virt_minus_evoked.svg');
    
end