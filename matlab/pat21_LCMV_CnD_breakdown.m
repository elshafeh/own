clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/CnD.CNV.lcmv.p600p1100.0p05.0p01.0p005.0p0005.mat ;
load ../data/yctot/index/rama_index.mat;

cnd_s = 1;
stat_list  = h_compare_stat_to_index(stat{cnd_s},rama_where,rama_list,0.05);

clearvars -except stat_list ;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    ext_comp    = 'lcmvSource';
    ext_time    = {'m550m50ms','p600p1100ms'};
    lst_cue     = {'VCnD','NCnD'};
    
    for cnd = 1:2
        
        for ntime = 1:2
            
            source_carr{ntime} = [];
            
            for prt = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(prt) '.' lst_cue{cnd} '.' ext_time{ntime} '.' ext_comp '.mat']);
                fname = fname.name;
                fprintf('\nLoading %50s',fname);
                load(['../data/source/' fname]);
                source_carr{ntime} = [source_carr{ntime} source] ; clear source
                
            end
        end
        
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        act                                 = nanmean(source_carr{2},2);
        bsl                                 = nanmean(source_carr{1},2);
        
        source_avg{sb,cnd}.pow            = (act-bsl)./bsl;
        source_avg{sb,cnd}.pos            = source.pos ;
        source_avg{sb,cnd}.dim            = source.dim ;
        
        clear source
        
    end
end

clearvars -except source_avg stat_list

for sb = 1:size(source_avg,1)
    for cnd = 1:size(source_avg,2)
        for roi = 1:size(stat_list,1)
            
            new_source_avg(sb,cnd,roi) = mean(source_avg{sb,cnd}.pow(stat_list{roi,3}));
            
        end
    end
end


clearvars -except source_avg stat_list new_source_avg ; clc ;

load ../data/yctot/rt/rt_cond_classified_iunf.mat

for sb = 1:14
    
    new_rt(sb,1) = median(rt_classified{sb,1})-median(rt_classified{sb,2});
    
end


clearvars -except source_avg stat_list new_source_avg new_rt; clc ;

sig_list = {};
i        = 0;

for roi = 1:size(new_source_avg,3)
    %     p_val(roi) = permutation_test([squeeze(new_source_avg(:,1,roi)) squeeze(new_source_avg(:,2,roi))],10000);
    data1                       = [squeeze(new_source_avg(:,1,roi))-squeeze(new_source_avg(:,2,roi))];
    [val_rho(roi),val_p(roi)]   = corr(data1,new_rt,'type','Pearson');
    
    if val_p(roi) < 0.1
        i = i + 1;
        sig_list{i,1} = stat_list{roi,1};
        sig_list{i,2} = val_rho(roi);
        sig_list{i,3} = val_p(roi);  
        figure;
        scatter(data1,new_rt);
    end
end