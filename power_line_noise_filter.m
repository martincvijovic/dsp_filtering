% powerline noise filter (notch)

% fs - ucestanost odabiranja
% fc - centralna ucestanost (60Hz za primenu u projektu)
% Aa/Ap - odgovarajuca slabljenja u nepropusnom/propusnom opsegu

% x = brojilac
% y = imenilac

function [x, y] = power_line_noise_filter(fs, fc, Aa, Ap)
    
    % ellipap
    
    %% odredjivanje granicnih ucestanosti (dato u tekstu):
    Fp1 = (fc - 2)/fs;
    Fp2 = (fc + 2)/fs;   % propusni opseg
    
    Fa1 = (fc - 0.5)/fs;
    Fa2 = (fc + 0.5)/fs; % nepropusni opseg
    
    %% predistorzija i prebacivanje f -> w
    % u tangensu stoji w/fs/2 = 2*pi*f/fs/2 = pi*F normalizovano
    wp1 = 2*fs*tan(Fp1*pi);
    wp2 = 2*fs*tan(Fp2*pi);
    wa1 = 2*fs*tan(Fa1*pi);
    wa2 = 2*fs*tan(Fa2*pi);
    
    %% normalizovani prototip eliptickog filtra (ANALOG)
    finished = 0; % indikator da su gabariti zadovoljeni
    
    Aa_temp = Aa;
    Ap_temp = Ap;
    
    count = 0;
    
    while ((finished) == 0)
        count = count + 1;
        % finished = 1; % debugging
        
        k = (wa2-wa1)/(wp2-wp1);
        k_prim = sqrt(1-k^2);
        q0 = (1-sqrt(k_prim))/(2*(1+sqrt(k_prim)));
        D = (10^(0.1*Aa_temp)-1)/(10^(0.1*Ap_temp)-1);
        q = q0+2*q0^5+15*q0^9+150*q0^3;
        N = ceil(log10(16*D)/log10(1/q));
        
        %% transformacija i diskretizacija
        
        [z,p,k] = ellipap(N, Ap_temp, Aa_temp); 
        
        x_temp = k*poly(z);
        y_temp = poly(p);       
        
        % NF -> NOTCH -> DIGITAL
		
        [x_temp, y_temp] = lp2bs(x_temp, y_temp, sqrt(wp1*wp2), wp2-wp1);
        [x_temp_dig, y_temp_dig] = bilinear(x_temp, y_temp, fs);
        
        %% provera gabarita
        % frekvencijski odziv (freqZ) -> gledamo amplitudsku karakteristiku
		
        H_digital = abs(freqz(x_temp_dig,y_temp_dig,100000));

        df = fs/200000; 
        
        index_stop1 = ceil(Fa1/df) + 1;
        index_stop2 = floor(Fa2/df) + 1;
        index_pass1 = floor(Fp1/df) + 1;
        index_pass2 = ceil(Fp2/df) + 1;
        
        H_stopband = H_digital(index_stop1:index_stop2);
        H_passband = [H_digital(1:index_pass1)' H_digital(index_pass2:length(H_digital))'];
        
        if((max(20*log10(H_stopband))>-Aa) && (min(20*log10(H_passband))<-Ap))
            finished = 1;
        else
            if(max(20*log10(H_stopband))>-Aa)
                Aa_temp = Aa_temp + 0.05;
            else
                Ap_temp = Ap_temp - 0.05;
            end
        end
        
        %disp(count);
    end
    
    x = x_temp_dig;
    y = y_temp_dig;

end

