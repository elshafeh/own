clear ; clc  ;dleiftrip_addpath ;

for sb = 1:14

    pkg = [];
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))] ;
    
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
    
    pkg.vol = vol ; clear vol grid ;

    for prt = 1:3
        
        fname_in = [suj '.pt' num2str(prt) '.nDT'];
        
        fprintf('Loading %50s\n',fname_in);
        
        load(['../data/elan/' fname_in '.mat'])
        
        load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']); clc ;
        
        pkg.leadfield = leadfield ; clear leadfield ;
        
        tim_slct = [-0.5 0.7];
        
        cfg         = [];
        cfg.latency = tim_slct;
        data_elan   = ft_selectdata(cfg,data_elan);
        
        h_dicsCommonFilter(suj,data_elan,pkg,prt,tim_slct,46,18.6,44,'nDT');
        %         h_dicsCommonFilter(suj,data_elan,pkg,prt,tim_slct,11,1.5,3,'nDT');
        %         h_dicsCommonFilter(suj,data_elan,pkg,prt,tim_slct,75,6.5,15,'nDT');

        pkg = rmfield(pkg,'leadfield');
        
        clear data_elan
        
    end
    
    clearvars -except sb
    
end
       

%K = 2*tw*fw-1,  % where K is required to be larger than 0. 
%  length of the sliding time-window in seconds (= tw).
%width of frequency smoothing in Hz (= fw)
