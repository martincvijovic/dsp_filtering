% Kajzerova aproksimacija
% FIR Band stop filter

function [hd, N] = keiser_band_stop_filter(fp1, fp2, fa1, fa2, Ap, Aa, fs)  
    
    %% jako slican kod kajzerovom NF-u, par stvari se menja

    Wp1 = 2*pi*fp1/fs;
    Wp2 = 2*pi*fp2/fs;
    Wa1 = 2*pi*fa1/fs;
    Wa2 = 2*pi*fa2/fs;
    
    %% parametri kajzerovog NF FIR filtra
    Bt = min((Wa1 - Wp1),(Wp2 - Wa2));
    
    Wc1 = Wp1 + Bt/2;
    Wc2 = Wp2 - Bt/2; % dve 'centralne' ucestanosti (opseg koji filtriramo)
    
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
    
    %% REALIZACIJA 
    
    % ovaj izraz se lako dobija iz furijeovog reda idealne funkcije prenosa
    % za band stop
    hd_temp = (-sin(n*Wc2)+sin(n*Wc1)+sin(n*pi))./(n*pi);    
    
    if (mod(M, 2) == 1)
        hd_temp( (M+1)/2 ) = (Wc1-Wc2)/pi + 1;
    end
    
    hd = hd_temp.*kaiser(M, beta)';
    
    N = M-1;
end
