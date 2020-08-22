%% IIR_DIRECT_II REALIZACIJA ( regularno i sa fiksnom tackom )

set(0,'defaulttextinterpreter','latex')

fs = 1000;
Ts = 1/fs;
N = 20000;
t = 0:Ts:(N-1)*Ts;

x = sin(2*pi*200*t)+sin(2*pi*100*t)+sin(2*pi*60*t);
X = abs(fft(x, 100000));

f = fs/2*linspace(0,1,100000/2+1);

%% ORIGINALNI SIGNAL I NJEGOVA AMPLITUDSKA KARAKTERISTIKA

figure('DefaultAxesFontSize', 15)
plot(t,x),title('Originalni signal, zbir sinusoida'),
xlabel('t [s]'),ylabel('Vrednost [mV]'), xlim([0 0.2]);

figure('DefaultAxesFontSize', 15)
plot(f, X(1:50001), 'LineWidth', 2),title('Amplitudska karakteristika originalnog signala'), xlim([0 fs/2]),
xlabel('f [Hz]'), ylabel('X[dB]');

%% FILTRIRANJE SIGNALA ORIGINALNIM FILTROM

[b, a] = power_line_noise_filter(fs, 60, 40, 1);

y = IIR_direct_II(b, a, x);
Y = abs(fft(y, 100000));
figure('DefaultAxesFontSize', 15)
plot(f, Y(1:50001), 'LineWidth', 2),title('Amplitudska karakteristika filtriranog signala'), xlim([0 fs/2])
xlabel('f [Hz]'), ylabel('Y[dB]');

%% REALIZACIJA SA BROJEVIMA SA FIKSNOM TACKOM

%% POTREBAN BROJ BITA DA FILTAR I DALJE OSTANE STABILAN (POLOZAJ NULA I POLOVA)

% B + 1 = 32
B = 31;
WHOLE = ceil(log2(max(abs(a))));
FRAC = B - WHOLE; 

%% DEFINISEMO MNOZENJE I SABIRANJE I PRIMENJUJEMO ARITMETIKU NA SIGNALE

FixedPointAttributes = fimath ( 'RoundingMethod', 'Floor', 'OverflowAction', 'Wrap', 'ProductMode', 'SpecifyPrecision', 'ProductWordLength', 32, 'ProductFractionLength', 30, 'SumMode', 'SpecifyPrecision', 'SumWordLength', 32, 'SumFractionLength', 30 ) ;

fi_params = struct('FILTER_COEFITIENTS_BITLENGTH', B + 1, 'FILTER_COEFITIENTS_FRAC', FRAC, 'SIGNAL_BITLENGTH', B+1, 'SIGNAL_FRAC', FRAC);

