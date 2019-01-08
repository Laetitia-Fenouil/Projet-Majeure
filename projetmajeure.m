clear all; close all; clc;

%% Récupère une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique échantillonnée, Fs = fréquence d'échantillonnage

%% Implement beat detection as described in Marco Ziccardi's article "Beat Detection Algorithms (Part 1)" (05/28/2015)
%  First method : Sound energy algorithm
[L,C] = size(y_stereo);
% Number of blocks of 1024 samples
NBlocks = (L-mod(L,1024))/1024;
EBlocks = zeros(NBlocks,1); %%Energy of each block

% For each block, compute the mean energy
for i=1:NBlocks
    range = [1+(i-1)*1024:1024+(i-1)*1024];
    EBlocks(i,:) = sum(y_stereo(range,1).^2 + y_stereo(range,2).^2);
end

Beats = zeros(NBlocks,1);
for i=1:NBlocks
    % Compute a 43 blocks-long window for each block
    % if i<43 take the 43 first blocks
    window =[];
    if i<43
        window = [1:43];
    else
        window = [i-43+1:i];
    end
    EW = EBlocks(window);
    % Compute the C factor for which a beat is detected (if E>C?mean(E))
    C = -0.0000015*var(EW)+1.5142857;
    if(EBlocks(i) > C*mean(EW))
       Beats(i) = 1; 
    else
        Beats(i) = 0;
    end
end

dBdt = diff(Beats);
indBegin = find(dBdt == 1);
indEnd = find(dBdt == -1);
Times = [];
BeatsMean = zeros(size(Beats));
T = 1024*[0:NBlocks-1]/Fs;
for i = 1:length(indEnd)
    ind = ceil(indBegin(i) + 1 + (indEnd(i) - indBegin(i))/2);
    Times(i) = T(ind);
    BeatsMean(ind) = 1;
end
stem(T,BeatsMean);
BPM = 60*sum(BeatsMean)/T(NBlocks-1)
%plot(T,Beats);
