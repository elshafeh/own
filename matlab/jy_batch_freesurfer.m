function jy_batch_freesurfer(cfg, script_number)

[~,ftpath] = ft_version;

if script_number == 1
    
    % shell_script = [ftpath,filesep,'bin',filesep,'ft_freesurferscript.sh'];
    shell_script = [cfg.scriptdir, filesep, 'jy_freesurferscript.sh'];
    
    % create the string that is executed in the linux terminal
    command = [shell_script, ' ', cfg.dirname, ' ', cfg.subjname];
    
elseif script_number == 2
    shell_script   = [ftpath,filesep,'bin',filesep,'ft_postfreesurferscript.sh'];
    surf_atlas_dir = '/home/predatt/yinzho/Documents/standard_mesh_atlases';
    
    % create the string that is executed in the linux terminal
    command = [shell_script, ' ', cfg.dirname, ' ', cfg.subjname, ' ', surf_atlas_dir];
    
end

%{
if script_number==1
    % freesurfer script 1
    shell_script = '/project/3018041.02/Analysis_PredAlpha/anatomy_freesurfer.sh';
elseif script_number==2
    shell_script = '/project/3018041.02/Analysis_PredAlpha/anatomy_freesurfer2.sh';
elseif script_number==3
    shell_script = '/project/3018041.02/Analysis_PredAlpha/anatomy_postfreesurferscript.sh';
end

mri_dir     = cfg.inputdir;
preproc_dir = 'preproc';

%}


% call the script
system(command);


end