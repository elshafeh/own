clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                    	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data                  	= '~/Dropbox/project_me/data/nback/peak/';
    
    fname_in                 	= [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.equalhemi.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allpeaks(nsuj,1)            = apeak;
    allpeaks(nsuj,2)            = bpeak;
    
end

for nsuj = 1:length(suj_list)
    
    subjectname                         = ['sub' num2str(suj_list(nsuj))];
    
    list_cond                           = {'1back' '2back.sub'}; %{'slow' 'fast'}; %
    
    for ncond = 1:length(list_cond)
        
        test_band                       = 'alpha'; % alpha beta
        
        fname                           = '~/Dropbox/project_me/data/nback/conn/';
        fname                           = [fname subjectname '.' list_cond{ncond} '.wallis.coh.connectivity.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        list_band                       = {'alpha' 'beta'};
        
        switch test_band
            case 'alpha'
                f_focus              	= allpeaks(nsuj,1);
                f_width              	= 1;
            case 'beta'
                f_focus               	= allpeaks(nsuj,2);
                f_width               	= 2;
        end
        
        f1                          	= nearest(coh.freq,f_focus-f_width);
        f2                           	= nearest(coh.freq,f_focus+f_width);
        
        test_done                       = {};
        chan_label                      = {};
        data                            = [];
        i                               = 0;
        
        ext_seed                        = {'max occ'};
        ext_node                        = {'IPS0' 'Mid-IPS' 'Anterior IPS' 'SPL' 'FEF' 'iFEF' 'Anterior MFG' 'MTG'};
        
        for xi =  1:length(ext_seed)
            for yi = 1:length(ext_node)
                
                str_check_1             = [num2str(xi) '.' num2str(yi)];
                str_fnd_1               = find(strcmp(test_done,str_check_1));
                
                str_check_2             = [num2str(yi) '.' num2str(xi)];
                str_fnd_2               = find(strcmp(test_done,str_check_2));
                
                if isempty(str_fnd_1) && isempty(str_fnd_2)
                    
                    i                   = i + 1;
                    
                    find_seed         	= find(contains(coh.label,ext_seed{xi}));
                    find_node         	= find(contains(coh.label,ext_node{yi}));
                    
                    tmp                 = squeeze(coh.cohspctrm(find_seed,find_node,f1:f2,:));
                    
                    tmp                 = squeeze(nanmean(tmp,1));
                    tmp                 = squeeze(nanmean(tmp,1));
                    tmp                 = squeeze(nanmean(tmp,1));
                    
                    data(i,:)           = tmp; clear tmp;
                    test_done           = [test_done; [num2str(xi) '.' num2str(yi)]; [num2str(yi) '.' num2str(xi)]];
                    chan_label          = [chan_label; [ext_seed{xi} ' to ' ext_node{yi}]];
                    
                end
                
                
            end
        end
        
        avg             	= [];
        avg.time        	= coh.time;
        avg.label           = chan_label;
        avg.dimord      	= 'chan_time';
        avg.avg             = data; clear data;
        
        alldata{nsuj,ncond} = avg ; clear freq chan_label;
        
    end
    
end

%%

list_test                               = [1 2];
list_name                               = {};
i                                       = 0;

for ntest = 1:size(list_test,1)
    
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
    ix1                                 = list_test(ntest,1);
    ix2                                 = list_test(ntest,2);
    
    cfg.latency                         = [-1 2];
    
    list_name{i}                        = [[list_cond{ix1}] ' versus ' [list_cond{ix2}]];
    stat{i}                             = ft_timelockstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]                = h_pValSort(stat{i});
    
end

%%

nrow                                    = 2;
ncol                                    = 2;
i                                       = 0;


for ntest = 1:length(stat)
    
    ix1                                 = list_test(ntest,1);
    ix2                                 = list_test(ntest,2);
    plimit                              = 0.09;
    
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
                cfg.color               = {'-b' '-r'};
                cfg.z_limit             = [0.05 0.2];
                cfg.lineshape           = '-k';
                
                cfg.linewidth           = 5;
                
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nwdata(:,[ix1 ix2]))
                
                chk                     = nw_stat.prob(nchan,:);
                chk(chk==0)             = NaN;
                chk                     = nanmin(chk);
                
                title({[test_band],list_name{ntest},nw_stat.label{nchan}});
                ylabel(['p = ' num2str(round(chk,3))]);
                
                vline(0,'--k');
                hline(0,'--k');
                
                set(gca,'FontSize',12,'FontName', 'Calibri','FontWeight','normal');
                
                legend({list_cond{ix1} '' list_cond{ix2} '' });
                
            end
        end
    end
end