clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% 
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);

[~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{3}(2:22);

% suj_list            = [suj_group{1};suj_group{2};suj_group{3}];
% suj_list            = unique(suj_list); clearvars -except suj_list ;

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                         = suj_list{sb};
    
    list_cond_main              = {'DIS'};
    vox_size                    = 0.5;
    
    dir_data                    = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    
    fname_in                    = [dir_data suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat'];
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    fname_in                    = [dir_data suj '.VolGrid.' num2str(vox_size) 'cm.mat'];
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    for nelan = 1:length(list_cond_main)
        
        fname_in                = [dir_data suj '.' list_cond_main{nelan} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.latency             = [-2 2];
        data_elan               = ft_selectdata(cfg,data_elan);
        
        pkg.leadfield           = leadfield;
        pkg.vol                 = vol;
        
        clear vol leadfield
        
        taper_type              = 'dpss';
        
        com_filter              = h_pccComonFilter(suj,data_elan,pkg,[-0.2 0.4],80,30,[list_cond_main{:}],['wPCCommon' taper_type 'Filter' num2str(vox_size) 'cm'],taper_type);
                
        cond_ix_sub             = {''};
        cond_ix_cue             = {0:2};
        cond_ix_dis             = {1:2};
        cond_ix_tar             = {1:4};
        
        for icond = 1:length(cond_ix_sub)
            
            trial_choose    = h_chooseTrial(data_elan,cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
            
            cfg             = [];
            cfg.trials      = trial_choose ;
            data_sub        = ft_selectdata(cfg,data_elan);
            
            data_sub        = h_removeEvoked(data_sub);
            
            tlist           = 0.1;
            twin            = 0.2;
            tpad            = 0;
            
            flist           = 80;
            fpad            = 20;
            
            for ntime = 1:length(tlist)
                for nfreq = 1:length(flist)
                    
                    new_suj     = ['../data/dis_pcc_data/' suj '.' cond_ix_sub{icond} list_cond_main{nelan}];
                    
                    source      = h_pccSeparate(new_suj,data_sub,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                        com_filter,pkg,['wPCCMinEvoked' taper_type 'Source' num2str(vox_size) 'cm'],'no',taper_type); % create source
                    
                    
                    clear source
                    
                end
            end
            
            clear data_elan
            
        end
        
        clear data_big
        
    end
end