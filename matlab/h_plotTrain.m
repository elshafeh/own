function h_plotTrain(allInfo)

figure;
hold on;

tot_vct         = [[allInfo.task] [allInfo.cue] cell2mat([allInfo.repCorrect])];

list_tsk        = {'ori','frq'};
list_cue        = {'pre','rtr'};

list_name       = {};
ix              = 0;
chk             = [];


for ncue = 1:2
    for ntask = 1:2
        ix              = ix+1;
        sub_vct         = tot_vct(tot_vct(:,1) == ntask & tot_vct(:,2) == ncue,3);
        
        val             = sum(sub_vct)./length(sub_vct);
        chk             = [chk val];
        
        list_name{ix}   = [list_tsk{ntask} ' ' list_cue{ncue}];
        
        bar(ix,val);
        
    end
end

set(gca,'xtick',1:length(list_name),'xticklabel',list_name);