clear ; global ft_default
ft_default.spmversion   = 'spm12';

load ../data/list/suj.list.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat
suj_list                                    = good_list;

for nsuj = 1%:length(suj_list)
    for nsession = 1:2
        
        fname                               = ['../data/prepro/stack/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '_3stacked.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        new_data                            = megrepair(data);
        
        grad                                = new_data.grad;
        label                               = new_data.label;
        
        fname                               = ['../data/prepro/stack/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '_3stacked.gradrepaired.mat'];
        fprintf('\nsaving %s\n',fname);
        save(fname,'grad','label');
        
        keep suj_list nsuj nsession
        
    end
end