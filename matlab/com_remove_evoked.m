clear ;

for ns = [1:4 8:17]
    for nd = 1:4
        
        list_data   = {'CnD.eeg','pt3.CnD.meg','pt2.CnD.meg','pt1.CnD.meg'};
        
        ext_name    = ['yc' num2str(ns) '.' list_data{nd} '.sngl.dwn100'];
        fname       = ['../data/preproc_data/' ext_name '.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        data        = h_removeEvoked(data);
        
        if isfield(data,'cfg')
            data    = rmfield(data,'cfg');
        end
        
        ext_name    = ['yc' num2str(ns) '.' list_data{nd} '.minus.evoked'];
        fname       = ['../data/preproc_data/' ext_name '.mat'];
        
        fprintf('saving %s\n',fname);
        save(fname,'data','-v7.3');
        
    end
end