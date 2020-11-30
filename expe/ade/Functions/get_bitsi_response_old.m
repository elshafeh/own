function [RT,response_button]= get_bitsi_response(Info)

% this captures responses from response device in DCCN behavioral cubicles

IOPort('CloseAll');

joker           = '';
sampleFreq      = 120;
baudRate        = 115200;
specialSettings = [];
InputBufferSize = sampleFreq * 3600;

% readTimeout     = max(10 * 1/sampleFreq, 15);
% readTimeout     = min(readTimeout, 21);

readTimeout     = 21; % after this value the IOport ends the script!!

portSettings    = sprintf('%s %s BaudRate=%i InputBufferSize=%i Terminator=0 ReceiveTimeout=%f ReceiveLatency=0.0001', joker, specialSettings, baudRate, InputBufferSize, readTimeout);
myport          = IOPort('OpenSerialPort', '/dev/ttyS0', portSettings);

flag            = 0;
t_report        = GetSecs;

while flag == 0
    
    if strcmp(Info.experiment,'stair')
        list_bitsi                  = [97 100 98 99];
    else
        list_bitsi                  = [97 98 99 100];
    end
    
    [pktdata, response_time]        = IOPort('Read', myport, 1, 1);
    response_button                 = find(list_bitsi == pktdata(1));
    
    if response_button > 0
        flag = 1;
    else
        clear response_button;
    end
    
    %     if ~isempty(response_button)
    %         flag = 1;
    %     end
    
end

RT              = response_time-t_report; % record reaction time 'if ever it's useful :)';