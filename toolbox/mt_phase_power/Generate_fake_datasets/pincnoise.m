function ans=pincnoise(n0)
%--- Generate 1/f noise. ---
%--- Fast result for n=2^m ---
n=2*ceil(n0/2);
fnoise=exp(2*pi*i*rand(n/2,1)).*1./(1:(n/2-1)/(n/2-1):n/2)';
fnoise(n/2)=real(fnoise(n/2));
f2=fnoise(1:n/2-1);
f3=conj(flipdim(f2,1));
f4=cat(1,[0],fnoise,f3);
ans=real(ifft(f4,n));

ans=ans(1:n0);