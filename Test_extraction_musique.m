clear all; close all; clc;

%% Récupère une musique et son path
[file,path] = uigetfile('*.mp3');

%% Lecture de la musique
[y_stereo,Fs] = audioread(file); % y=musique échantillonnée, Fs = fréquence d'échantillonnage

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Lecture de la musique
playerObj = audioplayer(y_mono,Fs);
start = playerObj.SampleRate * 10;
stop = playerObj.SampleRate * 20;
play(playerObj,[start,stop]);

%figure(1)
%plot(y_mono)

[ppx,w] = periodogram(y_mono);%abs(fft(y_mono)).^2;
%figure(2)
%plot(w,10*log10(ppx));

n = ceil((length(y_mono)/441));
data = zeros(441,n); % n vecteurs de 441 valeurs
for i = 1:n-1
    data(:,i) = y_mono([1:441]+(i-1)*441);
end
nb_zeros = 441-length(y_mono([441*(n-1)+1:end]));
add_to_data = [y_mono([441*(n-1)+1:end]);zeros(nb_zeros,1)];
data(:,n) = add_to_data;
