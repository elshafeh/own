clear; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                              	        = [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

ext_test                                        = 'dwn70';

for nsuj  = 1:length(list_suj)
    
    list_cond                                   = {'0back','1back','2back'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                              	= [];
        flist                                   = dir(['J:/temp/nback/data/sens_level_auc/rt/sub' num2str(list_suj(nsuj)) '.decoding.rt.' ...
            list_cond{ncond} '.' ext_test '.bsl.coef.combinedlead.lcmv.mat']);
        
        if length(flist) > 0
            for nf = 1:length(flist)
                fname                           = [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %50s\n',fname);
                load(fname);
                sub_carr(nf,:,:)                = [abs(data.avg)];
                time_axis                       = data.time;
            end
            
            sub_carr                            = squeeze(nanmean(sub_carr,1));
            
            t1                                  = find(round(time_axis,2) == round(-0.2,2));
            t2                                  = find(round(time_axis,2) == round(0,2));
            
            act                             	= sub_carr;
            bsl                                 = mean(sub_carr(:,t1:t2),2);
            
            alldata(nsuj,ncond,:,:)             = (act-bsl)./bsl;% (act-bsl);%act; %
            
            clear sub_carr act bsl t1 t2 flist;
            
        end
    end
    
end

keep alldata list_* ext_test time_axis template_*

for ncond = 1:size(alldata,2)
    allavg{ncond}                               = squeeze(nanmean(alldata(:,ncond,:,:),1));
end

ext_test                                        = 'auc';

load(['../data/stat/nback.rt.accuracy.' ext_test '.mat']); %.peak.centered.mat']);

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]              	= h_pValSort(stat{ntest});
end

ext_test                                        = 'broadband';

close all;
zlist                   = [2.5 2 2.5];

for ntest = 2:size(list_test,1)
    
    t1                  = find(round(time_axis,2) == round(stat{ntest}.time(1),2));
    t2                  = find(round(time_axis,2) == round(stat{ntest}.time(end),2));
    
    if isempty(t2)
        t2              = length(time_axis);
    end
    
    data1               = allavg{list_test(ntest,1)}(:,t1:t2);% .* stat{nt}.mask;
    
    find_mask           = stat{ntest}.prob < 0.05;
    find_stat           = stat{ntest}.stat .* find_mask;    
    find_sig            = find(find_stat ~= 0);
    
    find_sig(find_sig>size(data1,2)) = [];
    data1_plot         	= nanmean(squeeze(data1(:,find_sig)),2);
    
    fin_vct_plot        = data1_plot;
    
    if min(stat{ntest}.stat(find_sig)) >0
        fin_vct_plot(fin_vct_plot<0) = NaN;
    elseif  min(stat{ntest}.stat(find_sig)) <0
        fin_vct_plot(fin_vct_plot>0) = NaN;
    end
    
    fin_vct_plot(fin_vct_plot==0) = NaN;
    
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
        title([list_cond{ntest} ' against chance ' ext_test]);
        
        fout = 'D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/_prep/rt/';
        fout = [fout 'against.chance.' ext_test '.' list_cond{ntest} '.' list_view_name{nview} '.png'];
        saveas(gcf,fout);
        %         close all;
        
        
    end
    
    clear data1 find_sig
    
end