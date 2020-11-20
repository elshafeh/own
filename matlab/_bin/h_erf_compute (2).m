function h_erf_compute(data,ns,nsess,petit_ext)

cfg                                     = [];
cfg.demean                              = 'yes';
cfg.baselinewindow                      = [-0.1 0];
cfg.lpfilter                            = 'yes';
cfg.lpfreq                              = 20;
data                                    = ft_preprocessing(cfg,data);

list_name                               = {'0back','1back','2back'};
list_index                              = [4 5 6];

for nc = 1:length(list_name)
    
    ix                                  = find(data.trialinfo(:,2) == list_index(nc));
    
    if ~isempty(ix)
        cfg                             = [];
        cfg.trials                      = ix;
        data_sub                        = ft_selectdata(cfg,data);
        
        avg                             = ft_timelockanalysis([], data_sub);
        avg_comb                        = ft_combineplanar([],avg);
        avg_comb                        = rmfield(avg_comb,'cfg');
        
        fname_out                       = ['../data/erf/data_sess' num2str(nsess) '.s' num2str(ns) '.' petit_ext '.' list_name{nc} '.erfComb.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'avg_comb','-v7.3');toc
        
    end
end

