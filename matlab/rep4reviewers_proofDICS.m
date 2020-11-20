clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                    = suj_list(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                         = suj_list{sb};
    
    dir_data                    = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    
    load([dir_data suj '.VolGrid.0.5cm.mat']);
    load([dir_data suj '.adjusted.leadfield.0.5cm.mat']);
    
    pkg.vol                     = vol;
    
    list_cond_main              = {'CnD'};
    vox_size                    = 0.5;
    
    for nelan = 1:length(list_cond_main)
        
        fname_in                = [dir_data suj '.' list_cond_main{nelan} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
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
        
        com_filter{1}               = h_dicsCommonFilter(suj,data_all,pkg,[-0.6 1.8],80,20, ...
            [list_cond_main{:}],[taper_type{:} 'FixedCommonDicFilter' num2str(vox_size) 'cm'],'5%',taper_type{:}); % create common filter
        
        
        for nelan = 1:length(list_cond_main)
            
            data_big                = data_conc{nelan};
            
            cond_ix_sub             = {'','L','R'};
            cond_ix_cue             = {0:2,0:2,0:2};
            cond_ix_dis             = {0,0,0};
            cond_ix_tar             = {1:4,[1 3],[2 4]};
            
            for icond = 1:length(cond_ix_sub)
                
                trial_choose        = h_chooseTrial(data_big,cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
                
                cfg                 = [];
                cfg.trials          = trial_choose ;
                data_elan           = ft_selectdata(cfg,data_big);
                
                data_elan           = h_removeEvoked(data_elan); % !!
                
                tlist{1}            = [-0.4 0.1 1.25 1.3];
                twin{1}             = [0.2 0.2 0.2 0.2];
                flist{1}            = [80 80 80];
                fpad{1}             = [20 20 20];
                tpad{1}             = 0;
                
                for nfilter = 1:length(com_filter)
                    for ntime = 1:length(tlist{nfilter})
                        for nfreq = 1:length(flist{nfilter})
                            
                            new_suj     = ['../data/dis_rep4rev/' suj '.' list_cond_main{nelan} cond_ix_sub{icond}];
                            
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