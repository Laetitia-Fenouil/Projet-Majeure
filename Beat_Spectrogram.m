clear all; close all; clc;

%% R�cup�re une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

tic;
%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Divise la chanson en extrait de N secondes
N = 5;
data = [];
i = 0;
while((i+N)*Fs < length(y_mono))
    range = [i*Fs + 1: (i+N)*Fs];
    data(:,(i+1)) = y_mono(range,:);
    i = i +1;
end
T_song = [0:5:i-1];
spectrogram = [];
Beats = [];
for k = T_song
    
    [T, B, Beat] = Beat_Spectrum(data(:,k+1),Fs, N);
    spectrogram = [spectrogram, B'];
    Beats = [Beats, Beat];
end

figure(1)
imagesc(T_song,T, spectrogram)

time = toc