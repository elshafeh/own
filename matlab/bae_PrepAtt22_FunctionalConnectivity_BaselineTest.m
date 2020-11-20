clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
suj_list     = suj_group{1};

clearvars -except *suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cond_main           = 'CnD';
    list_ix_cond        = {'R','L','NL','NR'};
    
    for ncue = 1:length(list_ix_cond)
        
        fname_in                           = ['../data/' suj '/field/' suj '.' list_ix_cond{ncue} cond_main '.7t15Hz.m800p1200ms.Aud2All.plv.mat'];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(fname_in)
        
        %         cfg                         = [];
        %         cfg.time_start              = freq_plv.time(1);
        %         cfg.time_end                = freq_plv.time(end);
        %         cfg.time_step               = 0.1;
        %         cfg.time_window             = 0.1;
        %         freq_plv                    = h_smoothTime(cfg,freq_plv);
        %         freq_plv                    = rmfield(freq_plv,'dof');
        
        [tmp{1},tmp{2}]    = h_prepareBaseline(freq_plv,[-0.6 -0.2],[7 15],[-0.2 1.1],'no');
        
        clear freq_plv
        
        for cnd = 1:2
            
            i = 0 ;
            
            for nchan = 1:length(tmp{1}.label)
                
                if strcmp(tmp{cnd}.label{nchan}(1:4),'audR') || nchan == 1
                    
                    i = i + 1;
                    
                    new_GA{sb,ncue,cnd,i}            = tmp{cnd};
                    new_GA{sb,ncue,cnd,i}.powspctrm  = tmp{cnd}.powspctrm(nchan,:,:);
                    new_GA{sb,ncue,cnd,i}.label      = tmp{cnd}.label(nchan);
                    
                end
                
            end
        end
        
        clear tmp
        
    end
end

clearvars -except new_GA list_ix_cond cond_main; clc ; 

chk = [];

for sb = 1:size(new_GA,1)
    for ncue = 1:size(new_GA,2)
        for cnd = 1:size(new_GA,3)
            for nchan = 1:size(new_GA,4)
                
                chk = [chk ; size(new_GA{sb,ncue,cnd,nchan}.powspctrm)];
                
            end
        end
    end
end

[design,~]              = h_create_design_neighbours(size(new_GA,1),new_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.latency             = [0.6 1.1];
cfg.avgovertime         = 'yes';
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

for ncue = 1:length(list_ix_cond)
    for nchan = 1:size(new_GA,4)
        stat{ncue,nchan}                    = ft_freqstatistics(cfg, new_GA{:,ncue,1,nchan}, new_GA{:,ncue,2,nchan});
    end
end

for ncue = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        [min_p(ncue,nchan),p_val{ncue,nchan}]       = h_pValSort(stat{ncue,nchan});
    end
end

% clear chan_indx
% chan_indx = {};
% for ix = 1:5:length(stat{1}.label)
%     chan_indx{end+1} = ix:1:ix+3;
% end

close all;

for xi = 1:20:size(stat,2)
    
    figure;
    i = 0 ;
    
    for yi = 0:19
        
        i = i + 1;
        subplot(5,4,i)
        hold on 
        
        for ncue = 1:size(stat,1)
            
            nchan           = xi+yi;
            
            if nchan < size(stat,2)+1
                
                cfg             = [];
                cfg.ylim        = [-5 5];
                cfg.linewidth   = 1;
                cfg.p_threshold = 0.11;

                h_plotStatAvgOverDimension(cfg,stat{ncue,nchan})
                
                %                 stat{ncue,nchan}.mask     = stat{ncue,nchan}.prob < 0.11;
                %                 cfg                 = [];
                %                 cfg.parameter       = 'stat';
                %                 cfg.maskparameter   = 'mask';
                %                 cfg.maskstyle       = 'outline';
                %                 cfg.zlim            = [-5 5];
                %                 ft_singleplotTFR(cfg,stat{ncue,nchan});
                %                 title([list_ix_cond{ncue} 'CnD ' stat{ncue,nchan}.label ' ' num2str(nchan) ' p= ' min_p(ncue,nchan)]);
                %                 colormap('jet')
                
            end
        end
        
        title([stat{ncue,nchan}.label ' ' num2str(nchan)]);
        legend(list_ix_cond);
        
    end
end