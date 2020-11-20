clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51];
allpeaks                                = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                    = apeak; clear apeak;
    allpeaks(nsuj,2)                    = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)        = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_nback                              = [0 1 2];
    list_cond                               = {'0back','1back','2back'};
    list_freq                               = 3:30;
    
    list_color                              = 'rgb';
    
    for nback = 1:length(list_nback)
        
        list_lock                           = {'first.d'};
        
        pow                                 = [];
        
        for nfreq = 1:length(list_freq)
            for nlock = 1:length(list_lock)
                fname                       = ['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' ...
                    num2str(list_nback(nback)) 'back.agaisnt.all.' num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} 'wn70.bsl.excl.auc.mat'];
                
                fprintf('loading %s\n',fname);
                load(fname);
                pow(nlock,nfreq,:)          = scores; clear scores;
            end
        end

        %         list_name                   = {'alpha peak'};
        %         list_peak                   = [allpeaks(nsuj,1)];
        %         list_width                  = [1];
        
        list_name                   = {'beta peak'};
        list_peak                   = [allpeaks(nsuj,2)];
        list_width                  = [2];
        
        list_final                  = {};
        tmp                         = [];
        
        for np = 1:length(list_peak)
            
            xi                      = find(round(list_freq) == round(list_peak(np) - list_width(np)));
            yi                      = find(round(list_freq) == round(list_peak(np) + list_width(np)));
            
            zi                      = squeeze(pow(:,xi:yi,:)); clear xi yi;
            
            if size(zi,3) == 1
                tmp                 = [tmp; squeeze(nanmean(zi,1))];
            else
                tmp                 = [tmp;squeeze(nanmean(zi,2))];
            end
            
            clear zi;
            
            for luc = 1:length(list_lock)
                list_final{end+1}    = [list_name{np} ' ' list_lock{luc}];
            end
            
        end
        
        avg                         = [];
        avg.label                   = list_final; clear list_final
        avg.avg                     = tmp; clear tmp;
        avg.dimord                  = 'chan_time';
        avg.time                    = -1.5:0.02:2;
        
        alldata{nsuj,nback}         = avg; clear avg;
        
    end
    
    %     alldata{nsuj,3}                	= alldata{nsuj,1};
    %
    %     vct                             = alldata{nsuj,3}.avg;
    %     for xi = 1:size(vct,1)
    %         for yi = 1:size(vct,2)
    %
    %             ln_rnd                  = [0.49:0.001:0.51];
    %             rnd_nb                  = randi(length(ln_rnd));
    %             vct(xi,yi)              = ln_rnd(rnd_nb);
    %
    %         end
    %     end
    %
    %     alldata{nsuj,3}.avg             = vct; clear vct;
    
end

keep alldata list_*;

list_cond                           = {'0back','1back','2Back'};
list_test                           = [1 3; 2 3; 1 2];

for nt = 1:size(list_test,1)
    
    cfg                                 = [];
    cfg.statistic                       = 'ft_statfun_depsamplesT';
    cfg.method                          = 'montecarlo';
    cfg.correctm                        = 'cluster';
    cfg.clusteralpha                    = 0.05;
    
    cfg.latency                         = [-0.1 2];
    
    cfg.clusterstatistic                = 'maxsum';
    cfg.minnbchan                       = 0;
    cfg.tail                            = 0;
    cfg.clustertail                     = 0;
    cfg.alpha                           = 0.025;
    cfg.numrandomization                = 1000;
    cfg.uvar                            = 1;
    cfg.ivar                            = 2;
    
    nbsuj                               = size(alldata,1);
    [design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          = design;
    cfg.neighbours                      = neighbours;
    
    
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    list_test_name{nt}              = [list_cond{list_test(nt,1)} ' v ' list_cond{list_test(nt,2)}];
    
    [min_p(nt),p_val{nt}]           = h_pValSort(stat{nt});
    stat{nt}                        = rmfield(stat{nt},'negdistribution');
    stat{nt}                        = rmfield(stat{nt},'posdistribution');
end

save(['../data/stat/nbk.mtm.center.4cond.ag.all.' list_name{1} '.' list_lock{1}(1:end-2) '.mat'],'stat','list_test');

i                                   = 0;
nrow                                = 2;
ncol                                = 2;
z_limit                             = [0.47 0.8];
plimit                              = 0.05;

for nchan = 1:length(stat{1}.label)
    for nt = 1:length(stat)
        
        stat{nt}.mask                   = stat{nt}.prob < plimit;
        
        
        
        tmp                         = stat{nt}.mask(nchan,:,:) .* stat{nt}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                       = i + 1;
            subplot(nrow,ncol,i)
            
            nme                     = stat{nt}.label{nchan};
            
            cfg                     = [];
            cfg.channel             = stat{nt}.label{nchan};
            cfg.p_threshold        	= plimit;
            
            cfg.z_limit             = z_limit;
            cfg.time_limit          =stat{nt}.time([1 end]);
            
            ix1                     = list_test(nt,1);
            ix2                     = list_test(nt,2);
            
            cfg.color            	= list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,[ix1 ix2])));
            
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([stat{nt}.label{nchan} ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            xticks([0:0.4:2]);
            
            hline(0.5,'--k');
            vline(0,'--k');
            
        end
    end
end