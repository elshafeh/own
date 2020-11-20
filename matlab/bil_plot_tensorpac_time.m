clear;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:3
    
    subjectName           	= suj_list{nsuj};
    list_method             = {'circular' 'gc'};
    
    for nm = 1:2
        
        fname_out            	= ['F:/bil/pac/' subjectName '.3t5Hz.' list_method{nm} '.pac.maxchan.mat'];
        fprintf('loading %s\n',fname_out);
        load(fname_out);
        
        freq                    = [];
        freq.powspctrm(1,:,:)   = py_pac.powspctrm;
        freq.time               = py_pac.time;
        freq.freq               = py_pac.freq;
        freq.label              = {['pac ' list_method{nm}]};
        freq.dimord             = 'chan_freq_time';
        
        alldata{nsuj,nm}         = freq; clear freq;
        
    end
end

keep alldata

for nm = 1:2
    
    subplot(2,1,nm)
    
    cfg                                 = [];
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256, '*RdBu');
    cfg.ylim                            = [5 50];
    cfg.zlim                            = 'zeromax';
    ft_singleplotTFR(cfg, ft_freqgrandaverage([],alldata{:,nm}));
    
    xticks([0 1.5 3 4.5 5.5]);
    xticklabels({'1st cue' '1st gab' '2nd cue' '2nd gab' 'mean RT'});
    vline([0 1.5 3 4.5 5.5],'--k');
    
end