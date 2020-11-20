clear;clc;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:14
    
    suj = ['yc' num2str(suj_list(sb))] ;
    
    for prt = 1:3
        
        lst = {'DIS','fDIS'};
        
        for cd = 1:2
            fname_in = [suj '.pt' num2str(prt) '.' lst{cd}];
            fprintf('Loading %50s\n',fname_in);
            load(['../data/elan/' fname_in '.mat'])
            tmp{cd} = data_elan ; clear data_elan ;
        end
        
        data_elan = ft_appenddata([],tmp{:}); clear tmp ;
        
        st_point    = -0.2 ;
        tim_win     = 1;
        
        lm1 = st_point;
        lm2 = st_point+tim_win;
        
        cfg                         = [];
        cfg.latency                 = [lm1 lm2];
        data_in                     = ft_selectdata(cfg,data_elan);
        
        clear data_elan
        
        f_focus = 6;
        formul  = 3 ;
        f_tap   = 2;
        
        for f_cnd = 1:length(f_focus)
            h_dicsCommonFilter(suj,data_in,prt,[lm1 lm2],f_focus(f_cnd),f_tap(f_cnd),formul(f_cnd),'DISfDIS');
        end
        
        clear data_in
        
    end
    
end