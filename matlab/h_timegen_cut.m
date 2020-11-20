function scores = h_timegen_cut(scores)

for x = 1:size(scores,1)
    for y = 1:size(scores,2)
        
        if x == y
            scores(x,y)             = NaN;
        end
        
        for n = 1:size(scores,1)
            if n > x
                scores(x,n)         = NaN;
            end
        end
        
    end
end