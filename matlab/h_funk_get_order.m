function dis_match = h_funk_get_order(behav_table)

dis_in_ds                           = [];

for nb = 1:10
    indx                            = find([behav_table.nbloc] == nb);
    indx                            = behav_table.DIS(indx);
    indx(indx > 0)                  = 1;
    dis_in_ds                       = [dis_in_ds; repmat(nb,length(indx),1) indx];
end

dis_in_log                          = [];

for nb = 1:10
    
    tmp                             = readtable(['~/Dropbox/project_me/doc/pat/Prog/Disc_Fix_' num2str(nb) '.txt'],'TreatAsEmpty','};');
    tmp                             = tmp(1:end-1,:).Var8;
    
    indx                            = ones(length(tmp),1);
    indx(find(strcmp(tmp,'nul')))   = 0;
    
    dis_in_log                      = [dis_in_log; repmat(nb,length(indx),1) indx];
    
end

keep dis_*

dis_match                           = nan(8,2);

for nx = 1:10
    
    dis_match(nx,1)                 = nx;
    
    for ny = 1:10
        
        mtrx_x                      = dis_in_ds(dis_in_ds(:,1) == nx,2);
        
        if ~isempty(mtrx_x)
            
            mtrx_x                      = mtrx_x(1:20);
            
            mtrx_y                      = dis_in_log(dis_in_log(:,1) == ny,2);
            mtrx_y                      = mtrx_y(1:20);
            
            flg                         = length(unique(mtrx_x - mtrx_y));
            
            if flg == 1
                dis_match(nx,2)         = ny;
            end
        end
        
    end
end