clear ; clc ; dleiftrip_addpath ;

suj_list        = [1:4 8:17];

ncontrast        = {{'p80p120ms','p80p120ms'}};

cnd_data        = {'VDIS','VfDIS','NDIS','NfDIS'};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for ntest = 1:length(ncontrast)
        for ix = 1:2
            for ftype = 1:length(cnd_data)
                for cp = 1:3
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' cnd_data{ftype} '.' ncontrast{ntest}{ix} '.lcmvSource.mat']);
                    
                    if size(fname,1)==1
                        fname = fname.name;
                    end
                    
                    fprintf('Loading %50s\n',fname);
                    load(['../data/source/' fname]);
                    
                    if isstruct(source);
                        source = source.pow;
                    end
                    
                    src_carr{cp} = source ; clear source ;
                    
                end
                
                big_data_carrier{sb,ntest,ftype,ix}                = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr
                
            end
            
        end
    end
end

clearvars -except big_data_carrier ; clc ;

% subtract dis and fdis

for sb = 1:size(big_data_carrier,1)
    for ntest = 1:size(big_data_carrier,2)
        for ix = 1:2
            
            whoiswho = [1 2; 3 4];
            
            for ftype = 1:size(whoiswho,1)
                
                blo1 = big_data_carrier{sb,ntest,whoiswho(ftype,1),ix};
                blo2 = big_data_carrier{sb,ntest,whoiswho(ftype,2),ix};
                
                fdis_subtracted{sb,ntest,ftype,ix} =  blo1 - blo2 ; clear blo1 blo2 ;
                
            end
            
        end
    end
end

clearvars -except fdis_subtracted ; clc ;

load ../data/template/source_struct_template_MNIpos.mat;
template_source = source ; clear source ;

% subtract or not baseline

for sb = 1:size(fdis_subtracted,1)
    for ntest = 1:size(fdis_subtracted,2)
        for ftype = 1:size(fdis_subtracted,3)
            
            act = fdis_subtracted{sb,ntest,ftype,2};
            bsl = fdis_subtracted{sb,ntest,ftype,1};
            
            %             source_avg{sb,ntest,ftype}.pow          = (act-bsl)./bsl;
            %             source_avg{sb,ntest,ftype}.pow          = act-bsl;
            source_avg{sb,ntest,ftype}.pow              = act;
            
            source_avg{sb,ntest,ftype}.pos              = template_source.pos;
            source_avg{sb,ntest,ftype}.dim              = template_source.dim;
            clear act bsl
            
        end
        
    end
end

clearvars -except source_avg ; clc ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;
cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;
cfg.clusteralpha        =   0.05;             % First Threshold

for ncomp = 1:size(source_avg,2)
    stat{ncomp,1}       =   ft_sourcestatistics(cfg,source_avg{:,ncomp,1},source_avg{:,ncomp,2}) ;
end

for ncomp = 1:size(stat,1)
    for ftype = 1:size(stat,2)
        [min_p(ncomp,ftype),p_val{ncomp,ftype}]           =   h_pValSort(stat{ncomp,ftype});
    end
end

plim                    = 0.05;

for ncomp = 1:size(stat,1)
    for ftype = 1:size(stat,2)
        vox_list{ncomp,ftype} = FindSigClusters(stat{ncomp,ftype},plim);
    end
end
clc;
for ncomp = 1:size(stat,1)
    for ftype = 1:size(stat,2)
        if min_p(ncomp,ftype) < plim
            
            t_lim = 0; z_lim = 5;
            
            stat{ncomp,ftype}.mask = stat{ncomp,ftype}.prob < plim;
            
            for iside = 1:3
                
                lst_side                = {'left','right','both'};
                lst_view                = [-95 1;95,11;0 50];
                
                clear source ;
                source.pos              = stat{ncomp,ftype}.pos ;
                source.dim              = stat{ncomp,ftype}.dim ;
                tpower                  = stat{ncomp,ftype}.stat .* stat{ncomp,ftype}.mask;
                
                source.pow              = squeeze(tpower) ; clear tpower;
                
                cfg                     =   [];
                cfg.method              =   'surface';
                cfg.funparameter        =   'pow';
                cfg.funcolorlim         =   [-z_lim z_lim];cfg.opacitylim          =   [-z_lim z_lim];
                cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';
                cfg.camlight            =   'no';
                cfg.projthresh          =   0.2;
                cfg.projmethod          =   'nearest';
                cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                ft_sourceplot(cfg, source);
                view(lst_view(iside,1),lst_view(iside,2))
                %                 set(gcf,'position',lst_position{iside})
                %                 clear source
                
            end
        end
        
    end
end
clc;