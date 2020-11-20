clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% lst_group       = {'Old','Young','allyoung'};

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

lst_group       = {'allyoung'};

for nf = 1:1
    
    for ngroup = 1:length(lst_group)
        
        suj_list = suj_group{ngroup};
        
        for sb = 1:length(suj_list)
            
            suj                     = suj_list{sb};
            cond_main               = 'CnD';
            
            frq_list                = {'50t120Hz'};
            
            ext_name1               = frq_list{nf};
            
            %             if strcmp(ext_name1,'20t50Hz')
            %                 ext_name2               = '20t48Hz';
            %             elseif strcmp(ext_name1,'1t20Hz')
            %                 ext_name2               = '1t19Hz';
            %             elseif strcmp(ext_name1,'50t120Hz')
            %                 ext_name2               = '50t118Hz';
            %             end
            
            fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.AllYungSeparatePlusCombined.' ext_name1 '.m800p2000msCov.waveletPOW.40t120Hz.m1000p2000.KeepTrials.100Slct.AudLR.MinEvoked.mat']; %100SlctAudLR.mat']; %m800p2000msCov.waveletPOW.' ext_name2 '.m3000p3000.KeepTrials.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            list_ix_cue        = {2,1,0,0};
            list_ix_tar        = {[2 4],[1 3],[2 4],[1 3]};
            list_ix_dis        = {0,0,0,0};
            list_ix            = {'R','L','NR','NL'};
            
            for cnd = 1:length(list_ix_cue)
                
                cfg                         = [];
                cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
                new_freq                    = ft_selectdata(cfg,freq);
                new_freq                    = ft_freqdescriptives([],new_freq);
                
                %                 list_chan                   = {[76 78],[77 79],[1:75 80:84]};
                %                 list_name                    = {'audL','audR'};
                %
                %                 for n = 1:length(list_chan)
                %
                %                     cfg = []; cfg.channel = list_chan{n};
                %                     if n <3; cfg.avgoverchan = 'yes'; end;
                %
                %                     tmp{n}      = ft_selectdata(cfg,new_freq);
                %                     if n <3 ; tmp{n}.label = list_name(n); end;
                %                 end
                %
                %                 cfg=[];cfg.parameter='powspctrm';cfg.appendim ='chan';new_freq=ft_appendfreq(cfg,tmp{:});clear tmp;
                
                %                 cfg                         = [];
                %                 cfg.time_start              = new_freq.time(1);
                %                 cfg.time_end                = new_freq.time(end);
                %                 cfg.time_step               = 0.05;
                %                 cfg.time_window             = 0.05;
                %                 new_freq                    = h_smoothTime(cfg,new_freq);
                
                %                 cfg                         = [];
                %                 cfg.latency                 = [-0.8 2];
                %                 cfg.channel                 = 1:2;
                %                 new_freq                    = ft_selectdata(cfg,new_freq);
                
                for nchan = 1:length(new_freq.label)
                    allsuj_data{ngroup}{sb,cnd,nchan}            = new_freq;
                    allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm  = new_freq.powspctrm(nchan,:,:);
                    allsuj_data{ngroup}{sb,cnd,nchan}.label      = new_freq.label(nchan);
                end
                
                clear new_freq cfg
                
            end
            
            
            for cnd =1:length(list_ix)
                for nchan = 1:size(allsuj_data{ngroup},3)
                    
                    cfg                                     = [];
                    
                    if strcmp(ext_name1,'20t50Hz')
                        cfg.baseline                        = [-0.4 -0.2];
                    elseif strcmp(ext_name1,'1t20Hz')
                        cfg.baseline                        = [-0.6 -0.2];
                    elseif strcmp(ext_name1,'50t120Hz')
                        cfg.baseline                        = [-0.3 -0.1];
                    end
                    
                    cfg.baselinetype                        = 'relchange';
                    allsuj_data{ngroup}{sb,cnd,nchan}       = ft_freqbaseline(cfg, allsuj_data{ngroup}{sb,cnd,nchan});
                    
                end
            end
        end
    end
    
    %     big_freq{nf} = allsuj_data; clear allsuj_data ;
    
end

clearvars -except allsuj_data big_freq

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,~]              = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [0.2 1];
    %     cfg.frequency           = [60 100];
    %     cfg.avgoverfreq         = 'yes';
    cfg.avgovertime         = 'yes';
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    cfg.correctm            = 'fdr';
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    list_compare            = [1 3; 2 4; 1 2];
    
    i = 0 ;
    
    for nchan = 1:size(allsuj_data{ngroup},3)
        
        i = i + 1;
        
        for ntest = 1:size(list_compare,1)
            stat{ngroup,i,ntest}     = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1),nchan}, allsuj_data{ngroup}{:,list_compare(ntest,2),nchan});
        end
    end
end


for ngroup = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(ngroup,nchan,ntest), p_val{ngroup,nchan,ntest}]      = h_pValSort(stat{ngroup,nchan,ntest}) ;
        end
    end
end

list_test   = {'R.NR','L.NL','R.L'}; %,'RL minus N'}; %,'RL rel N'};
list_group  = {'allyoung'};
plimit  = 0.1;

