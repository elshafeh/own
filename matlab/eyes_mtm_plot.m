clear ;

list_suj                                            = {'pilot01','pilot02'};
list_eye                                            = {'open','closed'};
list_cue                                            = {'right','left'};  %{'both'}; % 

for ns = 1:length(list_suj)
    for ne = 1:length(list_eye)
        
        subjectName                                 = list_suj{ns};
        
        for nc = 1:length(list_cue)
            
            ext_name                                = ['cuelock.mtm.comb.' list_eye{ne} '.' list_cue{nc}];
            dir_data                                = ['../data/' subjectName '/tf/'];
            
            fname                                   = [dir_data subjectName '_' ext_name '.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            cfg                                     = [];
            cfg.baseline                            = [-0.4 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq_comb                               = ft_freqbaseline(cfg,freq_comb);
            
            tmp{nc}                                 = freq_comb; clear freq_comb;
            
        end
        
        alldata{ns,ne}                              = tmp{1};
        
        %         act                                         = tmp{1}.powspctrm;
        %         bsl                                         = tmp{2}.powspctrm; clear tmp;
        %         alldata{ns,ne}.powspctrm                    = (act-bsl) ./ bsl; % (act-bsl); %
        
    end
end

clearvars -except alldata list_*;

list_name                                               = {'open RmL','closed RmL'};
i                                                       = 0;
nrow                                                    = 2;
ncol                                                    = 2;

for ns = 1:size(alldata,1)
    for nc = 1:size(alldata,2)
        
        dataplot                                        = alldata{ns,nc};
        
        
        cfg                                             = [];
        cfg.layout                                      = 'CTF275_helmet.mat'; % 'CTF275.lay'; %
        
        cfg.xlim                                        = [0.4 0.8];
        
        %         cfg.ylim                                        = [8 11];
        
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
