clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}        = allsuj(2:15,1);
suj_group{2}        = allsuj(2:15,2);

suj_list            = [suj_group{1};suj_group{2}];

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);
% suj_list = [];
% for n = 1:length(suj_group)
%     suj_list            = [suj_list;suj_group{n}];
% end
% suj_list            = unique(suj_list);
% suj_list            = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    list_cond_main  = {'CnD'};
    vox_size        = 0.5;
    dir_data        = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
    
    
    load([dir_data suj '.VolGrid.0.5cm.mat']);
    
    pkg.vol         = vol;
    
    clear vol leadfield
    
    for nelan = 1:length(list_cond_main)
        
        fname_in            = [dir_data suj '.' list_cond_main{nelan} '.mat'];
        
        load([dir_data suj '.adjusted.leadfield.0.5cm.mat']);
        
        pkg.leadfield       = leadfield; clear leadfield;
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        list_concat         = [-0.6 0.9; -0.5 0.9];
        list_name           = {'m600p900','m500p900'};
        
        for nconcat = 1:2
            
            tlist            = list_concat(ntime,:);
            twin             = [0.3 0.3];
            tpad             = 0;
            
            ext_time         = '';
            
            for ntime = 1:length(tlist)
                
                cfg             = [];
                cfg.latency     = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
                poi{ntime}      = ft_selectdata(cfg,data_elan);
                
                if tlist(ntime) < 0
                    ext_time        = [ext_time 'm' num2str(abs(tlist(ntime)-tpad)*1000) 'm' num2str(abs(tlist(ntime)+tpad+twin(ntime))*1000)];
                else
                    ext_time        = [ext_time 'p' num2str(abs(tlist(ntime)-tpad)*1000) 'p' num2str(abs(tlist(ntime)+tpad+twin(ntime))*1000)];
                end
                
                if ntime < length(tlist)
                    ext_time        = [ext_time 'Concat'];
                end
                
            end
            
            data_filter             = ft_appenddata([],poi{:}); clear data_elan ;
            
            taper_type              = 'dpss';
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.output              = 'fourier';
            cfg.keeptrials          = 'yes';
            cfg.taper               = taper_type;
            cfg.foi                 = 13;
            cfg.tapsmofrq           = 3;
            freq                    = ft_freqanalysis(cfg,data_filter); clc ;
            
            ext_freq                = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
            
            cfg                     = [];
            cfg.method              = 'pcc';
            cfg.frequency           = freq.freq; cfg.grid                = pkg.leadfield; cfg.headmodel           = pkg.vol;
            cfg.pcc.lambda          = '5%'; cfg.pcc.keepfilter      = 'yes'; cfg.pcc.projectnoise    = 'yes'; cfg.pcc.fixedori        = 'yes'; cfg.keeptrials          = 'yes';
            source                  = ft_sourceanalysis(cfg, freq);
            com_filter              = source.avg.filter;
            
            FnameFilterOut          = [suj '.' list_cond_main{nelan} '.' ext_freq '.' ext_time '.wConcatPCCommonFilter' '.' taper_type '.' num2str(vox_size) 'cm'];
            fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
            
            clear ext_freq ext_time
            
            for ntime = 1:length(tlist)
                
                cond_ix_sub         = {''};
                cond_ix_cue         = {0:2};
                cond_ix_dis         = {0};
                cond_ix_tar         = {1:4};
                
                for ncue = 1:length(cond_ix_sub)
                    
                    trial_choose    = h_chooseTrial(poi{ntime},cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
                    
                    cfg             = [];
                    cfg.trials      = trial_choose ;
                    data_sub        = ft_selectdata(cfg,poi{ntime});
                    
                    flist           = 13;
                    fpad            = 3;
                    
                    for nfreq = 1:length(flist)
                        
                        new_suj     = ['../data/ageing_pcc_data/' suj '.' cond_ix_sub{ncue} list_cond_main{nelan}];
                        
                        source      = h_pccSeparate(new_suj,data_sub,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                            com_filter,pkg,['wConcat' list_name{nconcat} 'PCCSource.' taper_type '.' num2str(vox_size) 'cm'],'yes',taper_type); % create source
                        
                        clear source new_suj
                        
                    end
                    
                    clear data_sub
                    
                end
            end
        end
    end
end