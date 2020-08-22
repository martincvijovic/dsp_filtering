% Kajzerova aproksimacija
% FIR low pass filter


function [hd, N] = keiser_low_pass_filter(fp, fa, Ap, Aa, fs)    

    Wp = 2*pi*fp/fs;
    Wa = 2*pi*fa/fs;
    
    %% parametri kajzerovog NF FIR filtra
    Bt = (Wa - Wp);
    Wc = (Wa + Wp)/2; % centralna ucestanost
    
    
    %% ostali parametri
    delta = min((10^(0.05*Ap)-1)/(10^(0.05*Ap)+1), 10^(-0.05*Aa));
    
    if (delta ~= 10^(-0.05*Aa))
        Aa = -20*log10(delta);
    end
    
    if (Aa < 21)
        beta = 0;
    elseif (Aa <= 50)
        beta = 0.5842*(Aa - 21)^(0.4) + 0.07886*(Aa - 21);
    else
        beta = 0.1102*(Aa - 8.7);
    end
    
    if (Aa <= 21)
        D = 0.9222;
    else
        D = (Aa-7.95)/14.36;
    end
    
    M = ceil((2*pi*D)/(Bt) + 1);
    
    n = -((M-1)/2):((M-1)/2);
    
    %% hd_temp je samo u NF slucaju ovakav, zavisi od HD(e^jw) idealnog
    hd_temp = sin(Wc*n)./(n*pi);    
    
    if (mod(M, 2) == 1)
        hd_temp( (M+1)/2 ) = Wc/pi;
    end
    
    hd = hd_temp.*kaiser(M, beta)';
    
    N = M-1;
end

