clear all; close all; clc;
%% TODO METTRE SOUS FORME DE FONCTION
%% IMPLEMENTER LA SELECTION RANDOM DE L'EXTRAIT

%% Récupère une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique échantillonnée, Fs = fréquence d'échantillonnage

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Calcul du spectrogramme
n = 128*0.02*Fs;
range = [n+1:2*n];
data = y_mono(range);
nfft = 254;
Nx = length(data);
nsc = floor(2*Nx/129);
nov = floor(nsc/2);

[s,f,t] = spectrogram(data,hamming(nsc), nov, nfft, Fs, 'yaxis');

%% Mise en forme de l'image
image = flip(10*log10(abs(s)));
image = image - min(min(image));
image = image/max(max(image));

%% Creation du fichier
C = strsplit(file,'.');
imvec = image(:);
imagefile = '';
for i = 1:length(C) - 1
    imagefile = strcat(imagefile,char(C(i)));
    imagefile = strcat(imagefile,'.');
end
imwrite(image, strcat(imagefile,'png'))
