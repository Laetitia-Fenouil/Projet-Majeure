clear all; close all; clc;

%% Récupère une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique échantillonnée, Fs = fréquence d'échantillonnage

%% Implement beat detection as described in Marco Ziccardi's article "Beat Detection Algorithms (Part 1)" (05/28/2015)
%  Second method : Low Pass Filter Algorithm
