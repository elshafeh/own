clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

for sb = 1:2
    
    suj_list                = [1 14];
    suj                     = ['yc' num2str(suj_list(sb))] ;
    
    load(['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG21/pat.field/data/' suj '.VolGrid.0.5cm.mat']);
    
    for prt = 1:3
        
        fname_in            = [suj '.pt' num2str(prt) '.CnD'];
        
        fprintf('\nLoading %50s\n',fname_in);
        load(['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/all_data/' fname_in '.mat']);
        load(['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG21/pat.field/data/' suj '.adjusted.leadfield.pt' num2str(prt) '.0.5cm.mat']);
        
        cfg             = [];
        cfg.latency     = [-3 3];
        data_elan       = ft_selectdata(cfg,data_elan);
        
        pkg.leadfield   = leadfield;
        pkg.vol         = vol;
        
        load(['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.CnD.m800p2000.5t15Hz.NewCommonFilter.mat']);
        
        tlist           = [-0.6 0.6];
        twin            = [0.4 0.4];
        flist           = 9;
        fpad            = 2;
        tpad            = 0.025;
        
        fname           = {'CnD.m600m200.7t11Hz.NewSource.mat','CnD.p600p1000.7t11Hz.NewSource.mat'};
        
        for ntime = 1:length(tlist)
            for nfreq = 1:length(flist)
                
                source  = h_dicsSeparate(suj,data_elan,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                    com_filter,pkg,'','NewSource'); % create source
                
                save(['tmp_data/' suj '.pt' num2str(prt) '.' fname{ntime}],'source','-v7.3');
                
                clear source
                
            end
        end
    end
end
