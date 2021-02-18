clear;

load(['C:\Users\hesels\Desktop\subjects.mat']);

for nsuj = 1:length(name)
    
    if nsuj < 10
        sub_new_name        = ['sub0' num2str(nsuj)];
    else
        sub_new_name        = ['sub' num2str(nsuj)];
    end
    
    for cond = {'left' 'right'}
        
        check_ds           	= dir(['P:\3035002.01\somatosensory localizer\MEG\' name{nsuj} '*' cond{:} '*.ds']);
        
        if length(check_ds) == 1
            input_ds        = [check_ds(1).folder filesep check_ds(1).name];
            output_ds       = ['D:\Dropbox\project_ops\data\ds\' sub_new_name '_localizer_' cond{:} '.ds'];
            
            if ~exist(output_ds)
                go_anonymiseDs(input_ds,output_ds);
            end
            
        else
            error('');
        end
        
    end
    
end