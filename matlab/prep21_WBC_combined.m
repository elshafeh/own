clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list                                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    cond_main                           = 'CnD';
    dir_data                            = '/Volumes/PAT_MEG2/Fieldtripping/data/';
    
    fname_in                            = [dir_data '/headfield/' suj '.VolGrid.5mm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    for prt = 1:3
        
        fname_in                        = [dir_data '/all_data/' suj '.pt' num2str(prt) '.' cond_main '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        fname_in                        = [dir_data '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        for taper_type  = {'hanning','dpss'}
            
            name_extra                      = taper_type{:};
            
            name_in                         = ['../data/paper_data/' suj '.pt' num2str(prt) '.' cond_main];
            [com_filter]                    = h_prep21_common_filter(data_elan,leadfield,vol,name_in,name_extra,taper_type{:},10,5,[-0.8 2]);
            
            list_ix_cue_side                = {'','V','N'};
            list_ix_cue_code                = {0:2,[1 2],0};
            list_ix_dis_code                = {0,0,0};
            list_ix_tar_code                = {1:4,1:4,1:4};
            
            list_method                     = {'plv'};
            
            tlist                           = [-0.6 0.6];
            flist                           = [9 13 11];
            fpad                            = [2 2 4];
            twin                            = 0.4;
            tpad                            = 0.025;
            
            load ../data/index/paper_index_aud_occ_averaged.mat;
            
            ext_index                       = ['paper.data.' taper_type{:} '.ZBefore'];
            list_H                          = {'occ_LR'};
            index_H                         = index_H(index_H(:,2) < 3,:);
            index_H(:,2)                    = 1;
            
            h_prep21_calculate_wbc(flist,tlist,twin,tpad,fpad,data_elan,vol,leadfield,com_filter,prt,list_H,index_H,ext_index ...
                ,list_ix_cue_side,list_ix_cue_code,list_ix_dis_code,list_ix_tar_code,grid,list_method,suj,cond_main,taper_type{:});
            
        end
    end
end