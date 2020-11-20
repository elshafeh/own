clear; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                                    = [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

for nsuj  = 1:length(list_suj)
    
    list_cond                               = {'0back','1back'};
    ext_cond                                = '.lockedon.all.dwn70.bsl.excl';
    
    for ncond = 1:length(list_cond)
        
        sub_carr                            = [];
        flist                            	= dir(['J:/temp/nback/data/source/coef/sub' num2str(list_suj(nsuj)) '.sess*.' list_cond{ncond} ext_cond '.deocdingCond.coef.lcmv.mat']);
        
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
        
        alldata(nsuj,ncond,:,:)            = (act-bsl)./bsl;% (act-bsl);%act; %
        
        clear sub_carr act bsl t1 t2 flist;
        
    end
end

keep alldata template_grid time_axis

for ncond = 1:size(alldata,2)
    allavg{ncond}                         	= squeeze(nanmean(alldata(:,ncond,:,:),1));
end

keep alldata template_grid time_axis ncond allavg

load ../data/stat/nback.cond.per.stim.mat

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]              	= h_pValSort(stat{ntest});
end

list_view                                       = [90 0;-90 0;1 64]; %
zlist                                           = [1];

for ntest = 1:size(list_test,1)
    for nview = 1:size(list_view,1)
        
        vct                 = abs(time_axis-stat{ntest}.time(1));
        t1                  = find(vct==min(vct));
        
        vct                 = abs(time_axis-stat{ntest}.time(end));
        t2                  = find(vct==min(vct));
        
        data1               = allavg{list_test(ntest,1)}(:,t1:t2);% .* stat{nt}.mask;
        data2               = allavg{list_test(ntest,2)}(:,t1:t2);% .* stat{nt}.mask;
        
        find_mask           = stat{ntest}.prob < 0.05;
        find_stat           = stat{ntest}.stat .* find_mask;
        find_sig            = {};
        
        find_sig{1}         = find(find_stat ~= 0);
        
        for nsig = 1:length(find_sig)
            
            data1_plot         	= nanmean(squeeze(data1(:,find_sig{nsig})),2);
            data2_plot         	= nanmean(squeeze(data2(:,find_sig{nsig})),2);
            
            source              = [];
            source.pow          = nan(length(template_grid.pos),1);
            
            source.pow(template_grid.inside ==1)          = data1_plot - data2_plot;
            
            source.pos          = template_grid.pos;
            source.dim          = template_grid.dim;
            source.inside       = template_grid.inside;
            
            cfg               	= [];
            cfg.method        	= 'surface';
            cfg.funparameter   	= 'pow';
            cfg.maskparameter  	= cfg.funparameter;
            cfg.funcolorlim   	= [-zlist(ntest) zlist(ntest)];
            cfg.funcolormap    	= brewermap(256,'*RdBu');
            cfg.projmethod  	= 'nearest';
            cfg.camlight        = 'no';
            cfg.surffile        = 'surface_white_both.mat';
            cfg.surfinflated   	= 'surface_inflated_both.mat';
            ft_sourceplot(cfg, source);
            view(list_view(nview,:));
            
            saveas(gcf,['../figures/nback/new_start_source/per.cond.coef.02v12.view' num2str(nview) '.png']); close all;
            
        end
    end
end