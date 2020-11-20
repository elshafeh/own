clear ; clc ;

addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));
addpath('../scripts.m/');

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

[~,suj_group{3},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{3}        = suj_group{3}(2:22);

lst_group       = {'Old','Young','allyoung'};

subjects_done   = {};
subjects_where  = [];

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT';
        cond_sub            = {'','V','R','L','N','NR','NL'};
        
        list_ix_cue        = {0:2,[1 2],2,1,0,0,0};
        list_ix_tar        = {1:4,1:4,1:4,1:4,1:4,[2 4],[1 3]};
        list_ix_dis        = {0,0,0,0,0,0,0};
        
        where_suj          = find(strcmp(subjects_done,suj));
        
        if ~isempty(where_suj)

            fprintf('%s has been loaded already !\n',fname_in);
            
            wh_grp = subjects_where(where_suj,1);
            wh_suj = subjects_where(where_suj,2);
            
            for ncue = 1:length(cond_sub)
                allsuj_data{ngroup}{sb,ncue} = allsuj_data{wh_grp}{wh_suj,ncue};
                for ntest = 1:3
                    allsuj_behav{ngroup}{sb,ncue,ntest} = allsuj_behav{wh_grp}{wh_suj,ncue,ntest};
                end
            end
            
        else
            
            subjects_done{end+1} = suj;
            subjects_where       = [subjects_where; ngroup sb];
            
            for ncue = 1:length(cond_sub)
                
                if strcmp(cond_main,'CnD')
                    fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
                else
                    fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
                end
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                cfg                                 = [];
                cfg.baseline                        = [-0.1 0];
                data_pe                             = ft_timelockbaseline(cfg,data_pe);
                
                cfg                                 = [];
                cfg.method                          = 'amplitude';
                data_gfp                            = ft_globalmeanfield(cfg,data_pe);
                
                cfg                                 = [];
                cfg.time_start                      = data_gfp.time(1);
                cfg.time_end                        = data_gfp.time(end);
                cfg.time_step                       = 0.05;
                cfg.time_window                     = 0.05;
                data_gfp                            = h_smoothTime(cfg,data_gfp);
                
                allsuj_data{ngroup}{sb,ncue}        = data_gfp; clear data_*
                
                list_ix_cue                 = 0:2;
                list_ix_tar                 = 1:4;
                list_ix_dis                 = 1;
                [dis1_median,dis1_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
                
                list_ix_dis                 = 2;
                [dis2_median,dis2_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
                
                list_ix_dis                 = 0;
                [dis0_median,dis0_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
                
                list_ix_cue                 = [1 2];
                list_ix_tar                 = 1:4;
                list_ix_dis                 = 0;
                [inf_median,inf_mean,~,~]   = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
                
                list_ix_cue                 = 0;
                [unf_median,unf_mean,~,~]   = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
                
                allsuj_behav{sb,1}          = dis2_median - dis1_median;
                %     allsuj_behav{sb,2}          = dis2_mean - dis1_mean;
                
                allsuj_behav{sb,3}          = unf_median - inf_median;
                %     allsuj_behav{sb,4}          = unf_mean - inf_mean ;
                
                allsuj_behav{sb,5}          = dis0_median - dis1_median;
                allsuj_behav{sb,6}          = dis0_mean - dis1_mean ;
                
            end
         end   
    end
end

clearvars -except allsuj_data allsuj_behav lst_group list_ix cond_sub

% [~,neighbours]          = h_create_design_neighbours(14,allsuj_GA{1}{1},'meg','t'); clc;

for ngroup = 1:length(allsuj_data)
    for ncue = 1:size(allsuj_behav{ngroup},2)
        for ntest = 1:size(allsuj_behav{ngroup},3)
            
            cfg                                 = [];
            cfg.latency                         = [-0.1 0.6];
            cfg.method                          = 'montecarlo';
            cfg.statistic                       = 'ft_statfun_correlationT';
            cfg.correctm                        = 'cluster';
            cfg.clusterstatistics               = 'maxsum';
            cfg.clusteralpha                    = 0.05;
            cfg.tail                            = 0;
            cfg.clustertail                     = 0;
            cfg.alpha                           = 0.025;
            cfg.numrandomization                = 1000;
            cfg.ivar                            = 1;
            
            cfg.type                            = 'Spearman';
            
            nsuj                                = size(allsuj_behav{ngroup},1);
            cfg.design(1,1:nsuj)                = [allsuj_behav{ngroup}{:,ncue,ntest}];
            
            lst_behav                           = {'medianRT','meanRT','perCorrect'};
            
            stat{ngroup,ncue,ntest}       = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ncue});
            
            stat{ngroup,ncue,ntest}       = rmfield(stat{ngroup,ncue,ntest},'cfg');
            
            stat{ngroup,ncue,ntest}.label = {[lst_group{ngroup} '.' cond_sub{ncue} '.' lst_behav{ntest}]};
            
        end
    end
end


for ngroup = 1:size(stat,1)
    
    figure;
    i       =  0 ;
    
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            i = i + 1;
            
            subplot(size(stat,2),size(stat,3),i)
            
            stat{ngroup,ncue,ntest}.mask    = stat{ngroup,ncue,ntest}.prob < 0.11;
            avg                             = stat{ngroup,ncue,ntest}.mask .* stat{ngroup,ncue,ntest}.stat;
            
            plot(stat{ngroup,ncue,ntest}.time,avg,'LineWidth',2);
            xlim([stat{ngroup,ncue,ntest}.time(1) stat{ngroup,ncue,ntest}.time(end)])
            ylim([-3 3])
            
            title([lst_group{ngroup} '.' cond_sub{ncue} 'CnD.' lst_behav{ntest}])
            
        end
    end
end