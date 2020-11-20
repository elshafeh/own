clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

list_ext = {'4t6Hz.p100p500','9t13Hz.p300p600','15t25Hz.p300p600','30t40Hz.p300p600','60t80Hz.p50p250'};

for cs = 1:length(list_ext)
    
    lst_dis  = {'DIS','fDIS'};
    
    for sb = 1:14
        
        for cnd_dis = 1:2
            
            source_carr =[];
            
            for prt = 1:3
                
                suj = ['yc' num2str(suj_list(sb))];
                
                fname = dir(['../data/source/' suj '*pt' num2str(prt) '*.' lst_dis{cnd_dis} '.*' ...
                    list_ext{cs} '*']);
                
                fname = fname.name;
                
                fprintf('\nLoading %50s',fname);
                
                load(['../data/source/' fname]);
                
                source_carr = [source_carr source] ; clear source
                
            end
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            source_avg{sb,cs,cnd_dis}.pow            = nanmean(source_carr,2); clear source_carr ;
            source_avg{sb,cs,cnd_dis}.pos            = source.pos ;
            source_avg{sb,cs,cnd_dis}.dim            = source.dim ; clear source ;
            
        end
        
    end
end

clearvars -except source_avg ;

for cs = 1:size(source_avg,2)
    
    cfg                                   =   [];
    cfg.dim                               =   source_avg{1,1}.dim;
    cfg.method                            =   'montecarlo';
    cfg.statistic                         =   'depsamplesT';
    cfg.parameter                         =   'pow';
    cfg.correctm                          =   'cluster';
    cfg.clusterstatistic                  =   'maxsum';
    cfg.numrandomization                  =   1000;
    cfg.alpha                             =   0.025;
    cfg.tail                              =   0;
    cfg.clustertail                       =   0;
    cfg.design(1,:)                       =   [1:14 1:14];
    cfg.design(2,:)                       =   [ones(1,14) ones(1,14)*2];
    cfg.uvar                              =   1;
    cfg.ivar                              =   2;
    
    if cs == size(source_avg,2)
        cfg.clusteralpha                      =   0.05;             % First Threshold
    elseif cs == 1
        cfg.clusteralpha                      =   0.001;             % First Threshold
    else
        cfg.clusteralpha                      =   0.01;             % First Threshold
    end
    
    stat{cs}                           =   ft_sourcestatistics(cfg,source_avg{:,cs,1},source_avg{:,cs,2}) ;
    
end

% load ../data/yctot/stat/dis.versus.source.mat

for cs = 1:size(source_avg,2)
    [min_p(cs),p_val{cs}]           =   h_pValSort(stat{cs});
end

p_lim = 0.05 ;

for cs = 1:size(source_avg,2)
    list{cs}            = FindSigClusters(stat{cs},p_lim);
end

list_ext = {'4t6Hz.p100p500','9t13Hz.p300p600','15t25Hz.p300p600','30t40Hz.p300p600','60t80Hz.p50p250'};

close all;

for cs = 1:5
    
    if cs ==1
        p_lim = 0.001;
    else
        p_lim = 0.05;
    end
    
    if min_p(cs) < p_lim
        
        stat_int                = h_interpolate(stat{cs});
        stat_int.mask           = stat_int.prob < p_lim;
        
        %         stat_int.mask(abs(stat_int.stat) < nanmean(nanmean(nanmean(abs(stat_int.stat))))) = 0;
        %         stat_int.mask(abs(stat_int.stat) < nanmedian(nanmedian(nanmedian(abs(stat_int.stat))))) = 0;
        
        if cs ==1
            stat_int.mask(abs(stat_int.stat) < 5) = 0;
        else
            stat_int.mask(abs(stat_int.stat) < 2) = 0;
        end
        
        
        %         stat_int.stat           = stat_int.stat .* stat_int.mask;
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'stat';
        cfg.maskparameter       = 'mask';
        cfg.nslices             = 16;
        %         cfg.slicerange          = [70 84];
        cfg.funcolorlim         = [-5 5];
        ft_sourceplot(cfg,stat_int);clc;
        title(list_ext{cs});
        clear source source_int cfg
        
    end
end

% list_ext = {'6t8Hz.p300p500','9t15Hz.p300p500','16t26Hz.p100p300','16t26Hz.p400p600' ...
%     ,'32t42Hz.p0p200','32t42Hz.p100p300','32t42Hz.p300p500','55t75Hz.p0p200','55t75Hz.p200p400'};
% list_versus = {'DIS1 v DIS2','DIS1 v DIS3','DIS2 v DIS3'};

% for cs = 1:size(tmp,2)
%     for sb = 1:14
%         for cnd_delay = 1:3
%
%             source_avg{sb,cs,cnd_delay}     = tmp{sb,cs,1,cnd_delay};
%             source_avg{sb,cs,cnd_delay}.pow = tmp{sb,cs,1,cnd_delay}.pow - tmp{sb,cs,2,cnd_delay}.pow;
%
%         end
%     end
% end
%
% clearvars -except source_avg ;

% list_versus = [1 2; 1 3; 2 3];