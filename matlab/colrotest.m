clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

load ~/Dropbox/project_me/data/bil/virt/sub001.virtualelectrode.wallis.mat
chan_list   = data.label; clear data;

      
freq                            = [];
freq.powspctrm              	= [];

for nchan = 1
        
    fname                    	= '/Users/heshamelshafei/Dropbox/project_me/data/bil/virt/sub001.wallis.2t3Hz.chan1.gc.bin1.pac.mat';
    fprintf('loading %s\n',fname);
    load(fname);
    
    freq.powspctrm(nchan,:,:) 	= py_pac.powspctrm;
    freq.time                	= py_pac.time;
    freq.freq               	= py_pac.freq;
    freq.label              	= chan_list(1);
    freq.dimord               	= 'chan_freq_time';
    
end

            
t1                            	= find(round(freq.time,3) == round(-0.4,3));
t2                            	= find(round(freq.time,3) == round(-0.2,3));
bsl                           	= mean(freq.powspctrm(:,:,t1:t2),3);

% apply baseline correction
freq.powspctrm                  = (freq.powspctrm - bsl) ./ bsl;

keep freq;

%%

list_map = {'*PiYG' '*RdBu' 'PuOr' 'BrBG'};

for n = 1:length(list_map)
    figure;
    cfg             =[];
    cfg.ylim        = [5 40];
    cfg.colormap    = brewermap(256, list_map{n});
    ft_singleplotTFR(cfg,freq)
end