FI_b = fi ( b , true , fi_params.FILTER_COEFITIENTS_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
FI_a = fi ( a , true , fi_params.FILTER_COEFITIENTS_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);

%% RASPORED NULA I POLOVA ZA B = 31

figure('DefaultAxesFontSize', 15)
zplane(double(FI_b), double(FI_a)), title('Raspored nula i polova za B + 1 = 32'), xlabel('Re'), ylabel('Im'), zgrid;

%% SMANJUJEMO B DOK IMENILAC NE ISPADNE IZ JEDINICNOG KRUGA

while(max(abs(roots(double(FI_a)))) <= 1)
    B = B-1;
    FRAC = FRAC-1;
    
    fi_params = struct('FILTER_COEFITIENTS_BITLENGTH', B + 1, 'FILTER_COEFITIENTS_FRAC', FRAC, 'SIGNAL_BITLENGTH', 64, 'SIGNAL_FRAC', 32);
    
    FI_b = fi ( b , true , fi_params.FILTER_COEFITIENTS_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
    FI_a = fi ( a , true , fi_params.FILTER_COEFITIENTS_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
end

%% RASPORED NULA I POLOVA GRANICNO NESTABILNOG FILTRA

figure('DefaultAxesFontSize', 15)
zplane(double(FI_b), double(FI_a)), title('Nestabilan filtar za B+1 = 27'), xlabel('Re'), ylabel('Im'), zgrid;


%% RASPORED NULA I POLOVA GRANICNO STABILNOG FILTRA (dodavanje jednog bita) i filtriranje istim filtrom

B = B + 1;
FRAC = FRAC + 1;

B_SIGNAL = 36;
FRAC_SIGNAL = 32;

fi_params = struct('FILTER_COEFITIENTS_BITLENGTH', B + 1, 'FILTER_COEFITIENTS_FRAC', FRAC, 'SIGNAL_BITLENGTH', B_SIGNAL, 'SIGNAL_FRAC', FRAC_SIGNAL);
    
FI_b = fi ( b , true , fi_params.FILTER_COEFITIENTS_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
FI_a = fi ( a , true , fi_params.FILTER_COEFITIENTS_BITLENGTH , fi_params.FILTER_COEFITIENTS_FRAC, FixedPointAttributes);
FI_x = fi( x, true, fi_params.SIGNAL_BITLENGTH, fi_params.SIGNAL_FRAC, FixedPointAttributes);

figure('DefaultAxesFontSize', 15)
zplane(double(FI_b), double(FI_a)), title('Stabilan filtar za B+1 = 28'), xlabel('Re'), ylabel('Im'), zgrid;

%% BROJ BITA DA AMPLITUDSKA KARAKTERISTIKA NE ODSTUPA ZNACAJNO (rucno odredjen)
    
FI_b = fi ( b , true , 30, 22, FixedPointAttributes);
FI_a = fi ( a , true , 30, 22, FixedPointAttributes);

[h_digital, w_digital] = freqz(b, a, 10000); % frekvencijski odziv
H_digital = abs(h_digital);
f_digital = fs*w_digital/(2*pi);

[FI_h, FI_w] = freqz(double(FI_b), double(FI_a), 10000);
FI_H = abs(FI_h);

figure('DefaultAxesFontSize', 15) % amplitudska i fazna karakteristika
semilogx(f_digital,20*log10(H_digital),'LineWidth',2),title('Amplitudska karakteristika originalnog i FI filtra'),
xlabel('f [Hz]'),ylabel('20log_{10}|H_{digital}|'), grid on, hold on;
semilogx(f_digital, 20*log10(FI_H),'r','LineWidth',2),
legend('Originalni filtar', 'FI filtar');

%% ULAZNI SIGNAL, FIXED POINT, DOUBLE POINT I RAZLIKA
% Zbog specificnog izvestaja imacemo 4 male umesto jedne velike slike

B_SIGNAL = 32;
WHOLE_SIGNAL = ceil(max(abs(x)));
FRAC_SIGNAL = B_SIGNAL - WHOLE_SIGNAL + 1;

FI_x = fi(x, true, 64, 36, FixedPointAttributes);
y = FI_IIR_direct_II(FI_b, FI_a, FI_x);
y_double = IIR_direct_II(b, a, x);

figure('DefaultAxesFontSize', 15)
plot(t,x),title('Originalni signal, zbir sinusoida'),
xlabel('t [s]'),ylabel('Vrednost [V]'), xlim([0 0.2]);

figure('DefaultAxesFontSize', 15)
plot(t,y),title('Signal filtriran sa fixed-point tacnoscu'),
xlabel('t [s]'),ylabel('Vrednost [V]'), xlim([0 0.2]);

figure('DefaultAxesFontSize', 15)
plot(t,y_double),title('Signal filtriran sa double-point tacnoscu'),
xlabel('t [s]'),ylabel('Vrednost [V]'), xlim([0 0.2]);

figure('DefaultAxesFontSize', 15)
plot(t,y_double - y),title('Razlika'),
xlabel('t [s]'),ylabel('Vrednost [V]'), xlim([0 0.2]);


