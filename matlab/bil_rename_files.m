clear;

file_list       = dir('P:\3015079.01\data\sub*\source\sub*.60t100Hz*');

for nfile = 1:length(file_list)
    
    fname_in    = [file_list(nfile).folder filesep file_list(nfile).name];
    
    trgt_ext    = 'BetaReconDics.mat';
    fnd_ext     = strfind(fname_in,trgt_ext);
    
    fname_out   = [fname_in(1:fnd_ext-1) 'GammaReconDics.mat'];
    
    fprintf('moving %s\n',fname_in);
    movefile(fname_in,fname_out);
    
    clear fname_in fname_out *_ext
    
end

clear;

file_list       = dir('P:\3015079.01\data\sub*\source\sub*.60t80Hz*');

for nfile = 1:length(file_list)
    
    fname_in    = [file_list(nfile).folder filesep file_list(nfile).name];
    
    trgt_ext    = 'BetaReconDics.mat';
    fnd_ext     = strfind(fname_in,trgt_ext);
    
    fname_out   = [fname_in(1:fnd_ext-1) 'GammaReconDics.mat'];
    
    fprintf('moving %s\n',fname_in);
    movefile(fname_in,fname_out);
    
    clear fname_in fname_out *_ext
    
end

