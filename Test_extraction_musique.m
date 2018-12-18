clear all; close all; clc;

%% Récupère une musique et son path
%[file,path] = uigetfile('*.mp3');
file = '01 Panama.mp3';
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
for i = 1:n
    [ppx2(:,i),f] = pwelch(data(:,i),441,200,441,Fs,'onesided','power');
    y = [y;ppx2(:,i)];
    [M, I] = max(ppx2(:,i));
    result_f(i) = f(I);
    result_A(i) = M;
end

% figure(2)
% plot(f,10*log10(ppx2(:,23)));
% xlabel('Frequency (Hz)')
% ylabel('Magnitude (dB)')
% grid

figure(1)
plot(result_f);
figure(2)
plot(result_A)

audiowrite('our_song.wav',y,Fs/2);