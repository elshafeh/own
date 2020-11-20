clear;close all;clc;

figure;
nrow                                                = 3;
ncol                                                = 4;
i                                                   = 0;

file_list                                           = dir('../data/preproc/*.fixlock.fin.mat');

nsuj      = [1];
nratio  = [3];
ntarget = [0];

for nfreq   = [1 2 3]
    
    subjectName                             = strsplit(file_list(nsuj).name,'.');
    subjectName                          	= subjectName{1};
    
    list_percent                            = [60 80 100];
    
    fname                                   = ['../data/tf/' subjectName '.freq' num2str(nfreq) '.' num2str(ntarget) 'cycles.'];
    fname                                   = [fname num2str(list_percent(nratio)) 'perc.mtm.minevoked.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    flist                                   = [1.3 2.1 3.1];
    
    ix1                                     = 5/(flist(nfreq));
    ix2                                     = ix1+ 3/(flist(nfreq));
    ix1                                     = find(abs(freq_comb.time - ix1) == min(abs(freq_comb.time - ix1)));
    ix2                                     = find(abs(freq_comb.time - ix2) == min(abs(freq_comb.time - ix2)));
    
    avg{nfreq}                              = h_freq2avg(freq_comb,ix1,ix2,'time');
    %     avg{nfreq}.avg                          = avg{nfreq}.avg - mean(avg{nfreq}.avg,2);
    
    
end

list_chan_group                         = {'MLO*','MRO*','MLF*','MLP*','MLC*','MLT*','MRF*','MRP*','MRC*','MRT*'};

for nc = 1:length(list_chan_group)
    
    i                                   = i +1;
    subplot(nrow,ncol,i);
    
    cfg                                     = [];
    cfg.channel                             = list_chan_group{nc};
    cfg.colormap                            = brewermap(256,'*RdBu');
    cfg.colorbar                            = 'no';
    cfg.layout = 'CTF275.lay';
    cfg.xlim                                = [0 4];
    ft_singleplotER(cfg,avg{:});
    
    title(list_chan_group{nc});
    
end

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

% title([subjectName ' F' num2str(nfreq) ' %' num2str(nratio) ' ' num2str(ntarget) 'CYC']);

%             legend({'F1%','F2%','F3%'}); % {'60%','80%','100%'}
