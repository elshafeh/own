clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    dir_data                        = '~/Dropbox/project_me/data/bil/virt/';
    
    fname                           = [dir_data subjectName '.wallis.alpha.beta.peak.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    test_band                       = 'gamma';
    
    switch test_band
        case 'alpha'
            peak_focus          	= 1;
            bn_width             	= peak_focus;
            allpeaks                = allpeaks(:,peak_focus);
            fnd_nan                 = find(isnan(allpeaks));
            if ~isempty(fnd_nan)
                allpeaks(fnd_nan)   = nanmean(allpeaks);
            end
        case 'beta'
            peak_focus              = 2;
            bn_width                = peak_focus;
            allpeaks                = allpeaks(:,peak_focus);
            fnd_nan                 = find(isnan(allpeaks));
            if ~isempty(fnd_nan)
                allpeaks(fnd_nan)   = nanmean(allpeaks);
            end
        case 'gamma'
            allpeaks(:)             = 80;
            bn_width                = 20;
        case 'theta'
            allpeaks(:)             = 4;
            bn_width                = 1;
    end
    
    %     allpeaks(:)                     = 80;
    
    list_cond{1}                    = {'pre','correct','*'};
    list_cond{2}                    = {'retro','correct','*'};
    
    list_cond{3}                    = {'*','correct','*'};
    list_cond{4}                    = {'*','incorrect','*'};
    
    list_cond{5}                    = {'*','correct','fast'};
    list_cond{6}                    = {'*','correct','slow'};
    
    list_cond{7}                    = {'pre','correct','*'};
    list_cond{8}                    = {'pre','incorrect','*'};
    
    list_cond{9}                    = {'retro','correct','*'};
    list_cond{10}                   = {'retro','incorrect','*'};
    
    for ncond = 1:length(list_cond)
        
        fprintf('\n');
        
        ext_name                    = ['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.mtm.1t100Hz'];
        
        ext_cue                     = list_cond{ncond}{1};
        ext_cor                     = list_cond{ncond}{2};
        ext_rea                     = list_cond{ncond}{3};
        
        flist                       = dir([ext_name '.' ext_cue '.' ext_cor '.' ext_rea '.mat']);
        pow                         = [];
        
        for nfile = 1:length(flist)
            fname                   = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nfile,:,:,:)        = freq.powspctrm;
        end
        
        freq.powspctrm              = squeeze(mean(pow,1));
        pow                         = [];
        
        for nchan = 1:length(freq.label)
            % choose frequency band
            xi                      = find(round(freq.freq) == round(allpeaks(nchan)-bn_width));
            yi                      = find(round(freq.freq) == round(allpeaks(nchan)+bn_width));
            pow                     = [pow;squeeze(mean(freq.powspctrm(nchan,xi:yi,:),2))'];
        end
        
        
        avg                         = [];
        avg.avg                     = pow; clear pow;
        avg.label                   = freq.label;
        avg.dimord                  = 'chan_time';
        avg.time                    = freq.time; clear freq;
        
        % baseline correct
        t1                          = find(round(avg.time,2) == round(-0.4,2));
        t2                          = find(round(avg.time,2) == round(-0.2,2));
        bsl                         = nanmean(avg.avg(:,t1:t2),2);
        avg.avg                     = (avg.avg - bsl) ./bsl;
        
        alldata{nsuj,ncond}         = avg; clear avg freq bsl xi yi t1 t2;
        
    end
end

keep alldata list_*

%%

list_test                           = [1 2; 3 4; 5 6; 7 8; 9 10];
list_name                           = {};
i                                   = 0;

for ntest = 1:size(list_test,1)
    
    nsuj                            = size(alldata,1);
    [design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;
    
    cfg                             = [];
    cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                        = 1;cfg.ivar = 2;
    cfg.tail                        = 0;cfg.clustertail  = 0;
    cfg.neighbours                  = neighbours;
    
    cfg.clusteralpha                = 0.05; % !!
    cfg.minnbchan                   = 0; % !!
    cfg.alpha                       = 0.025;
    
    cfg.numrandomization            = 1000;
    cfg.design                      = design;
    
    i                               = i +1;
    ix1                             = list_test(ntest,1);
    ix2                             = list_test(ntest,2);
    
    cfg.latency                     = [-0.2 5];
    
    list_name{i}                    = [[list_cond{ix1}{:}] ' versus ' [list_cond{ix2}{:}]];
    stat{i}                         = ft_timelockstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]            = h_pValSort(stat{i});
    
end

%%

close all;

for ntest = 1:length(stat)
    
    ix1                             = list_test(ntest,1);
    ix2                             = list_test(ntest,2);
    plimit                          = 0.2;
    
    if min_p(ntest) < plimit
        
        figure;
        nrow                            = 3;
        ncol                            = 3;
        i                               = 0;
        
        
        nw_stat                         = stat{ntest};
        nw_stat.mask                    = nw_stat.prob < plimit;
        
        mn_np_chan                      = [];
        
        for nchan = 1:length(nw_stat.label)
            tmp                         = nw_stat.prob(nchan,:);
            tmp(tmp == 0)               = NaN;
            mn_np_chan              	= [mn_np_chan;nanmin(tmp) nchan];
        end
        
        mn_np_chan                      = sortrows(mn_np_chan,1);
        nw_order                        = mn_np_chan(:,2);
        
        nw_stat.mask                    = nw_stat.mask(nw_order,:);
        nw_stat.stat                    = nw_stat.stat(nw_order,:);
        nw_stat.prob                    = nw_stat.prob(nw_order,:);
        nw_stat.label                	= nw_stat.label(nw_order);
        
        for sb = 1:size(alldata,1)
            for nc = 1:size(alldata,2)
                nwdata{sb,nc}           = alldata{sb,nc};
                nwdata{sb,nc}.avg       = nwdata{sb,nc}.avg(nw_order,:);
                nwdata{sb,nc}.label  	= nwdata{sb,nc}.label(nw_order);
            end
        end
        
        for nchan = 1:length(nw_stat.label)
            
            if mn_np_chan(nchan,1) < plimit
                
                i = i+1;
                
                cfg                     = [];
                cfg.channel             = nchan;
                cfg.time_limit          = nw_stat.time([1 end]);
                cfg.color               = 'br';
                cfg.z_limit             = [-0.6 0.6];
                cfg.linewidth           = 5;
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nwdata(:,[ix1 ix2]))
                
                chk                     = nw_stat.prob(nchan,:);
                chk(chk==0)             = NaN;
                chk                     = nanmin(chk);
                
                title({list_name{ntest},nw_stat.label{nchan}});
                ylabel(['p= ' num2str(round(chk,3))]);
                
                vct_plt                 = [0 1.5 3 4.5 5.5];
                
                vline(vct_plt,'--k');
                xticklabels({'Cue1' 'Gab1' 'Cue2' 'Gab2' 'RT'}); % '1st Cue'
                xticks(vct_plt);
                hline(0,'--k');
                
                set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
                
                
            end
        end
    end
end