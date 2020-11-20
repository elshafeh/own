function h_plotbehavior(allInfo)

subplot(2,2,4);
hold on;

tot_nmb         = size(allInfo,1);
tot_vct         = [[allInfo.task] [allInfo.cue] [allInfo.color] [allInfo.match]];
tot_vct(:,4)    = tot_vct(:,4) + 1;

list_tsk        = {'ori','frq'};
list_cue        = {'pre','rtr'};
list_col        = {'wte','blk'};
list_mtc        = {'no','ys'};

list_name       = {};
ix              = 0;
chk             = [];

for ntask = 1:2
    for ncue = 1:2
        for ncolor = 1:2
            for nmatch = 1:2
                
                ix              = ix+1;
                sub_vct         = tot_vct(tot_vct(:,1) == ntask & tot_vct(:,2) == ncue & tot_vct(:,3) == ncolor & tot_vct(:,4) == nmatch);
                chk             = [chk length(sub_vct)];
                
                list_name{ix}   = [list_tsk{ntask} ' ' list_cue{ncue} ' ' list_col{ncolor} ' ' list_mtc{nmatch}];
                
                barh(ix,length(sub_vct));
                
            end
        end
    end
end

xlim([0 max(chk)+1]);
set(gca,'ytick',1:length(list_name),'yticklabel',list_name);

title 'trial distribution:'
box off