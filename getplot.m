close all, clear all, clc
tic
%% R�cup�re une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage
dt = 30/1000;
sample = y_stereo([10*Fs:30*Fs],:);
Beat = getbeat(sample, Fs, dt);
T_song = [0:length(Beat) - 1]*20/(length(Beat) - 1);

figure
plot(T_song,Beat)
xlabel('Time (s)')
ylabel('Energy')
title('Beat detection')

[T, B, BPM, D] = Beat_Spectrum(sample,Fs,10,[]);
figure
plot(T,B)
xlabel('Lag time (s)')
ylabel('Beat spectrum (self-similarity in the sample)')
title('Beat spectrum')

figure,
imagesc(T+10,T+10,D)
colormap('gray')
title('Similarity matrix')
xlabel('Time (s)')
ylabel('Time (s)')

y_mono = sample(:,1)+sample(:,2);
y_mono = y_mono/2;

nwindow = floor(Fs*dt);
n = ceil((length(y_mono)/nwindow));

i = floor(rand()*(n-2) + 1);
data = y_mono([1:nwindow]+(i-1)*nwindow);
[ppx2,f] = pwelch(data ,nwindow,floor(nwindow/2),Fs,Fs,'onesided','psd');
figure
plot(f, ppx2)
xlabel('frequencies (Hz)')
ylabel('PSD')
title('Periodogram')

V = getvolume(sample, Fs, dt);
figure
plot(T_song,V)
V = movmean(V, 10);
hold on
plot(T_song,V, 'r')
hold off
xlabel('Time (s)')
ylabel('Loudness (dB)')
title('Loudness')
legend('original','smoothed')

