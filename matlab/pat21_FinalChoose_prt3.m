clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/NewSourceDpssStat.mat

big_stat = [];

for x = 1:size(stat,1)
    for y = 1:size(stat,2)
        stat{x,y}.mask = stat{x,y}.prob < 0.05;
        tmp            = stat{x,y}.mask .* abs(stat{x,y}.stat);
        big_stat       = [big_stat tmp];
        clear tmp;
        
    end
end

stat                = squeeze(nanmean(big_stat,2)) ;
stat(isnan(stat))   = 0;

clearvars -except stat ;

load ../data/yctot/index/CnD.LitplusAtlas4Gamma.mat ;

reg_list = unique([arsenal_list(:,3)]);

final_list = {};

i = 0 ;

for n = 1:length(reg_list)
    
    flag_where  = find(strcmp([arsenal_list(:,3)],reg_list{n}));
    flag_what   = stat([arsenal_list{flag_where,2}],:);
    
    for ntrl = 1:2
        
        ix = find(flag_what == max(flag_what));
        
        if flag_what(ix) ~= 0
            
            i = i + 1;
            
            final_list{i,1} = arsenal_list{flag_where(ix),1};
            final_list{i,2} = arsenal_list{flag_where(ix),2};
            final_list{i,3} = arsenal_list{flag_where(ix),3};
            
            flag_what(ix) = 0;
            
        end
    end
    
end

arsenal_list = final_list ;

clearvars -except arsenal_list ;

save ../data/yctot/index/CnD.SomaGamma.mat;