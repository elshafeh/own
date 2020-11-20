clear ; clc ;

load ../data/yctot/stat/cohVNstat.mat

meas_list = {'plv','coherency'};
time_list = {'early','late'};
chan_list = tres{1,1}.label ;
freq_list = round(tres{1,1}.freq);

ix_s = 0 ;

for ix_coh =  1
    
    for ix_t = 1:2
        
        for frq = 1:length(tres{1,1,1}.freq)
            
            for chan1 = 1:length(tres{1,1,1}.label)
                
                for chan2 = 1:length(tres{1,1}.label)
                    
                    %                     if ~strcmp(tres{1,1,1}.label{chan1}(1:3),'max') && ~strcmp(tres{1,1,1}.label{chan2}(1:3),'max')
                    
                    nana = find(strcmp(chan_list{chan1}(1),'r'));
                    nina = find(strcmp(chan_list{chan2}(1),'r'));
                    
                    ka = length(nana)+length(nina);
                    
                    if ka == 1
                        
                        if ix_coh >1
                            p           = tres{ix_coh,ix_t}.cohspctrm(chan1,chan2,frq);
                            abs_p       = abs(p);
                        else
                            p         = tres{ix_coh,ix_t}.plvspctrm(chan1,chan2,frq);
                            abs_p       = abs(p);
                        end
                        
                        if abs_p < 0.05 && abs_p > 0
                            
                            ix_s = ix_s + 1;
                            
                            Summary(ix_s).measure   = meas_list{ix_coh};
                            Summary(ix_s).freq      = freq_list(frq);
                            Summary(ix_s).time      = time_list(ix_t);
                            Summary(ix_s).chan1     = chan_list{chan1};
                            Summary(ix_s).chan2     = chan_list{chan2};
                            Summary(ix_s).p         = abs_p ;
                            
                            if p < 1
                                Summary(ix_s).direction = '+ve';
                            else
                                Summary(ix_s).direction = '-ve';
                            end
                            
                        end
                    end
                    %                     end
                end
            end
        end
    end
end

clearvars -except tres coh_measures Summary