function [y, bmax] = FI_IIR_direct_II_cascade(b, a, x)
    %% Koristicemo tf2sos funkciju koja je zaduzena za prebacivanje transfer funkcije u niz funkcija drugog reda
    % sos predstavlja Lx6 matricu gde ita vrsta sadrzi b0i b1i b2i 1 a1i
    % a21
    
    %% FIXED POINT
    B = 64;
    WHOLE = ceil(log2(max(abs(a))));
    FRAC = B - WHOLE + 1;
    
    fi_params = struct('OUT_SIGNAL_BITLENGTH', 2*B + 1, 'OUT_SIGNAL_FRAC', 2*FRAC);
    FixedPointAttributes = fimath( 'RoundingMethod', 'Floor', 'OverflowAction', 'Saturate', 'ProductMode', 'SpecifyPrecision', 'ProductWordLength', 2*fi_params.OUT_SIGNAL_BITLENGTH , 'ProductFractionLength', 2*fi_params.OUT_SIGNAL_FRAC, 'SumMode', 'SpecifyPrecision', 'SumWordLength', 2*fi_params.OUT_SIGNAL_BITLENGTH, 'SumFractionLength', 2*fi_params.OUT_SIGNAL_FRAC );
    
    %% FILTARSKA FUNKCIJA
    [sos, g] = tf2sos(b, a);  
    n = size(sos);   
    
    x = fi(x, true, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes);
    y_temp = x;
    
    Bmax = 0;
    
    for i=1:n(1)
        FI_b = fi(sos(i, 1:3), true, B+1, FRAC, FixedPointAttributes); 
        FI_a = fi(sos(i, 4:6), true, B+1, FRAC, FixedPointAttributes); 
        
        B_temp = B;
        FRAC_temp = FRAC; 
        
        while(max(abs(roots(double(FI_a)))) <= 1)
            B_temp = B_temp-1;
            FRAC_temp = FRAC_temp-1;

            fi_params = struct('OUT_SIGNAL_BITLENGTH', B_temp + 1, 'FILTER_COEFITIENTS_FRAC', FRAC_temp, 'SIGNAL_BITLENGTH', 64, 'SIGNAL_FRAC', 32);

            FI_b = fi ( sos(i, 1:3) , true , fi_params.OUT_SIGNAL_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
            FI_a = fi ( sos(i, 4:6) , true , fi_params.OUT_SIGNAL_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
        end
        
        B_temp = B_temp + 3;
        FRAC_temp = FRAC_temp + 3; % dodali smo 3 bita da lici na prethodnu realizaciju
        
        fi_params = struct('OUT_SIGNAL_BITLENGTH', B_temp + 1, 'FILTER_COEFITIENTS_FRAC', FRAC_temp, 'SIGNAL_BITLENGTH', 64, 'SIGNAL_FRAC', 32);
        
        FI_b = fi ( sos(i, 1:3) , true , fi_params.OUT_SIGNAL_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
        FI_a = fi ( sos(i, 4:6) , true , fi_params.OUT_SIGNAL_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
        
        y_temp = FI_IIR_direct_II(FI_b, FI_a, y_temp); % probaj sa IIR_direct_II
        
        if (B_temp > Bmax)
            Bmax = B_temp;
        end
    end
    
    y = g*y_temp;
    bmax = Bmax;
end