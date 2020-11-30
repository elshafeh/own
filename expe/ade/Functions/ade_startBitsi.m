function P = ade_startBitsi(P)

if IsLinux
    
    try
        b = Bitsi('/dev/ttyS0');
        fclose(instrfind);
    catch
        fclose(instrfind);
    end
    
    P.bitsi = Bitsi('/dev/ttyS0');
    
end