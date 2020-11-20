clear ; global ft_default
ft_default.spmversion   = 'spm12';

load ../data/list/suj.list.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat
suj_list                                    = good_list;

for nsuj = 1:length(suj_list)
    
    subjectname                                                     = ['sub' num2str(suj_list(nsuj))];
    list_time                                                       = {'m500m0','p500p1500','p2500p3500','p4500p5500'};
    
    load('../data/template/template_grid_0.5cm.mat');
    
    for nsession = 1:2
        for nback = [1 2 3]
            
            chk                                                     = dir(['../data/source/alpha/' subjectname '.session' num2str(nsession) '.' num2str(nback-1) 'back.*.dics.mat']);
            
            if ~isempty(chk)
                
                for ntime = 1:length(list_time)
                    
                    fname                                           = dir(['../data/source/alpha/' subjectname '.session' num2str(nsession) '.' num2str(nback-1) 'back.*.' list_time{ntime} '.dics.mat']);
                    fprintf('loading %s\n',fname.name);
                    load([fname.folder filesep fname.name]);
                    
                    source.pos                                      = template_grid.pos;
                    source.dim                                      = template_grid.dim;
                    
                    if ntime == 1 % keep first as baseline
                        bsl                                         = source.pow;
                    else
                        source.pow                                  = (source.pow - bsl) ./ bsl;
                        alldata{nsuj,nsession,nback,ntime-1}        = source;
                    end
                    
                    clear source
                    
                end
            end
        end
    end
    
    list_time                                       = list_time(2:end);
    
end

clearvars -except alldata list_time;

for nsuj = 1:size(alldata,1)
    for nback = 1:size(alldata,3)
        for ntime = 1:size(alldata,4)
            
            pow_1                                   = alldata{nsuj,1,nback,ntime};
            pow_2                                   = alldata{nsuj,2,nback,ntime};
            
            if isempty(pow_1)
                newdata{nsuj,nback,ntime}           = alldata{nsuj,2,nback,ntime};
            elseif isempty(pow_2)
                newdata{nsuj,nback,ntime}           = alldata{nsuj,1,nback,ntime};
            else
                newdata{nsuj,nback,ntime}           = ft_sourcegrandaverage([],alldata{nsuj,:,nback,ntime});
            end
            
            if isempty(newdata{nsuj,nback,ntime})
                error('empty struct found!');
            end
            
            clear pow_1 pow_2
            
        end
    end
end

alldata                                    = newdata; clear newdata;

clearvars -except alldata list_time;

for ntime = 1:size(alldata,3)
    
    ix_test = [1 2; 1 3; 2 3];
    
    for ntest = 1:size(ix_test,1)
        
        cfg                                 =   [];
        cfg.dim                             =   alldata{1}.dim;
        cfg.method                          =   'montecarlo';
        cfg.statistic                       =   'depsamplesT';
        cfg.parameter                       =   'pow';
        cfg.correctm                        =   'cluster';
        
        cfg.clusteralpha                    =   0.01;             % First Threshold
        
        cfg.clusterstatistic                =   'maxsum';
        cfg.numrandomization                =   1000;
        cfg.alpha                           =   0.025;
        cfg.tail                            =   0;
        cfg.clustertail                     =   0;
        
        nsuj                                =   size(alldata,1);
        
        cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                            =   1;
        cfg.ivar                            =   2;
        
        stat{ntime,ntest}                   =   ft_sourcestatistics(cfg, alldata{:,ix_test(ntest,1),ntime},alldata{:,ix_test(ntest,2),ntime});
        
    end
end

clearvars -except alldata stat list_*;

for ntime = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ntime,ntest),p_val{ntime,ntest}]      = h_pValSort(stat{ntime,ntest});
    end
end

clearvars -except alldata stat list_* stat min_p p_val;

p_limit 	= 0.05;% / (size(stat,1)+size(stat,2));

i = 0 ; clear who_seg ,

list_test                               = {'0v1 Back','0v2 Back','1v2 Back'};

for ntime   = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for iside = [3]
            
            if min_p(ntime,ntest) < p_limit
                
                lst_side                = {'left','right','both'};
                lst_view                = [-95 1;95,11;-2 4];
                
                z_lim                   = 5;
                
                clear source ;
                
                stolplot                = stat{ntime,ntest};
                stolplot.mask           = stolplot.prob < p_limit;
                
                source.pos              = stolplot.pos ;
                source.dim              = stolplot.dim ;
                tpower                  = stolplot.stat .* stolplot.mask;
                tpower(tpower == 0)     = NaN;
                source.pow              = tpower ; clear tpower;
                
                cfg                     =   [];
                cfg.method              =   'surface';
                cfg.funparameter        =   'pow';
                cfg.funcolorlim         =   [-z_lim z_lim];
                cfg.opacitylim          =   [-z_lim z_lim];
                cfg.opacitymap          =   'rampup';
                cfg.colorbar            =   'off';
                cfg.camlight            =   'no';
                cfg.projmethod          =   'nearest';
                cfg.funcolormap      	= brewermap(256,'*RdBu');
                cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                
                ft_sourceplot(cfg, source);
                view(lst_view(iside,:))
                
                
                title([list_time{ntime} '.' list_test{ntest}]);
                
            end
        end
    end
end

clearvars -except alldata stat list_* stat min_p p_val;