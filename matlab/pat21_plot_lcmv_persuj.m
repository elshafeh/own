clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    ext_comp    = '';
    lst_time    = {'.fDIS.N1','.DIS.N1'};
    
    source_carr = [];
    
    for prt = 1:3
        for cnd = 1:length(lst_time)
            fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' ext_comp '*' lst_time{cnd} '*']);
            fname = fname.name;
            fprintf('\nLoading %50s',fname);
            load(['../data/source/' fname]);
            tmp{cnd} = source ; clear source ;
        end
        
        pow         = (tmp{2}-tmp{1})./tmp{1};
        source_carr = [source_carr pow];
        clear pow;
        
    end
    
    src_sub.pow = nanmean(source_carr,2);
    load ../data/template/source_struct_template_MNIpos.mat
    src_sub.pos            = source.pos ;
    src_sub.dim            = source.dim ;
    clear source;
    
    lmt = src_sub.pow(~isnan(src_sub.pow));
    lmt = mean(lmt);
    
    src_int{sb} = h_interpolate(src_sub) ; clear src_sub ; 

end

clearvars -except src_int

for sb = 1:14
    
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'pow';
    cfg.nslices                 = 1;
    cfg.colorbar                = 'no';
    cfg.slicerange              = [70 84];
    cfg.funcolorlim             = 'zeromax';
    ft_sourceplot(cfg,src_int{sb});clc;
    saveFigure(gcf,['/Users/heshamelshafei/Desktop/n1.dis/sb.' num2str(sb) '.jpg']);
    close all;
    
end