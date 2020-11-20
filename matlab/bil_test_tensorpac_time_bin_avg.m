clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

load /Users/heshamelshafei/Dropbox/project_me/data/bil/virt/sub001.virtualelectrode.wallis.mat;
chan_list = data.label; clear data;

lim_suj                                 = length(dir('~/Dropbox/project_me/data/bil/virt/*.wallis.5t6Hz.chan22.gc.bin5.pac.mat'));

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    cond_list                           = {'bin1' 'bin5'}; %{'correct' 'incorrect'}; %
    
    load(['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.alpha.beta.peak.mat']);
    
    test_band                           = 'beta mean';
    
    switch test_band
        case 'alpha mean'
            peak_focus                  = 1;
            bn_width                    = peak_focus;
            allpeaks(:)                 = round(nanmean(allpeaks(:,peak_focus)));
        case 'beta mean'
            peak_focus                  = 2;
            bn_width                    = peak_focus;
            allpeaks(:)                 = round(nanmean(allpeaks(:,peak_focus)));
        case 'gamma'
            allpeaks(:)                 = 80;
            bn_width                    = 20;
        case 'alpha adapt'
            peak_focus                  = 1;
            bn_width                    = peak_focus;
            allpeaks                    = allpeaks(:,peak_focus);
            fnd_nan                     = find(isnan(allpeaks));
            if ~isempty(fnd_nan)
                allpeaks(fnd_nan)       = nanmean(allpeaks);
            end
        case 'beta adapt'
            peak_focus                  = 2;
            bn_width                    = peak_focus;
            allpeaks                    = allpeaks(:,peak_focus);
            fnd_nan                     = find(isnan(allpeaks));
            if ~isempty(fnd_nan)
                allpeaks(fnd_nan)       = nanmean(allpeaks);
            end
    end
    
    list_low                            = {'1t2Hz' '2t3Hz' '3t4Hz' '4t5Hz' '5t6Hz' '3t5Hz' };
    
    for nfreq = 1:length(list_low)
        for ncond = 1:2
            
            avg                         = [];
            avg.avg                     = [];
            
            for nchan = 1:22
                
                fname                   = ['~/Dropbox/project_me/data/bil/virt/' subjectName];
                fname                   = [fname  '.wallis.' list_low{nfreq} '.chan' num2str(nchan) '.gc.' cond_list{ncond} '.pac.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                xi                      = find(round(py_pac.freq) == round(allpeaks(nchan)-bn_width));
                yi                      = find(round(py_pac.freq) == round(allpeaks(nchan)+bn_width));
                
                avg.avg(nchan,:)        = mean(py_pac.powspctrm(xi:yi,:),1);
                avg.time                = py_pac.time;
                avg.label               = chan_list;
                avg.dimord              = 'chan_time'; clear xi yi py_pac;
                
            end
            
            t1                          = find(round(avg.time,3) == round(-0.4,3));
            t2                          = find(round(avg.time,3) == round(-0.2,3));
            bsl                         = mean(avg.avg(:,t1:t2),2);
            
            % apply baseline correction
            avg.avg                     = (avg.avg - bsl);% ./ bsl;
            
            alldata{nsuj,nfreq,ncond} 	= avg; clear avg t1 t2 bsl;clc;
            
        end
    end
end

keep alldata test_band cond_list list_low

%%

i                                       = 0;

for ntest = 1:size(alldata,2)
    
    nsuj                                = size(alldata,1);
    [design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;
    
    cfg                                 = [];
    cfg.clusterstatistic                = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                        = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                            = 1;cfg.ivar = 2;
    cfg.tail                            = 0;cfg.clustertail  = 0;
    cfg.neighbours                      = neighbours;
    
    cfg.clusteralpha                    = 0.05; % !!
    cfg.minnbchan                       = 0; % !!
    cfg.alpha                           = 0.025;
    
    cfg.numrandomization                = 1000;
    cfg.design                          = design;
    
    i                                   = i +1;
    
    cfg.latency                         = [-0.2 5.5];
    
    stat{i}                             = ft_timelockstatistics(cfg, alldata{:,ntest,1},alldata{:,ntest,2});
    [min_p(i), p_val{i}]                = h_pValSort(stat{i});
    
end

%%

figure;
nrow                                    = 2;
ncol                                    = 2;
i                                       = 0;

for ntest = 1:length(stat)
    
    plimit                              = 0.15;
    
    if min_p(ntest) < plimit
        
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
            for nc = 1:size(alldata,3)
                nwdata{sb,nc}           = alldata{sb,ntest,nc};
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
                %                 cfg.z_limit             = [-0.01 0.01];
                cfg.linewidth           = 5;
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nwdata);
                
                chk                     = nw_stat.prob(nchan,:);
                chk(chk==0)             = NaN;
                chk                     = nanmin(chk);
                
                title({list_low{ntest},[test_band],nw_stat.label{nchan}});
                ylabel(['p= ' num2str(round(chk,3))]);
                
                vct_plt                 = [0 1.5 3 4.5 5.5];
                
                vline(vct_plt,'--k');
                xticklabels({'Cue1' 'Gab1' 'Cue2' 'Gab2' 'RT'}); % '1st Cue'
                xticks(vct_plt);
                hline(0,'--k');
                
                set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
                
                legend({cond_list{1} '' cond_list{2} ''});
                
            end
        end
    end
end