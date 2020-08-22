% Filtriranje nepoznatog zvucnog signala
% 2 NEPROPUSNIKA OPSEGA I 1 NISKOFREKVENTNI FILTAR 

% Font je preveliki na samim plotovima ali je dobar u izvestaju

set(0,'defaulttextinterpreter','latex') % za potrebe izvestaja

[sound_corrupted, fs] = audioread('sound_corrupted.wav');
figure('DefaultAxesFontSize', 20)
spectrogram(sound_corrupted, boxcar(1024), 512, 4096, fs, 'MinTreshold', -120, 'yaxis'),title('Spektrogram originalnog zvucnog signala'), xlabel('t [s]');

%% PRVI FILTER : LOW PASS

[fir_filter, N] = keiser_low_pass_filter(5000, 5200, 1, 60, fs);
sound_filtered = filter(fir_filter, 1, sound_corrupted);
figure('DefaultAxesFontSize', 20)
spectrogram(sound_filtered, boxcar(1024), 512, 4096, fs, 'MinTreshold', -180, 'yaxis'),title('Spektrogram nakon prvog, NF filtriranja'), xlabel('t [s]');

%% DRUGI I TRECI  FILTAR : BAND STOP

[fir_filter, N] = keiser_band_stop_filter(1200, 1700, 1300, 1600, 1, 60, fs); 
sound_filtered = filter(fir_filter, 1, sound_filtered);

[fir_filter, N] = keiser_band_stop_filter(2400, 3100, 2500, 3000, 1, 60, fs); 
sound_filtered = filter(fir_filter, 1, sound_filtered);

%% SPEKTROGRAM NAKON FILTRIRANJA

figure('DefaultAxesFontSize', 20)
spectrogram(sound_filtered, boxcar(1024), 512, 4096, fs, 'MinTreshold', -180, 'yaxis'),title('Spektrogram nakon NF i 2 NO filtriranja'), xlabel('t [s]');

audiowrite('out_signal_2017_0558.wav', sound_filtered, fs);

%% KARAKTERISTIKE LOW PASS FILTRA

[low_pass, N] = keiser_low_pass_filter(5000, 5200, 1, 60, fs);
[h_digital, w_digital] = freqz(low_pass, 1, 100000);
H_digital = abs(h_digital);
f_digital = fs*w_digital/(2*pi);

figure('DefaultAxesFontSize', 15) 
semilogx(f_digital,20*log10(H_digital),'LineWidth',2)
title('Amplitudska karakteristika NF filtra'),
xlabel('f [Hz]'),ylabel('20log_{10}|H_{digital}|'), grid on, hold on;
x0 = [500 5000]; y0 = [-1 -1];
x1 = [5000 5000]; y1 = [-1 -10];
x2 = [52000 5200]; y2 = [-60 -60];
x3 = [5200 5200]; y3 = [-60 -120];
plot(x0, y0, 'r', 'LineWidth',1.5), hold on;
plot(x1, y1, 'r', 'LineWidth',1.5), hold on;
plot(x2, y2, 'r', 'LineWidth',1.5), hold on;
plot(x3, y3, 'r', 'LineWidth',1.5), hold on;


%% KARAKTERISTIKE BAND STOP FILTRA 

[notch, N] = keiser_band_stop_filter(1200, 1700, 1300, 1600, 1, 60, fs);
[h_digital, w_digital] = freqz(notch, 1, 100000);
H_digital = abs(h_digital);
f_digital = fs*w_digital/(2*pi);

figure('DefaultAxesFontSize', 15) 
semilogx(f_digital,20*log10(H_digital),'LineWidth',2)
title('Amplitudska karakteristika NO filtra'),
xlabel('f [Hz]'),ylabel('20log_{10}|H_{digital}|'), grid on, hold on;
x0 = [120 1200]; y0 = [-1 -1];
x1 = [1200 1200]; y1 = [-1 -600];
x2 = [1600 1600]; y2 = [-60 0];
x3 = [1300 1300]; y3 = [-60 0];
x4 = [1700 17000]; y4 = [-1 -1];
x5 = [1700 1700]; y5 = [-1 -600];
x6 = [1300 1600]; y6 = [-60 -60];
plot(x0, y0, 'r', 'LineWidth',1.5), hold on;
plot(x1, y1, 'r', 'LineWidth',1.5), hold on;
plot(x2, y2, 'r', 'LineWidth',1.5), hold on;
plot(x3, y3, 'r', 'LineWidth',1.5), hold on;
plot(x4, y4, 'r', 'LineWidth',1.5), hold on;
plot(x5, y5, 'r', 'LineWidth',1.5), hold on;
plot(x6, y6, 'r', 'LineWidth',1.5), hold on;
