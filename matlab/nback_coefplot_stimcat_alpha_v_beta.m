clear; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                              	        = [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

for nsuj  = 1:length(list_suj)
    
    list_cond                                   = {'alpha.peak.centered.1back','alpha.peak.centered.2back', ...
        'beta.peak.centered.1back','beta.peak.centered.2back'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                              	= [];
        flist                                   = dir(['J:/nback/source/coef/sub' num2str(list_suj(nsuj)) '.' list_cond{ncond} ...
            '.istarget.bsl.exl.coef.combinedlead.lcmv.mat']);
        
        if length(flist) > 0
            for nf = 1:length(flist)
                fname                           = [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %50s\n',fname);
                load(fname);
                sub_carr(nf,:,:)                = [abs(data.avg)];
                time_axis                       = data.time;
            end
            
            sub_carr                            = squeeze(nanmean(sub_carr,1));
            
            t1                                  = find(round(time_axis,2) == round(-0.1,2));
            t2                                  = find(round(time_axis,2) == round(0,2));
            
            act                             	= sub_carr;
            bsl                                 = mean(sub_carr(:,t1:t2),2);
            
            alldata(nsuj,ncond,:,:)            = act; %(act-bsl)./bsl;% (act-bsl);%
            
            clear sub_carr act bsl t1 t2 flist;
            
        end
    end
end

keep alldata template_grid time_axis list_cond

%%

for ncond = 1:size(alldata,2)
    allavg{ncond}       	= squeeze(nanmean(alldata(:,ncond,:,:),1));
end

load ../data/stat/nback_stim_category_alpha_v_beta.mat

%%

zlist                   = [2 3];
list_test               = [2 3; 2 4];
cluster_list         	= {[1 2]};

for ncluster = 1:length(cluster_list)
    for ntest = 1:size(list_test,1)
        
        find_cluster       	= [];
        
        for ni = 1:length(cluster_list{ncluster})
            find_cluster  	= [find_cluster find(stat.posclusterslabelmat == cluster_list{ncluster}(ni))];
        end
        
        find_cluster      	= sort(find_cluster);
        chk_sig           	= find(stat.mask(find_cluster)==1);
        
        tm_points          	= stat.time(find_cluster);
        tm_points_lim      	= tm_points([1 end]);
        
        tim_indx            = [];
        
        for nt = 1:length(tm_points)
            tim_indx = [tim_indx; find(round(time_axis,2) == round(tm_points(nt),2))];
        end
        
        data1               = allavg{list_test(ntest,1)}(:,tim_indx);% .* stat{nt}.mask;
        data2               = allavg{list_test(ntest,2)}(:,tim_indx);% .* stat{nt}.mask;
        
        data1_plot         	= nanmean(squeeze(data1),2);
        data2_plot         	= nanmean(squeeze(data2),2);
        
        fin_vct_plot        = (data1_plot- data2_plot) ./ data2_plot; %
        
        plot_z              = [-zlist(ntest) zlist(ntest)];
        plot_map            = brewermap(256,'*RdBu');
        
        source              = [];
        source.pow          = nan(length(template_grid.pos),1);
        
        source.pow(template_grid.inside ==1)          = fin_vct_plot;
        
        source.pos          = template_grid.pos;
        source.dim          = template_grid.dim;
        source.inside       = template_grid.inside;
        
        cfg                 = [];
        cfg.method       	= 'surface';
        cfg.funparameter   	= 'pow';
        cfg.maskparameter 	= cfg.funparameter;
        cfg.funcolorlim    	= plot_z;
        cfg.funcolormap    	= plot_map;
        cfg.projmethod     	= 'nearest';
        cfg.camlight       	= 'no';
        cfg.surfinflated   	= 'surface_inflated_both_caret.mat';
        cfg.projthresh    	= 0.4;
        list_test_name      = {[list_cond{list_test(ntest,1)} ' minus'],[list_cond{list_test(ntest,2)}]};
        
        list_view           = {[-90 0 0],[90 0 0]};
        list_view_name      = {'left','right'};
        
        for nview = 1:length(list_view)
            
            ft_sourceplot(cfg, source);
            view (list_view{nview});
            light ('Position',list_view{nview});
            material dull
            title(list_test_name);
            
            %         fout = 'D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/_prep/cond_ag_all_contrast/';
            %         fout = [fout 'condition.contrast.' list_test_name{ntest} '.' list_view_name{nview} '.png'];
            %         saveas(gcf,fout);
            %         close all;
            
            
        end
    end
end