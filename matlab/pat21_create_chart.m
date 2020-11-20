clear ; clc ;

fin_ext   = 'PaperExtConvol';
fname = ['../data/yctot/' fin_ext '.mat'];

load(fname); clear ext ;

% Baseline Correct & Choose %

for sb = 1:size(allsuj,1)
    
    for cnd = 1:size(allsuj,2)
        
        tmp = allsuj{sb,cnd}(:,:,:) ;
        
        bt1 = find(round(template.time,2) == -0.6);
        bt2 = find(round(template.time,2) == -0.2);
        
        bsl = mean(tmp(:,:,bt1:bt2),3);
        bsl = repmat(bsl,1,1,size(tmp,3));
        
        tmp = (tmp-bsl)./ bsl ;
        
        clear bsl bt1 bt2
        
        t1 = find(round(template.time,2) == -0.6);
        t2 = find(round(template.time,2) == 2);
        
        new_template.time = template.time(t1:t2);
        
        source_avg(sb,cnd,:,:,:) = tmp(:,:,t1:t2) ;
        
        clear t1 t2 f1 f2
        
        new_template.label = template.label;
        
        clear tmp
        
    end
end

avg = squeeze(source_avg(:,1:3,6,5:7,:));
avg = squeeze(mean(avg,1));
avg = squeeze(mean(avg,2));
% avg = squeeze(mean(avg,1));

clearvars -except avg new_template

t_list = -0.2:0.2:1.4;

new_avg = [];

for t = 1:length(t_list)
    
    ix = find(round(new_template.time,2) == round(t_list(t),2));
    new_avg = [new_avg avg(:,ix)];
    
end

% new_new = mean(new_avg(:,5:7),2);
% new_new = new_new';