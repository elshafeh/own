clear ;

keyword1                    = 'mtmconvol';
keyword2                    = '10t40Hz';
keyword3                    = 'comb';

suj_list                    = dir(['../data/sub*/tf/*' keyword1 '*' keyword2 '*' keyword3 '.mat']);
fprintf('\n %2d subjects found\n',length(suj_list));

keyword3                    = [keyword3 '_hc_regress'];

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
        freq                = h_remove_hc_confound(headpos,freq_comb); clear freq_comb
    else
        freq                = h_remove_hc_confound(headpos,freq_axial); clear freq_axial
    end
    
    list_cond               = {'pre','retro','correct','incorrect'};
    list_find               = {[11 12],13,1,0};
    ix_target               = [1 1 16 16];
    
    for ni = 1:length(list_cond)
        
        cfg                 = [];
        cfg.trials          = find(ismember(freq.trialinfo(:,ix_target(ni)),list_find{ni}));
        tmp                 = ft_selectdata(cfg,freq);
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        tmp                 = ft_freqbaseline(cfg,tmp);
        
        alldata{ns,ni}      = ft_freqdescriptives([],tmp); clear tmp;
        alldata{ns,ni}      = rmfield(alldata{ns,ni},'cfg');
        
    end
    
end

keep alldata* keyword* list_* suj_list;

nsuj                        = size(alldata,1);
[design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                         = [];
cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.tail                    = 0;cfg.clustertail  = 0;
cfg.neighbours              = neighbours;

cfg.frequency               = [10 40];

cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 2; % !!

cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

list_contrast               = {[1 2] [3 4]};
list_latency                = {[0 6.5] [0 6.5]};

for nt = 1:length(list_contrast)
    
    i1                      = list_contrast{nt}(1);
    i2                      = list_contrast{nt}(2);
    
    cfg.latency             = list_latency{nt};
    
    stat{nt}                = ft_freqstatistics(cfg, alldata{:,i1},alldata{:,i2});
    stat{nt}                = rmfield(stat{nt},'cfg');
    
    list_compare{nt}        = [list_cond{i1} '.vs.' list_cond{i2}];
    
end


keyword4                    = 'multip.comparison';

fname_out                   = ['../results/stat/n' num2str(length(suj_list)) '_' keyword4 '_' keyword1 '_' keyword2 '_' keyword3 '.mat'];
save(fname_out,'stat','list_compare','-v7.3');