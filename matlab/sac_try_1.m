clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 1
    
    suj                                     = suj_list{sb};
    fname_in                                = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in);
    
    data            = [];
    
    for ntrial = 1:length(data_elan.trial)
        data            = [data data_elan.trial{ntrial}];
    end
    
    %     microsaccades = micsaccdeg(data(1,:)', 600);
    
end