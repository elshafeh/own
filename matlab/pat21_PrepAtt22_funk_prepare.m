function posOUT = PrepAtt22_funk_prepare(posIN,suj)

% output sub bloc event sample

lst_group = {'yc','oc','fp','mg','uc'};


posOUT                      = posIN ;
nbloc                       = 1;
idx_group                   = find(strcmp(lst_group,suj(1:2)));
sb                          = str2double(suj(3:end));

posOUT(posOUT(:,2)==10,:)   =   [];
posOUT(posOUT(:,2)==90,:)   =   [];
posOUT(posOUT(:,2)==91,:)   =   [];
posOUT(posOUT(:,2)==253,:)  =   [];
posOUT(posOUT(:,2)==255,:)  =   [];

posOUT = [repmat(sb,length(posOUT),1)  repmat(nbloc,length(posOUT),1) posOUT(:,2) posOUT(:,1) repmat(idx_group,length(posOUT),1)];