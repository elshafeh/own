clear ; clc;

Summary = [];
suj_list = [1:4 8:17];

for a = [1:4 8:17]
    
    inpt = 'pos';
    
    suj = ['yc' num2str(a)];
    
    behav_in            = PrepAtt2_funk_behav_load(suj,inpt);
    behav_in_recoded    = PrepAtt2_funk_behav_recode(suj,behav_in,inpt);
    pos                 = PrepAtt2_funk_behav_summary(suj,behav_in_recoded,inpt);
    
    Summary = [Summary; pos];
    
    clear pos behav_*
    
end

% Summary(:,10) = 0;
% Summary(Summary(:,2) ~= 0,10) = 1;
% Summary(Summary(:,2) == 0,10) = 2;

clear RT_DIS

perc_corr   = zeros(14,4);
RT          = zeros(14,3);

for cue_cond = 1:3
    
    for dis_cond = 1:4
        
        suj_list = [1:4 8:17];
        
        cue_idx = cue_cond-1;
        dis_idx = dis_cond-1;
        
        for a = 1:length(suj_list)
            
            %             siz_int = size(Summary(Summary(:,1) == suj_list(a) & Summary(:,3) == dis & Summary(:,7)==0 & Summary(:,8)==1,9),1);
            %             siz_all = size(Summary(Summary(:,1) == suj_list(a) & Summary(:,3) == dis,9),1);
            %             perc_corr(a,d) = (siz_int/siz_all)*100;
            
            if a <= 4
                suj_idx = a ;
            else
                suj_idx = a + 3;
            end
            
            %     RT{d} = [RT{d};median(Summary(Summary(:,1)  == suj_idx & Summary(:,5) == cue_idx & Summary(:,6)  == 0 & Summary(:,10)  ==  1 & Summary(:,12)  ==  0,11))]; 
            %         RT(a,d) = median(Summary(Summary(:,1)  == suj_idx & Summary(:,5) == cue_idx & Summary(:,6)  == 0 & Summary(:,10)  ==  1 & Summary(:,12)  ==  0,11));
            
            RT(a,cue_cond,dis_cond) = median(Summary(Summary(:,1)  == suj_idx & Summary(:,5) == cue_idx & Summary(:,6) == dis_idx & ...
                Summary(:,10)  ==  1 & Summary(:,12)  ==  0,11));
            
        end
    end
end

clearvars -except RT Summary

cnd_test = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4] ;

for p = 1:length(cnd_test)
    
    data(:,1,:) = RT(:,:,cnd_test(p,1));
    data(:,2,:) = RT(:,:,cnd_test(p,2));
    
    clear col
    
    probability{p} = permutation_test(data,10000);
    
end

% for n = 1:size(cnd,1)
%
%     data = [RT{:,cnd(n,1)) RT(:,cnd(n,2))];
%
%     prob_cuNodis = [prob_cuNodis ; permutation_test(data,10000)];
%
%     clear data
%
% end

% dis3_1_rt=[];
%
% for c = 1:2
%
%     dis3_1_rt(:,c) = RT{c,4} - RT{c,2} ;
%
% end
%
% prob_dis3_1 = permutation_test(dis3_1_rt,10000);

% cnd_test{1} = [1 2];
% cnd_test{2} = [1 3];
% cnd_test{3} = [1 4];
% cnd_test{4} = [2 3];
% cnd_test{5} = [2 4];
% cnd_test{6} = [3 4];
%
% prob_dis_percue = [];
%
% for n = 1:length(cnd_test)
%
%     clear data
%
%     for p = 1:2
%         data(:,p) = [RT{1,cnd_test{n}(p)};RT{2,cnd_test{n}(p)}];
%     end
%
%     prob_dis_percue = [prob_dis_percue ; permutation_test(data,10000)];
%
%     clear data
%
% end

% cnd_test{1} = [1 2];
% cnd_test{2} = [1 3];
% cnd_test{3} = [1 4];
% cnd_test{4} = [2 3];
% cnd_test{5} = [2 4];
% cnd_test{6} = [3 4];
%
% for p = 1:length(cnd_test)
%
%     for c =1:2
%         col{c} = RT_DIS{cnd_test{p}(c)};
%     end
%
%     idx = abs(length(col{1})-length(col{2}));
%
%     for c = 1:2
%         if length(col{c}) - idx < 0
%             col{c}(end:end+idx) = NaN;
%         end
%     end
%
%     data = [col{1} col{2}];
%
%     clear col
%
%     probability = permutation_test(data,n_rand,tail);
%
% end