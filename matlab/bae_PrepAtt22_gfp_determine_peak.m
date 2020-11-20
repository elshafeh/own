clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
%
% suj_list        = [suj_group{1};suj_group{2}];

for sb = 1:21 %length(suj_list)
    
    suj                 = ['yc' num2str(sb)]; %suj_list{sb};
    cond_main           = 'nDT';
    cond_sub            = {''};
    
    for ncue = 1:length(cond_sub)
        
        fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in);
        
        cfg                                 = [];
        cfg.baseline                        = [-0.1 0];
        data_pe                             = ft_timelockbaseline(cfg,data_pe);
        
        cfg                                 = [];
        cfg.method                          = 'amplitude';
        data_gfp                            = ft_globalmeanfield(cfg,data_pe);
        
        x1                                  = find(round(data_gfp.time,3) == round(0.08,3));
        x2                                  = find(round(data_gfp.time,3) == round(0.12,3));
        avg                                 = data_gfp.avg;
        avg(1:x1-1)                         = 0;
        avg(x2+1:end)                       = 0;
        a_peak                              = find(avg==max(avg));
        t_peak                              = data_gfp.time(a_peak);
        win_width                           = 0.01;
        
        peak_info{sb,1}                     = suj;
        peak_info{sb,2}                     = [cond_sub{ncue} cond_main];
        peak_info{sb,3}                     = [t_peak-win_width t_peak+win_width];
        
        clearvars -except sb ncue cond_main cond_sub suj_list peak_info ; clc ; 
        
    end
end

peak_info   = cell2table(peak_info,'VariableNames',{'SUB','COND','TWIN'});

save('../data_fieldtrip/index/allYoungControl.nDT.N1Latency.20msWide.mat','peak_info');