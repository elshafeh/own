clear;

list_suj                                = {};
for j = 1:9
    list_suj{j,1}                       = ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:22,24:30]
    j                                   = j+1;
    list_suj{j,1}                       = ['sub0', num2str(k)];
end

keep list_suj

for nsuj = 1:15 %length(list_suj)
    
    subjectName                             = list_suj{nsuj};
    dir_data                                = 'I:/eyes/decode/';
    
    list_cond                               = {'cueLock','stimLock'};
    list_feature                            = {'decodCorrect','decodCue','decodStim'};
    
    for n_con = 1:length(list_cond)
        
        tmp                                 = [];
        
        for nfeat = 1:length(list_feature)
            for nfreq = 1:30
                
                
                ext_feature               	= list_feature{nfeat};
                fname                    	= [dir_data subjectName '.' list_cond{n_con} '.'  ...
                    ext_feature '.' num2str(nfreq) 'Hz.auc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(nfeat,nfreq,:)       	= scores; clear scores;
            end
            
        end
        
        freq                                = [];
        freq.label                          = list_feature;
        freq.dimord                         = 'chan_freq_time';
        freq.time                           = time_axis; clear time_axis;
        freq.freq                           = 1:30;
        freq.powspctrm                      = tmp; clear tmp;
        alldata{nsuj,n_con}                 = freq; clear freq;
        
    end
    
    
end

i =0;

for nchan = 1:length(alldata{1}.label)
    for ncond = 1:size(alldata,2)
        
        i = i +1;
        subplot(4,2,i);
        
        cfg=[];
        cfg.channel                             = nchan;
        %         cfg.xlim                                = [-1 alldata{1,ncond}.time(end)];
        %         cfg.zlim                                = [0.45 1];
        cfg.colromap                            = brewermap(256,'*RdBu');
        ft_singleplotTFR(cfg,ft_freqgrandaverage([],alldata{:,ncond}));
        
        title([list_cond{ncond} ' ' alldata{1}.label{nchan}]);
        set(gca,'FontSize',14,'FontName','Calibri','FontWeight','normal');
        
        vline(0,'--r');
        
    end
end
