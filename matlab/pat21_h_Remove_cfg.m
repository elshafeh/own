for sb = 1:14
    for dis = 1:3
        allsujGA{sb,dis} = rmfield(allsujGA{sb,dis},'cfg');
    end
end

for a = 1:5
    for b = 1:3
        stat{a,b} = rmfield(stat{a,b},'cfg');
    end
end

clearvars -except allsujGA stat