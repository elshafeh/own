clear ; clc;

addpath(genpath('kakearney-boundedline'));

load ../data/goodsubjects-07-Oct-2019.mat;

for nm = 1:length(list_modality)
    
    list_suj                                    = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                     = list_suj{ns};
        modality                                = list_modality{nm};
        
        for nb = 1:6
            
            fname                               = ['../data/' suj '_' modality '_sfn_dwnsample.B' num2str(nb) '.mat'];
            fprintf('loading %s\n',fname)
            load(fname);
            
            data_car{nb}                        = data; clear data;
            
        end
        
        ibig                                    = 0;
        
        for nc = [1 3 5]
            
            ibig                                = ibig + 1;
            
            data                                = ft_appenddata([],data_car{nc},data_car{nc+1});
            data                                = rmfield(data,'cfg');
            
            fname                               = ['../data/' suj '_' modality '_sfn_dwnsample.BigB' num2str(ibig) '.mat'];
            fprintf('Saving %s\n',fname);
            tic;save(fname,'data','-v7.3');toc;
            
            index                               = data.trialinfo;
            fname                               = ['../data/' suj '_' modality '_sfn_dwnsample_trialinfo.BigB' num2str(ibig) '.mat'];
            fprintf('Saving %s\n',fname);
            tic;save(fname,'index');toc;
            
            fprintf('\n');
            
        end
        
    end
end