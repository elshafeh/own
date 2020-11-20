clear;close all;clc;
file_list                                           = dir('../data/preproc/*.fixlock.fin.mat');

figure;
nrow                                                = 2;
ncol                                                = 6;
i                                                   = 0;

for nf = 1:length(file_list)
    
    subjectName                                     = strsplit(file_list(nf).name,'.');
    subjectName                                     = subjectName{1};
    
    
    for ntarget = [0 3]
        for nratio  = [3]
            for nfreq = [1 2 3]
                
                
                i                                   = i+1;
                subplot(nrow,ncol,i)
                
                list_percent                        = [60 80 100];
                
                fname                               = ['../data/tf/' subjectName '.freq' num2str(nfreq) '.' num2str(ntarget) 'cycles.'];
                fname                               = [fname num2str(list_percent(nratio)) 'perc.mtm.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                cfg                                 = [];
                cfg.ylim                            = [0 4];
                cfg.xlim                            = [1.5 5];
                cfg.channel                         = 'MLP*'; %{'MLO11', 'MLO21', 'MLO22', 'MLO31', 'MRO11', 'MRO12', 'MRO21', 'MRO22', 'MRO31', 'MZO01', 'MZO02'};
                cfg.colormap                        = brewermap(256,'*RdBu');
                %                 cfg.baseline                        = [-0.6 -0.2];
                %                 cfg.baselinetype                    = 'relchange';
                cfg.colorbar                        = 'no';
                ft_singleplotTFR(cfg,freq_comb);
                
                %                 chan_interest                       = find(~cellfun('isempty', strfind(freq_comb.label,'P'))); % find(ismember(freq_comb.label,cfg.channel));%
                %
                %                 ix1                                 = 6;
                %                 ix2                                 = 7;
                %                 ix1                                 = find(abs(freq_comb.time - ix1) == min(abs(freq_comb.time - ix1)));
                %                 ix2                                 = find(abs(freq_comb.time - ix2) == min(abs(freq_comb.time - ix2)));
                %
                %                 data                                = nanmean(nanmean(freq_comb.powspctrm(chan_interest,:,ix1:ix2),3),1);
                %
                %                 ix1                                 = -0.6;
                %                 ix2                                 = -0.2;
                %                 ix1                                 = find(abs(freq_comb.time - ix1) == min(abs(freq_comb.time - ix1)));
                %                 ix2                                 = find(abs(freq_comb.time - ix2) == min(abs(freq_comb.time - ix2)));
                %
                %                 bsl                                 = nanmean(nanmean(freq_comb.powspctrm(chan_interest,:,ix1:ix2),3),1);
                %
                %                 data                                = (data - bsl) ./ bsl;
                %
                %                 cfg.linecolor                       = 'kbr';
                %                 plot(freq_comb.freq,data,cfg.linecolor(nfreq),'LineWidth',1);
                %                 plot(freq_comb.freq,data,cfg.linecolor(nratio),'LineWidth',1);
                %                 xlim([0 5]);
                
                title([subjectName ' F' num2str(nfreq) ' %' num2str(nratio) ' ' num2str(ntarget) 'CYC']);
            end
            
            %             legend({'F1%','F2%','F3%'}); % {'60%','80%','100%'}
            
        end
    end
end