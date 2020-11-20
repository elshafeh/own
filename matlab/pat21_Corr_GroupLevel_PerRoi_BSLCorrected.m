% source correlation group level 

clear ; clc ;

suj_list = [1:4 8:17];

cnd_time = {{'.m600m200','.p200p600'},{'.m600m200','.p600p1000'}};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_freq = {'8t10','12t14'} ;
    
    for cf = 1:length(cnd_freq)
        for ct = 2
            for cp = 1:3
                for ix = 1:2
                    
                    fname = dir(['../data/' suj '/source/*pt' num2str(cp) '*CnD.all.mtmfft*' cnd_freq{cf} '*' cnd_time{ct}{ix} '*bsl.5mm.source*']);
                    fname = fname.name;
                    fprintf('Loading %50s\n',fname);
                    load(['../data/' suj '/source/' fname]);
                    
                    if isstruct(source);
                        source = source.avg.pow;
                    end
                    
                    src_carr{ix} = source ; clear source ;
                    
                end
                
                tmp{cp} = (src_carr{2} - src_carr{1}) ./ src_carr{1};
                
                clear src_carr
                
            end
            
            source_avg{sb,cf,ct} = mean([tmp{1} tmp{2} tmp{3}],2);
            
        end
        
    end
    
end

clearvars -except source_avg ;
load ../data/yctot/rt_CnD_adapt.mat ;
load ../data/yctot/ArsenalIndex.mat ; 

for cf = 1:2
    for ct = 2
        roi_l = unique(indx_tot(:,2));
        
        for n = 1:length(roi_l)
            
            for sb = 1:14
                ix = indx_tot(indx_tot(:,2) == roi_l(n),1);
                nw_suj{sb,n,cf,ct} = nanmean(source_avg{sb,cf,ct}(ix,:));
            end
            
            X = [nw_suj{:,n,cf,ct}];
            Y = cellfun(@median,rt_all);
            [rho_val(n,cf,ct),p_val(n,cf,ct)] = corr(X',Y', 'type', 'Spearman');
            clear X Y
        end
        
    end
end