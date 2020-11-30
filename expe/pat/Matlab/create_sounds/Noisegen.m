function s=noisegen(fmin, fmax, fs, Tn);

rand('state',sum(100*clock));
N=round(fs*Tn);
df=1/Tn; 
% creation du bruit
i1=round(fmin/df);
i2=round(fmax/df);
Y=zeros(1,N);
for ii=i1:i2
   phi = rand*2*pi;
   Y(ii)= complex(cos(phi), sin(phi));
   Y(N+2-ii)= complex(cos(phi), -sin(phi));
end;
S0=ifft(Y);
clear Y;
coef=N/sqrt(2*(i2-i1+1));
s=real(S0*coef);




 