clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51];


for nsuj = 1:length(suj_list)
    
    list_cond                               = {'0back','1back','2back'};
    list_freq                               = 3:30;
    
    list_color                              = 'rgb';
    
    for nback = 1:length(list_cond)
        
        list_lock                           = {'target.fft'};%,'first.fft','all.fft','nonrand.fft'};
        pow                                 = [];
        
        for nlock = 1:length(list_lock)
            fname                           = ['J:/temp/nback/data/fft/sub' num2str(suj_list(nsuj)) '.decoding.' ...
                list_cond{nback} '.agaisnt.all.lockedon.' list_lock{nlock} '.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nlock,:)                    = scores; clear scores;
        end
        
        avg                                 = [];
        avg.label                           = list_lock; clear list_final
        avg.avg                             = pow; clear pow;
        avg.dimord                          = 'chan_time';
        avg.time                            = time_axis;
        
        alldata{nsuj,nback}                 = avg; clear avg;
        
    end
    
end

list_test                           = [1 3; 2 3; 1 2];

for nt = 1:size(list_test,1)
    
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
    cfg.numrandomization                = 5000;
    cfg.uvar                            = 1;
    cfg.ivar                            = 2;
    
    nbsuj                               = size(alldata,1);
    [design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          = design;
    cfg.neighbours                      = neighbours;
    
    
    stat{nt}                            = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    list_test_name{nt}                  = [list_cond{list_test(nt,1)} ' v ' list_cond{list_test(nt,2)}];
    
    [min_p(nt),p_val{nt}]               = h_pValSort(stat{nt});
    
end

i                                       = 0;
nrow                                    = 2;
ncol                                    = 2;
z_limit                                 = [0.47 0.8];
plimit                                  = 0.05;

for nchan = 1:length(stat{1}.label)
    for nt = 1:length(stat)
        
        stat{nt}.mask             	= stat{nt}.prob < plimit;
        
        
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
            cfg.time_limit          = stat{nt}.time([1 end]);
            
            ix1                     = list_test(nt,1);
            ix2                     = list_test(nt,2);
            
            cfg.color            	= list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,[ix1 ix2])));
            
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([stat{nt}.label{nchan} ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',14,'FontName', 'Calibri');
                        
            hline(0.5,'--k');
            vline(0,'--k');
            
        end
    end
end