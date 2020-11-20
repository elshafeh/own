% Function for detecting microsaccades from a time series of eye movements.
%
% Inputs:
%    EyeDeg   - Time series of eye movements
%    SAMPLING - The sampling rate of the time series of eye movements.

%
% Outputs:
%    microsaccades - Column one: Time of onset of microsaccades
%                    Column two: Time at which the microsaccdes terminate
%                    Column three: Peak velocity of microsaccades
%                    Column four: Peak amplitude of microsaccades

%
% Outputs:
%    microsaccades - Column one: Time of onset of microsaccades
%                    Column two: Time at which the microsaccdes terminate
%                    Column three: Peak velocity of microsaccades
%                    Column four: Peak amplitude of microsaccades
%                    
% Haider Riaz - haider.riaz@mail.mcgill.ca
% McIntyre Medical Building Room 1225
% Department of Physiology, McGill University
%
% Created by Haider Riaz Khan 2013.

function microsaccades = micsaccdeg(EyeDeg, SAMPLING)

N = length(EyeDeg);
v = zeros(N,3);

for k=1:N
    
    v(k,1)= EyeDeg(k,1);
    
end

for k=2:N-1
    
    
    if k>=3 & k<=N-2
        v(k,2:3) = SAMPLING/6*[EyeDeg(k+2,2)+EyeDeg(k+1,2)-EyeDeg(k-1,2)-EyeDeg(k-2,2) EyeDeg(k+2,3)+EyeDeg(k+1,3)-EyeDeg(k-1,3)-EyeDeg(k-2,3)];
    end
end

vel = sqrt(v(:,2).^2 + v(:,3).^2);

i=1;
onset = [];
finish = [];
vpeak = [];
ampl = [];
while(i<=N)
    j=1;
    
    
    if vel(i) >=8
        
        while(vel(i+j) >= 8)
            
            j = j + 1;
            
        end
        j = j-1;
        
        if j>=5 && j<=150
            onset = vertcat(onset,i);
            finish = vertcat(finish , (j+i));
            vpeak = vertcat(vpeak, max(vel(i: (j+i))));% peak velocity
            ampl = vertcat(ampl,sqrt( (EyeDeg(i,2)-EyeDeg(i+j,2))^2 + (EyeDeg(i,3)-EyeDeg(j+i,3))^2 ));  % amplitude
            i = i + j + 10;
        else
            
            i = i + j + 1;
            
        end
    else
        i = i + 1;
    end
    
    
end


microsaccades = [onset , finish , vpeak , ampl];

end