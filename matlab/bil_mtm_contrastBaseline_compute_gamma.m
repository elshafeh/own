clear ;

keyword1                    = 'mtmconvol';
keyword2                    = '40t100Hz';
keyword3                    = 'comb';

suj_list                    = dir(['../data/sub*/tf/*' keyword1 '*' keyword2 '*' keyword3 '.mat']);
fprintf('\n %2d subjects found\n',length(suj_list));

keyword3                    = [keyword3]; % '_hc_regress'];

for ns = 1:length(suj_list)
    
    fname                   = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    subjectName             = suj_list(ns).name(1:6);
    
    fname                   = ['../data/' subjectName '/preproc/' subjectName '_firstCueLock_hc_data.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % this finds the freq structure loaded
    find_var                = whos;
    find_var                = {find_var.name};
    find_var                = find(strcmp(find_var,'freq_axial'));
    
    if isempty(find_var)
        if length(keyword3) > 4
            freq                = h_remove_hc_confound(headpos,freq_comb); clear freq_comb
        else
            freq                = freq_comb;
        end
    else
        if length(keyword3) > 4
            freq                = h_remove_hc_confound(headpos,freq_axial); clear freq_axial
        else
            freq                = freq_axial;
        end
    end
    
    if strcmp(freq.dimord(1:3),'rpt')
        freq                    = ft_freqdescriptives([],freq);
    end
        
    period_baseline             = [-0.2 -0.1];
    freq_interest               = [40 100];
    
    list_window                 = 0;
    list_width                  = 6.5;
    
    for nt = 1:length(list_window)
        
        ix1                     = list_window(nt);
        time_window             = list_width(nt);
        ix2                     = ix1+time_window;
        
        period_interest         = [ix1 ix2];
        
        [act,bsl]               = h_prepareBaseline(freq,period_baseline,period_interest,freq_interest,'na');
        
        alldata_act{ns,nt}      = act; clear act;
        alldata_bsl{ns,nt}      = bsl; clear bsl;
        
    end
    
    clc;
    
end

keep alldata_act alldata_bsl keyword*;

nsuj                        = size(alldata_act,1);
[design,neighbours]         = h_create_design_neighbours(nsuj,alldata_act{1,1},'meg','t'); clc;

cfg                         = [];
cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.neighbours              = neighbours;

cfg.tail                    = 0;cfg.clustertail  = cfg.tail;
cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 4; % !!

keyword4                    = [num2str(cfg.minnbchan) 'minChan' num2str(cfg.tail) 'tail'];

cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

for nt = 1:size(alldata_act,2)
    stat{nt}                = ft_freqstatistics(cfg, alldata_act{:,nt},alldata_bsl{:,nt});
    stat{nt}                = rmfield(stat{nt},'cfg');
end

if length(stat) == 1
    tmp = stat{1};
    stat = tmp; clear tmp;
end

fname_out                   = ['../results/stat/n10_tfEmergence_' keyword1 '_' keyword2 '_' keyword3 '_' keyword4 '.mat'];
save(fname_out,'stat','-v7.3');