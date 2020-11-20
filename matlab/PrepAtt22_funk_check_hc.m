function PrepAtt22_funk_check_hc(blocksArray,suj)

direc_ds            = ['../data/' suj '/ds/'];
check               = [];
DSpath              = {};

if strcmp(suj,'yc18');
    blocksArray = blocksArray;
else
    blocksArray = blocksArray(1:end-1);
end

for nbloc = 1:length(blocksArray)
    DSpath{end+1}   =  [direc_ds suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.ds'];
    hc              = read_ctf_hc([direc_ds suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.ds/' suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.hc']);
    
    if nbloc == 1
        stndrd_block = [hc.standard.nas';hc.standard.lpa';hc.standard.rpa';hc.dewar.nas';hc.dewar.lpa';hc.dewar.rpa';hc.head.nas';hc.head.lpa';hc.head.rpa'];
    else
        new_block = [hc.standard.nas';hc.standard.lpa';hc.standard.rpa';hc.dewar.nas';hc.dewar.lpa';hc.dewar.rpa';hc.head.nas';hc.head.lpa';hc.head.rpa'];
        check = [check stndrd_block-new_block];
    end
    
    
end

double_check = check(check~=0);

if ~isempty(double_check)
    error(sprintf('CAREFUL !! hc files have not been processed !!! '));
end