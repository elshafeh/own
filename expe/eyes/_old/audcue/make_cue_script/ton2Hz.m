% fonction en demi-ton
function f=ton2Hz(F0,ton);

a=2^(ton/12);
f=1.0;
% if ton >= 1
%     for i=1:ton
%        f=f*a;
%     end;
% % else
%     for i=ton:1
%        f=f*a;
%     end;
% end
f=a*F0;


