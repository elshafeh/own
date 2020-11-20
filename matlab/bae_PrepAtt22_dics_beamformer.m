clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
% suj_list            = [suj_group{1};suj_group{2}];
% suj_list            = unique(suj_list);

[~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{3}(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    list_cond_main  = {'DIS','fDIS'};
    vox_size        = 0.5;
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    for nelan = 1:length(list_cond_main)
        
        fname_in         = ['../data/' suj '/field/' suj '.' list_cond_main{nelan} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg         = [];
        cfg.latency = [-2 2];
        data_elan   = ft_selectdata(cfg,data_elan);
        
        %         load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        %         cfg                 = [];
        %         cfg.latency         = [-3 3];
        %         cfg.trials          = [trial_array{:}];
        %         data_elan           = ft_selectdata(cfg,data_elan);
        
        data_conc{nelan}    = data_elan ; clear data_elan avg;
        
    end
    
    pkg.leadfield   = leadfield;
    pkg.vol         = vol;
    
    clear vol leadfield
    
    if length(data_conc) > 1
        data_elan = ft_appenddata([],data_conc{:});
    else
        data_elan = data_conc{1};
    end
    
    data_elan       = h_removeEvoked(data_elan);
    com_filter      = h_dicsCommonFilter(suj,data_elan,pkg,[-0.2 0.7],10,4,[list_cond_main{:}],['dpssFixedCommonDicFilterMinEvoked' num2str(vox_size) 'cm']); % create common filter
        
    %     load(['../data/' suj '/field/' suj '.CnD.5t15Hz.m800p2000.dpssFixedCommonDicFilter.mat']);
    
    clear data_elan
    
    for nelan = 1:length(list_cond_main)
        
        data_big        = data_conc{nelan};
        
        cond_ix_sub     = {'','N','L','R'};
        cond_ix_cue     = {0:2.0,1,2};
        cond_ix_dis     = {0,0,0,0};
        cond_ix_tar     = {1:4,1:4,1:4,1:4};
        
        for icond = 1:length(cond_ix_sub)
            
            cfg             = [];
            cfg.trials      = h_chooseTrial(data_big,cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
            data_elan       = ft_selectdata(cfg,data_big);
            
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %
            data_elan       = h_removeEvoked(data_elan); % !!!!!!!!! % 
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %
            
            tlist           = [-0.4 -0.2 0 0.2 0.4 0.6 0.8 1];
            twin            = [0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2];
            
            flist           = [12 80];
            
            fpad            = [04 20];
            
            tpad            = 0.025;
            
            for ntime = 1:length(tlist)
                for nfreq = 1:length(flist)
                    
                    ext_name    = 'MinEvoked';
                    
                    source      = h_dicsSeparate(suj,data_elan,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                        com_filter,pkg,[list_cond_main{nelan} cond_ix_sub{icond}],['dpssFixedCommonDicSource' ext_name num2str(vox_size) 'cm'] ); % create source
                    
                    clear source
                    
                end
            end
            
            clear data_elan
            
        end
        
        clear data_big
        
    end
    
    clear pkg com_filter suj data_big
    
end