function [p,noiselevel] =signplf(N,sig)

runs = 1000;

for j=1:runs 
    ang = 2.0*pi*rand(N,1);
    w(j) = abs((sum(cos(ang) + 1i*sin(ang))))/N; 
end

noiselevel = mean(w); 
w = sort(w);
%hist(w)
p = w(floor(runs*(1-sig)));
