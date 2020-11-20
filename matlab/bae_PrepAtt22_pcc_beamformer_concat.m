clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
%
% % [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% % suj_group{3}        = suj_group{3}(2:22);
%
% suj_list = [];
%
% for n = 1:length(suj_group)
%     suj_list            = [suj_list;suj_group{n}];
% end
%
% suj_list            = unique(suj_list);

suj_list = {'yc2','yc3','yc6','yc8','yc9','yc17','yc20'};

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    list_cond_main  = {'CnD'};
    vox_size        = 0.5;
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    pkg.leadfield   = leadfield;
    pkg.vol         = vol;
    
    clear vol leadfield
    
    for nelan = 1:length(list_cond_main)
        
        fname_in         = ['../data/' suj '/field/' suj '.' list_cond_main{nelan} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        tlist           = [-0.6 0.6];
        twin            = [0.4 0.4];
        tpad            = 0;
        
        for ntime = 1:length(tlist)
            
            cfg             = [];
            cfg.latency     = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
            poi{ntime}      = ft_selectdata(cfg,data_elan);
            
        end
        
        data_filter             = ft_appenddata([],poi{:}); clear data_elan ;
        
        cfg                     = [];
        cfg.method              = 'mtmfft'; cfg.output              = 'fourier';
        cfg.keeptrials          = 'yes';
        cfg.foi                 = 10;
        cfg.tapsmofrq           = 5;
        freq                    = ft_freqanalysis(cfg,data_filter); clc ;
        
        cfg                     = [];
        cfg.method              = 'pcc';
        cfg.frequency           = freq.freq; cfg.grid                = pkg.leadfield; cfg.headmodel           = pkg.vol;
        cfg.pcc.lambda          = '5%'; cfg.pcc.keepfilter      = 'yes'; cfg.pcc.projectnoise    = 'yes'; cfg.pcc.fixedori        = 'yes'; cfg.keeptrials          = 'yes';
        source                  = ft_sourceanalysis(cfg, freq);
        com_filter              = source.avg.filter;
        
        ext_time                = 'm600p600Concat';
        ext_freq                = '5t15Hz';
        
        FnameFilterOut = [suj '.' list_cond_main{:} '.' ext_freq '.' ext_time '.wConcatPCCommonFilter' num2str(vox_size) 'cm'];
        
        %         load(['../data/' suj '/field/' FnameFilterOut '.mat']);
        
        fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
        save(['../data/' suj '/field/' FnameFilterOut '.mat'],'com_filter','-v7.3');
        
        for ntime = 1:length(tlist)
            
            cond_ix_sub             = {''};
            cond_ix_cue             = {0:2};
            cond_ix_dis             = {0};
            cond_ix_tar             = {1:4};
            
            for icond = 1:length(cond_ix_sub)
                
                trial_choose    = h_chooseTrial(poi{ntime},cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
                
                cfg             = [];
                cfg.trials      = trial_choose ;
                data_sub        = ft_selectdata(cfg,poi{ntime});
                
                flist           = [9 13 11];
                fpad            = [2 2 4];
                
                for nfreq = 1:length(flist)
                    
                    source  = h_pccSeparate(suj,data_sub,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                        com_filter,pkg,[cond_ix_sub{icond} list_cond_main{nelan}],['wConcatPCCSource' num2str(vox_size) 'cm'],'yes'); % create source
                    
                    clear source
                    
                end
                
                clear data_sub
                
            end
        end
    end
end