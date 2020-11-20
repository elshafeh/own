clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/template/template_grid_0.5cm.mat

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list        = suj_group{ngroup};
    ext_comp        ='dpssFixedCommonDicSourceMinEvoked0.5cm.mat'; % 
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        list_cond_main          = {''};
        list_time               = {'p100p300'};
        list_freq               = {'60t100Hz'};
        
        
        for ncue = 1:length(list_cond_main)
            for ntime = 1:length(list_time)
                for nfreq = 1:length(list_freq)
                    
                    dir_data                = '../data/all_dis_data/';
                    fname                   = [dir_data suj '.fDIS'  list_cond_main{ncue} '.' list_freq{nfreq} '.' list_time{ntime} '.' ext_comp];
                    
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source              = source; clear source
                    
                    fname                   = [dir_data suj '.DIS'   list_cond_main{ncue} '.' list_freq{nfreq} '.' list_time{ntime}    '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source              = source; clear source ;
                    
                    pow                     = act_source-bsl_source ; % act_source; % (act_source-bsl_source)./bsl_source; %
                    pow(isnan(pow))         = 0;
                    
                    allsuj_avg{ngroup}{sb,ncue,ntime,nfreq}.pow                 = pow;
                    allsuj_avg{ngroup}{sb,ncue,ntime,nfreq}.pos                 = template_grid.pos ;
                    allsuj_avg{ngroup}{sb,ncue,ntime,nfreq}.dim                 = template_grid.dim ;
                    allsuj_avg{ngroup}{sb,ncue,ntime,nfreq}.inside              = template_grid.inside;
                    
                    clear pow act_source bsl_source
                    
                end
            end
        end
        
        list_ix_cue                 = 0:2;
        list_ix_tar                 = 1:4;
        list_ix_dis                 = 1:2;
        
        [~,~,~,~,~,~,~,per_incorr]  = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        allsuj_behav{ngroup}{sb,1}  = per_incorr;
        
    end
end

clearvars -except allsuj_*