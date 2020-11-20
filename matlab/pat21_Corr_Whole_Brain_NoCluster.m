clear;clc;dleiftrip_addpath;

load ../data/yctot/rt/rt_CnD_adapt.mat ;
load ../data/yctot/elements4alpha2gamma.correlation.mat ;

for sb = 1:14
    
    allsuj_behav{sb,5} = mean(rt_all{sb});
    allsuj_behav{sb,6} = median(rt_all{sb});
end

clearvars -except source_avg allsuj_behav

for sb = 1:14
    source_compact(sb,:,:,:) = source_avg{sb}.pow;
end

i = 0 ;

corr_list               = {'Spearman','Pearson'};

for a = 1:size(allsuj_behav,2)
    for b = 1:size(allsuj_behav,2)
        for y = 1:size(source_avg{1}.pow,2)
            for z = 1:size(source_avg{1}.pow,3)
                
                stat_source{a,b}                = [];
                stat_source{a,b}.pos            = source_avg{1}.pos;
                stat_source{a,b}.time           = source_avg{1}.time;
                stat_source{a,b}.freq           = source_avg{1}.freq;
                data                            = source_compact(:,:,y,z);
                [rho,p]                         = corr(data,[allsuj_behav{:,b}]' , 'type', corr_list{a});
                stat_source{a,b}.corr(:,y,z)    = rho;
                stat_source{a,b}.pval(:,y,z)    = p;
                
                i = i + 1;
                
                ntot = 2*size(allsuj_behav,2)*size(source_avg{1}.pow,3)*size(source_avg{1}.pow,2);
                fprintf('Calculating %2d out of %2d\n',i,ntot);
                
            end
        end
    end
end

clearvars -except stat_source ;