clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/NewSourceDpssStat.mat

big_stat = [];

for x = 1:size(stat,1) % freq
    for y = 1:size(stat,2) % time
        stat{x,y}.mask = stat{x,y}.prob < 0.05;
        tmp            = stat{x,y}.mask .* abs(stat{x,y}.stat);
        big_stat       = [big_stat tmp];
        clear tmp;
        
    end
end

stat                   = squeeze(nanmean(big_stat,2)) ;
stat(isnan(stat))      = 0;

clearvars -except stat ;

load ../data/yctot/index/rama_index.mat;

final_rama_list = {};
i               = 0;
j               = 0;
excluded        = {};

for n = 1:132
    flag_where  = rama_where(rama_where(:,2)==n,1);
    flag_what   = stat(flag_where,:);
    
    tmp{1} = [];
    tmp{2} = rama_list{n};
    
    for ntrl = 1:5    
        ix = find(flag_what == max(flag_what));
        
        if ~isempty(ix)>0 && length(ix)<2
            if flag_what(ix) ~= 0
                tmp{1} = [tmp{1};flag_where(ix)];
                flag_what(ix)        = 0;
            end
        end
    end
    
    if length(tmp{2})>4 && strcmp(tmp{2}(1:5),'ParaH')
        
        j = j +1;
        excluded{j,1} = tmp{1};
        excluded{j,2} = tmp{2};
        
    else
        
        if length(tmp{1})>3
            if ~strcmp(tmp{2}(1:4),'Angu') && ~strcmp(tmp{2}(1:4),'Caud') && ~strcmp(tmp{2}(1:4),'Olfa') && ~strcmp(tmp{2}(1:4),'Rect') &&  ~strcmp(tmp{2}(1:4),'Amyg') && ~strcmp(tmp{2}(1:4),'Hipp')  && ~strcmp(tmp{2}(1:4),'Insu')
                i = i+ 1;
                final_rama_list{i,1} = tmp{1};
                final_rama_list{i,2} = tmp{2};
            else
                j = j +1;
                excluded{j,1} = tmp{1};
                excluded{j,2} = tmp{2};
            end
        else
            j = j +1;
            excluded{j,1} = tmp{1};
            excluded{j,2} = tmp{2};
        end
    end
    
    clear tmp
    
end

clearvars -except final_rama_list excluded;

save('../data/yctot/index/RamaAlphaFusion.mat','final_rama_list');