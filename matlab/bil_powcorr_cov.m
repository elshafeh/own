clear;

load ../data/bil_goodsubjectlist.27feb20.mat



for nsuj = 1:length(suj_list)
    
    subjectName           	= suj_list{nsuj};
    
    fname_out            	= ['F:/bil/preproc/' subjectName '.maxchan_4signals.mat'];
    fprintf('loading %s\n',fname_out);
    load(fname_out);
    
    cfg                 	= [];
    cfg.covariance          = 'yes';
    cfg.keeptrials          = 'no';
    cfg.removemean          = 'yes';
    timelock                = ft_timelockanalysis(cfg,data);
    
    cov                     = timelock.cov; % all trials
    d                       = sqrt(diag(cov)); % SD, diagonal is variance per channel
    r(nsuj,:,:)             = cov ./ (d*d');
    
end

figure; 
imagesc(1:4,1:4,squeeze(mean(r,1)));
xticks(1:4);yticks(1:4);
xticklabels(timelock.label);yticklabels(timelock.label)