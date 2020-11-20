clear ; clc ;  dleiftrip_addpath ;

chk_out = [];

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.conv.5t18Hz.m4p4.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    c_list = 2;
    f_list = 13;
    t_list = 0.9;
    
    for chn = 1:length(c_list)
        
        for t = 1:length(t_list)
            
            for f = 1:length(f_list)
                
                load  ../data/yctot/rt/rt_CnD_adapt.mat
                
                x = find(round(freq.freq) == round(f_list(f)));
                y = find(round(freq.time,2) == round(t_list(t),2));
                z = find(round(freq.time,2) == round(t_list(t)+0.2,2));
                
                ext_freq    = [num2str(f_list(f)) 'Hz'];
                ext_time    = [num2str(t_list(t)*1000) 'ms'];
                
                data        = squeeze(freq.powspctrm(:,c_list(chn),x,y:z));
                data        = mean(data,2);
                [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                data = mean(data);
                
                chk_out = [chk_out [data;mean(rt_all{sb})]];
                
            end
            
        end
    end
    
end

x = chk_out(1,:);
y = chk_out(2,:);

b1 = x/y;

yCalc1 = b1*x;
scatter(x,y);
hold on
plot(x,yCalc1);
