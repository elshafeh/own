function h_makesubjectdirectory(suj_name)

if ispc
    start_dir = 'P:\';
else
    start_dir = '/project/';
end

mkdir([start_dir '3015079.01/data/' suj_name]);

mkdir([start_dir '3015079.01/data/' suj_name '/preproc']);
mkdir([start_dir '3015079.01/data/' suj_name '/tf']);
mkdir([start_dir '3015079.01/data/' suj_name '/log']);
mkdir([start_dir '3015079.01/data/' suj_name '/erf']);
