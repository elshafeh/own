clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

[~,suj_group{3},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{3}        = suj_group{3}(2:22);


for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        cond_subs               = {'R','NR','L','NL'};
        
        for cnd = 1:length(cond_subs)
            
            fname_in                = ['../data/' suj '/field/' suj '.' cond_subs{cnd} cond_main '.waveletPOW.1t150Hz.m3000p3000.AvgTrials.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                         = [];
            cfg.baseline                = [-0.6 -0.2];
            cfg.baselinetype            = 'relchange';
            freq                        = ft_freqbaseline(cfg,freq);
            
            cfg                         = [];
            cfg.frequency               = [5 15];
            cfg.latency                 = [-0.7 2.1];
            freq                        = ft_selectdata(cfg,freq);
            
            tmp{cnd}                    = freq; clear freq ;
            
        end
       
        cfg                             = [];
        cfg.operation                   = 'x1-x2';
        cfg.parameter                   = 'powspctrm';
        allsuj_data{ngrp}{sb,1}          = ft_math(cfg,tmp{1},tmp{2});
        allsuj_data{ngrp}{sb,2}          = ft_math(cfg,tmp{3},tmp{4});
        
        clear tmp
        
    end
end

clearvars -except allsuj_data

for ngroup = 1:length(allsuj_data)
    
    ix_test = [1 2];
   
    nsuj                        = size(allsuj_data{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'meg','t'); clc;
    
    for ntest = 1
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.latency             = [-0.2 1.2];
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        cfg.minnbchan           = 4;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ntest}      = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)},allsuj_data{ngroup}{:,ix_test(ntest,2)});
        stat{ngroup,ntest}      = rmfield(stat{ngroup,ntest},'cfg');
        
    end
end

clearvars -except allsuj_data list_ix_cue stat

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]  = h_pValSort(stat{ngroup,ntest}) ;
    end
end

clearvars -except allsuj_data list_ix_cue stat min_p p_val

list_ix_group = {'old','young','allyoung'};
list_ix_test  = {'RmNRvLmNL'};

i  = 0 ;

for ngroup = 1:size(stat,1)
    
    %     figure;
    
    for ntest = 1:size(stat,2)
        
        plimit                  = 0.11;%(0.05)/(size(stat,1)*size(stat,2));
        
        stat2plot               = h_plotStat(stat{ngroup,ntest},0.000000000000000000000000000001,plimit);
        
        twin                    = 0.2;
        tlist                   = stat{ngroup,ntest}.time(1):twin:stat{ngroup,ntest}.time(end);
        zlimit                  = 1;
        fwin                    = 0;
        flist                   = 7:15;
        
        i = i + 1;
        subplot(size(stat,1),size(stat,2),i)
        
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.zlim    = [-zlimit zlimit];
        cfg.marker  = 'off';
        cfg.comment = 'no';
        ft_topoplotER(cfg,stat2plot);
        
        title([list_ix_group{ngroup} ' ' list_ix_test{ntest} ' min_p @ ' num2str(min_p(ngroup,ntest))]);
        
        %         for f = 1:length(flist)
        %             for t = 1:length(tlist)-1
        %
        %                 i = i + 1;
        %
        %                 subplot(length(flist),length(tlist)-1,i)
        %
        %                 cfg         = [];
        %                 cfg.layout  = 'CTF275.lay';
        %                 cfg.xlim    = [tlist(t) tlist(t)+twin];
        %                 cfg.ylim    = [flist(f) flist(f)+fwin];
        %                 cfg.zlim    = [-zlimit zlimit];
        %                 cfg.marker  = 'off';
        %                 cfg.comment = 'no';
        %                 ft_topoplotER(cfg,stat2plot);
        %
        %                 tit_ext1    = [num2str(round(flist(f))) 'Hz'];
        %                 tit_ext2    = [num2str(round(mean([tlist(t) tlist(t)+twin])*1000)) 'ms'];
        %
        %                 title([tit_ext1 '.' tit_ext2])
        %
        %             end
        %         end
        
        
    end
end