for ngroup = 1:size(stat,1)
    
    figure;
    
    i       = 0 ;
    
    for ntest = 1:size(stat,3)
        for nchan = size(stat,2):-1:1
            
            i = i + 1;
            
            zlimit                          = 2;
            
            s2plot                          = stat{ngroup,nchan,ntest};
            %             s2plot.mask                     = s2plot.prob < plimit;
            
            subplot(3,2,i)
            
            %             cfg                             = [];
            %             %             cfg.xlim                        = [0.5 1.1];
            %             %             cfg.ylim                        = list_freq{nfreq};
            %             cfg.parameter                   = 'stat';
            %             cfg.maskparameter               = 'mask';
            %             cfg.colorbar                    = 'no';
            %             cfg.maskstyle                   = 'outline';
            %             cfg.zlim                        = [-5 5];
            %             ft_singleplotTFR(cfg,s2plot);
            
            cfg             = [];
            cfg.ylim        = [-zlimit zlimit];
            cfg.linewidth   = 1;
            cfg.p_threshold = plimit;
            h_plotStatAvgOverDimension(cfg,s2plot);
            
            title([list_group{ngroup} '.' list_test{ntest} '.' s2plot.label{1} ' p limit at ' num2str(plimit)]);
            
            colormap('jet')
            
        end
    end
end

%             subplot(size(stat,1),size(stat,3),i)

%             s2plot      = stat{ngroup,nchan,ntest};
%             s2plot.mask = s2plot.prob < plimit;
%             plot(s2plot.time,squeeze(s2plot.mask .* s2plot.stat));
%             xlim([s2plot.time(1) s2plot.time(end)]);
%             ylim([-zlimit zlimit]);

%
% for ngroup = 1:length(big_freq{1})
%     for sb = 1:size(big_freq{1}{1},1)
%         for cnd = 1:size(big_freq{1}{1},2)
%             for nchan = 1:size(big_freq{1}{1},3)
%
%                 cfg             = [];
%                 cfg.parameter   = 'powspctrm';
%                 cfg.appendim    = 'freq';
%
%                 allsuj_data{ngroup}{sb,cnd,nchan} = ft_appendfreq(cfg,big_freq{1}{ngroup}{sb,cnd,nchan}, ...
%                     big_freq{2}{ngroup}{sb,cnd,nchan}, ...
%                     big_freq{3}{ngroup}{sb,cnd,nchan}) ;
%
%             end
%         end
%     end
% end
%
% clearvars -except allsuj_data big_freq
%
% load ../data_fieldtrip/grand_average/allyc_sujByR.L.NR.NL.RLAbsDiff.RLRelChange_AudLR.mat
%
% fOUT = '../documents/4R/Allyoung.RamaVirtual.AudLAudR.AlphaGamma.txt';
% fid  = fopen(fOUT,'W+');
% fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG');
%
%
% for ngroup = 1:length(allsuj_data)
%     for sb = 1:size(allsuj_data{ngroup},1)
%         for ncue = 1:4 % size(allsuj_data{ngroup},2)
%             for nchan = 1:size(allsuj_data{ngroup},3)
%
%                 frq_list = [7 7; 8 8; 9 9; 10 10; 11 11; 60 70; 70 80; 80 90; 90 100];
%
%                 tim_wind = 0.1;
%
%                 tim_list = 0.5:tim_wind:1.9;
%
%                 for nfreq = 1:size(frq_list,1)
%                     for ntime = 1:length(tim_list)
%
%                         ls_group = {'allyoung'};
%                         ls_cue   = {'R','L','R','L'};
%                         ls_chan  = allsuj_data{ngroup}{sb,ncue,nchan}.label;
%                         ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
%                         ls_freq  = [num2str(mean(frq_list(nfreq,:))) 'Hz'];
%
%                         x1       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.time,2)== round(tim_list(ntime),2));
%                         x2       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.time,2)== round(tim_list(ntime)+tim_wind,2));
%
%                         y1       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.freq)== round(frq_list(nfreq,1)));
%                         y2       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.freq)== round(frq_list(nfreq,2)));
%
%                         if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
%                             error('ahhhh')
%                         else
%                             pow      = mean(allsuj_data{ngroup}{sb,ncue,nchan}.powspctrm(1,y1:y2,x1:x2),3);
%                             pow      = squeeze(mean(pow,2));
%
%                             if size(pow,1) > 1 || size(pow,2) > 1
%                                 error('oohhhhhhh')
%                             else
%
%                                 if ncue > 2
%                                     cue_cat = 'uninformative';
%                                 else
%                                     cue_cat = 'informative';
%                                 end
%
%                                 original_cue_list = {'R','L','NR','NL'};
%
%                                 if strcmp(original_cue_list{ncue}(1),'N')
%                                     threewise = 'Neutral';
%                                 else
%                                     threewise = [original_cue_list{ncue} 'Cue'];
%                                 end
%
%                                 fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\n',ls_group{ngroup},['yc' num2str(sb)],ls_cue{ncue},ls_chan{:},ls_freq,ls_time,pow,cue_cat,original_cue_list{ncue},threewise);
%
%                                 %                                 fprintf('%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',ls_group{ngroup},['yc' num2str(sb)],ls_cue{ncue},ls_chan{:},ls_freq,ls_time,pow);
%                             end
%                         end
%
%                     end
%                 end
%             end
%         end
%     end
% end
%
% fclose(fid);