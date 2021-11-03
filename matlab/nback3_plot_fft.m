clear;clc;

suj_list             	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_time        	= {'pre' 'post'};

    for ntime = 1:2

        dir_data     	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        fname_1     	= dir([dir_data 'sub' num2str(suj_list(nsuj)) '.*.target.fast.' list_time{ntime}  '.fft.mat']);
        fname_2     	= dir([dir_data 'sub' num2str(suj_list(nsuj)) '.*.target.slow.' list_time{ntime}  '.fft.mat']);
        flist           = [fname_1;fname_2]; clear fname_*
        
        pow             = [];
        
        for nf = 1:length(flist)
            
            fname       = [flist(nf).folder filesep flist(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            pow(nf,:,:)	= freq_comb.powspctrm;
            
        end
        
        alldata{nsuj,ntime}     = freq_comb;
        alldata{nsuj,ntime}.powpsctrm     = squeeze(mean(pow,1)); clear pow freq_comb
        
        
    end
end

keep alldata

%%
clc;
close all;


cfg                     = [];
cfg.channel            	= {'MEG1912+1913','MEG1922+1923','MEG2032+2033','MEG2042+2043','MEG2112+2113', ... 
    'MEG2312+2313','MEG2342+2343'};
cfg.xlim                = [1 40];
cfg.color               = 'br';
cfg.plot_single         = 'no';
h_plot_erf(cfg,alldata);
legend({'pre' '' 'post' ''});
title('Occipital power spectrum');
set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
