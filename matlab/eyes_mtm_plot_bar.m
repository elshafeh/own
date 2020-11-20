clear ;

list_suj                                                        = {'pilot01','pilot02','pilot03'};
list_eye                                                        = {'open','closed'};
list_cue                                                        = {'right','left'};


for ns = 1:length(list_suj)
    
    i                                                           = 0;
    subjectName                                                 = list_suj{ns};
    
    for ne = 1:length(list_eye)
        for nc = 1:length(list_cue)
            
            ext_name                                            = ['cuelock.mtm.minevoked.comb.' list_eye{ne} '.' list_cue{nc}];
            dir_data                                            = ['../data/' subjectName '/tf/'];
            
            fname                                               = [dir_data subjectName '_' ext_name '.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            cfg                                                 = [];
            cfg.baseline                                        = [-0.6 -0.2];
            cfg.baselinetype                                    = 'relchange';
            freq_comb                                           = ft_freqbaseline(cfg,freq_comb);
            
            load chan_TDmod.mat
            
            i                                                   = i + 1;
            
            zoom_time                                           = [0.4 0.9];
            zoom_freq                                           = [8 11];
            
            for nchan = 1:2
                
                ix_chan                                         = find(ismember(freq_comb.label,list_chan{nchan}));
                
                ix_t1                                           = find(round(freq_comb.time,3) == round(zoom_time(1),3));
                ix_t2                                           = find(round(freq_comb.time,3) == round(zoom_time(2),3));
                
                ix_f1                                           = find(round(freq_comb.freq,1) == round(zoom_freq(1),1));
                ix_f2                                           = find(round(freq_comb.freq,1) == round(zoom_freq(2),1));
                
                tmp                                             = freq_comb.powspctrm(ix_chan,ix_f1:ix_f2,ix_t1:ix_t2);
                tmp                                             = squeeze(mean(tmp,1));
                tmp                                             = squeeze(mean(tmp,1));
                tmp                                             = squeeze(mean(tmp));

                alldata(ns,i,nchan)                             = tmp;
                
                list_name{i}                                    = [list_eye{ne} ' ' list_cue{nc}];
                
                cfg                                             = [];
                cfg.frequency                                   = zoom_freq;
                cfg.latency                                     = zoom_time;
                cfg.avgoverfreq                                 = 'yes';
                cfg.avgovertime                                 = 'yes';
                alltopo{ns,i}                                   = ft_selectdata(cfg,freq_comb);
                
            end
        end
    end
end

clearvars -except alldata list_* alltopo;

nsuj                                                            = 3;
i                                                               = 0;
nrow                                                            = 2*nsuj;
ncol                                                            = 4;

for ns = 1:size(alldata,1)
    
    for ncon = 1:4
        
        i                                                       = i +1;
        subplot(nrow,ncol,i)
        
        cfg                                                     = [];
        cfg.layout                                              = 'CTF275_helmet.mat';
        cfg.ylim                                                = 'absmax';
        cfg.marker                                              = 'off';
        cfg.comment                                             = 'no';
        cfg.colorbar                                            = 'no';
        cfg.colormap                                            = brewermap(256, '*RdYlBu');
        ft_topoplotTFR(cfg,alltopo{ns,ncon});
        
    end
    
    i                                                           = i +1;
    subplot(nrow,ncol,i:i+3)
    
    data                                                        = squeeze(alldata(ns,:,:));
    
    bar(data);
    
    xticks(0:length(list_name)+1)
    xticklabels([{''} list_name {''}]);
    
    xlim([0 length(list_name)+1]);
    ylim([-0.3 0.3]);
    
    title(list_suj{ns});
    
    legend({'left cent chan','right cent chan'})
    
    grid on
    set(gca,'FontSize',14);
    
    i                                                           = i +3;
    
end