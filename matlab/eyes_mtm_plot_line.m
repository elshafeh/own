clear ;

list_suj                                                    = {'pilot01','pilot02'};
list_eye                                                    = {'open','closed'};
list_cue                                                    = {'right','left'};


for ns = 1:length(list_suj)
    
    i                                                       = 0;
    subjectName                                             = list_suj{ns};
    
    for ne = 1:length(list_eye)
        for nc = 1:length(list_cue)
            
            ext_name                                        = ['cuelock.mtm.minevoked.comb.' list_eye{ne} '.' list_cue{nc}];
            dir_data                                        = ['../data/' subjectName '/tf/'];
            
            fname                                           = [dir_data subjectName '_' ext_name '.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            cfg                                             = [];
            cfg.baseline                                    = [-0.6 -0.2];
            cfg.baselinetype                                = 'relchange';
            freq_comb                                       = ft_freqbaseline(cfg,freq_comb);
            
            load chan_TDmod.mat
            
            i                                               = i + 1;
            
            for nchan = 1:2
                
                ix_chan                                     = find(ismember(freq_comb.label,list_chan{nchan}));
                
                ix_f1                                       = find(round(freq_comb.freq,1) == round(7,1));
                ix_f2                                       = find(round(freq_comb.freq,1) == round(15,1));
                
                tmp                                         = freq_comb.powspctrm(ix_chan,ix_f1:ix_f2,:);
                tmp                                         = squeeze(mean(tmp,1));
                tmp                                         = squeeze(mean(tmp));
                
                alldata(ns,i,nchan,:)                       = tmp;
                
                list_name{i}                                = [list_eye{ne} ' ' list_cue{nc}];
                list_axs                                    = freq_comb.time;
                
            end
        end
    end
end

clearvars -except alldata list_*;

i                                                           = 0;
nrow                                                        = 2;
ncol                                                        = 4;

for ns = 1:size(alldata,1)
    for ni = 1:size(alldata,2)
        
        i                                                   = i +1;
        subplot(nrow,ncol,i)
        
        data                                                = squeeze(alldata(ns,ni,:,:));
        
        plot(list_axs,data,'LineWidth',2);
        
        xlim([-0.1 2]);
        ylim([-0.3 0.3]);
        
        title([list_suj{ns} ' ' list_name{ni}]);
        legend({'left chan','right chan'})
        
        vline(0,'--k');
        hline(0,'--k');
        
        grid on
        set(gca,'FontSize',14);
        
    end
end