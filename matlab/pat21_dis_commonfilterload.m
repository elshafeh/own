function data = dis_commonfilterload(suj,prt)

% load dis

fname_in = [suj '.pt' num2str(prt) '.DIS'];
fprintf('Loading %50s\n',fname_in);
load(['../data/elan/' fname_in '.mat'])

tmp{1} = data_elan ;

clear data_elan

% load fdis

fname_in = [suj '.pt' num2str(prt) '.fDIS'];
fprintf('Loading %50s\n',fname_in);
load(['../data/elan/' fname_in '.mat'])

tmp{2} = data_elan ; clear data_elan

data = ft_appenddata([],tmp{:}); clear tmp