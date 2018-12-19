clear all; close all; clc;

%% Récupère une musique et son path
%[file,path] = uigetfile('*.mp3');
file = 'Various Artist - Student X (School 2017 OST) 학교 2017 OST.mp3';
%file = 'Maroon 5 feat. Christina Aguilera - Moves Like Jagger.mp3';

%% Lecture de la musique
[y_stereo,Fs] = audioread(file); % y=musique échantillonnée, Fs = fréquence d'échantillonnage

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Lecture de la musique
playerObj = audioplayer(y_mono,Fs);
start = playerObj.SampleRate * 0.01;
stop = playerObj.SampleRate * 10;
play(playerObj,[start,stop]);

%figure(1)
%plot(y_mono)

%% Extraction des fréquences et de leur amplitude
n = ceil((length(y_mono)/441));
data = zeros(441,n); % n vecteurs de 441 valeurs
for i = 1:n-1
    data(:,i) = y_mono([1:441]+(i-1)*441);
end
nb_zeros = 441-length(y_mono([441*(n-1)+1:end]));
add_to_data = [y_mono([441*(n-1)+1:end]);zeros(nb_zeros,1)];
data(:,n) = add_to_data;

ppx2 = [];
result_f = [];
result_A = [];
y = [];
result_f_lowpass = [];
for i = 1:n
    [ppx2(:,i),f] = pwelch(data(:,i),441,200,441,Fs,'onesided','power');
    y = [y;ppx2(:,i)];
    [M, I] = max(ppx2(:,i));
    result_f(i) = f(I);
    result_A(i) = M;
    if f(I)<500
        result_f_lowpass(i) = f(I);
    else
        result_f_lowpass(i) = 0;
    end
end

% figure(2)
% plot(f,10*log10(ppx2(:,23)));
% xlabel('Frequency (Hz)')
% ylabel('Magnitude (dB)')
% grid

figure(1)
plot(result_f);
xlabel('Time (s/100)')
ylabel('Frequency (Hz)')
figure(2)
plot(result_A)
xlabel('Time (s/100)')
ylabel('Magnitude (dB)')

audiowrite('our_song.wav',y,Fs/2);

[d,sr] = audioread('our_song.wav');
% Calculate the beat times
b = beat2(y_mono,Fs);

% result_f_lowpass = lowpass(result_f,2000);
% Fs  = 8000;                                 % Sampling Frequency (Hz)
% Fn  = Fs/2;                                 % Nyquist Frequency
% Fco =   20;                                 % Passband (Cutoff) Frequency
% Fsb =   30;                                 % Stopband Frequency
% Rp  =    1;                                 % Passband Ripple (dB)
% Rs  =   10;                                 % Stopband Ripple (dB)
% [n,Wn]  = buttord(Fco/Fn, Fsb/Fn, Rp, Rs);  % Filter Order & Wco
% [b,a]   = butter(n,Wn);                     % Lowpass Is Default Design
% [sos,g] = tf2sos(b,a);                      % Second-Order-Section For STability
% figure(3)
% freqz(sos, 2048, Fs)                         % Check Filter Performance
% result_f_lowpass = filter(b,a,result_f);
% figure(3)
% plot(result_f_lowpass);
% xlabel('Time (s/100)')
% ylabel('Frequency (Hz)')


