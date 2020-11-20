clear ; clc ;  dleiftrip_addpath ;

fOUT = '../txt/SmallCovarianceCorrelation.SingleFreq.SingleTime.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\t%5s\n','SUB','COND','CHAN','FREQ','TIME','CORR');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    fname       = ['../data/tfr/' suj '.CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse.KeepTrial.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    freq        = rmfield(freq,'hidden_trialinfo');
    
    nw_chn      = [1 1;2 2;3 5;4 6];
    nw_lst      = {'occL','occR','audL','audR'};
    
    for l = 1:length(nw_lst)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
    freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    f_list = 7:15;
    twin   = 0.1;
    t_list = 0.6:0.1:1;
    
    load  ../data/yctot/rt/rt_cond_classified.mat
    
    cnd_list = {'NCue','LCue','RCue'};
    
    for chn = 1:length(freq.label)
        for t = 1:length(t_list)
            for f = 1:length(f_list)
                for cnd = 1:length(cnd_list)
                    load  ../data/yctot/rt/rt_CnD_adapt.mat
                    
                    x = find(round(freq.freq)   == round(f_list(f)));
                    y = find(round(freq.time,2) == round(t_list(t),2));
                    z = find(round(freq.time,2) == round(t_list(t)+twin,2));
                    
                    data            = squeeze(freq.powspctrm(rt_indx{sb,cnd},chn,x,y:z));
                    data            = squeeze(mean(data,2));
                    [rho,p]         = corr(data,rt_classified{sb,cnd} , 'type', 'Spearman');
                    rhoF            = .5.*log((1+rho)./(1-rho));
                    
                    ext_frq         = [num2str(round(f_list(f))) 'Hz'];
                    ext_tim         = [num2str(round(t_list(t)*1000)) 'ms'];
                    
                    fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\t%.4f\n',suj,cnd_list{cnd},freq.label{chn},ext_frq,ext_tim,rhoF);
                    
                    
                end
            end
        end
    end
end

fclose(fid);