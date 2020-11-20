clear ; clc; close all;

if isunix
    project_dir                                 = '/project/3015079.01/';
else
    project_dir                                 = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

suj_list                                        = suj_list([1:9 11:19 21:length(suj_list)-1]);

for nsuj = 1:length(suj_list)
    
    subjectName                                 = suj_list{nsuj};
    list_cond                                   = {'correct.pre','correct.retro'};
    list_window                                 = {'p500p1500' 'p2000p3000' 'p3500p4500' 'p5000p6000'};
    
    load('../data/stock/template_grid_1cm.mat');
    
    for ncond = 1:length(list_cond)
        for ntime = 1:length(list_window)
            
            flist                               = dir(['I:/bil/source/' subjectName '.*Hz.m1000m0'  ...
                '.' list_cond{ncond} '.BetaRecon.coh.mat']);
            fname                               = [flist(1).folder filesep flist(1).name];
            fprintf('loading %s\n',fname);
            load(fname); coh_bsl = source_conn.cohspctrm;
            
            flist                               = dir(['I:/bil/source/' subjectName '.*Hz.'  ...
                list_window{ntime} '.' list_cond{ncond} '.BetaRecon.coh.mat']);
            fname                               = [flist(1).folder filesep flist(1).name];
            fprintf('loading %s\n',fname);
            load(fname); coh_act = source_conn.cohspctrm;
            
            fname_out                           = ['I:/bil/source/' subjectName '.gratinglock.max10vox.mat'];
            fprintf('loading %s\n',fname_out);
            load(fname_out);
            
            coh_bsl                             = nanmean(coh_bsl(max_vox,:),1);
            coh_act                             = nanmean(coh_act(max_vox,:),1);
            
            source                              = [];
            source.pos                          = template_grid.pos;
            source.dim                          = template_grid.dim;
            source.inside                       = template_grid.inside;
            source.pow                          = (coh_act); % - coh_bsl) ./ coh_bsl;
            
            alldata{nsuj,ntime,ncond}           = source; clear source flist fname source_conn max_vox coh_*
            
        end
    end
end

keep alldata list_*

for ntime = 1:size(alldata,2)
    
    cfg                                         =   [];
    cfg.dim                                     =   alldata{1}.dim;
    cfg.method                                  =   'montecarlo';
    cfg.statistic                               =   'depsamplesT';
    cfg.parameter                               =   'pow';
    cfg.correctm                                =   'cluster';
    cfg.clusterstatistic                        =   'maxsum';
    cfg.numrandomization                        =   1000;
    cfg.alpha                                   =   0.025;
    cfg.tail                                    =   0; % !!!
    cfg.clustertail                             =   0; % !!!
    cfg.clusteralpha                            =   0.05;
    
    nsuj                                        =   length(alldata);
    cfg.design(1,:)                             =   [1:nsuj 1:nsuj];
    cfg.design(2,:)                             =   [ones(1,nsuj) ones(1,nsuj)*2];
    cfg.uvar                                    =   1;
    cfg.ivar                                    =   2;
    
    stat{ntime}                                 = ft_sourcestatistics(cfg, alldata{:,ntime,1},alldata{:,ntime,2});
    [min_p(ntime),p_val{ntime}]                 = h_pValSort(stat{ntime});
    
end

keep alldata list_* stat min_p; close all;

list_view                                       = [-90 0 0; 90 0 0; 0 0 90];
plimit                                          = 0.15;

for ntime = 1:size(alldata,2)
    
    if min_p(ntime) < plimit
        
        for nview = [1 2 3]
            
            stat{ntime}.mask                    = stat{ntime}.prob < plimit;
            
            source                              = [];
            source.pos                          = stat{ntime}.pos;
            source.dim                          = stat{ntime}.dim;
            source.pow                          = stat{ntime}.mask .* stat{ntime}.stat;
            
            cfg                                 = [];
            cfg.method                       	= 'surface';
            cfg.funparameter                  	= 'pow';
            cfg.maskparameter                	= cfg.funparameter;
            cfg.funcolormap                  	= brewermap(256,'*RdBu'); % brewermap(256,'Reds');
            cfg.projmethod                  	= 'nearest';
            cfg.camlight                       	= 'no';
            cfg.surfinflated                   	= 'surface_inflated_both_caret.mat';
            cfg.colorbar                        = 'no';
            cfg.funcolorlim                     = [-3 3];
            
            ft_sourceplot(cfg, source);
            view (list_view(nview,:));
            %             light ('Position',list_view(nview,:));
            material dull
            title(['pre v retro ' list_window{ntime}]);
            
            %         dir_fig                             = 'D:\Dropbox\project_me\pub\Presentations\bil update april\_figures\source\alpha\';
            %         saveas(gcf,[dir_fig 'pre.retro.conrast.' list_window{ntime} '.v' ...
            %             num2str(nview) '.png']);
            %         close all;
            
        end
    end
end

keep alldata list_* stat min_p