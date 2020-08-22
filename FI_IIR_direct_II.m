% Fixed-point realizacija FIR filtra

function y = FI_IIR_direct_II(b, a, x)
    %% fi_params parametri koje gadjamo prema duzinama ulaza
   
    fi_params = struct('OUT_SIGNAL_BITLENGTH', x.WordLength , 'OUT_SIGNAL_FRAC', x.FractionLength);
    FixedPointAttributes = fimath( 'RoundingMethod', 'Floor', 'OverflowAction', 'Saturate', 'ProductMode', 'SpecifyPrecision', 'ProductWordLength', fi_params.OUT_SIGNAL_BITLENGTH , 'ProductFractionLength', fi_params.OUT_SIGNAL_FRAC, 'SumMode', 'SpecifyPrecision', 'SumWordLength', fi_params.OUT_SIGNAL_BITLENGTH, 'SumFractionLength', fi_params.OUT_SIGNAL_FRAC );
    
    %% Definisimo pomocne promenljive slicno kao u originalnoj realizaciji, argument '1' oznacava da je broj signed
    delay = fi(zeros(max(length(a)-1, length(b)-1), 1), 1, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes); 
    a_temp = fi([a, zeros(1, length(delay)-length(a)+1)], 1, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes); 
    b_temp = fi([b, zeros(1, length(delay)-length(b)+1)], 1, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes);    
    
    %a_temp = fi([a, zeros(1, length(delay)-length(a)+1)], a.Signed, a.WordLength, a.FractionLength, FixedPointAttributes); 
	%b_temp = fi([b, zeros(1, length(delay)-length(b)+1)], b.Signed, b.WordLength, b.FractionLength, FixedPointAttributes); 
    x_temp = fi(x, x.Signed, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes);
    
    %% Definisemo x i y
    y = fi(zeros(1, length(x)), 1, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes);
    % x_temp = fi(x, 1, fi_params.OUT_SIGNAL_BITLENGTH, fi_params.OUT_SIGNAL_FRAC, FixedPointAttributes);
    
    %% A, B I X SE NE RACUNAJU OVDE VEC U GLAVNOM PROGRAMU!!
    
    %% Na dalje radimo identicno
    for i = 1:length(x_temp)
        % delay vektor se mnozi sa -a (svi sem 'nezakasnjenog' clana i 
        % dodaje na x(i).
        delay_new = x_temp(i) - a_temp(2:end)*delay; % 'leva strana' seme
        % sve sto smo sabrali sa x(i) mnozimo sa b_0 dok zakasnjene delove
        % signala mnozimo sa delay i sve saljemo u y(i)
        y(i) = delay_new*b_temp(1) + b_temp(2:end)*delay; 
        % prebacujemo delay_new na delay(_old) da bismo nastavili dalje
        delay = [delay_new; delay(1:end-1)];
    end
end