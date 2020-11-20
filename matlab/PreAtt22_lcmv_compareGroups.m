clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list    = suj_group{ngrp};
    
    lst_cnd     = {'VCnD','NCnD'}; %'RCnD','LCnD','NRCnD','NLCnD','VCnD','NCnD'};
    
    lst_time    = {'p540p790ms'};
    
    lst_bsl     = 'm300m50ms';
    
    ext_comp    = 'lcmvSource.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        for cnd_time = 1:length(lst_time)
            for ncue = 1:length(lst_cnd)
                
                
                fname = ['../data/' suj '/field/' suj '.' lst_cnd{ncue} '.bigCovFilter.' lst_bsl '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                pow   = source; clear source
                
                fname = ['../data/' suj '/field/' suj '.' lst_cnd{ncue} '.bigCovFilter.' lst_time{cnd_time}   '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                bsl   = source; clear source
                
                tmp{ncue,1}   = pow-bsl;
                tmp{ncue,2}   = (pow-bsl)./bsl; clear pow bsl
                
            end
            
            source_avg{ngrp,sb,cnd_time,1}.pow            = tmp{1,1} - tmp{2,1}; 
            source_avg{ngrp,sb,cnd_time,1}.pos            = template_grid.pos ;
            source_avg{ngrp,sb,cnd_time,1}.dim            = template_grid.dim ;
            
            source_avg{ngrp,sb,cnd_time,2}.pow            = tmp{1,2} - tmp{2,2};
            source_avg{ngrp,sb,cnd_time,2}.pos            = template_grid.pos ;
            source_avg{ngrp,sb,cnd_time,2}.dim            = template_grid.dim ;
            
            
            source_avg{ngrp,sb,cnd_time,1}.pow(isnan(source_avg{ngrp,sb,cnd_time,1}.pow))     = 0;
            source_avg{ngrp,sb,cnd_time,2}.pow(isnan(source_avg{ngrp,sb,cnd_time,2}.pow))     = 0;            
            
            clear tmp
            
        end
    end
end

clearvars -except source_avg lst_time ;

for cnd_time = 1:size(source_avg,3)
    for nbsl = 1:size(source_avg,4)
        
        cfg                     =   [];
        cfg.dim                 =  source_avg{1}.dim;
        cfg.method              =  'montecarlo';
        cfg.statistic           = 'indepsamplesT';
        cfg.parameter           = 'pow';
        cfg.correctm            = 'cluster';
        cfg.clusteralpha        = 0.05;             % First Threshold
        
        cfg.clusterstatistic    = 'maxsum';
        cfg.numrandomization    = 1000;
        cfg.alpha               = 0.025;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        
        nsuj                    = size(source_avg,2);
        
        cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.ivar                = 1;
        
        stat{cnd_time,nbsl}     =   ft_sourcestatistics(cfg, source_avg{2,:,cnd_time,nbsl},source_avg{1,:,cnd_time,nbsl});
        
        [min_p(cnd_time,nbsl),p_val{cnd_time,nbsl}]     = h_pValSort(stat{cnd_time,nbsl});
        
    end
end

clearvars -except source_avg lst_time stat min_p p_val;