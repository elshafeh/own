clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat


i = 0 ;
figure;

for ext_gab = {'first','second'}
    
    for nsuj = 1:length(suj_list)
        
        subjectName                         = suj_list{nsuj};
        dir_data                            = [project_dir 'data/' subjectName '/decode/'];
        
        list_cond                           = {'cue.pre.ori','cue.retro.ori','cue.pre.freq','cue.retro.freq'};
        list_feature                        = {'gab.ori','gab.freq'};
        
        for n_con = 1:length(list_cond)
            
            tmp                           	= [];
            
            for nfeat = 1:length(list_feature)
                ext_feature               	= list_feature{nfeat};
                fname                    	= [dir_data subjectName '.' ext_gab{:} 'gab.lock.' list_cond{n_con} '.' ...
                    ext_feature '.correct.bsl.auc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(nfeat,:)                = scores; clear scores;
            end
            
            avg                             = [];
            avg.label                       = list_feature;
            avg.dimord                      = 'chan_time';
            avg.time                        = time_axis; clear time_axis;
            avg.avg                         = tmp; clear tmp;
            alldata{nsuj,n_con}         	= avg; clear avg;
            
        end
        
    end
    
    
    for ncond = 1:size(alldata,2)
        for nchan = 1:length(alldata{1}.label)
            
            cfg=[];
            cfg.channel = nchan;
            i = i +1;
            subplot(4,4,i);
            ft_singleplotER(cfg,ft_timelockgrandaverage([],alldata{:,ncond}));
            xlim([-0.2 2]);
            title([ext_gab{:} ' ' alldata{1}.label{nchan}]);
            
            if nchan == 1
                ylim([0.48 0.6]);
            else
                ylim([0.48 0.8]);
            end
            
            hline(0.5,'--r');
            vline(0,'--r');
            
        end
    end
    
    keep ext_gab suj_list project_dir i
    
end