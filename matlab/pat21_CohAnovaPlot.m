clear ; clc ; close all ; 

load ../data/yctot/stat/cohAnovastat.mat
% load ../data/yctot/stat/cohAnovaPerCondFisher.mat

meas_list = {'plv'};
time_list = {'early','late'};
chan_list = tres{1,1}.label ;
freq_list = round(tres{1,1}.freq);

ix_s = 0 ;

for ix_coh =  1
    
    for ix_t = 1:2
        
        for frq = 1:3
            for chan1 = 1:length(tres{1,1,1}.label)
                for chan2 = 1:length(tres{1,1}.label)
                    
                    nana = find(strcmp(chan_list{chan1}(1),'r'));
                    nina = find(strcmp(chan_list{chan2}(1),'r'));
                    
                    ka = length(nana)+length(nina);
                    
                    if ka == 1
                        
                        p         = tres{ix_coh,ix_t}.plvspctrm(chan1,chan2,frq);
                        
                        if p < 0.07 && p > 0
                            
                            ix_s = ix_s + 1;
                            
                            Summary(ix_s).measure   = meas_list{ix_coh};
                            Summary(ix_s).freq      = freq_list(frq);
                            Summary(ix_s).time      = time_list(ix_t);
                            Summary(ix_s).chan1     = chan_list{chan1};
                            Summary(ix_s).chan2     = chan_list{chan2};
                            Summary(ix_s).p         = p ;
                            
                        end
                        
                    end
                end
            end
        end
    end
end

clearvars -except tres coh_measures Summary

time_list = {'early','late'};
freq_list  = round(coh_measures{1,1,1,1}.freq);

for n = 1:length(Summary)
    
    c1 = Summary(n).chan1;
    c2 = Summary(n).chan2;
    
    i1 = find(strcmp(coh_measures{1,1,1,1}.label,c1));
    i2 = find(strcmp(coh_measures{1,1,1,1}.label,c2));
    
    t  = find(strcmp(time_list,Summary(n).time))+1;
    f  = find(freq_list == Summary(n).freq);
    
    relchange= [];
    
    for cnd = 1:3
        for sb = 1:14
            bsl                 = coh_measures{sb,cnd,t,1}.plvspctrm(i1,i2,f) ;
            act                 = coh_measures{sb,cnd,1,1}.plvspctrm(i1,i2,f) ;
            relchange(sb,cnd)   = (act - bsl) ./ bsl ;
        end
    end
    
    p_rl = permutation_test([relchange(:,1) relchange(:,2)],1000);
    p_rn = permutation_test([relchange(:,1) relchange(:,3)],1000);
    p_ln = permutation_test([relchange(:,2) relchange(:,3)],1000);
    
    cnd_post = '';
    
    if p_rl < 0.05
        cnd_post = [cnd_post 'rl.'];
    end
    
    if p_rn < 0.05
        cnd_post = [cnd_post 'rn.'];
    end
    
    if p_ln < 0.05
        cnd_post = [cnd_post 'ln.'];
    end
    
    figure;
    boxplot(relchange,'labels',{'RCue','LCue','NCue'})
    ylim([-2 2])
    title([c1 '&' c2 ' ' num2str(Summary(n).freq) ' ' Summary(n).time{:} ' ' cnd_post])
    clear relchange
    
end