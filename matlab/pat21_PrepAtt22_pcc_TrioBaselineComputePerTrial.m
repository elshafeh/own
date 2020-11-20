clear;clc;dleiftrip_addpath;

for cond_freq = {'13t15Hz'}
    
    for cond_filter = {'pcc.FixedAvg'} % 'pcc.FixedAvg'
        
        for sb = 1:14
            
            suj_list = [1:4 8:17];
            
            for prt = 1:3
                
                lck = 'CnD' ;
                suj = ['yc' num2str(suj_list(sb))] ;
                
                fname_in = [suj '.pt' num2str(prt) '.' lck];
                fprintf('Loading %50s \n',fname_in);
                load(['../data/' suj '/elan/' fname_in '.mat'])
                
                data = data_elan ;
                
                clear data_elan
                
                for cnd_time = 1:2
                    
                    st_point    = [-0.45 0.9];
                    tim_win     = 0.2;
                    
                    % Select period of interests
                    
                    lm1 = st_point(cnd_time)-0.04;
                    lm2 = st_point(cnd_time)+tim_win+0.04;
                    
                    cfg             = [];
                    cfg.toilim      = [lm1 lm2];
                    poi             = ft_redefinetrial(cfg, data);
                    
                    % Fourrier transform
                    
                    f_focus = 14;
                    
                    %                     f_tap   = str2double(cond_freq{:}(4:5))  - str2double(cond_freq{:}(1:2));
                    %                     f_tap   = f_tap / 2 ;
                    %                     f_tap   = f_tap + 4 ;
                    
                    f_tap = 3;
                    cfg               = [];
                    cfg.method        = 'mtmfft';
                    cfg.output        = 'fourier';
                    cfg.keeptrials    = 'yes';
                    cfg.foi           = f_focus;
                    cfg.tapsmofrq     = f_tap;

                    freq              = ft_freqanalysis(cfg,poi);
                    
                    if lm1 < 0
                        ext1= 'bsl';
                    else
                        ext1='actv';
                    end
                    
                    fprintf('\nLoading Leadfield and Common Filters\n');
                    load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
                    load(['../data/' suj  '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
                    
                    cfg                     = [];
                    cfg.method              = 'pcc';
                    cfg.frequency           = freq.freq;
                    cfg.grid                = leadfield;
                    cfg.headmodel           = vol;
                    cfg.keeptrials          = 'yes';
                    cfg.pcc.fixedori        = 'yes';
                    cfg.pcc.projectnoise    = 'yes';
                    cfg.pcc.lambda          = '5%';
                    cfg.pcc.keepmom         = 'yes';
                    
                    if strcmp(cond_filter{:}(end-2:end),'Avg')
                        fname_filt = [suj '.CnD.4KT.' cond_freq{:} '.commonFilter.' cond_filter{:}];
                    else
                        fname_filt = [suj '.pt' num2str(prt) '.CnD.4KT.' cond_freq{:} '.commonFilter.' cond_filter{:}];
                    end
                    
                    fprintf('\nLoading %50s \n\n',fname_filt);
                    load(['../data/' suj '/filter/' fname_filt '.mat']);
                    
                    cfg.grid.filter         = com_filter;
                    source                  = ft_sourceanalysis(cfg, freq);
                    
                    mom                     = source.avg.mom ;
                    
                    ix = find(source.inside,1,'first');
                    
                    mom = cellfun(@(x) abs(x).^2, mom, 'UniformOutput',false);
                    
                    iy = size(source.avg.mom{find(source.inside,1,'first')},2);
                    
                    iz = length(freq.trialinfo);
                    
                    mom(cellfun(@isempty, mom)) = {nan(1,iy)};
                    
                    source = cell2mat(mom);
                    
                    if iy ~= iz
                        
                        fct = iy/iz ; 
                        
                        for ii = 1:fct
                            
                            lmSrc1 = ((ii-1) * iz) + 1;
                            lmSrc2 = lmSrc1 + iz - 1;
                            
                            src{ii}   = source(:,lmSrc1:lmSrc2);
                            
                        end
                        
                        source = cat(3,src{:});
                        source = mean(source,3);
                        
                        clear src lmSrc1 lmSrc2 fct
                        
                    end
                    
                    clear mom ix iy iz 
                    
                    f_name_source = [suj '.pt' num2str(prt) '.' lck '.KT.' cond_freq{:} '.' ext1 ...
                        '.' cond_filter{:}];
                    
                    fprintf('Saving %50s \n',f_name_source);
                    save(['../data/' suj '/source/' f_name_source '.mat'],'source','-v7.3');
                    
                    clear source com_filter leadfield vol freq poi
                    
                end
                
                clear data
                
            end
            
        end
        
    end
    
    clearvars -except cond_filter cond_freq
    
end