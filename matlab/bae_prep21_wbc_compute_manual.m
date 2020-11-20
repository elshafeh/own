clear ; clc ; addpath(genpath('../../fieldtrip-20151124/'));

suj_list                                = 16:17; % [1:4 8 :17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    cond_main                           = 'CnD';
    
    fname_in                            = ['../../PAT_MEG21/pat.field/data/' suj '.VolGrid.0.5cm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    for prt = 1:3
        
        fname_in                        = ['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.' cond_main '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        fname_in                        = ['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        name_extra                      = 'Hanning';
        name_in                         = ['/media/hesham.elshafei/PAT_MEG2/prep21_cnd_gamma_conn/' suj '.pt' num2str(prt) '.' cond_main];
        
        [com_filter]                    = h_prep21_common_filter(data_elan,leadfield,vol,name_in,name_extra,10,5); % change me !!
        
        list_ix_cue_side                = {'','N','L','R'};
        list_ix_cue_code                = {0:2,0,1,2};
        list_ix_dis_code                = {0,0,0,0};
        list_ix_tar_code                = {1:4,1:4,1:4,1:4};
        
        list_method                     = {'plv'};
        
        tlist                           = [-0.6 0.6];
        flist                           = [9 13 11];
        twin                            = 0.4;
        tpad                            = 0.025;
        fpad                            = [2 2 4];
        
        load ../data_fieldtrip/index/paper_index_aud_occ_averaged.mat;
        
        ext_index                       = 'paper.data.hanning';
        
        h_prep21_calculate_wbc_manual(flist,tlist,twin,tpad,fpad,data_elan,vol,leadfield,com_filter,prt,list_H,index_H,ext_index ... 
    ,list_ix_cue_side,list_ix_cue_code,list_ix_dis_code,list_ix_tar_code,grid,list_method,suj,cond_main);

    end
end