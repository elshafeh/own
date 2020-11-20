clear ; clc ; 

addpath('../scripts.m/');
addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/grand_average/allyc_sujByR.L.NR.NL.RLAbsDiff.RLRelChange_AudLR.mat

lst_group       = {'allyoung'};

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:4 
            for nchan = 2
                
                suj                     = ['yc' num2str(sb)];
                
                list_ix_cue             = {2,1,0,0};
                list_ix_tar             = {[2 4],[1 3],[2 4],[1 3]};
                list_ix_dis             = {0,0,0,0};
                list_ix                 = {'R','L','NR','NL'};
                
                [allsuj_behav{ngroup}{sb,ncue,nchan,1},allsuj_behav{ngroup}{sb,ncue,nchan,2}, ... 
                    allsuj_behav{ngroup}{sb,ncue,nchan,3},~] = h_behav_eval(suj,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue}); clc ;
                
                
            end
        end
    end
end

clearvars -except allsuj_data allsuj_behav lst_group list_ix

for ngroup = 1:length(allsuj_data)
    for ncue = 1:size(allsuj_behav{ngroup},2)
        for nchan = 2
            for ntest = 1:size(allsuj_behav{ngroup},4)
                
                cfg                                 = [];
                cfg.latency                         = [0.6 1.1];
                cfg.frequency                       = [50 100];
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
                cfg.design(1,1:nsuj)                = [allsuj_behav{ngroup}{:,ncue,nchan,ntest}];
                
                lst_behav                           = {'medianRT','meanRT','perCorrect'};
                
                stat{ngroup,ncue,nchan,ntest}       = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ncue,nchan});
                stat{ngroup,ncue,nchan,ntest}       = rmfield(stat{ngroup,ncue,nchan,ntest},'cfg');
                stat{ngroup,ncue,nchan,ntest}.label = {[lst_group{ngroup} '.' list_ix{ncue} '.' allsuj_data{ngroup}{1,ncue,nchan}.label{1} '.' lst_behav{ntest}]};
                
            end
        end
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for nchan = 2
            for ntest = 1:size(stat,4)
                [min_p(ngroup,ncue,nchan,ntest),p_val{ngroup,ncue,nchan,ntest}]     = h_pValSort(stat{ngroup,ncue,nchan,ntest});
            end
        end
    end
end

for nchan = 2
    
    figure;
    i = 0 ;
    
    for ncue = 1:size(stat,2)
        for ngroup = 1:size(stat,1)
            for ntest = 1:size(stat,4)
                
                stat{ngroup,ncue,nchan,ntest}.mask = stat{ngroup,ncue,nchan,ntest}.prob < 0.05;
                
                i = i+1 ;
                
                subplot(size(stat,2),size(stat,4),i)
                
                %                 cfg             = [];
                %                 cfg.ylim        = [-5 5];
                %                 cfg.linewidth   = 1;
                %                 cfg.p_threshold = 0.11;
                %
                %                 h_plotStatAvgOverDimension(cfg,stat{ngroup,ncue,nchan,ntest})
                
                cfg                 = [];
                cfg.parameter       = 'stat';
                cfg.maskparameter   = 'mask';
                cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                ft_singleplotTFR(cfg,stat{ngroup,ncue,nchan,ntest});
                
                title([stat{ngroup,ncue,nchan,ntest}.label ' p= ' num2str(min_p(ngroup,ncue,nchan,ntest))])
                
                colormap('jet')
                
                set(gca,'fontsize', 18)

                
            end
        end
    end
end


% load ../data_fieldtrip/stat/correlation_gavg_sensor_123OldYoungAllYoung_1234RLNC_123MedianMeanPerCorrect.mat
% 

