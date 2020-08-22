function y = IIR_direct_II(b, a, x)

delay = zeros(max(length(a)-1, length(b)-1), 1); % idemo od x1 do xn
% imamo N-1 delay elemenata, oduzimamo 1 za potrebe duzine niza
% a taj 1 dodajemo u a_temp i b_temp
% koji su zapravo a i b izjednaceni na istu duzinu (manji dopunjen nulama)
a_temp = [a, zeros(1, length(delay)-length(a)+1)];
b_temp = [b, zeros(1, length(delay)-length(b)+1)];

y = zeros(1, length(x));
for i = 1:length(x)
    % delay vektor se mnozi sa -a (svi sem 'nezakasnjenog' clana i 
    % dodaje na x(i).
	delay_new = x(i) - a_temp(2:end)*delay; % 'leva strana' seme
    % sve sto smo sabrali sa x(i) mnozimo sa b_0 dok zakasnjene delove
    % signala mnozimo sa delay i sve saljemo u y(i)
	y(i) = delay_new*b_temp(1) + b_temp(2:end)*delay; 
    % prebacujemo delay_new na delay(_old) da bismo nastavili dalje
	delay = [delay_new; delay(1:end-1)];
end
end

