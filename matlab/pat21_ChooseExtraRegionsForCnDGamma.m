clear ; clc ; dleiftrip_addpath ;

extra_table = readtable('../xls/FrontalCoordinates.csv');
indx_tot    = h_createIndexfieldtrip;

load ../data/template/source_struct_template_MNIpos.mat

load ../data/yctot/stat/NewSourceDpssStat.mat

for nfreq = 1:size(stat,1)
    for ntime = 1:size(stat,2)
        stat{nfreq,ntime}.mask = stat{nfreq,ntime}.prob < 0.05 ;
    end
end


big_list        = {};
big_where       = [];

for nextra = 1:height(extra_table)
    
    vox_x  = str2double(cell2num(extra_table.X(nextra)));
    vox_y  = str2double(cell2num(extra_table.Y(nextra)));
    vox_z  = str2double(cell2num(extra_table.Z(nextra)));
    
    maxPos = round([vox_x vox_y vox_z]/10); clear vox_* ;
    whereb = [];
    
    m1  = maxPos ; m1(1,1) = m1(1,1) + 0.5 ;    m2 = maxPos ; m2(1,1) = m2(1,1) - 0.5 ;
    m3  = maxPos ; m3(1,2) = m3(1,2) + 0.5 ;m4 = maxPos ; m4(1,2) = m4(1,2) - 0.5 ;
    m5  = m1 ; m5(1,3) = m5(1,3) + 0.5 ;m6 = m1 ; m6(1,3) = m6(1,3) - 0.5 ;
    m7  = m2 ; m7(1,3) = m7(1,3) + 0.5 ;m8 = m2 ; m8(1,3) = m8(1,3) - 0.5 ;
    m9  = m3 ; m9(1,3)  = m9(1,3) + 0.5 ;m10 = m3 ; m10(1,3) = m10(1,3) - 0.5 ;
    m11 = m4 ; m11(1,3)  = m11(1,3) + 0.5 ;m12  = m4 ; m12(1,3)  = m12(1,3) - 0.5 ;
    m13 = maxPos ; m13(1,3)  = m13(1,3) + 0.5 ;m14  = maxPos ; m14(1,3)  = m14(1,3) - 0.5 ;
    
    postot = [maxPos; m1;m2;m3;m4;m5;m6;m7;m8;m9;m10;m11;m12;m13;m14];
    
    clear maxPos m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
    
    bigb    = source.pos;
    
    for n = 1:size(postot,1)
        x = postot(n,1) ; y = postot(n,2) ; z = postot(n,3) ;
        if isnumeric(x) && isnumeric(y) && isnumeric(z)
            whereb = [whereb;find(bigb(:,1) == x & bigb(:,2) == y & bigb(:,3) == z)];
        end
    end
    
    whereb      = sort(whereb);
    
    for n = 1:length(whereb)
        ix = find(indx_tot(:,1) == whereb(n));
        
        if isempty(ix)
            whereb(n) = 0;
        end
    end
    
    whereb = whereb(whereb~=0);
    
    clearvars -except whereb nextra extra_table indx_tot source stat big_where big_list
    
    if ~isempty(whereb)
        
        list_time       = {'1','2','3'};
        list_freq       = {'lo','hi'};
        
        for nfreq = 1:size(stat,1)
            for ntime = 1:size(stat,2)
                
                tmp_list        = {};
                
                for nvox = 1:length(whereb)
                    
                    ix = stat{nfreq,ntime}.stat(whereb(nvox));
                    
                    findmax(nvox,1) = ix;
                    new_label       = [extra_table.Shortcut{nextra} '_' list_time{ntime} list_freq{nfreq} '_' num2str(nvox)];
                    tmp_list{end+1} = {new_label};
                    
                end
                
                findmax             = abs(findmax);
                first_bo            = find(findmax == max(findmax));
                
                if isempty(find(big_where == whereb(first_bo)))
                    big_list{end+1}     = tmp_list{first_bo};
                    big_where           = [big_where;whereb(first_bo)];
                end
                
                findmax(first_bo)   = 0;
                
                secnd_bo            = find(findmax == max(findmax));
                
                if isempty(find(big_where == whereb(secnd_bo)))
                    big_list{end+1,1}   = tmp_list{secnd_bo};
                    big_where           = [big_where;whereb(secnd_bo)];
                end
                
            end
        end
        
        clearvars -except big_where big_list whereb nextra extra_table indx_tot source stat tmp_list
        
    end
end

clearvars -except big_where big_list ;

save('../data/yctot/index/CnD.ExtraRois.4Gamma.mat','big_where','big_list');