clear ; global ft_default
ft_default.spmversion   = 'spm12';

load ../data/list/suj.list.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat

for nsuj = good_list'
    for nsess = 1:2
        
        chk                                                     = dir(['/Volumes/heshamshung/nback/tf/sub' num2str(nsuj) '*sess' num2str(nsess) '*15t30*']); 
        
        if length(chk) < 3 % 3conditions per session (2 backs + all)
            
            fname                                               = ['../data/prepro/stack/data_sess' num2str(nsess) '_s' num2str(nsuj) '_3stacked.mat'];
            fprintf('\nloading %s\n',fname);
            load(fname);
            
            data_repair                                         = megrepair(data);
            h_mtm_compute(data_repair,nsuj,nsess,-1.5:0.03:6,15:1:30,[4 5 6],'stakcombined');
            
            keep nsess nsuj
            
        end
        
    end
end