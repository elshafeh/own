function [min_val,max_val] = h_findMaxMinMatrix(x)

% generates maxmimum and minimum value in a matrix of any dimension

ix = length(size(x));

str2type{1,1}   = 'min(';
str2type{2,1}   = 'max(';

str2type{1,2}   = ')';
str2type{2,2}   = ')';

txtFinal{1} = '';
txtFinal{2} = '';

for mm = 1:2
    
    for nn = 1:ix
        txtFinal{mm} = [txtFinal{mm} str2type{mm,1}];
    end
    
    txtFinal{mm} = [txtFinal{mm} 'x'];
    
    for nn = 1:ix
        txtFinal{mm} = [txtFinal{mm} str2type{mm,2}];
    end
    
    txtFinal{mm} = [txtFinal{mm} ';'];
    
end

min_val = eval(txtFinal{1});
max_val = eval(txtFinal{2});