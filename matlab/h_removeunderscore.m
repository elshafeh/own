function label_out = h_removeunderscore(label_in)

for n = 1:length(label_in)
    
    fnd_undr        = strfind(label_in{n},'_');
    label_out{n}    = label_in{n};
    label_out{n}(fnd_undr)  = ' ';
    
    
end
