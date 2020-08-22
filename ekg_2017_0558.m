% Filtriranje EKG signala

%% SETUP
ecg = load('ecg_corrupted.mat');
for (i=1:length(ecg.val))
    ecg_signal(i) = ecg.val(i);
end

set(0,'defaulttextinterpreter','latex')

fs = 360; 
Ts = 1/fs;
t = Ts:Ts:length(ecg_signal)*Ts;

t1 = Ts:Ts:length(ecg_signal)*Ts/3; % smanujemo duzinu signala da bi se 
                                    % bolje video efekat powerline noise 
                                    % filtriranja.
                                    % naravno, filtrira se ceo signal
ecg_shortened = ecg_signal(1:length(ecg_signal)/3); 

%% FILTRIRANJE

[coeff_b, coeff_a] = baseline_drift_filter(360, 0.4, 1, 30, 0.5);
ecg_baseline_filtered = filter(coeff_b, coeff_a, ecg_signal);

[coeff_b, coeff_a] = power_line_noise_filter(360, 60, 40, 0.5);
ecg_full_filtered = filter(coeff_b, coeff_a, ecg_baseline_filtered);
ecg_full_filtered_shortened = ecg_full_filtered(1:length(ecg_full_filtered)/3); 

%% PRIKAZ REZULTATA

figure('DefaultAxesFontSize', 15)
plot(t,ecg_signal),title('Originalni EKG signal'),
xlabel('t [s]'),ylabel('Vrednost [mV]'), xlim([0 17]);
figure('DefaultAxesFontSize', 15)
plot(t1,ecg_shortened),title('Uvelicani originalni EKG signal'),
xlabel('t [s]'),ylabel('Vrednost [mV]'), xlim([0 5.5]);
figure('DefaultAxesFontSize', 15)
plot(t,ecg_baseline_filtered),title('EKG signal filtriran baseline drift filtrom'),
xlabel('t [s]'),ylabel('Vrednost [mV]'), xlim([0 17]);
figure('DefaultAxesFontSize', 15)
plot(t1,ecg_full_filtered_shortened),title('EKG signal filtriran baseline drift i powerline noise filtrima'),
xlabel('t [s]'),ylabel('Vrednost [mV]'), xlim([0 5.5]);

%% KARAKTERISTIKE BASELINE DRIFT FILTRA

[coeff_b, coeff_a] = baseline_drift_filter(360, 0.4, 1, 30, 0.5);
[h_digital, w_digital] = freqz(coeff_b, coeff_a, 100000); % frekvencijski odziv
H_digital = abs(h_digital);
f_digital = fs*w_digital/(2*pi);

figure('DefaultAxesFontSize', 15) % amplitudska i fazna karakteristika
semilogx(f_digital,20*log10(H_digital),'LineWidth',2),title('Amplitudska karakteristika baseline drift filtra'),
xlabel('f [Hz]'),ylabel('20log_{10}|H_{digital}|'), grid on, hold on;
x0 = [1 10]; y0 = [-0.5 0.5]; x1 = [1 1]; y1 = [-0.5 0]; x2 = [0.4 0.4/10]; y2 = [-30 -30]; x3 = [0.4 0.4]; y3 = [-30 -60];
plot(x0, y0, 'r', 'LineWidth', 1.5); hold on;
plot(x1, y1, 'r', 'LineWidth', 1.5); hold on;
plot(x2, y2, 'r', 'LineWidth', 1.5); hold on;
plot(x3, y3, 'r', 'LineWidth', 1.5); hold off;
figure('DefaultAxesFontSize', 15)
semilogx(f_digital,angle(h_digital),'LineWidth',2),title('Fazna karakteristika baseline drift filtra'),
xlabel('f [Hz]'),ylabel('arg(h) [rad]'), grid on;

figure('DefaultAxesFontSize', 15) % raspored nula i polova
zplane(coeff_b, coeff_a), title('Raspored nula i polova baseline drift filtra'), xlabel('Re(s)'), ylabel('Im(s)'), zgrid; 

%% KARAKTERISTIKE POWER LINE NOISE FILTRA 

[coeff_b, coeff_a] = power_line_noise_filter(360, 60, 40, 0.5);
[h_digital, w_digital] = freqz(coeff_b, coeff_a, 100000);
H_digital = abs(h_digital);
f_digital = fs*w_digital/(2*pi);

figure('DefaultAxesFontSize', 15) % amplitudska i fazna karakteristika
semilogx(f_digital,20*log10(H_digital),'LineWidth',2),title('Amplitudska karakteristika powerline noise filtra')
xlabel('f [Hz]'),ylabel('20log_{10}|H_{digital}|','interpreter','latex'), grid on, hold on;

fs=360; fc=60; Aa=40; Ap=0.5; % 
fp1=(fc-2); fa1=(fc-0.5); fp2=(fc+2);  fa2=(fc+0.5);    
x0=[fp1/10 fp1];    y0=[-Ap -Ap];
x1=[fp1 fp1];       y1=[-Ap 0];
x2=[fa1 fa2];       y2=[-Aa -Aa];
x3=[fa1 fa1];       y3=[-Aa -2*Aa];
x4=[fa2 fa2]; 
x5=[fp2 fp2*10];
x6=[fp2 fp2];

plot(x0, y0, 'r', 'LineWidth', 1.5); hold on;
plot(x1, y1, 'r', 'LineWidth', 1.5); hold on;
plot(x2, y2, 'r', 'LineWidth', 1.5); hold on;
plot(x3, y3, 'r', 'LineWidth', 1.5); hold on;
plot(x4, y3, 'r', 'LineWidth', 1.5); hold on;
plot(x5, y0, 'r', 'LineWidth', 1.5); hold off;
figure('DefaultAxesFontSize', 15)
semilogx(f_digital,angle(h_digital),'LineWidth',2),title('Fazna karakteristika powerline noise filtra')
xlabel('f [Hz]'),ylabel('arg(h) [rad]'), grid on;

figure('DefaultAxesFontSize', 15) % raspored nula i polova
zplane(coeff_b, coeff_a), title('Raspored nula i polova powerline noise filtra'), xlabel('Re(s)'), ylabel('Im(s)'), zgrid; 
ax.XAxis.FontSize = 15;
ax.YAxis.FontSize = 24;
