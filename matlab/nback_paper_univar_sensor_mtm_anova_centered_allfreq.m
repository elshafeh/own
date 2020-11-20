clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51];
allpeaks                                = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                    = apeak; clear apeak;
    allpeaks(nsuj,2)                    = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)        = nanmean(allpeaks(:,2));

keep suj_list allpeaks

test_band                               = 'alpha';

for nsuj = 1:length(suj_list)
    
    subjectName                         = ['sub' num2str(suj_list(nsuj))];clc;
    list_stim                           = {'first','target'};
    
    for nstim = 1:length(list_stim)
        for nback = [0 1 2]
            
            % load data from both sessions
            check_name                  = dir(['J:/temp/nback/data/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.' list_stim{nstim} '.stim.1t100Hz.sens.mat']);
            
            for nf = 1:length(check_name)
                
                fname                   = [check_name(nf).folder filesep check_name(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp{nf}                 = freq_comb; clear freq_comb;
                
            end
            
            % avearge both sessions
            freq                        = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
            
            apeak                       = allpeaks(nsuj,1);
            bpeak                       = allpeaks(nsuj,2);
            
            list_freq{1}                = [4 6];
            list_freq{2}                = [3 5];
            list_freq{3}                = [apeak-1 apeak+1];
            list_freq{4}                = [bpeak-2 bpeak+2];
            list_freq{5}                = [60 80];
            list_freq{6}                = [60 100];
            
            list_freq_name              = {'theta 1' 'theta 2','alpha','beta','gamma 1' ,'gamma 2'};
            
            for nfreq = 1:length(list_freq)
                
                xi                      = find(round(freq.freq) == round(list_freq{nfreq}(1)));
                yi                      = find(round(freq.freq) == round(list_freq{nfreq}(2)));
                
                if nfreq < 5
                    cfg.baseline        = [-0.4 -0.2];
                else
                    cfg.baseline        = [-0.2 0];
                end
                
                t1                      = find(round(freq.time,2) == round(cfg.baseline(1),2));
                t2                      = find(round(freq.time,2) == round(cfg.baseline(2),2));
                
                avg                  	= [];
                avg.avg               	= squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
                avg.label             	= freq.label;
                avg.dimord             	= 'chan_time';
                avg.time              	= freq.time; clear xi yi;
                
                bsl                     = nanmean(avg.avg(:,t1:t2),2);
                avg.avg                 = (avg.avg - bsl) ./ bsl; clear bsl t1 t1;
                
                alldata{nsuj,nstim,nfreq,nback+1}         = avg; clear avg;
                
            end
        end
    end
end

keep alldata list_*

for nstim = 1:size(alldata,2)
    for nfreq = 1:size(alldata,3)
        
        % compute anova
        cfg                 	= [];
        cfg.latency           	= [-0.1 2];
        if nfreq < 5
            cfg.minnbchan    	= 3;
        else
            cfg.minnbchan       = 2; % go easy on gamma :)
        end
        stat{nstim,nfreq}       = h_anova(cfg,alldata(:,nstim,nfreq,:));
    end
end

keep alldata list_* stat

for nfreq = 1:size(stat,2)
    for nstim = 1:size(stat,1)
        
        cfg_in                  = [];
        cfg_in.nrow             = 4;
        cfg_in.ncol             = 4;
        
        cfg_in.topo.layout      ='neuromag306cmb.lay';
        cfg_in.topo.colormap   	= brewermap(256,'*RdBu');
        cfg_in.posthoc.xticklabels     = {'0B','1B','2B'};
        h_plotanova(cfg_in,stat{nstim,nfreq},squeeze(alldata(:,nstim,nfreq,:)),[list_stim{nstim} ' ' list_freq_name{nfreq}]);
        
    end
end