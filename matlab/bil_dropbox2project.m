function bil_dropbox2project

target_dir          	= input('Enter target directory : ','s');
target_ext              = input('Enter target extension : ','s');

file_list               = dir(['D:\Dropbox\project_me\pjme_bil\meg\data\sub*\' target_dir '\s*' target_ext]);
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

for nf = indx
    
    fname_in            = [file_list(nf).folder filesep file_list(nf).name];
    
    suj                 = file_list(nf).name(1:6);
    
    dir_data            = ['P:\3015079.01\data\' suj '\' target_dir];
    fname_out           = [dir_data filesep file_list(nf).name];
    
    chk                 = dir(fname_out);
    
    if isempty(chk)
        fprintf('\n moving %s\n',fname_in);
        tic;
        movefile(fname_in,fname_out);
        toc;
    else
        fprintf('\n already exists %s\n',fname_out);
        delete(fname_in);
    end
    
    
end







