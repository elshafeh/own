clear ;

keyword1                    = 'mtmconvol';
keyword2                    = '10t40Hz';
keyword3                    = 'comb';

suj_list                    = dir(['../data/sub*/tf/*' keyword1 '*' keyword2 '*' keyword3 '.mat']);
fprintf('\n %2d subjects found\n',length(suj_list));

for ns = 1:length(suj_list)
    
    fname                   = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    subjectName             = suj_list(ns).name(1:6);
    
    % this finds the freq structure loaded
    find_var                = whos;
    find_var                = {find_var.name};
    find_var                = find(strcmp(find_var,'freq_axial'));
    
        
    if isempty(find_var)
        freq                = freq_comb; clear freq_comb
    else
        freq                = freq_axial; clear freq_axial
    end
    
    list_cond               = {'pre','retro','correct','incorrect'};
    list_find               = {[11 12],13,1,0};
    ix_target               = [1 1 16 16];
    
    for ni = 1:length(list_cond)
        
        cfg                 = [];
        cfg.trials          = find(ismember(freq.trialinfo(:,ix_target(ni)),list_find{ni}));
        tmp                 = ft_selectdata(cfg,freq);
        
        tmp                 = ft_freqdescriptives([],tmp);
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        tmp                 = ft_freqbaseline(cfg,tmp);
        
        cfg                 = [];
        cfg.latency         = [-0.2 6];
        tmp                 = ft_selectdata(cfg,tmp);
        
        alldata{ns,ni,1}    = h_freq2avg(tmp,[13 17],'avg_over_freq');
        alldata{ns,ni,2}    = h_freq2avg(tmp,[22 27],'avg_over_freq');
        
    end
end

keep alldata list_* suj_list keyword*

fname_out                   = ['../results/gavg/n' num2str(length(suj_list)) '_' keyword1 '_' keyword2 '_' keyword3 '.AverageToPlot.mat'];
save(fname_out,'-v7.3');