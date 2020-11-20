function all_evnts = PrepAtt22_funk_check_cueBaseline(pos_single,wcue)

all_evnts   = [];

lm1         = wcue - 1200;
lm2         = wcue + 1200;

trlbox      = pos_single(pos_single(:,4) >= lm1 & pos_single(:,4) <= lm2,4);

sub_before  = trlbox(trlbox<wcue);

if ~isempty(sub_before)
    for hiho = 1:length(sub_before)
        stmp       = sub_before(hiho) - wcue;
        stmp       = stmp * 5/3;
        all_evnts = [all_evnts ; stmp];
        clear stmp
    end
end

clear hiho sub_before sub_after trlbox 