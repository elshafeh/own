function posOUT = PrepAtt22_funk_pos_prepare(posIN,sb,nbloc,ngrp)

% This function removes duplicate triggers and irrelevant codes [10 90 91 253
% 255]
% output is [1] sub_index [2] bloc_index [3] code [4] sample [5] group_index

% fprintf('Removing Duplicates and unwanted codes...\n');

posOUT = posIN(1,:);

for j = 2:size(posIN,1)
    if posIN(j,1) ~= posIN(j-1,1)
        posOUT = [posOUT;posIN(j,:)];
    end
end

posOUT(posOUT(:,2)==10,:)   =   [];
posOUT(posOUT(:,2)==90,:)   =   [];
posOUT(posOUT(:,2)==91,:)   =   [];
posOUT(posOUT(:,2)==253,:)  =   [];
posOUT(posOUT(:,2)==255,:)  =   [];

posOUT          = [repmat(sb,length(posOUT),1)  repmat(nbloc,length(posOUT),1) posOUT(:,2) posOUT(:,1) repmat(ngrp,length(posOUT),1)];

