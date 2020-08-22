% baseline drift filter

% fs - ucestanost odabiranja
% fa - granicna ucestanost nepropusnog opsega
% fp - granicna ucestanost propusnog opsega
% Aa, Ap - odgovarajuca slabljenja u nepropusnom/propusnom opsegu (alfa_a,
% alfa_p)

% x = brojilac
% y = imenilac

function [x, y] = baseline_drift_filter(fs, fa, fp, Aa, Ap)
    %% SETUP
    wa = 2*pi*fa;
    wp = 2*pi*fp;
    
    %% PREDISTORZIJA
    wa_predistortion = 2*fs*tan(wa/fs/2);
    wp_predistortion = 2*fs*tan(wp/fs/2);
    
    %% NF prototip (ANALOGNI!) (cheb2ap - cheb 2. vrste analog prototype)
    
    finished = 0; % indikator da su gabariti zadovoljeni
    
    Aa_temp = Aa;
    Ap_temp = Ap;
    
    count = 0;
    
    while ((finished) == 0)
        count = count + 1;
        % finished = 1; % debugging
        
        %% ODREDJIVANJE PARAMETARA
        
        D = (10^(0.1*Aa_temp)-1)/(10^(0.1*Ap_temp)-1);
        k = wa_predistortion / wp_predistortion;
        N = ceil(acosh(sqrt(D))/acosh(1/k));
        
        
        [z,p,k] = cheb2ap(N, Aa_temp); 
        
        x_temp = k*poly(z);
        y_temp = poly(p);
        
        
        %% TRANSFORMACIJE
        [x_temp, y_temp] = lp2hp(x_temp, y_temp, wa_predistortion);
        [x_temp_dig, y_temp_dig] = bilinear(x_temp, y_temp, fs);
        
        %% PROVERA GABARITA
        
        % frekvencijski odziv (freqZ) -> gledamo amplitudsku karakteristiku
        H_digital = abs(freqz(x_temp_dig,y_temp_dig,100000));
        
        df = fs/200000; % 2 * broj tacaka za freqz
        index_stop = ceil(fa/df) + 1;
        index_pass = floor(fp/df) + 1;
        
        H_stopband = H_digital(1:index_stop);
        H_passband = H_digital(index_pass:length(H_digital));
        
        
        if((max(20*log10(H_stopband))<-Aa) && (min(20*log10(H_passband))>-Ap))
            finished = 1;
        else
            if(max(20*log10(H_stopband))>-Aa)
                Aa_temp = Aa_temp + 0.05;
            else
                Ap_temp = Ap_temp - 0.05;
            end
        end
    end
    
    x = x_temp_dig;
    y = y_temp_dig;
    
    % disp(count);
    
end