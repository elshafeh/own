clear;

ext_name                                                    = '10t40Hz*Keep*';
suj_list                                                    = dir(['../data/sub*/tf/*' ext_name '.mat']);

for ns = 1:length(suj_list)
    
    subjectName                                             = suj_list(ns).name(1:6);
    
    chk                                                     = [];
    
    if isempty(chk)
        
        fname                                               = [suj_list(ns).folder '/' suj_list(ns).name];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        erf_ext_name                                        = 'max20chan.p0p200ms';
        
        fname                                               = ['../data/' subjectName '/erf/' subjectName '.gratinglock.erfComb.' erf_ext_name '.postOnset.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        peak_window                                         = [-0.6 0];
        peak_name                                           = ['m' num2str(abs(peak_window(1)*1000)) 'm' num2str(abs(peak_window(2)*1000)) 'ms'];
        
        cfg                                                 = [];
        cfg.channel                                         = max_chan;
        cfg.latency                                         = peak_window;
        cfg.frequency                                       = [15 30];
        freq_peak                                           = ft_selectdata(cfg,freq_comb);
        
        cfg                                                 = [];
        cfg.method                                          = 'maxabs' ;
        cfg.foi                                             = [15 35];
        apeak                                               = alpha_peak(cfg,freq_peak);
        
        apeak                                               = apeak(1);
        
        fname_out                                           = ['../data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.betaPeak.' peak_name '.' erf_ext_name '.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'apeak');
        
        list_windows                                        = [-0.6 0; 0.5 1.5; 2 3; 3.5 4.5];
        
        list_cond                                           = {'pre','retro'};
        
        %         for nc = 1:2
        %             for ntime = 1:size(list_windows,1)
        %
        %                 cfg                                         = [];
        %                 cfg.channel                                 = max_chan;
        %                 cfg.latency                                 = list_windows(ntime,:);
        %                 cfg.frequency                               = [15 35];
        %                 cfg.trials                                  = find(freq_comb.trialinfo(:,8) == nc);
        %                 freq                                        = ft_selectdata(cfg,freq_comb);
        %
        %                 for nb_bin  = [6 7 8 9 10]
        %
        %                     bnwidth                                 = 1;
        %
        %                     [bin_summary]                           = h_preparebins(freq,apeak,nb_bin,bnwidth);
        %
        %                     bin_name                                = [num2str(nb_bin) 'Bins.' num2str(bnwidth) 'Hz'];
        %
        %                     fname_out                               = ['../data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.betaPeak.' peak_name '.' erf_ext_name '.' bin_name '.window' num2str(ntime) '.' list_cond{nc} '.mat'];
        %                     fprintf('saving %s\n',fname_out);
        %                     save(fname_out,'bin_summary');
        %
        %                     clear bin_summary
        %
        %                 end
        %
        %                 clear freq
        %
        %             end
        %         end
        
        keep suj_list ns
        
    end
end