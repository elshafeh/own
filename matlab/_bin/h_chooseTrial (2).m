function itrl = h_chooseTrial(data_elan,icue,idis,itarget)

%  Cue : 0 uninformative ; 1 left ; 2 right
%  Dis : 0 1 2 3 ;
%  Tar : 1 left low 2 right low 3 left high 4 right high

itrl        = [];

pos         = data_elan.trialinfo; % extract code
pos(:,2)    = round(pos(:,1)/1000); % determine type of trigger
pos(:,3)    = pos(:,1) - (pos(:,2)*1000); % remove the recoding
pos(:,4)    = round(pos(:,3)/100); % code 
pos(:,5)    = round((pos(:,3) - (pos(:,4)*100))/10); % cue 
pos(:,6)    = mod(pos(:,3),10); % dis 
pos(:,7)    = pos(:,4)*100 + pos(:,5)*10 + pos(:,6); % target

if pos(:,7) ~= pos(:,3)
    fprintf('%s\n','Something is wrong');
else
    for i = 1:length(icue)
        for ii = 1:length(idis)
            for iii = 1:length(itarget)
                tmp     = find(pos(:,4)==icue(i) & pos(:,5) == idis(ii) & pos(:,6) == itarget(iii));
                itrl    = [itrl;tmp]; %#ok<*AGROW>
                clear tmp
            end
        end
    end   
end

itrl = sort(itrl); % !!!