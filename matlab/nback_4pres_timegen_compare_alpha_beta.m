clear ; close all;
clc;

suj_list 	= [1:33 35:36 38:44 46:51];

run_test    = 2;
ext_fix     = 'target';

for nsuj = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(nsuj))];
    
    list_lock                                   = {'auc'};
    list_cond                                   = {'alpha','beta'};
    
    for ncond = 1:length(list_cond)
        for nlock = 1:length(list_lock)
            
            i                                   = i +1;
            ext_lock                            = list_lock{nlock};
            flist                               = [];
            
            for nback = 1:2
                flist                         	= [flist;dir(['J:/nback/sens_level_auc/timegen/' suj_name '.sess*.' num2str(nback) 'back.' ...
                    list_cond{ncond} '.peak.centered.isfirst.bsl.excl.timegen.mat'])];
            end
            
            tmp                                 = [];
            
            for nf = 1:length(flist)
                fname                           = [flist(nf).folder filesep flist(nf).name];
                fprintf('Loading %s\n',fname);
                load(fname);
                tmp                             = cat(3,tmp,scores); clear scores;
            end
            
            pow(nlock,:,:)                      = mean(tmp,3); clear tmp;
            
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= list_lock;
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= pow;
        alldata{nsuj,ncond}                     = freq; clear pow ;
        
        fprintf('\n');
        
    end
end

keep alldata ns pow time_axis ext_lock list_cond

%%

list_test                                       = [1 2];
i                                               = 0;

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    
    cfg.latency                                 = [-0.1 1];
    cfg.frequency                               = cfg.latency;
    
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 0;
    cfg.tail                                    = 0;
    cfg.clustertail                             = 0;
    cfg.alpha                                   = 0.025;
    cfg.numrandomization                        = 1000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    
    nbsuj                                       = size(alldata,1);
    [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                                  = design;
    cfg.neighbours                              = neighbours;
    
    for nchan = 1:length(alldata{1,1}.label)
        
        cfg.channel                             = nchan;
        i                                       = i + 1;
        stat{i}                                 = ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
        
        [min_p(i),p_val{i}]                     = h_pValSort(stat{i});
        
        if isfield(stat{i},'negdistribution')
            stat{i}                             = rmfield(stat{i},'negdistribution');
        end
        if isfield(stat{i},'posdistribution')
            stat{i}                             = rmfield(stat{i},'posdistribution');
        end
        
        list_test_name{i}                       = [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)} ' ' stat{i}.label{1}];
        
    end
end

keep alldata list_* stat min_p p_val run_test ext_fix

%%

% save('../data/stat/nbac_timegen_alpha_v_beta_target_stim.mat','list_test','list_cond','list_test_name');

i                                         	= 0;
nrow                                    	= 2;
ncol                                     	= 3;

plimit                                      = 0.05;

for ntest = 1:length(stat)
    for nchan = 1:length(stat{ntest}.label)

        stat{ntest}.mask                    = stat{ntest}.prob < plimit;
        
        tmp                               	= stat{ntest}.mask(nchan,:,:) .* stat{ntest}.stat(nchan,:,:);
        ix                                	= unique(tmp);
        ix                                	= ix(ix~=0);
        
        if ~isempty(ix)
            
            i                           	= i + 1;
            
            cfg                          	= [];
            cfg.colormap                	= brewermap(256, '*RdBu');
            cfg.channel                 	= nchan;
            cfg.parameter               	= 'stat';
            cfg.maskparameter             	= 'mask';
            cfg.maskstyle               	= 'outline';
            cfg.zlim                      	= [-10 10];
            cfg.colorbar                  	='yes';
            
            nme                           	= stat{ntest}.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ntest});
            
            title([list_test_name{ntest} ' p = ' num2str(round(min_p(ntest),3))]);
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel('Training Time');
            xlabel('Testing Time');
            
            %             ylim([-0.5 1]);
            %             xlim([-0.5 1]);
            
            xticks([-0.5 0 0.5 1 1.5 2]);
            yticks([-0.5 0 0.5 1 1.5 2]);
            
            vline(0,'-k');
            hline(0,'-k');
            
            set(gca,'FontSize',10,'FontName', 'Calibri','FontWeight','normal');
            
            
        end
    end
end