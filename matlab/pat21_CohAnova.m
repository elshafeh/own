clear ; clc ;

load ../data/yctot/stat/coherence_perCondition.mat

% ttest

ii = 0 ;

for chan1 = 1:length(coh_measures{1,1,1,1}.label)
    for chan2 = 1:length(coh_measures{1,1,1,1}.label)
        if chan1 ~= chan2
            ii = ii + 1;
            tmp = [chan1 chan2];
            tmp = sort(tmp);
            chn_list{ii} =[num2str(tmp(1)) '.' num2str(tmp(2))];
            clear tmp 
        end
    end
end

chn_list = unique(chn_list);

chan1_list = [];
chan2_list = [];


for ii = 1:length(chn_list)
   
    dotdot = strfind(chn_list{ii},'.');
    
    chan1_list(end+1) = str2num(chn_list{ii}(1:dotdot-1));
    chan2_list(end+1) = str2num(chn_list{ii}(dotdot+1:end));
    
end

clearvars -except coh_measures chn_list chan*

ntest = 0 ;

for ix_coh = 1
    
    for ix_t   = 2:3
        
        tres{ix_coh,ix_t-1}                         =  coh_measures{1,1,1,1};
        tres{ix_coh,ix_t-1}.plvspctrm(:,:,:)        = 0 ;
        
        for frq = 1:length(coh_measures{1,1,1}.freq)
            
            for c_c = 1:length(chan1_list)
                
                x = []; y = [];
                
                for sb = 1:size(coh_measures,1)
                    
                    v_bsl   = coh_measures{sb,4,ix_t,ix_coh}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    v_act   = coh_measures{sb,3,1,ix_coh}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    n_bsl   = coh_measures{sb,3,ix_t,ix_coh}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    n_act  = coh_measures{sb,3,1,ix_coh}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    
                    x(sb) = (v_act - v_bsl) ./ v_bsl ;
                    y(sb) = (n_act - n_bsl) ./ n_bsl ;
                    
                end
                
                p           = permutation_test([x' y'],1000);
                
                direction = (nanmean(x) - nanmean(y));
                
                if direction < 0
                    p = p * -1 ;
                end
                
                ntest       = ntest + 1;
                
                p_bag(ntest) = p ;
                
                if ix_coh==1
                    tres{ix_coh,ix_t-1}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
                else
                    tres{ix_coh,ix_t-1}.cohspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
                end
                
                
            end
            
        end
        
    end
    
end

clearvars -except tres p_bag coh_measures