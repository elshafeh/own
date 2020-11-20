clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name2               = 'EmergenceBasedMNI.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked10MStep80Slct';
        
        list_ix                 = {'R','L','N'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                                    = ft_freqdescriptives([],freq);
            
            cfg                                     = [];
            cfg.baseline                            = [-0.6 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            
            allsuj_data{ngroup}{sb,ncue}            = freq;
            allsuj_data{ngroup}{sb,ncue}.suj        = suj;
            
            
            clear new_freq cfg
            
        end
    end
end

clearvars -except allsuj_data big_freq

for ngroup = 1:length(allsuj_data)
    
    figure;
    
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        for nchan = 1
            
            for ncue = 1:size(allsuj_data{ngroup},2)
                
                
                ls_threewise        = {'R_Cue','L_Cue','N_Cue'};
                ls_chan             = allsuj_data{ngroup}{sb,ncue}.label{nchan};
                
                name_chan           =  ls_chan;
                suj                 = allsuj_data{ngroup}{sb,ncue}.suj;
                
                
                x1                  = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(0.6,2));
                x2                  = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(1.1,2));
                
                y1                  = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(7));
                y2                  = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(15));
                
                tmp                 = mean(allsuj_data{ngroup}{sb,ncue}.powspctrm(nchan,y1:y2,x1:x2),3);
                pow(ncue,1)         = squeeze(mean(tmp,2));
                
                
            end
        end
        
        subplot(4,4,sb)
        plot(pow);
        title(suj);
        
    end
end
