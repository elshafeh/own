clear ; global ft_default
ft_default.spmversion = 'spm12';

% suj_list                                            = [1:33 35:36 38:44 46:51];
load suj_list_peak.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                     = ['sub' num2str(suj_list(nsuj))];clc;
    
    for nback = [0 1 2]
        
        % load data from both sessions
        check_name                                  = dir(['../data/tf/' subjectName '.sess*.' num2str(nback) 'back.1t30Hz.1HzStep.AvgTrials.stk.exl.mat']);
        
        for nfile = 1:length(check_name)
            fname                                   = [check_name(nfile).folder filesep check_name(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp{nfile}                              = freq_comb; clear freq_comb;
        end
        
        % avearge both sessions
        freq                                        = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
        % baseline-correct
        cfg                                         = [];
        cfg.baseline                                = [-0.2 0];
        cfg.baselinetype                            = 'relchange';
        freq                                        = ft_freqbaseline(cfg,freq);
        
        % load peak
        fname                                       = ['../data/peak/' subjectName '.alphabetapeak.m1000m0ms.mat'];
        fprintf('loading %s\n\n',fname);
        load(fname);
        
        fpeak                                       = [bpeak 25];
        bnwidth                                     = [3 5];
        
        for nfreq = 1:length(fpeak)
            
            f1                                      = fpeak(nfreq) - bnwidth(nfreq);
            f2                                      = fpeak(nfreq) + bnwidth(nfreq);
            
            cfg                                     = [];
            cfg.frequency                           = [f1 f2];
            cfg.avgoverfreq                         = 'yes';
            avg                                     = ft_selectdata(cfg,freq);
            
            avg.avg                                 = squeeze(avg.powspctrm);
            avg.dimord                              = 'chan_time';
            avg                                     = rmfield(avg,'powspctrm');
            avg                                     = rmfield(avg,'freq');
            
            alldata{nback+1,nfreq,nsuj}             = avg ;
            
        end
        
        clear f1 f2 fpeak apeak bpeak freq freq_comb ; clc;
        
    end
end

keep alldata ;

for nb = 1:size(alldata,1)
    for nfreq = 1:size(alldata,2)
        gavg{nb,nfreq}                              = ft_timelockgrandaverage([],alldata{nb,nfreq,:});
    end
end

keep alldata gavg;

cfg                                                 = [];
cfg.layout                                          = 'neuromag306cmb.lay';
cfg.marker                                          = 'off';
cfg.comment                                         = 'no';
cfg.colormap                                        = brewermap(256, '*RdBu'); % PuBuGn % *RdYlBu
cfg.showlegend                                      = 'no';
cfg.colorbar                                        = 'no';
cfg.zlim                                            = 'maxabs'; % maxabs % minzero % zeromax
cfg.linewidth                                       = 2;
cfg.channel                                         = {'MEG1922+1923', 'MEG1932+1933', 'MEG2112+2113', 'MEG2332+2333', 'MEG2342+2343'};

for nfreq = 1:size(gavg,2)
    subplot(2,2,nfreq)
    ft_singleplotER(cfg,gavg{:,nfreq});
    title('');legend({'0B','1B','2B'});%legend({'alpha','beta'});
end