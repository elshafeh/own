% loads all tfrs and plots them
clear;

% adding Fieldtrip path
fieldtrip_path                                  = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

sj_list                                         = {'sub004'};
md_list                                         = {'vis'};
list_condition                                  = {'correct','incorrect'}; % {'correct','incorrect'};

for nsuj = 1:length(sj_list)
    for nmod = 1:length(md_list)
        for nlist = 1:length(list_condition)
            
            dir_data                                    = ['../data/' sj_list{nsuj} '/tf/'];
            file_ext                                    = [sj_list{nsuj} '_mtmconvolPOW_m3000p3000ms50Step_2t40Hz1Step_' list_condition{nlist} '_' md_list{nmod}];
            fname                                       = [dir_data file_ext '.mat'];
            
            fprintf('Loading %s\n',fname);
            load(fname);
            
            allFreq{nsuj,nmod,nlist}                    = freq; clear freq;
            
        end
    end
end

figure;
ii                                                  = 0;

for nsuj = 1:length(sj_list)
    
    time_win                                        = 0.2;
    list_time                                       = -0.6:time_win:0.2;
    
    for nlist = 1:length(list_condition)
        for ntime = 1:length(list_time)
            
            ii                                      = ii +1;
            nplt_x                                  = 2;
            nplt_y                                  = length(list_time);
            
            subplot(nplt_x,nplt_y,ii)
            
            cfg                                     = [];
            cfg.layout                              = 'CTF275_helmet.mat';
            cfg.ylim                                = [7 14];
            cfg.marker                              = 'off';
            cfg.comment                             = 'no';
            
            cfg.baseline                            = [-1.2 0.8];
            cfg.baselinetype                        = 'relchange';
            cfg.zlim                                = [-0.15 0.15];
            
            cfg.colorbar                            = 'no';
            
            cfg.xlim                                = [list_time(ntime) list_time(ntime)+time_win];
            ft_topoplotTFR(cfg, allFreq{nsuj,1,nlist});
            
            title([sj_list{nsuj} ' ' list_condition{nlist} ' ' num2str(list_time(ntime))]);
            
        end
        
    end
end