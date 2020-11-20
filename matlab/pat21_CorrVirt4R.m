clear ; clc ;  dleiftrip_addpath ;

fOUT = '../txt/SmallCovarianceCorrelationSepBands2taperWinInterest.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\t%5s\n','SUB','COND','CHAN','FREQ','TIME','CORR');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    fname       = ['../data/tfr/' suj '.CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse.KeepTrial.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    freq        = rmfield(freq,'hidden_trialinfo');
    
    nw_chn      = [1 1;2 2;3 5; 4 6];
    nw_lst      = {'occL','occR','audL','audR'};
    nw_frq      = [11 15; 11 15; 7 11; 7 11];
    
    for l = 1:size(nw_chn,1)
        
        cfg                         = [];
        cfg.frequency               = [nw_frq(l,1) nw_frq(l,2)];
        cfg.avgoverfreq             = 'yes';
        cfg.channel                 = nw_chn(l,:);
        cfg.avgoverchan             = 'yes';
        data                        = ft_selectdata(cfg,freq);
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        data                        = ft_freqbaseline(cfg,data);
        
        cfg                         = [];
        cfg.latency                 = [0.6 1];
        cfg.avgovertime             = 'yes';
        data                        = ft_selectdata(cfg,data);
        
        cnd_list = {'NCue','LCue','RCue'};
        
        for cnd = 1:3
            
            load  ../data/yctot/rt/rt_cond_classified.mat
            
            dataCond        = squeeze(data.powspctrm(rt_indx{sb,cnd},:));
            [rho,p]         = corr(dataCond,rt_classified{sb,cnd} , 'type', 'Spearman');
            rhoF            = .5.*log((1+rho)./(1-rho));
            
            fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\t%.4f\n',suj,cnd_list{cnd},nw_lst{l},'Hz','Ms',rhoF);
            
        end
    end
end

fclose(fid);

%     f_list = round(freq.freq);
%     t_list = 0.9;
%     twin   = 0.2;
%     cnd_list = {'NCue','LCue','RCue'};
%
%     for cnd = 1:3
%         for chn = 1:length(freq.label)
%             for t = 1:length(t_list)
%                 for f = 1:length(f_list)
%
%                     load  ../data/yctot/rt/rt_cond_classified.mat
%
%                     x           = find(round(freq.freq) == round(f_list(f)));
%                     y           = find(round(freq.time,2) == round(t_list(t),2));
%                     z           = find(round(freq.time,2) == round(t_list(t)+twin,2));
%
%                     ext_freq    = [num2str(f_list(f)) 'Hz'];
%                     ext_time    = [num2str(t_list(t)*1000) 'ms'];
%                     ext_chan    = freq.label{chn};
%                     ext_cond    = cnd_list{cnd};
%
%                     data        = squeeze(freq.powspctrm(rt_indx{sb,cnd},chn,x,y:z));
%                     data        = mean(data,2);
%                     [rho,p]     = corr(data,rt_classified{sb,cnd} , 'type', 'Spearman');
%
%                     rhoF        = .5.*log((1+rho)./(1-rho));
%
%                     fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\t%.4f\n',suj,ext_cond,ext_chan,ext_freq,ext_time,rhoF);
%
%                 end
%
%             end
%         end
%
%     end
%
% end
