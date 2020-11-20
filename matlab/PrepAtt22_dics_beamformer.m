clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
% suj_list_old        = [suj_group{1};suj_group{2}]; clear allsuj suj_group;
% suj_list            = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};
% patient_list;
% suj_list            = [fp_list_meg cn_list_meg];

[~,suj_list,~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                    = suj_list(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                         = suj_list{sb};
    
    dir_data                    = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    
    load([dir_data suj '.VolGrid.0.5cm.mat']);
    load([dir_data suj '.adjusted.leadfield.0.5cm.mat']);
    
    pkg.vol                     = vol;
    
    list_cond_main              = {'DIS','fDIS'};
    vox_size                    = 0.5;
    
    for nelan = 1:length(list_cond_main)
        
        fname_in                = [dir_data suj '.' list_cond_main{nelan} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.latency             = [-2 2];
        data_elan               = ft_selectdata(cfg,data_elan);
        
        data_conc{nelan}        = data_elan ; clear data_elan avg;
        
    end
    
    pkg.leadfield               = leadfield;
    
    clear vol leadfield
    
    if length(data_conc) > 1
        data_all = ft_appenddata([],data_conc{:});
    else
        data_all = data_conc{1};
    end
    
    for taper_type                  = {'dpss'};
        
        com_filter{1}               = h_dicsCommonFilter(suj,data_all,pkg,[-0.2 0.4],80,30, ...
            [list_cond_main{:}],[taper_type{:} 'FixedCommonDicFilter' num2str(vox_size) 'cm'],'5%',taper_type{:}); % create common filter
        
        
        for nelan = 1:length(list_cond_main)
            
            data_big                = data_conc{nelan};
            
            cond_ix_sub             = {'','V','N'};
            cond_ix_cue             = {0:2,[1 2],0};
            cond_ix_dis             = {1:2,1:2,1:2};
            cond_ix_tar             = {1:4,1:4,1:4};
            
            for icond = 1:length(cond_ix_sub)
                
                trial_choose        = h_chooseTrial(data_big,cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
                
                cfg                 = [];
                cfg.trials          = trial_choose ;
                data_elan           = ft_selectdata(cfg,data_big);
                
                data_elan           = h_removeEvoked(data_elan); % !!
                
                tlist{1}            = -0.3;
                twin{1}             = 0.2;
                flist{1}            = 80;
                fpad{1}             = 20;
                tpad{1}             = 0;
                
                for nfilter = 1:length(com_filter)
                    for ntime = 1:length(tlist{nfilter})
                        for nfreq = 1:length(flist{nfilter})
                            
                            new_suj     = ['../data/all_dis_data/' suj '.' list_cond_main{nelan} cond_ix_sub{icond}];
                            
                            source      = h_dicsSeparate(new_suj,data_elan,tlist{nfilter}(ntime),twin{nfilter}(ntime),tpad{nfilter},flist{nfilter}(nfreq),fpad{nfilter}(nfreq), ...
                                com_filter{nfilter},pkg,[taper_type{:} 'FixedCommonDicSourceMinEvoked' num2str(vox_size) 'cm'],'5%',taper_type{:}); % create source
                            
                            clear source
                            
                        end
                    end
                end
            end
        end
        
    end
    
    clearvars -except suj_list sb
    
end