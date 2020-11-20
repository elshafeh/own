clear ; clc ;

clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd_delay = 1:3
        
        load ../data/yctot/rt/rt_dis_per_delay.mat
        
        nwRt(sb,cnd_delay,1) = median([rt_dis{sb,cnd_delay}]);
        nwRt(sb,cnd_delay,2) = mean([rt_dis{sb,cnd_delay}]);
        
        lst         =   {'DIS','fDIS'};
        
        for cnd_dis = 1:2
            
            ext         = [num2str(cnd_delay) '.AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat'];
            fname_in    = ['../data/tfr/' suj '.'  lst{cnd_dis} ext];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            freq        = rmfield(freq,'hidden_trialinfo');
            
            nw_chn  = [3 5;4 6];
            nw_lst  = {'audL','audR'};
            
            for l = 1:2
                cfg             = [];
                cfg.channel     = nw_chn(l,:);
                cfg.avgoverchan = 'yes';
                nwfrq{l}        = ft_selectdata(cfg,freq);
                nwfrq{l}.label  = nw_lst(l);
            end
            
            cfg             = [];
            cfg.parameter   = 'powspctrm';
            cfg.appenddim   = 'chan';
            tmp{cnd_dis}    = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq ;
            
        end
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.operation       = 'subtract';
        freq                = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
        
        t_win   = 0.1;     tlist   = 0.3;
        ftap    = 30;        flist   = 50;
        
        for chn = 1:length(freq.label)
            for t = 1:length(tlist)
                for f = 1:length(flist)
                    
                    lmt1 = find(round(freq.time,2) == round(tlist(t),2));
                    lmt2 = find(round(freq.time,2) == round(tlist(t)+t_win,2));
                    
                    lmf1 = find(round(freq.freq) == round(flist(f)));
                    lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                    
                    data                                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
                    nwspctrm(sb,cnd_delay,chn,f,t)      = squeeze(mean(data,2));
                    
                end
            end
        end   
    end
end

clearvars -except nwspctrm nwRt ;

for chn = 1:2 
    subplot(1,4,chn)
    boxplot(squeeze(nwspctrm(:,:,chn)));   
    ylim([min(min(min(nwspctrm))) max(max(max(nwspctrm)))])
end

subplot(1,4,3)
boxplot(squeeze(nwRt(:,:,1)));
ylim([300 900]);
subplot(1,4,4)
boxplot(squeeze(nwRt(:,:,1)));
ylim([300 900]);

% for r = 1:2
%     for chn = 1:size(nwspctrm,3)
%         for f = 1:size(nwspctrm,4)
%             for t = 1:size(nwspctrm,5)
%                 
%                 for sb = 1:14
%                     data_tfr                = squeeze(nwspctrm(sb,:,chn,f,t));
%                     data_rt                 = nwRt(sb,:,r);
%                     [rho(sb),p(sb)]         = corr(data_tfr',data_rt' , 'type', 'Spearman');
%                 end
%                 
%                 pResults(r,chn,f,t) = permutation_test([rho',zeros(14,1)],1000);
%                 rResults(r,chn,f,t) = mean(rho);
%             end
%         end
%     end
% end
% 
% mask   = pResults < 0.05;
% squeeze(rResults(1,2,:,:) .* mask(1,2,:,:))