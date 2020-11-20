clear ; close all;

% suj_list                                            = dir('../data/sub*/tf/*cuelock.fourier.alltrials.comb.mat');
% 
% for ns = 1:length(suj_list)
%     
%     fname                                           = [suj_list(ns).folder '/' suj_list(ns).name];
%     fprintf('\nloading %s\n',fname);
%     load(fname);
%     
%     sujName                                         = suj_list(ns).name(1:6);
%     
%     index_cnd{1}                                    = 1:length(freq_comb.trialinfo);
%     list_cnd                                        = {'alltrials'};
%     
%     for nc = 1:length(list_cnd)
%         
%         cfg                                         = [];
%         cfg.trials                                  = index_cnd{nc};
%         freq_select                                 = ft_selectdata(cfg,freq_comb); clc;
%         
%         cfg                                         = [];
%         cfg.indexchan                               = 'all';
%         cfg.index                                   = 'all';
%         cfg.alpha                                   = 0.05;
%         cfg.time                                    = [-0.5 6];
%         cfg.freq                                    = [1 10];
%         
%         phase_lock                                  = mbon_PhaseLockingFactor(freq_select, cfg);
%         
%         fname                                       = ['../data/' sujName '/tf/' sujName '.cuelock.itc.comb.' list_cnd{nc} '.mat'];
%         fprintf('Saving %s\n',fname);
%         tic;save(fname,'phase_lock','-v7.3');toc;
%         
%         clear phase_lock freq_select
%         
%     end
end
