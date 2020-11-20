clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1}                = {'oc1','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9','oc10','oc11','oc12','oc13','oc14'};
suj_group{2}                = {'yc1','yc10','yc11','yc4','yc18','yc21','yc7','yc19','yc15','yc14','yc5','yc13','yc16','yc12'};

lst_group                   = {'Old','Young'};

load ../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    lst_freq    = {'11t15Hz'};
    lst_time    = {'p600p1000'};
    lst_bsl     = 'm600m200';
    ext_comp    = 'dpssFixedCommonDicSource.mat';
    
    for sb = 1:length(suj_list)
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        lst_sub_cond       = {''};
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                for ncue = 1:length(lst_sub_cond)
                    
                    fname = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.' lst_sub_cond{ncue} cond_main '.' lst_freq{nfreq} '.' lst_bsl '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source                                            = source; clear source
                    
                    fname = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.' lst_sub_cond{ncue} cond_main '.' lst_freq{nfreq} '.' lst_time{ntime}   '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                                  = source; clear source
                    pow                                                         = (act_source-bsl_source)./bsl_source;
                    pow(isnan(pow))                                             = 0;
                    
                    source_avg{ngroup}{sb,nfreq,ntime,ncue}.pow             = pow;
                    source_avg{ngroup}{sb,nfreq,ntime,ncue}.pos             = template_grid.pos ;
                    source_avg{ngroup}{sb,nfreq,ntime,ncue}.dim             = template_grid.dim ;
                    source_avg{ngroup}{sb,nfreq,ntime,ncue}.inside          = template_grid.inside;
                    
                    clear act_source bsl_source
                end
            end
        end
    end
end

clearvars -except source_avg ;

for ngroup = 1:length(source_avg)
    for nfreq = 1:size(source_avg{ngroup},2)
        for ntime = 1:size(source_avg{ngroup},3)
            for ncue = 1:size(source_avg{ngroup},4)
                
                grand_average{ngroup,nfreq,ntime,ncue} = ft_sourcegrandaverage([],source_avg{ngroup}{:,nfreq,ntime,ncue});
                
            end
        end
    end
end

clearvars -except grand_average ;

for ngroup = 1:size(grand_average,1)
    for nfreq = 1:size(grand_average,2)
        for ntime = 1:size(grand_average,3)
            for ncue = 1:size(grand_average,4)
                for iside = 1:3
                    
                    lst_side                      = {'left','right','both'};
                    lst_view                      = [-95 1;95 11;-2 15];
                    z_lim                         = 0.2;
                    
                    source                        =   grand_average{ngroup,nfreq,ntime,ncue};
                    
                    cfg                           =   [];
                    cfg.method                    =   'surface';
                    cfg.funparameter              =   'pow';
                    cfg.funcolorlim               =   [-z_lim z_lim];
                    cfg.opacitylim                =   [-z_lim z_lim];
                    cfg.opacitymap                =   'rampup';
                    cfg.colorbar                  =   'off';
                    cfg.camlight                  =   'no';
                    cfg.projthresh                =   0.2;
                    cfg.projmethod                =   'nearest';
                    cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:));
                    
                    saveas(gcf,['../images/ageing_summary/source_grand_average_group' num2str(ngroup) '_side' num2str(iside) '.png']); close all;
                    
                end
            end
        end
    end
end