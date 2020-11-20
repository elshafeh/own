clear; global ft_default; close all;
ft_default.spmversion = 'spm12';

list_suj                    	= [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

for nsuj  = 1:length(list_suj)
    
    list_cond                	= {'0back.all.4cond','1back.all.4cond'};
    list_freq               	= {'alpha1Hz','beta2Hz'};
    
    for nfreq  = 1:length(list_freq)
        for ncond = 1:length(list_cond)
            sub_carr         	= [];
            
            flist               = dir(['J:/temp/nback/data/source/coef_mtm/sub' num2str(list_suj(nsuj)) '.sess*.' ...
                list_freq{nfreq} '.' list_cond{ncond} '.coef.lcmv.mat']);
            
            for nf = 1:length(flist)
                fname       	= [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %50s\n',fname);
                load(fname);
                sub_carr(nf,:,:) 	= [abs(data.avg)];
                time_axis     	= data.time;
            end
            
            sub_carr         	= squeeze(nanmean(sub_carr,1));
            
            t1                	= find(round(time_axis,2) == round(-0.4,2));
            t2               	= find(round(time_axis,2) == round(0,2));
            
            act             	= sub_carr;
            bsl                 = nanmean(sub_carr(:,t1:t2),2);
            
            alldata(nsuj,ncond,nfreq,:,:)    	= (act-bsl)./bsl;% (act-bsl);%act; %
            
            clear sub_carr act bsl t1 t2 flist;
            
        end
    end
end

keep alldata template_grid time_axis list*

for ncond = 1:size(alldata,2)
    allavg{ncond}               = squeeze(nanmean(alldata(:,ncond,:,:,:),1));
end

load ../data/stat/nbk.mtm.center.4cond.mat

list_view                     	= [90 0;-90 0;0 82]; %

zlist{1}    = [];
zlist{2}    = [];
zlist{3}    = [2 1];

for ntest = 3
    for nfreq = 1:2
        
        find_mask               = stat{ntest}.prob(nfreq,:) < 0.05;
        find_stat               = stat{ntest}.stat(nfreq,:) .* find_mask;
        find_sig	        	= find(find_stat ~= 0);
        
        for nview = 3%1:size(list_view,1)
            
            t1                  = find(round(time_axis,2) == round(stat{ntest}.time(1),2));
            t2                  = find(round(time_axis,2) == round(stat{ntest}.time(end),2));
            
            source              = [];
            source.pow          = nan(length(template_grid.pos),1);
            
            if ntest == 3
                
                data1        	= squeeze(allavg{list_test(ntest,1)}(nfreq,:,t1:t2));
                data2        	= squeeze(allavg{list_test(ntest,2)}(nfreq,:,t1:t2));
                
                data1_plot   	= nanmean(squeeze(data1(:,find_sig)),2);
                data2_plot     	= nanmean(squeeze(data2(:,find_sig)),2);
                
                source.pow(template_grid.inside ==1)          = data1_plot - data2_plot;
                
            else
                
                data1           = squeeze(allavg{ntest}(nfreq,:,t1:t2));
                data1_plot   	= nanmean(squeeze(data1(:,find_sig)),2);
                source.pow(template_grid.inside ==1)          = data1_plot;
                
            end
            
            source.pos          = template_grid.pos;
            source.dim          = template_grid.dim;
            source.inside       = template_grid.inside;
            
            cfg               	= [];
            cfg.method        	= 'surface';
            cfg.funparameter   	= 'pow';
            cfg.maskparameter  	= cfg.funparameter;
            cfg.funcolorlim   	= [-zlist{ntest}(nfreq) zlist{ntest}(nfreq)];
            cfg.funcolormap    	= brewermap(256,'*RdBu');
            cfg.projmethod  	= 'nearest';
            cfg.camlight        = 'no';
            cfg.surffile        = 'surface_white_both.mat';
            cfg.surfinflated   	= 'surface_inflated_both.mat';
            %             cfg.projthresh     	= 0.5;
            ft_sourceplot(cfg, source);
            view(list_view(nview,:));
            
            list_test_name      = {'0and2','1and2','0and2 vs 1and2'};
            title([list_test_name{ntest} ' ' list_freq{nfreq}]);
            
            saveas(gcf,['../figures/nback/coef_mtm/coef.' list_test_name{ntest} '.' list_freq{nfreq} ...
                '.view' num2str(nview) '.png']); close all;
            
        end
    end
end