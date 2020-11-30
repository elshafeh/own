function x=wind(srate,wdms,x);
% srate in Hz, gate duration in ms, vector.
npts=size(x);
npts=npts(2);
if(srate==48828)
   wds= round(2*wdms/1000 * srate);
else
   wds= 2*wdms/1000 * srate;
end
w=linspace(-1*(pi/2),1.5*pi,wds);
w=(sin(w)+1)/2;
x(1:round(wds/2))=x(1:round(wds/2)).*w(1:round(wds/2));
if(srate==48828)
   x(npts-round(wds/2)+1:npts)=x(npts-round(wds/2)+1:npts).*w(round(wds/2):wds);
else
   x(npts-round(wds/2)+1:npts)=x(npts-round(wds/2)+1:npts).*w(round(wds/2)+1:wds);
end


