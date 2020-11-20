clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   '.AudFrontal4Alpha.VirtTimeCourse.all.wav.NewEvoked.1t20Hz.m3000p3000.mat';
    lst         =   {'DIS','fDIS'};
    
    lcue        = 'RLN';
    
    for cue = 1:length(lcue)
        for delay = 1:3
            for cnd_dis = 1:2
                fname_in    = ['../data/tfr/' suj '.'  lcue(cue) lst{cnd_dis} num2str(delay) ext];
                fprintf('\nLoading %50s \n',fname_in);
                load(fname_in)
                
                if isfield(freq,'hidden_trialinfo');
                    freq = rmfield(freq,'hidden_trialinfo');
                end
                
                tfdis{cnd_dis}      = freq; clear freq ;
                
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'powspctrm';
            cfg.operation                       = 'subtract';
            freq                                = ft_math(cfg,tfdis{1},tfdis{2}); clear tf_dis ;
            
            cfg                                 = [];
            cfg.baseline                        = [-0.5 -0.3];
            cfg.baselinetype                    = 'absolute';
            freq                                = ft_freqbaseline(cfg,freq);
            
            cfg                                 = [];
            cfg.channel                         = 1:2;
            cfg.frequency                       = [7 15];
            cfg.latency                         = [0.3 0.6];
            cfg.avgovertime                     = 'yes';
            cfg.avgoverfreq                     = 'yes';
            freq                                = ft_selectdata(cfg,freq);
            
            data2box(sb,cue,delay,:)            = squeeze(freq.powspctrm); clear freq ;
            
        end
    end
end

clearvars -except data2box

data2box = data2box ./ 10^23;

for chn = 1:2    
    nw_data = squeeze(data2box(:,:,:,chn));  
    pow = squeeze(mean(nw_data,1));
    sem = squeeze(std(nw_data,1)) ./ sqrt(14) ;   
    palete = 'brg';    
    subplot(1,2,chn);
    for cue = 1:size(pow,1)
        hold on
        errorbar(pow(cue,:),sem(cue,:),palete(cue),'LineWidth',5);
    end
    set(gca,'Xtick',0:1:5);
    xlim([0 4])
    set(gca,'Xtick',0:5,'XTickLabel', {'','DIS1','DIS2','DIS3',''})
    legend({'R','L','N'}, 'Location', 'Northeast')   
end

% figure;
% for delay = 1:3
%     subplot(1,3,delay)
%     boxplot(squeeze(data2box(:,:,delay)),'labels', ...
%         {['N' num2str(delay)],['L' num2str(delay)],['R' num2str(delay)]});
% end
% 
% lcue = 'NLR';
% figure;
% for cue = 1:3
%     subplot(1,3,cue)
%     for delay = 1:3
%         boxplot(squeeze(data2box(:,cue,:)),'labels', ...
%             {[lcue(cue) '1'],[lcue(cue) '2'],[lcue(cue) '3']});
%     end
% end