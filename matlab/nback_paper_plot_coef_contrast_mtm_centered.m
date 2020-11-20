clear; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                              	        = [1:33 35:36 38:44 46:51];
load ../data/stock/template_grid_0.5cm.mat

run_test                                        = 3;

for nsuj  = 1:length(list_suj)
    
    list_cond                                   = {'0back','1back','2back'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                              	= [];
        
        switch run_test
            case 1
                ext_name                        = 'alpha.peak.centered';
                flist                          	= dir(['J:/temp/nback/data/source/coef/sub' num2str(list_suj(nsuj)) '.' ext_name '.' ...
                    list_cond{ncond} '.istarget.bsl.exl.coef.combinedlead.lcmv.mat']);
            case 2
                ext_name                     	= 'alpha.peak.centered';
                flist                         	= dir(['J:/temp/nback/data/source/coef/sub' num2str(list_suj(nsuj)) '.decoding.' ...
                    list_cond{ncond} '.agaisnt.all.' ext_name '.lockedon.target.dwn70.bsl.excl.coef.combinedlead.lcmv.mat']);
            case 3
                
                ext_name                       	= 'beta.peak.centered';
                flist                        	= dir(['J:/temp/nback/data/source/coef/sub' num2str(list_suj(nsuj)) '.decoding.' ...
                    list_cond{ncond} '.agaisnt.all.' ext_name '.lockedon.target.dwn70.bsl.excl.coef.combinedlead.lcmv.mat']);
        end
        
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
            bsl                                 = nanmean(sub_carr(:,t1:t2),2);
            
            alldata(nsuj,ncond,:,:)            = (act);%-bsl)./bsl;
            
            clear sub_carr act bsl t1 t2 flist;
            
        end
    end
    
    fprintf('\n');
    
end

for ncond = 1:size(alldata,2)
    allavg{ncond}       	= squeeze(nanmean(alldata(:,ncond,:,:),1));
end

keep alldata template_grid time_axis ncond allavg list_cond run_test

switch run_test
    case 1
        load('../data/stat/nbk.mtm.center.4stim.alpha peak.mat');
        ext_fig                 = 'stim.alpha';
        zlist                   = [0.5 0.5 0.5];
        
    case 2
        load('../data/stat/nbk.mtm.center.4cond.ag.all.beta peak.mat');
        ext_fig                 = 'cond.ag.all.alpha';
        zlist                   = [0.015 0.01 0.012];
        
    case 3
        load('../data/stat/nbk.mtm.center.4cond.ag.all.beta peak.mat');
        ext_fig                 = 'cond.ag.all.beta';
        zlist                   = [0.01 0.01 0.015];
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]              	= h_pValSort(stat{ntest});
    list_test_name{ntest}                    	= [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
end

close all;
plimit                  = 0.1;

for ntest = 1:size(list_test,1)
    
    t1                  = find(round(time_axis,2) == round(stat{ntest}.time(1),2));
    t2                  = find(round(time_axis,2) == round(stat{ntest}.time(end),2));
    
    if isempty(t2)
        t2              = length(time_axis);
    end
    
    data1               = allavg{list_test(ntest,1)}(:,t1:t2);% .* stat{nt}.mask;
    data2               = allavg{list_test(ntest,2)}(:,t1:t2);% .* stat{nt}.mask;
    
    find_mask           = stat{ntest}.prob < plimit;
    find_stat           = stat{ntest}.stat .* find_mask;
    
    find_sig            = find(find_stat ~= 0);
    
    data1_plot         	= nanmean(squeeze(data1(:,find_sig)),2);
    data2_plot         	= nanmean(squeeze(data2(:,find_sig)),2);
    
    fin_vct_plot        = (data1_plot - data2_plot) ./ data2_plot;
    
    %     if min(stat{ntest}.stat(find_sig)) >0
    %         fin_vct_plot(fin_vct_plot<0) = NaN;
    %     elseif min(stat{ntest}.stat(find_sig)) <0
    %         fin_vct_plot(fin_vct_plot>0) = NaN;
    %     end
    
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
    
    list_view           = {[-90 0 0],[90 0 0]};
    list_view_name      = {'left','right'};
    
    for nview = 1:length(list_view)
        
        ft_sourceplot(cfg, source);
        view (list_view{nview});
        light ('Position',list_view{nview});
        material dull
        title([list_test_name{ntest} ' max=' num2str(round(nanmax(fin_vct_plot),3))  ' min=' num2str(round(nanmin(fin_vct_plot),3))])
        
        fout = 'D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/_prep/center_coef/';
        fout = [fout ext_fig '.' list_test_name{ntest} '.' list_view_name{nview} '.png'];
        saveas(gcf,fout);
        %         close all;
        
        
    end
end