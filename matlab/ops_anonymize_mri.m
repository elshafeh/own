clear;

[~,info,~]                      = xlsread('C:\Users\hesels\Desktop\localizer.xlsx','A:C');
info                            = cell2table(info(2:end,:),'VariableNames',info(1,:));

for nsuj = 1:height(info)
    
    if nsuj < 10
        sub_new_name            = ['sub0' num2str(nsuj)];
    else
        sub_new_name            = ['sub' num2str(nsuj)];
    end
    
    mri_in                      = ['P:\3035002.01\somatosensory localizer\mri\' info(nsuj,:).mri{:}];
    
    if exist(mri_in)
        
        mri_out                 = ['D:\Dropbox\project_ops\data\mri\' sub_new_name '.nii'];
        
        if ~exist(mri_out)
            mri               	= ft_read_mri(mri_in);
            cfg             	= [];
            cfg.feedback     	= 'no';
            mri_anon         	= ft_defacevolume([], mri);
            ft_write_mri(mri_out, mri_anon.anatomy, 'transform', mri_anon.transform, 'dataformat', 'nifti');
        end
        
    else
        
        if strcmp(info(nsuj,:).name,'ramon')
            
            mri                 = ft_read_mri('P:\3035002.01\somatosensory localizer\mri\Loon_van_R\PAUGAA_20061220_VANLOON.MR.FCDC_SEQUENCES_STANDARD_SEQUENCES.2.1.2006.12.20.14.04.32.500000.196714348.IMA');
            mri_out                 = ['D:\Dropbox\project_ops\data\mri\' sub_new_name '.nii'];
            cfg                 = [];
            cfg.feedback        = 'no';
            mri_anon            = ft_defacevolume([], mri);
            ft_write_mri(mri_out, mri_anon.anatomy, 'transform', mri_anon.transform, 'dataformat', 'nifti');
            
        else
            
            warning(['MRI missing for ' info(nsuj,:).name{:}]);
            
        end
        
    end
    
    clear mri*
    
end