% 
% for ngroup = 1:size(stat,1)
%     
%     figure;
%     i = 0;
%     
%     lst_group   = {'Old','Young','AllYoung'};
%     lst_cue     = {'RCnD','LCnD','NCnD','CnD'};
%     lst_msr     = {'medRT','meanRT','PerCorr'};
%     
%     for ncue = 1:size(stat,2)
%         for ntest = 1:size(stat,3)
%           
%             i = i + 1;
%             
%             stat{ngroup,ncue,ntest}.mask = stat{ngroup,ncue,ntest}.prob < 0.11;
%             
%             corr2plot.label         = stat{ngroup,ncue,ntest}.label;
%             corr2plot.freq          = stat{ngroup,ncue,ntest}.freq;
%             corr2plot.time          = stat{ngroup,ncue,ntest}.time;
%             corr2plot.powspctrm     = stat{ngroup,ncue,ntest}.rho .* stat{ngroup,ncue,ntest}.mask;
%             corr2plot.dimord        = stat{ngroup,ncue,ntest}.dimord;
%             
%             subplot(size(stat,2),3,i)
%             cfg                     = [];
%             cfg.comment             = 'no';
%             cfg.layout              = 'CTF275.lay';
%             cfg.zlim                = [-0.1 0.1];
%             ft_topoplotTFR(cfg,corr2plot);
%             title([lst_group{ngroup} ' ' lst_cue{ncue} ' ' lst_msr{ntest} ' ' num2str(min_p(ngroup,ncue,ntest))])
%             
%         end
%     end
% end

% addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));
% addpath('../scripts.m/');
%
% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);
%
% lst_group       = {'allyoung'};
%
% for ngroup = 1:length(lst_group)
%
%     suj_list = suj_group{ngroup};
%
%     for sb = 1:length(suj_list)
%
%         suj                     = suj_list{sb};
%         cond_main               = 'CnD';
%
%         fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.Rama.50t120Hz.m800p2000msCov.waveletPOW.50t118Hz.m3000p3000.KeepTrials.mat'];
%
%         fprintf('\nLoading %50s \n',fname_in);
%         load(fname_in)
%
%         if isfield(freq,'check_trialinfo')
%             freq = rmfield(freq,'check_trialinfo');
%         end
%
%         list_ix_cue             = {2,1,0,0};
%         list_ix_tar             = {[2 4],[1 3],[2 4],[1 3]};
%         list_ix_dis             = {0,0,0,0};
%         list_ix                 = {'R','L','NR','NL'};
%
%         for cnd = 1:length(list_ix_cue)
%
%             cfg                         = [];
%             cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
%             new_freq                    = ft_selectdata(cfg,freq);
%             new_freq                    = ft_freqdescriptives([],new_freq);
%
%             list_chan                   = {[76 78],[77 79],[1:75 80:84]};
%             list_name                    = {'audL','audR'};
%
%             for n = 1:length(list_chan)
%
%                 cfg = []; cfg.channel = list_chan{n};
%                 if n <3; cfg.avgoverchan = 'yes'; end;
%
%                 tmp{n}      = ft_selectdata(cfg,new_freq);
%                 if n <3 ; tmp{n}.label = list_name(n); end;
%             end
%
%             cfg=[];cfg.parameter='powspctrm';cfg.appendim ='chan';new_freq=ft_appendfreq(cfg,tmp{:});clear tmp;
%
%             cfg                         = [];
%             cfg.channel                 = 2;
%             new_freq                    = ft_selectdata(cfg,new_freq);
%
%             cfg                         = [];
%             cfg.baseline                = [-0.2 -0.1];
%             cfg.baselinetype            = 'relchange';
%             new_freq                    = ft_freqbaseline(cfg,new_freq);
%
%             for nchan = 1:length(new_freq.label)
%
%                 allsuj_data{ngroup}{sb,cnd,nchan}            = new_freq;
%                 allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm  = new_freq.powspctrm(nchan,:,:);
%                 allsuj_data{ngroup}{sb,cnd,nchan}.label      = new_freq.label(nchan);
%
%
%                 [allsuj_behav{ngroup}{sb,cnd,nchan,1},allsuj_behav{ngroup}{sb,cnd,nchan,2},allsuj_behav{ngroup}{sb,cnd,nchan,3},~] = h_behav_eval(suj,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}); clc ;
%
%             end
%
%             clear new_freq
%
%         end
%
%     end
%
% end
%
% clearvars -except allsuj_data allsuj_behav lst_group list_ix