clear ; clc ;

suj_list = {'oc1','oc12','oc2','oc5','oc8','yc1','yc12','yc15','yc18','yc20','yc4','yc7', ...
    'oc10','oc13','oc3','oc6','oc9','yc10','yc13','yc16','yc19','yc21','yc5','yc8','oc11',...
    'oc14','oc4','oc7','yc11','yc14','yc17','yc2','yc3','yc6','yc9'};

for sb = 1:length(suj_list)
    
    suj = suj_list{sb};
    
    source_file = ['/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/resting_state/' suj ];
    destin_file = ['/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/resting_state/' suj '.pat2.restingstate.thrid_order.ds'];
    
    system(['mv ' source_file ' ' destin_file]);
    
end