clear; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                              	        = [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

for nsuj  = 1:length(list_suj)
    
    list_cond                                   = {'1back','2back'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                              	= [];
        flist                                   = dir(['J:/nback/source/coef/sub' num2str(list_suj(nsuj)) '.decoding.' list_cond{ncond} ...
            '.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl.coef.combinedlead.lcmv.mat']);
        
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
            
            alldata(nsuj,ncond,:,:)             = act; % (act-bsl)./bsl;%(act-bsl);%
            
            clear sub_carr act bsl t1 t2 flist;
        else
            error('no files found dude..');
        end
        
    end
    
    fprintf('\n');
    
end

keep alldata template_grid time_axis list_cond

%%

for ncond = 1:size(alldata,2)
    allavg{ncond}       	= squeeze(nanmean(alldata(:,ncond,:,:),1));
end

keep alldata template_grid time_axis ncond allavg list_cond;clc;

%%
close all;
zlist                   = 0.006;
list_test               = [1 2];

for ntest = 1:size(list_test,1)
    
    t1                  = find(round(time_axis,2) == round(0.52,2));
    t2                  = find(round(time_axis,2) == round(0.62,2));

    data1               = allavg{list_test(ntest,1)}(:,t1:t2);
    data2               = allavg{list_test(ntest,2)}(:,t1:t2);
    
    data1_plot         	= nanmean(squeeze(data1),2);
    data2_plot         	= nanmean(squeeze(data2),2);
    
    fin_vct_plot        = (data1_plot - data2_plot) ./ data2_plot;
    
    fin_vct_plot(fin_vct_plot > 0) = NaN;
    
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
    
    list_test_name      = {'1v2'};
    list_view           = {[-90 0 0],[90 0 0]};
    list_view_name      = {'left','right'};
    
    for nview = 1:length(list_view)
        
        ft_sourceplot(cfg, source);
        view (list_view{nview});
        light ('Position',list_view{nview});
        material dull
        title([list_test_name{ntest}]);
        
        fig_dir     	= 'D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript_v2/_new_prep/source/';
        fig_ext      	= 'coef.cond.beta';
        saveas(gcf,[fig_dir fig_ext '.'  list_view_name{nview} '.png']);
    end
end