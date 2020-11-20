clear ; global ft_default
ft_default.spmversion   = 'spm12';

load ../data/list/suj.list.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat
suj_list                = good_list;

for ns = 1:length(suj_list)
    
    subjectName                                             = ['sub' num2str(suj_list(ns))];clc;
    
    for nback = [0 1 2]
        
        % load data from both sessions
        i = 0;
        
        for nses = 1:2
            
            test_for                                        = 'beta';
            
            switch test_for
                case 'alpha'
                    fname                                 	= ['../data/tf/' subjectName '.sess' num2str(nses) '.' ...
                        num2str(nback) 'back.1t20Hz.1HzStep.AvgTrials.stakcombined.mat'];
                case 'beta'
                    fname                                  	= ['../data/tf/' subjectName '.sess' num2str(nses) '.' ...
                        num2str(nback) 'back.15t30Hz.1HzStep.AvgTrials.stakcombined.mat'];
            end
            
            if exist(fname)
                i = i +1;
                
                fprintf('loading %s\n',fname);
                load(fname);
                
                % baseline-correct
                cfg                                         = [];
                cfg.baseline                                = [-0.4 -0.2];
                cfg.baselinetype                            = 'relchange';
                freq_comb                                   = ft_freqbaseline(cfg,freq_comb);
                tmp{i}                                      = freq_comb; clear freq_comb;
                
            end
        end
        
        % avearge both sessions
        if length(tmp) > 1
            freq                                            = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        else
            freq                                            = tmp{1};
        end
        
        % load peak
        fname                                               = ['../data/peak/' subjectName '.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat'];
        fprintf('loading %s\n\n',fname);
        load(fname);
        
        % % define band-width - average across that and
        % % then fool fieldtrip :)
        
        switch test_for
            case 'alpha'
                bnd_width                                   = 1;
                xi                                          = find(round(freq.freq) == round(apeak - bnd_width));
                yi                                      	= find(round(freq.freq) == round(apeak + bnd_width));
            case 'beta'
                bnd_width                                 	= 2;
                xi                                        	= find(round(freq.freq) == round(bpeak - bnd_width));
                yi                                         	= find(round(freq.freq) == round(bpeak + bnd_width));
        end
        
        avg                                                 = [];
        avg.avg                                             = squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
        avg.label                                           = freq.label;
        avg.dimord                                          = 'chan_time';
        avg.time                                            = freq.time; clear freq;
        
        alldata{ns,nback+1}                                 = avg; clear avg;
        
    end
end

keep alldata test_for bnd_width

nb_suj                                                      = size(alldata,1);
[design,neighbours]                                         = h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                                                         = [];
cfg.latency                                                 = [-0.2 6];
cfg.statistic                                               = 'ft_statfun_depsamplesT';
cfg.method                                                  = 'montecarlo';
cfg.correctm                                                = 'cluster';
cfg.clusteralpha                                            = 0.05;
cfg.clusterstatistic                                        = 'maxsum';
cfg.minnbchan                                               = 3;
cfg.tail                                                    = 0;
cfg.clustertail                                             = 0;
cfg.alpha                                                   = 0.025;
cfg.numrandomization                                        = 1000;
cfg.uvar                                                    = 1;
cfg.ivar                                                    = 2;
cfg.neighbours                                              = neighbours;
cfg.design                                                  = design;

stat{1}                                                     = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
stat{2}                                                     = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,3});
stat{3}                                                     = ft_timelockstatistics(cfg, alldata{:,2}, alldata{:,3});

for nt   = 1:length(stat)
    [min_p(nt),p_val{nt}]                                   = h_pValSort(stat{nt});
end

save(['../data/stat/nback.snsr.tf.centered.' test_for '.' num2str(bnd_width) 'Hz.mat'],'stat');

keep stat alldata min_p p_val stat2plot test_for bnd_width

i                                                           = 0;

