clear;clc;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:14
    
    suj = ['yc' num2str(suj_list(sb))] ;
    
    for prt = 1:3
        
        data = dis_commonfilterload(suj,prt);
        
        st_point    = -1.6 ;
        tim_win     = 2.3;
        
        lm1 = st_point;
        lm2 = st_point+tim_win;
        
        cfg                         = [];
        cfg.latency                 = [lm1 lm2];
        data_in                     = ft_selectdata(cfg,data_elan);
        
        clear data_elan
        
        f_focus = 35;
        formul  = 5 ;
        f_tap   = 1.2;
        
        for f_cnd = 1:length(f_focus)
            h_dicsCommonFilter(suj,data_in,prt,[lm1 lm2],f_focus(f_cnd),f_tap(f_cnd),formul(f_cnd),'nDT');
        end
        
        clear data_in
        
    end
    
end