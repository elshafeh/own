clear ; clc ;addpath(genpath('../../../fieldtrip-20151124/'));

suj         = 'oc12';

direc_raw   = dir(['../rawdata/' suj '/*ds']);

bloc_tot    =  length(direc_raw);
bloc_good   = 0 ;
bloc_bad    = 0 ;
bloc_rest   = 0;
ix_concat   = [];


for b = 1:size(direc_raw,1)
    
    dsName      = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG22/pat.meeg/rawdata/' suj '/' direc_raw(b).name];
    posnameout  = ['../data/' suj '/pos/' direc_raw(b).name '.code.pos'];
    
    if ~exist(posnameout)
        
        posIN       = ft_read_event(dsName);
        allCodes    = [];
        allSamples  = [];
        
        for h  =1:length(posIN)
            if strcmp(posIN(h).type,'UPPT001')
                if ~isempty(posIN(h).value)
                    if ~isempty(posIN(h).sample)
                        allCodes    = [allCodes ;posIN(h).value];
                        allSamples  = [allSamples ;posIN(h).sample];
                    end
                end
            end
        end
        
        %                 if length(allSamples) ~= length(allCodes)
        %                     allCodes=[repmat(allCodes(1),abs(length(allSamples) - length(allCodes)) ,1);allCodes];
        %                 end
        
        posIN = [allSamples allCodes];
        dlmwrite(posnameout,posIN,'Delimiter','\t' ,'precision','%10d');
        
    else
        posIN = load(posnameout);
    end
    
    posIN = posIN(:,2);
    
    nbloc = strsplit(direc_raw(b).name,'_');  nbloc = nbloc{4}; nbloc = strsplit(nbloc,'.') ; nbloc = str2double(nbloc{1});
    
    ntrl = 0 ;
    
    if length(posIN) < 3 && unique(posIN) == 253
        bloc_rest       = bloc_rest +1;
        whereIsRest     = nbloc ;
    else
        
        posIN(posIN==10 | posIN==91 | posIN==90 | posIN==253,:)=[];
        
        posIN       = posIN((posIN >= 1 & posIN <= 24) | (posIN >= 101 & posIN <= 123) | (posIN >= 202 & posIN <= 224));
        check{b}    = posIN;    
        ntrl        = length(posIN);
        
        if ntrl == 64
            bloc_good = bloc_good + 1;
            ix_concat = [ix_concat;nbloc];
        else
            bloc_bad = bloc_bad + 1;
        end
    end
    
end