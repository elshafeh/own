clear ;

suj_list                                    = {'pilot01','pilot02','pilot03'};
list_name                                   = {'open.left','open.right','closed.left','closed.right'};

for ns = 1:length(suj_list)
    
    
    i                                       = 0;
    subjectName                             = suj_list{ns};
    
    for ncue = 1:length(list_name)
        
        
        ext_name                            = ['cuelock.erf.comb.' list_name{ncue}];
        dir_data                            = ['../data/' subjectName '/erf/'];
        
        fname                               = [dir_data subjectName '_' ext_name '.mat'];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        i                                   = i+1;
        alldata{ns,i}                       = avg_comb; clear avg_comb;
        alllegend{i}                        = list_name{ncue}; % [suj_list{ns} '-' list_name{ncue}];
        
    end
end

clearvars -except all* suj_list;

for ns = 1:size(alldata,1)
    
    nrow                                    = size(alldata,1); 
    ncol                                    = 1;
    subplot(nrow,ncol,ns)
    
    cfg                                     = [];
    cfg.layout                              = 'CTF275_helmet.mat';
    cfg.ylim                                = 'zeromax';
    cfg.marker                              = 'off';
    cfg.comment                             = 'no';
    cfg.colormap                            = brewermap(256, '*RdYlBu');
    cfg.colorbar                            = 'no';
    cfg.xlim                                = [-0.1 0.8];
    cfg.linewidth                           = 2;
    cfg.channel                             = {'MLT23','MLT24', 'MLT33', 'MLT34', 'MLT35', 'MLT43', 'MLT42','MLT44', ...
        'MRT33', 'MRT34', 'MRT35', 'MRT42', 'MRT43', 'MRT44', 'MRT53'};
    
    ft_singleplotER(cfg, alldata{ns,:});
    
    legend(alllegend);
    title(suj_list{ns});
    vline(0,'--k');
    
end