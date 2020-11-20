clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
suj_list     = suj_group{1};

clearvars -except *suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cond_main           = 'CnD';
    list_ix_cond        = {'R','L','NR','NL'};
    
    for ntest = 1:length(list_ix_cond)
        
        fname_in               = ['../data/' suj '/field/' suj '.' list_ix_cond{ntest} cond_main '.7t15Hz.m800p1200ms.Aud2All.plv.mat'];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(fname_in)
        
        list_ix_bsl     = {'noBSL','absBSL','relBSL'};
        
        for nbsl = 1:3
            
            if nbsl ==1
                
                new_plv=freq_plv;
                
            else
                
                cfg                         = [];
                cfg.baseline                = [-0.6 -0.2];
                
                if nbsl == 2
                    cfg.baselinetype            = 'absolute';
                else
                    cfg.baselinetype            = 'relchange';
                end
                
                new_plv                    = ft_freqbaseline(cfg,freq_plv);
            end
            
            i = 0 ;
            
            for nchan = 1:length(new_plv.label)
                
                if strcmp(new_plv.label{nchan}(1:4),'audR') || nchan == 1
                    
                    i = i + 1 ;
                    allsuj_GA{sb,ntest,i,nbsl}            = new_plv;
                    allsuj_GA{sb,ntest,i,nbsl}.powspctrm  = new_plv.powspctrm(nchan,:,:);
                    allsuj_GA{sb,ntest,i,nbsl}.label      = {[new_plv.label{nchan} ' ' list_ix_bsl{nbsl}]};
                    
                end
            end
            
            clear new_plv
            
        end
    end
end

clearvars -except allsuj_* ; clc ;

% for sb = 1:size(allsuj_GA,1)
%     for nchan = 1:size(allsuj_GA,3)
%         for nbsl = 1:size(allsuj_GA,4)
%             tmp                         = allsuj_GA{sb,1,nchan,nbsl};
%             tmp.powspctrm               = allsuj_GA{sb,1,nchan,nbsl}.powspctrm - allsuj_GA{sb,3,nchan,nbsl}.powspctrm;
%             %             allsuj_GA{sb,1,nchan,nbsl}  = ;
%             tmp                         = allsuj_GA{sb,2,nchan,nbsl};
%             tmp.powspctrm               = allsuj_GA{sb,2,nchan,nbsl}.powspctrm - allsuj_GA{sb,4,nchan,nbsl}.powspctrm;
%         end
%     end
% end

[design,~]              = h_create_design_neighbours(size(allsuj_GA,1),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.latency             = [0.2 1.1];
cfg.frequency           = [7 15];
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ix_test                 = [1 3; 2 4; 1 2];

for ntest = 1:size(ix_test,1)
    for nchan = 1:size(allsuj_GA,3)
        for nbsl = 1:size(allsuj_GA,4)
            stat{ntest,nchan,nbsl}        = ft_freqstatistics(cfg, allsuj_GA{:,ix_test(ntest,1),nchan,nbsl}, allsuj_GA{:,ix_test(ntest,2),nchan,nbsl});
        end
    end
end

for ntest = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for nbsl = 1:size(stat,3)
            [min_p(ntest,nchan,nbsl),p_val{ntest,nchan,nbsl}]     = h_pValSort(stat{ntest,nchan,nbsl});
        end
    end
end

list_ix_test = {'R.RN','L.LN','R.L'};

for nchan = 1:size(stat,2)
    
    figure;
    i = 0 ;
    
    for nbsl =1:size(stat,3)
        for ntest = 1:size(stat,1)
            
            i = i + 1;
            
            stat{ntest,nchan,nbsl}.mask     = stat{ntest,nchan,nbsl}.prob < 0.11;
            
            subplot(size(stat,3),size(stat,1),i)
            
            cfg                 = [];
            cfg.parameter       = 'stat';
            cfg.maskparameter   = 'mask';
            cfg.colorbar        = 'no';
            cfg.maskstyle       = 'outline';
            cfg.zlim            = [-5 5];
            ft_singleplotTFR(cfg,stat{ntest,nchan,nbsl});
            title([list_ix_test{ntest} '.' stat{ntest,nchan,nbsl}.label '.' num2str(min_p(ntest,nchan,nbsl)) '.' num2str(nchan)]);
            colormap('jet')
            
            
        end
    end
end