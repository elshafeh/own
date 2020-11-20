clear ; close all;

suj_list 	= [1:33 35:36 38:44 46:51];

run_test    = 1;
ext_fix     = 'target';

for nsuj = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(nsuj))];
    
    switch run_test
        case 1
            list_lock                           = {'alpha.peak.centered.isfirst','beta.peak.centered.isfirst'}; % {'alpha.peak.centered.istarget','beta.peak.centered.istarget'};
        case 2
            list_lock                         	= {['alpha.peak.centered.lockedon.' ext_fix],['beta.peak.centered.lockedon.' ext_fix]};
    end
    
    
    list_cond                                   = {'0back','1back','2back'};
    
    for nback = 1:length(list_cond)
        for nlock = 1:length(list_lock)
            
            i                                   = i +1;
            ext_lock                            = list_lock{nlock};
            
            switch run_test
                case 1
                    flist                     	= dir(['J:/temp/nback/data/sens_level_auc/timegen/' suj_name '.sess*' ...
                        '.' list_cond{nback} '.' ext_lock '.bsl.excl.timegen.mat']);
                case 2
                    
                    flist                      	= dir(['J:/temp/nback/data/sens_level_auc/timegen/' suj_name '.decoding' ...
                        '.' list_cond{nback} '.agaisnt.all.' ext_lock '.bsl.excl.timegen.mat']);
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
        alldata{nsuj,nback}                     = freq; clear pow ;
        
    end
    
    %     alldata{nsuj,3}                            = alldata{nsuj,1};
    %     alldata{nsuj,3}.powspctrm(:)            	= 0.5;
    
end

keep alldata list_* run_test ext_fix

list_test                                       = [1 2; 1 3; 2 3];
i                                               = 0;

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    
    % cfg.latency                                 = [0 2];
    % cfg.frequency                               = cfg.latency;
    
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

switch run_test
    case 1
        save('../data/stat/nbac_timegen_centered_target_stim.mat','stat','list_test','list_cond','list_test_name');
    case 2
        save(['../data/stat/nbac_timegen_centered_' ext_fix '_cond.mat'],'stat','list_test','list_cond','list_test_name');
end

keep alldata list_* stat min_p p_val run_test ext_fix

i                                         	= 0;
nrow                                    	= 2;
ncol                                     	= 3;

plimit                                      = 0.1;

for ntest = [1 3 5 2 4 6]
    for nchan = 1:length(stat{ntest}.label)

        stat{ntest}.mask                    = stat{ntest}.prob < plimit;
        
        tmp                               	= stat{ntest}.mask(nchan,:,:) .* stat{ntest}.prob(nchan,:,:);
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
            cfg.zlim                      	= [-5 5];
            cfg.colorbar                  	='yes';
            
            nme                           	= stat{ntest}.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ntest});
            
            title([list_test_name{ntest} ' p=' num2str(round(min(ix),3))]);
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel('Training Time');
            xlabel('Testing Time');
            
            ylim([-0.5 2]);
            xlim([-0.5 2]);
            
            xticks([-0.5 0 0.5 1 1.5 2]);
            yticks([-0.5 0 0.5 1 1.5 2]);
            
            vline(0,'-k');
            hline(0,'-k');
            
            set(gca,'FontSize',10,'FontName', 'Calibri','FontWeight','normal');
            
            
        end
    end
end