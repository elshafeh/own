clear; global ft_default;clc;
ft_default.spmversion = 'spm12';

list_suj                              	        = [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

for nsuj  = 1:length(list_suj)
    
    list_cond                                   = {'alpha.peak.centered.1back.istarget','alpha.peak.centered.2back.istarget', ...
        'beta.peak.centered.1back.istarget','beta.peak.centered.2back.istarget'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                              	= [];
        flist                                   = dir(['J:/nback/source/coef/sub' num2str(list_suj(nsuj)) '.' list_cond{ncond} ...
            '.bsl.exl.coef.combinedlead.lcmv.mat']);
        
        if length(flist) > 0
            i                                   = 0;
            for nf = 1:length(flist)
                fname                           = [flist(nf).folder filesep flist(nf).name];
                chk                             = strfind(fname,'0back');
                if isempty(chk)
                    i                           = i + 1;
                    fprintf('loading %50s\n',fname);
                    load(fname);
                    sub_carr(i,:,:)          	= [abs(data.avg)];
                    time_axis                	= data.time;
                end
            end
            
            sub_carr                            = squeeze(nanmean(sub_carr,1));
            
            t1                                  = find(round(time_axis,2) == round(-0.2,2));
            t2                                  = find(round(time_axis,2) == round(0,2));
            
            act                             	= sub_carr;
            bsl                                 = mean(sub_carr(:,t1:t2),2);
            
            temp_sub(ncond,:,:)             	= act; % (act-bsl);% (act-bsl)./bsl;%
            
            clear sub_carr act bsl t1 t2 flist;
            
        end
    end
    
    vct1                            = temp_sub(2,:,:);
    vct2                            = temp_sub(1,:,:);
    alldata(nsuj,1,:,:)             = (vct1 - vct2);% ./ vct2; 
    
    vct1                            = temp_sub(4,:,:);
    vct2                            = temp_sub(3,:,:);
    alldata(nsuj,2,:,:)             = (vct1 - vct2);% ./ vct2;
    
    clear temp_sub vct1 vct2
    
    fprintf('\n');
    
end

keep alldata template_grid time_axis list_cond

%%

for ncond = 1:size(alldata,2)
    allavg{ncond}       	= squeeze(nanmean(alldata(:,ncond,:,:),1));
end

%%
close all
zlist                       = [1.5];
thresh_list                 = [0];
list_test                   = [2 1];

for ntest = 1:size(list_test,1)
    
    load ../data/stat/nback.multivar.diff.mat
    stat              	= stat{1};
    
    stat.mask           = stat.prob < 0.05;
    stat.time        	= stat.time .* stat.mask;
    stat.time         	= stat.time(stat.time ~= 0);
    
    find_sig         	= [];
    
    for ni = 1:length(stat.time)
        find_sig        = [find_sig find(round(time_axis,3) == round(stat.time(ni),3))];
    end
    
    data1               = allavg{list_test(ntest,1)}(:,find_sig);
    data2               = allavg{list_test(ntest,2)}(:,find_sig);
    
    data1_plot         	= nanmean(squeeze(data1),2);
    data2_plot         	= nanmean(squeeze(data2),2);
    
    fin_vct_plot        = (data1_plot-data2_plot) ./ data2_plot;
    fin_vct_plot(fin_vct_plot < 0) = NaN;
    
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
    cfg.funcolorlim    	= plot_z; %'auto'; %
    cfg.funcolormap    	= plot_map;
    cfg.projmethod     	= 'nearest';
    cfg.camlight       	= 'no';
    cfg.surfinflated   	= 'surface_inflated_both_caret.mat';
    cfg.projthresh    	= thresh_list(ntest);
    list_test_name      = {[list_cond{list_test(ntest,1)} ' minus '],[list_cond{list_test(ntest,2)}]};
    
    list_view           = {[-90 0 0],[90 0 0]};
    list_view_name      = {'left','right'};
    
    for nview = 1:length(list_view)
        
        ft_sourceplot(cfg, source);
        view (list_view{nview});
        light ('Position',list_view{nview});
        material dull
        title(list_test_name);
        
        %         fout = ['D:/Dropbox/project_me/figures_me/nback/post-kia/source/multivar/stim_av/target_test' num2str(ntest) '.' list_view_name{nview} '.png'];
        %         saveas(gcf,fout);
        
    end
end