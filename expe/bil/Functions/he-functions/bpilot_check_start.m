function strt = bpilot_check_start(Info)

vct             = Info.TrialInfo.nbloc;
number_blocks   = max(unique(vct));
check_blocks    = [];

for nbloc = 1:number_blocks
    
    check_blocks(nbloc,1)   = nbloc;
    check_blocks(nbloc,2)   = 0;
    
    tmp         = Info.TrialInfo(find(vct == nbloc),:).repRT;
    
    for ntrial = 1:length(tmp)
        if ~isempty(tmp{ntrial})
            check_blocks(nbloc,2) = check_blocks(nbloc,2)+1;
        end 
    end
end

strt            = check_blocks(check_blocks(:,2) < 64,1);
strt            = strt(1);
which_block     = find(vct == strt);

strt            = which_block(1);
