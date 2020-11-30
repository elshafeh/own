function StimStruc = bpilot_CreateAllStim

StimCyc         = [0.2 0.25 0.6 0.65]; % [0.2 0.3 0.6 0.7];
StimOri         = [144 107 36 73]; % [145 115 35 65];

ix              = 0;

for ndeg = 1:length(StimCyc)
    for nori = 1:length(StimOri)
        
        ix                                      = ix +1;
        trial_structure(ix).target              = [StimOri(nori) StimCyc(ndeg)];
        trial_structure(ix).color               = 1;
        
    end
end

clearvars -except trial_structure

StimStruc       = struct2table(trial_structure);