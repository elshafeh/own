clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                     = suj_list{nsuj};
    list_name                                       = {'cue1.to.gab1' 'gab1.to.cue2' 'cue2.to.gab2' 'gab2.to.resp'};
    list_cond                                    	= {'pre.correct' 'retro.correct'};
    
    for ncond = 1:length(list_cond)
        for ntime = 1:length(list_name)
            
            flist                                   = dir(['J:\temp\bil\conn\' subjectName '.yeo.coh.imag.' list_cond{ncond} '.' list_name{ntime} '.mat']);
            tmp=[];
            
            for nf = 1:length(flist)
                fname                               = [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp(nf,:,:,:)                       = coh.cohspctrm;
            end
            
            coh.cohspctrm                           = squeeze(mean(tmp,1));
            
            test_done                               = {};
            chan_label                              = {};
            data                                    = [];
            
            for xi = 1:length(coh.label)
                for yi = 1:length(coh.label)
                    
                    if xi ~= yi
                        
                        str_check_1               = [num2str(xi) '.' num2str(yi)];
                        str_fnd_1                 = find(strcmp(test_done,str_check_1));
                        
                        str_check_2               = [num2str(yi) '.' num2str(xi)];
                        str_fnd_2                 = find(strcmp(test_done,str_check_2));
                        
                        
                        if isempty(str_fnd_1) && isempty(str_fnd_2)
                            
                            tmp                 = coh.cohspctrm(xi,yi,:);
                            data                = [data; tmp]; clear tmp;
                            test_done           = [test_done; [num2str(xi) '.' num2str(yi)]; [num2str(yi) '.' num2str(xi)]];
                            chan_label          = [chan_label; [coh.label{xi} ' to ' coh.label{yi}]];
                            
                        end
                        
                    end
                    
                end
            end
            
            avg         = [];
            avg.time    = coh.freq;
            avg.label   = chan_label;
            avg.dimord  = 'chan_time';
            avg.avg     = squeeze(data); 
            alldata{nsuj,ntime,ncond} = avg; 
            
            keep nsuj suj_list subjectName alldata ncond ntime list_*
            
        end
    end
end

keep alldata list_*

for nt = 1:length(list_name)
    
    cfg                                 = [];
    cfg.statistic                       = 'ft_statfun_depsamplesT';
    cfg.method                          = 'montecarlo';
    cfg.correctm                        = 'cluster';
    cfg.clusteralpha                    = 0.05;
    cfg.clusterstatistic                = 'maxsum';
    cfg.minnbchan                       = 0;
    cfg.tail                            = 0;
    cfg.clustertail                     = 0;
    cfg.alpha                           = 0.025;
    cfg.numrandomization                = 1000;
    cfg.uvar                            = 1;
    cfg.ivar                            = 2;
    cfg.latency                         = [1 30];
    
    nbsuj                               = size(alldata,1);
    [design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1},'gfp','t');
    
    cfg.design                          = design;
    cfg.neighbours                      = neighbours;
    
    stat{nt}                            = ft_timelockstatistics(cfg, alldata{:,nt,1}, alldata{:,nt,2});
    
    [min_p(nt),p_val{nt}]               = h_pValSort(stat{nt});
    
end

i                                       = 0;
nrow                                    = 2;
ncol                                    = 2;
plimit                                  = 0.1;

for nt = 1:length(stat)
    
    stat{nt}.mask                       = stat{nt}.prob < plimit;
    
    for nchan = 1:length(stat{nt}.label)
        
        tmp                             = stat{nt}.mask(nchan,:,:) .* stat{nt}.prob(nchan,:,:);
        ix                              = unique(tmp);
        ix                              = ix(ix~=0);
        
        if ~isempty(ix)
            
            i = i +1;
            subplot(nrow,ncol,i)
            
            cfg                         = [];
            cfg.channel                 = stat{nt}.label{nchan};
            cfg.p_threshold             = plimit;
            cfg.time_limit              = stat{nt}.time([1 end]);
            cfg.z_limit                 = [-0.1 0.3];
            cfg.color                   ='br';
            
            h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,nt,:)))
            
            title([stat{nt}.label{nchan}  ' p = ' num2str(round(min(ix),4))]);
            ylabel(list_name{nt});
            
            %             legend({'' list_cond{1} '' list_cond{2} ''})
            
        end
    end
end