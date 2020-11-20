clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    for nsess = 1:2
        
        fname                               = ['K:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        index                               = data.trialinfo;
        
        fname                               = ['K:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '_trialinfo.mat'];
        save(fname,'index');
        
        clear data index;
        
    end
end