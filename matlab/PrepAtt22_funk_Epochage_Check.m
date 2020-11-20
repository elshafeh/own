function PrepAtt22_funk_Epochage_Check(suj)


posFile{1}             = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.pos']);
posFile{2}             = load(['../data/' suj '/pos/' suj '.icacorrMEG.regress0.pos']);

for cnd = 1:2
    tmp = posFile{cnd};
    tmp = tmp(tmp(:,3)==0 & floor(tmp(:,2)/1000)==1,1:2);
    posFile{cnd} = tmp;
    clear tmp;
end

if length(posFile{1}) == length(posFile{2})
    
    for xi = 1:length(posFile{1})
        
        if (posFile{1}(xi,1) == posFile{2}(xi,1)) && (posFile{1}(xi,2) == posFile{2}(xi,2))
            fprintf('Trial Ok\n')
        else
            error(' !! ')
        end
        
    end
    
else
    error('!!')
end

