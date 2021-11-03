clear;

preproc_directory               = '~/Dropbox/project_me/data/pam/preproc/';
vol_directory                   = '~/Dropbox/project_me/data/pam/headfield/';

suj_list                        = {'yc1' 'yc2' 'yc3' 'yc4'};

for nsuj = 1:length(suj_list)
    
    sujname                     = suj_list{nsuj};
    
    fname_in                 	= [vol_directory sujname '_volgrid_0.1cm.mat'];
    fprintf('loading: %s\n',fname_in);
    load(fname_in);
    
    for npart = 1:3
        
        fname_in             	= [preproc_directory sujname '.pt' num2str(npart) '.CnD.meg.sngl.dwn100.mat'];
        fprintf('loading: %s\n',fname_in);
        load(fname_in);
        
        cfg                  	= [];
        cfg.sourcemodel       	= grid;
        cfg.headmodel        	= vol;
        cfg.grad               	= data.grad;
        cfg.channel            	= 'MEG';
        leadfield              	= ft_prepare_leadfield(cfg);
        
        fname_out               = [vol_directory sujname '_pt' num2str(npart) '_leadfield_1mm.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'leadfield','-v7.3');
        
        
    end
end