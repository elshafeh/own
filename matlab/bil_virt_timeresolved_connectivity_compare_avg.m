clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                          	= suj_list{nsuj};
    list_cond                               = {'bin1' 'bin5'}; 
    
    for ncond = 1:length(list_cond)
        
        connec_measure                      = 'plv'; % plv coh.imag
        test_band                           = 'beta'; % theta alpha beta gamma
        
        fname                               = ['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.itc.' ... 
            list_cond{ncond} '.' connec_measure '.mat'];
        
        
        fprintf('loading %s\n',fname);
        load(fname);
                
        list_band                           = {'theta' 'alpha' 'beta' 'gamma'};
        
        f_center                            = find(strcmp(list_band,test_band));
        
        test_done                        	= {};
        chan_label                       	= {};
        data                            	= [];
        i                                   = 0;
        
        for xi =  1:length(coh.label) % [1] % 
            for yi = 1:length(coh.label)
                
                if xi ~= yi
                    
                    str_check_1         	= [num2str(xi) '.' num2str(yi)];
                    str_fnd_1             	= find(strcmp(test_done,str_check_1));
                    
                    str_check_2            	= [num2str(yi) '.' num2str(xi)];
                    str_fnd_2            	= find(strcmp(test_done,str_check_2));
                    
                    
                    if isempty(str_fnd_1) && isempty(str_fnd_2)
                        
                        i                   = i + 1;
                        
                        if isfield(coh,'cohspctrm')
                            tmp          	= squeeze(coh.cohspctrm(xi,yi,f_center,:));
                        elseif isfield(coh,'plvspctrm')
                            tmp          	= squeeze(coh.plvspctrm(xi,yi,f_center,:));
                        elseif isfield(coh,'ppcspctrm')
                            tmp          	= squeeze(coh.ppcspctrm(xi,yi,f_center,:));
                        elseif isfield(coh,'amplcorrspctrm')
                            tmp          	= squeeze(coh.amplcorrspctrm(xi,yi,f_center,:));
                        end
                        
                        data(i,:)           = tmp; clear tmp;
                        test_done           = [test_done; [num2str(xi) '.' num2str(yi)]; [num2str(yi) '.' num2str(xi)]];
                        chan_label          = [chan_label; [coh.label{xi} ' to ' coh.label{yi}]];
                        
                    end
                    
                end
                
            end
        end
        
        keep coh data nsuj suj_list ncond list_cond subjectName chan_label alldata connec_measure test_band
        
        avg                                 = [];
        avg.avg                             = data; clear data;
        avg.time                            = coh.time;
        avg.label                           = chan_label;
        avg.dimord                          = 'chan_freq_time';
        
        t1                                  = find(round(avg.time,2) == round(-0.4,2));
        t2                                  = find(round(avg.time,2) == round(-0.2,2));
        bsl                                 = mean(avg.avg(:,t1:t2),2);
        
        if ~strcmp(connec_measure,'coh.imag')
            avg.avg                     	= (avg.avg - bsl) ./ bsl;
        end
        
        alldata{nsuj,ncond}                 = avg ; clear freq chan_label;
        
    end
    
end

keep alldata list_cond connec_measure test_band

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
    
    cfg.latency                         = [-0.1 5.5];
    
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
    plimit                              = 0.2;
    
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
                cfg.z_limit             = [-0.3 0.7];
                cfg.linewidth           = 5;
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nwdata(:,[ix1 ix2]))
                
                chk                     = nw_stat.prob(nchan,:);
                chk(chk==0)             = NaN;
                chk                     = nanmin(chk);
                
                title({[connec_measure ' ' test_band],list_name{ntest},nw_stat.label{nchan}});
                ylabel(['p= ' num2str(round(chk,3))]);
                
                vct_plt                 = [0 1.5 3 4.5 5.5];
                
                vline(vct_plt,'--k');
                xticklabels({'Cue1' 'Gab1' 'Cue2' 'Gab2' 'RT'}); % '1st Cue'
                xticks(vct_plt);
                hline(0,'--k');
                
                set(gca,'FontSize',12,'FontName', 'Calibri','FontWeight','normal');
                
                
            end
        end
    end
end