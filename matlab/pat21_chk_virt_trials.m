clear ; clc ;

load ../data/yctot/rt/CnD_part_index.mat

sexyfive = {};

for sb = 1:14
    
    %     suj = ['yc' num2str(suj_list(sb))];
    %     load(['../data/trialinfo/' suj '.nDT.trialinfo.mat']);
    %     data_elan.trialinfo = trialinfo ;
    %     ntrl(sb) = length(h_chooseTrial(data_elan,0:2,cnd,1:4));
    %     for prt = 1:3
    %         ntrl(sb,prt) = length(indx_pt(indx_pt(:,1)==sb & indx_pt(:,2)==prt,3));
    %     end
    
    ntrl = length(indx_pt(indx_pt(:,1)==sb,3));
    ncut = 5;
    step = floor(ntrl/ncut);
    i    = 0;
    
    for n = 1:step:ntrl
        i = i + 1;
        
        if i < ncut + 1;
            data        = indx_pt(indx_pt(:,1)==sb,3);
            if i < ncut
                sexyfive{sb,i} = data(n:n+step-1);
            else
                sexyfive{sb,i} = data(n:end);
            end
        end
    end
end

for sb = 1:14
    
    x = length(sexyfive{sb,1})+length(sexyfive{sb,2})+length(sexyfive{sb,3})+length(sexyfive{sb,4})+length(sexyfive{sb,5});
    y = length(indx_pt(indx_pt(:,1)==sb,3));
    
    if x ~= y
        fprintf('Fuck\n');
    end
end

clearvars -except sexyfive ; 
save ../data/yctot/rt/sexyfive.mat ;