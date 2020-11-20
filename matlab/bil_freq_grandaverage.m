clear ;

keyword1                    = 'mtmconvol';
keyword2                    = '10t40Hz';
keyword3                    = 'comb';

suj_list                    = dir(['../data/sub*/tf/*' keyword1 '*' keyword2 '*' keyword3 '.mat']);
fprintf('\n %2d subjects found\n',length(suj_list));

for ns = 1:length(suj_list)
    
    fname                   = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % this finds the freq structure loaded
    find_var                = whos;
    find_var                = {find_var.name};
    find_var                = find(strcmp(find_var,'freq_axial'));
    
    if isempty(find_var)
        freq                = ft_freqdescriptives([],freq_comb); clear freq_comb
    else
        freq                = ft_freqdescriptives([],freq_axial); clear freq_axial
    end
    
    freq                    = rmfield(freq,'cfg');
    
    all_data{ns,1}          = freq; clear freq;
    
end

keep all_data keyword*;

gavg                        = ft_freqgrandaverage([],all_data{:,1});
gavg                        = rmfield(gavg,'cfg');

fname_out                   = ['../results/gavg/n10_gavg_' keyword1 '_' keyword2 '_' keyword3 '.mat'];
save(fname_out,'gavg','all_data','-v7.3');