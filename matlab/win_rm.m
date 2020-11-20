function win_rm(file_ext)

flist           = dir(file_ext);

for nf = 1:length(flist)
    fname       = [flist(nf).folder filesep flist(nf).name];
    fprintf('deleting %s\n',fname);
    delete(fname);
end