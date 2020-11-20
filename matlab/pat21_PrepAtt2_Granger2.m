clear ; clc ;

load ../data/yctot/stat/granger_primer.mat ; clear tres ;

for sb = 1:14
    
    for ix_t = 1:3
        
        grn                               = coh_measures{sb,ix_t,1}.grangerspctrm(:,:,4:9);
        grn_log                           = log10(grn);
        grn_z                             = zscore(grn);
        
        for ix_n = 1:3
            granger{sb,ix_t,ix_n}.label          = coh_measures{sb,ix_t,1}.label;
            granger{sb,ix_t,ix_n}.dimord         = coh_measures{sb,ix_t,1}.dimord;
            granger{sb,ix_t,ix_n}.freq           = coh_measures{sb,ix_t,1}.freq(4:9);
        end
        
        granger{sb,ix_t,1}.grangerspctrm = grn ;
        granger{sb,ix_t,2}.grangerspctrm = grn_log ;
        granger{sb,ix_t,3}.grangerspctrm = grn_z ;
        
        clear grn*
        
    end
    
end

clearvars -except granger

ii = 0 ;

for chan1 = 1:length(granger{1,1,1}.label)
    for chan2 = 1:length(granger{1,1,1}.label)
        if chan1 ~= chan2
            ii = ii + 1;
            tmp = [chan1 chan2];
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

clearvars -except granger chn_list chan*

ntest_tot = 0 ;

for ix_trans = 1:3
    for ix_t   = 2:3
        for frq = 4:9
            for c_c = 1:length(chan1_list)
                ntest_tot = ntest_tot + 1;
            end
        end
    end
end

clearvars -except granger chn_list chan* ntest_tot

ntest = 0 ;

for ix_trans = 1:3
    
    for ix_t   = 2:3
        
        tres{ix_trans,ix_t-1}                           = granger{1,1,ix_trans} ;
        tres{ix_trans,ix_t-1}.grangerspctrm(:,:,:)      = 0 ;
        
        for frq = 1:6
            
            for c_c = 1:length(chan1_list)
                
                for sb = 1:size(granger,1)
                    
                    x(sb) = granger{sb,ix_t,ix_trans}.grangerspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    y(sb) = granger{sb,1,ix_trans}.grangerspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    
                end
                
                p           = permutation_test([x' y'],1000);
                direction   = (nanmean(x) - nanmean(y));
                
                if direction < 0
                    p = p * -1 ;
                end
                
                ntest       = ntest + 1;
                
                fprintf('Computing test %6d out of %6d\n',ntest,ntest_tot);
                
                tres{ix_trans,ix_t-1}.grangerspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
                
                
            end
            
        end
        
    end
    
end

clearvars -except tres