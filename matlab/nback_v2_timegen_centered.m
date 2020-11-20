clear ; close all;

suj_list 	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(nsuj))];
    
    list_lock                                   = {'alpha.peak.centered.lockedon.target','beta.peak.centered.lockedon.target'};
    list_cond                                   = {'1back','2back'};
        
    for ncond = 1:length(list_cond)
        for nlock = 1:length(list_lock)
                                    
            if strcmp(list_cond{1}(1:5),'alpha')
                flist                       	= dir(['J:/nback/sens_level_auc/timegen/' suj_name '.sess*.' list_lock{nlock} '.' list_cond{ncond} ...
                    '.decoding.stim*.bsl.excl.timegen.mat']);
            else
                flist                       	= dir(['J:/nback/sens_level_auc/timegen/' suj_name '.sess*.' list_cond{ncond} '.' list_lock{nlock} ...
                    '.decoding.stim*.bsl.excl.timegen.mat']);
            end
            
            if isempty(flist)
                error('no files found')
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
        
    end
    
end

keep alldata list_* run_test ext_fix

%%

if size(alldata,2) > 2
    list_test                            	= [1 2; 3 4];
else
    list_test                               = [1 2];
end

i                                           = 0;

for ntest = 1:size(list_test,1)
    
    cfg                                  	= [];
    cfg.statistic                           = 'ft_statfun_depsamplesT';
    cfg.method                              = 'montecarlo';
    cfg.correctm                            = 'cluster';
    cfg.clusteralpha                      	= 0.05;
    
    cfg.latency                             = [-0.1 1];
    cfg.frequency                          	= cfg.latency;
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                          	= 0;
    cfg.tail                             	= 0;
    cfg.clustertail                       	= 0;
    cfg.alpha                           	= 0.025;
    cfg.numrandomization                 	= 1000;
    cfg.uvar                             	= 1;
    cfg.ivar                             	= 2;
    
    nbsuj                                	= size(alldata,1);
    [design,neighbours]                     = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          	= design;
    cfg.neighbours                      	= neighbours;
    
    for nchan = 1:length(alldata{1,1}.label)
        
        cfg.channel                     	= nchan;
        i                                   = i + 1;
        stat{i}                         	= ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
        
        [min_p(i),p_val{i}]                 = h_pValSort(stat{i});
        
        if isfield(stat{i},'negdistribution')
            stat{i}                         = rmfield(stat{i},'negdistribution');
        end
        if isfield(stat{i},'posdistribution')
            stat{i}                         = rmfield(stat{i},'posdistribution');
        end
        
        list_test_name{i}                   = {[list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}], stat{i}.label{1}};
        
    end
end

keep alldata list_* stat min_p p_val run_test ext_fix

%%

i                                         	= 0;
nrow                                    	= 2;
ncol                                     	= 2;

plimit                                      = 0.05;% ./ length(list_test_name);

for ntest = 1:length(stat)
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
            cfg.colorbar                  	= 'yes';
            
            nme                           	= stat{ntest}.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ntest});
            
            title(list_test_name{ntest});
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel({['p= ' num2str(round(min(ix),3))],'Training Time'});
            xlabel('Testing Time');
            
            xticks([-0.5 0 0.2 0.4 0.6 0.8 1]);
            yticks([-0.5 0 0.2 0.4 0.6 0.8 1]);
            
            vline(0,'-k');
            hline(0,'-k');
            
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
            
            
        end
    end
end