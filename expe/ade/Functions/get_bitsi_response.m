function [RT,response_button] = get_bitsi_response(P)

% this captures responses from response device in DCCN behavioral cubicles
% and MEG room

% global adeBitsi

flag                      = 0;
P.bitsi.clearResponses();

% while flag == 0

t_report                  = GetSecs;
[b_button,b_time]         = P.bitsi.getResponse(60*60,1);
list_bitsi                = [97 98 99 100];
response_button           = find(list_bitsi == b_button);

RT                        = b_time-t_report; % record reaction time 'if ever it's useful :)';
    
%     if isempty(response_button)
%         flag = 0;
%     else
%         flag = 1;
%     end
%     
% end