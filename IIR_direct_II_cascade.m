function y = IIR_direct_II_cascade(b, a, x)
    %% Koristicemo tf2sos funkciju koja je zaduzena za prebacivanje transfer funkcije u niz funkcija drugog reda
    % sos predstavlja Lx6 matricu gde ita vrsta sadrzi b0i b1i b2i 1 a1i
    % a21
    [sos, g] = tf2sos(b, a);
    
    n = size(sos);
    
    y_temp = x;
    
    for i=1:n(1)
        %num = poly(sos(i, 1:3));
        %denom = poly(sos(i, 4:6));
        y_temp = IIR_direct_II(sos(i, 1:3), sos(i, 4:6), y_temp);
    end
    y = g*y_temp;
end