for nt  = 1:length(stat)
    
    stat{nt}.mask                                           = stat{nt}.prob < (0.05);
    
    stat2plot                                               = [];
    stat2plot.avg                                           = stat{nt}.mask .* stat{nt}.stat;
    stat2plot.label                                         = stat{nt}.label;
    stat2plot.dimord                                        = stat{nt}.dimord;
    stat2plot.time                                          = stat{nt}.time;
    
    cfg                                                     = [];
    cfg.layout                                              = 'neuromag306cmb.lay';
    cfg.zlim                                                = 'maxabs';
    cfg.colormap                                            = brewermap(256,'*RdBu');
    
    cfg.marker                                              = 'off';
    cfg.comment                                             = 'no';
    
    i                                                       = i +1;
    subplot(3,1,i)
    ft_topoplotER(cfg,stat2plot);
    
end

figure;
i                                                           = 0;

cfg                                                         = [];

switch test_for
    case 'alpha'
        cfg.channel 	= {'MEG1632+1633', 'MEG1642+1643', 'MEG1732+1733', 'MEG1832+1833', ...
            'MEG1842+1843', 'MEG1912+1913', 'MEG1922+1923', 'MEG1932+1933', 'MEG1942+1943', ...
            'MEG2012+2013', 'MEG2022+2023', 'MEG2032+2033', 'MEG2042+2043', 'MEG2112+2113', ...
            'MEG2122+2123', 'MEG2232+2233', 'MEG2242+2243', 'MEG2312+2313', 'MEG2322+2323', ...
            'MEG2332+2333', 'MEG2342+2343', 'MEG2442+2443', 'MEG2512+2513'};
end

cfg.p_threshold                                             = 0.05;
cfg.time_limit                                              = [-0.1 5.5];
cfg.z_limit                                                 = [-0.1 0.1];
cfg.color                                                   = 'br';

switch test_for
    case 'beta'
        cfg.channel     = {'MEG1732+1733', 'MEG1742+1743', 'MEG1922+1923', 'MEG1932+1933', 'MEG1942+1943', 'MEG2042+2043'};
end

i                                                           = i +1;
subplot(3,1,i)
h_plotSingleERFstat_selectChannel(cfg,stat{1},alldata(:,[1 2]));

switch test_for
    case 'beta'
        cfg.channel     ={'MEG0732+0733','MEG0742+0743','MEG1822+1823','MEG1832+1833','MEG2012+2013',...
            'MEG2022+2023','MEG2212+2213','MEG2232+2233','MEG2242+2243'};
        %         cfg.channel     = {'MEG0132+0133','MEG0212+0213','MEG0342+0343', 'MEG0712+0713', 'MEG0722+0723', 'MEG0732+0733', 'MEG0742+0743'};
end

i                                                           = i +1;
subplot(3,1,i)
h_plotSingleERFstat_selectChannel(cfg,stat{2},alldata(:,[1 3]));

switch test_for
    case 'beta'
        cfg.channel = {'MEG0732+0733','MEG0742+0743','MEG1832+1833','MEG1922+1923','MEG1932+1933','MEG2042+2043',...
            'MEG2212+2213','MEG2232+2233','MEG2242+2243'};
        %         cfg.channel     = {'MEG1842+1843', 'MEG1922+1923', 'MEG1932+1933', 'MEG2012+2013', 'MEG2022+2023', ...
        %             'MEG2032+2033', 'MEG2042+2043', 'MEG2112+2113', 'MEG2122+2123', 'MEG2332+2333', 'MEG2342+2343'};
end

i                                                           = i +1;
subplot(3,1,i)
h_plotSingleERFstat_selectChannel(cfg,stat{3},alldata(:,[2 3]));

%     %     figure;
%
%     time_win                                                = 1;
%     time_list                                               = [stat2plot.time(1):time_win:stat2plot.time(end)];
%
%     for t = 1:length(time_list)-1
%
%         i                                                   = i +1;
%
%         subplot(3,6,i)
%         cfg                                                 = [];
%         cfg.layout                                          = 'neuromag306cmb.lay';
%         cfg.zlim                                            = 'maxabs';
%
%         if t == length(time_list)
%             cfg.xlim                                        = [time_list(t) stat2plot.time(end)];
%         else
%             cfg.xlim                                        = [time_list(t) time_list(t)+time_win];
%         end
%
%         cfg.marker                                          = 'off';
%         cfg.comment                                         = 'no';
%         ft_topoplotER(cfg,stat2plot);
%
%         title(num2str(nt));
%
%     end
%
% end