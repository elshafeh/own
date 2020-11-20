clear ; clc ;

ext = 'plv4R';

load(['../data/yctot/' ext '.mat']) ;

chan_list = coh_measures{1,1}.label ;
freq_list = round(coh_measures{1,1}.freq);
cnd_list = {'RCue','LCue','NCue'};

fout = (['../txt/' ext '.txt']);
fid  = fopen(fout,'W+');

fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\n','SUB','COND','PAIR','FREQ','PLV');

for cnd = 1:3
    
    for frq = 1:length(coh_measures{1,1}.freq)-1
        
        for c_c = 1:length(chan1_list)
            
            for sb = 1:size(coh_measures,1)
                
                suj = ['yc' num2str(sb)];
                
                c1  = chan_list{chan1_list(c_c)};
                
                c2  = chan_list{chan2_list(c_c)};
                
                if chan1_list(c_c) < 3
                    ext1 = 'viz';
                elseif chan1_list(c_c) > 2 && chan1_list(c_c) < 7
                    ext1 = 'aud';
                elseif chan1_list(c_c) > 6 && chan1_list(c_c) < 11
                    ext1 = 'mot';
                else
                    ext1 = 'front';
                end
                
                if chan2_list(c_c) < 3
                    ext2 = 'viz';
                elseif chan2_list(c_c) > 2 && chan2_list(c_c) < 7
                    ext2 = 'aud';
                elseif chan2_list(c_c) > 6 && chan2_list(c_c) < 11
                    ext2 = 'mot';
                else
                    ext2 = 'front';
                end
                
                if ~strcmp(ext1,'mot') && ~strcmp(ext2,'mot')
                    
                    if strcmp(ext1,'viz') && strcmp(ext2,'viz')
                    elseif strcmp(ext2,'viz') && strcmp(ext1,'viz')
                    elseif strcmp(ext1,'aud') && strcmp(ext2,'aud')
                    elseif strcmp(ext2,'aud') && strcmp(ext1,'aud')
                    elseif strcmp(ext1,'mot') && strcmp(ext2,'mot')
                    elseif strcmp(ext2,'mot') && strcmp(ext1,'mot')
                    elseif strcmp(ext1,'aud') && strcmp(ext2,'mot')
                    elseif strcmp(ext2,'aud') && strcmp(ext1,'mot')
                    elseif strcmp(ext1,'viz') && strcmp(ext2,'mot')
                    elseif strcmp(ext2,'viz') && strcmp(ext1,'mot')
                    else
                        
                        f   = [num2str(freq_list(frq)) 'Hz'];
                        plv = coh_measures{sb,cnd}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq);
                        
                        fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%.4f\n',suj,cnd_list{cnd},[c1 '.' c2],f,plv);
                        
                        clear suj c1 c2 f plv
                        
                    end
                    
                end
            end
            
        end
        
    end
end

fclose(fid);