function bil_project2dropbox

% this function copies data from BILBO project folder to personal BILBOdropbox folder

target_dir          	= input('Enter target directory : ','s');
target_ext              = input('Enter target extension : ','s');

try
    
    file_list               = dir(['P:\3015079.01\data\sub*\' target_dir '\*' target_ext '*']);
    file_order              = [];
    
    % sorts files in order of date
    
    for nf = 1:length(file_list)
        fname               = [file_list(nf).name];
        list{nf}            = fname;
        file_order          = [file_order; nf datenum(file_list(nf).date)];
    end
    
    file_order              = sortrows(file_order,2);
    
    file_list               = file_list(file_order(:,1));
    list                    = list(file_order(:,1));
    
    [indx,~]                = listdlg('ListString',list,'ListSize',[400,400]);
    
    fprintf('\n %4d files found \n',length(file_list(indx)));
    
    for nf = indx
        
        fname_in            = [file_list(nf).folder filesep file_list(nf).name];
        
        suj                 = file_list(nf).name(1:6);
        
        dir_data            = ['D:\Dropbox\project_me\data\bil\' suj '\' target_dir];
        
        if ~exist(dir_data)
            mkdir(dir_data);
        end
        
        fname_out           = [dir_data filesep file_list(nf).name];
        
        fprintf('\nsource: %s\n',fname_in);
        fprintf('target: %s \n',fname_out);
        
        tic;
        copyfile(fname_in,fname_out);
        toc;
        
    end
    
end