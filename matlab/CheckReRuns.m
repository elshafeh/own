clear ; clc ;

suj_list        = dir('../rawdata/') ;

for n = 1:length(suj_list)
    
    if length(suj_list(n).name) > 2 && length(suj_list(n).name) < 5
        
        suj         = suj_list(n).name;
        
        direc_raw   = dir(['../rawdata/' suj '/*ds']);
        
        toverify    = zeros(64,length(direc_raw));
        
        for b = 1:size(direc_raw,1)
            
            dsName  = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG22/pat.meeg/rawdata/' suj '/' direc_raw(b).name];
            
            posnameout = ['../data/' suj '/pos/' direc_raw(b).name '.code.pos'];
            
            posIN       = load(posnameout); posIN = posIN(:,2);
            posIN       = posIN((posIN >= 1 & posIN <= 24) | (posIN >= 101 & posIN <= 123) | (posIN >= 202 & posIN <= 224));

            toverify(1:length(posIN),b)  = posIN' ;
            
        end
        
        for x = 1:length(direc_raw)
            for y = 1:length(direc_raw)
                
                chk1 = toverify(:,x);
                chk2 = toverify(:,y);
                
                chk3 = unique(chk1-chk2);
                
                if x ~= y
                    if length(chk3) == 1
                        if chk3 == 0
                            fprintf('%s and %s are identical\n',direc_raw(x).name,direc_raw(y).name);
                        end
                    end
                end
                
            end
        end
        
    end
    
    clearvars -except fid* fOUT* n suj_list ;
    
end
