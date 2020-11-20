clear ; clc ;

suj_list                            = {
    'yc1','yc10','yc11','yc4','yc18','yc21','yc7','yc19','yc15','yc14','yc5','yc13','yc16','yc12',...
    'oc1','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9','oc10','oc11','oc12','oc13','oc14'};

for sb = 1:length(suj_list)
    
    suj                             = suj_list{sb};
    behav_table                     = h_behavdis_eval(suj);
    dis_match                       = h_funk_get_order(behav_table);
    
    bloc_limits                     = h_funk_get_bloc(behav_table);
    
    [nmbr,txt]                      = xlsread('~/Dropbox/project_me/doc/pat/PrepAtt22_bloc_order.xlsx');
    
    list_code                       = txt(2:end,2);
    ix                              = find(strcmp(list_code,suj));
    
    bloc_order                      = dis_match(:,2)';
    bloc_order                      = bloc_order(bloc_order ~= 0);
    
    dis_list                        = [];
    
    for nb = 1:length(bloc_order)
        
        tmp                         = readtable(['~/Dropbox/project_me/doc/pat/Prog/Disc_Fix_' num2str(bloc_order(nb)) '.txt'],'TreatAsEmpty','};');
        tmp                         = tmp(1:end-1,:);
        
        if strcmp(suj,'oc14') && nb == 9
            tmp                     = tmp([1:42 44:end],:);
        else
            tmp                     = tmp(1:bloc_limits(nb),:);
        end
        
        dis_list                  	= [dis_list;tmp.Var8];
        
    end
    
    load ../data/stock/final_dis_frequency_list.mat;
    
    for nt = 1:length(dis_list)
        if strcmp(dis_list{nt},'nul')
            dis_list{nt,2}          = 'none';
        else
            ix                      = find(strcmp(dis_list{nt},final_list(:,1)));
            dis_list{nt,2}          = final_list{ix,2};
        end
        
        if strcmp(suj(1:2),'yc')
            dis_list{nt,3}          = 'young';
        else
            dis_list{nt,3}          = 'elderly';
        end
        
        dis_list{nt,4}              = suj;
        
        list_cue                    = {'unf','inf','inf'};
        dis_list{nt,5}              = list_cue{behav_table.CUE(nt)+1};
        dis_list{nt,6}              = ['DIS' num2str(behav_table.DIS(nt))];
        
        dis_list{nt,7}              = [dis_list{nt,6} '-' final_list{ix,2}];
        
    end
    
    dis_list                        = array2table(dis_list,'VariableNames',{'dis_name','dis_pitch','group','suj', ...
        'cue_type','dis_delay','dis_concat'});
    
    behav_table                     = [behav_table dis_list];
    
    for nt = 1:height(behav_table)
        if (behav_table.DIS(nt) == 0)
            if(strcmp(behav_table.dis_name{nt},'nul'))
                x                   = 0;
            else
                error('trial mismatch');
            end
        end
    end
    
    keep suj suj_list big_table sb behav_table
    
    pos_fin                         = load(['~/GoogleDrive/training/log_files/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
    
    find_dis_in_pos              	= pos_fin(find(floor(pos_fin(:,2)/1000) == 2),2) - 2000;
    
    find_dis_in_pos(:,2)            = floor(find_dis_in_pos(:,1) / 100);
    find_dis_in_pos(:,3)            = floor((find_dis_in_pos(:,1) - find_dis_in_pos(:,2)*100) / 10);
    find_dis_in_pos(:,4)            = pos_fin(find(floor(pos_fin(:,2)/1000) == 2),3);
    
    find_dis_in_log              	= behav_table.DIS(find(~strcmp(behav_table.dis_delay,"DIS0")));
    
    vct                             = [];
    
    lok_mtrx                        = 1:length(find_dis_in_log);
    
    for n = 1:length(find_dis_in_pos)
        
        for m = 1:length(lok_mtrx)
            if find_dis_in_pos(n,3) == find_dis_in_log(lok_mtrx(m))
                vct             = [vct; lok_mtrx(m)];
                lok_mtrx(m)     = [];
                break;
            end
        end
    end
    
    keep suj suj_list big_table sb behav_table find_dis_* vct
    
    tmp                         = behav_table.dis_pitch(find(~strcmp(behav_table.dis_delay,"DIS0")));
    tmp                         = tmp(vct);
    
    pitch_mtrx                  = zeros(length(tmp),1);
    
    pitch_mtrx(find(strcmp(tmp,'low'))) = 10;
    pitch_mtrx(find(strcmp(tmp,'mid'))) = 20;
    pitch_mtrx(find(strcmp(tmp,'high'))) = 30;
    
    final_index                 = pitch_mtrx(find(find_dis_in_pos(:,4) == 0));
    
    keep suj suj_list final_index
    
end