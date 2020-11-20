clear ;

list_suj                                                = {'pilot01','pilot02'};
list_eye                                                = {'open','closed'};
list_cue                                                = {'right','left'};

for ns = 1:length(list_suj)
    
    i                                                   = 0;
    
    for ne = 1:length(list_eye)
        for nc = 1:length(list_cue)
            
            
            subjectName                                 = list_suj{ns};
            
            ext_name                                    = ['cuelock.mtm.comb.' list_eye{ne} '.' list_cue{nc}];
            dir_data                                    = ['../data/' subjectName '/tf/'];
            
            fname                                       = [dir_data subjectName '_' ext_name '.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            cfg                                         = [];
            cfg.baseline                                = [-0.6 -0.2];
            cfg.baselinetype                            = 'relchange';
            freq_comb                                   = ft_freqbaseline(cfg,freq_comb);
            
            i                                           = i + 1;
            alldata{ns,i}                               = freq_comb;
            list_name{i}                                = [list_eye{ne} ' ' list_cue{nc}];
            
        end
    end
end

clearvars -except alldata list_*;

i                                                       = 0;
nrow                                                    = 2;
ncol                                                    = 4;

for ns = 1:size(alldata,1)
    for nc = 1:size(alldata,2)
        
        dataplot                                        = alldata{ns,nc};
        
        
        cfg                                             = [];
        cfg.layout                                      = 'CTF275_helmet.mat'; % 'CTF275.lay'; %
        
        cfg.xlim                                        = [0.4 0.8];
        cfg.ylim                                        = [9 11];
        
        cfg.marker                                      = 'off';
        cfg.comment                                     = 'no';
        cfg.colormap                                    = brewermap(256, '*RdYlBu');
        cfg.colorbar                                    = 'no';
        
        i                                               = i +1;
        subplot(nrow,ncol,i)
        
        cfg.zlim                                        = 'maxabs';
        ft_topoplotTFR(cfg,dataplot);
        title([list_suj{ns} ' ' list_name{nc}]);
        
        
    end
end