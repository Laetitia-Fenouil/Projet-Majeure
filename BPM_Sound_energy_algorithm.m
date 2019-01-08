clear all; close all; clc;

%% Récupère une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique échantillonnée, Fs = fréquence d'échantillonnage

%% Implement beat detection as described in Marco Ziccardi's article "Beat Detection Algorithms (Part 1)" (05/28/2015)
%  First method : Sound energy algorithm
[L,C] = size(y_stereo);
% Number of blocks of 1024 samples
NSamples = 1024;
NBlocks = (L-mod(L,NSamples))/NSamples;
EBlocks = zeros(NBlocks,1); %%Energy of each block

% For each block, compute the mean energy
for i=1:NBlocks
    range = [1+(i-1)*NSamples:i*NSamples];
    EBlocks(i,:) = sum(y_stereo(range,1).^2 + y_stereo(range,2).^2);
end

Beats = zeros(NBlocks,1);
NWindow = 43;
for i=1:NBlocks
    % Compute a 43 blocks-long window for each block
    % if i<43 take the 43 first blocks
    window =[];
    if i<NWindow
        window = [1:NWindow];
    else
        window = [i-NWindow+1:i];
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

%% FIN DE L'ALGO

%% Tentative de mise en forme des résultats
% dérive le beat pour ne pas garder plusieurs valeurs pour un même beat
dBdt = diff(Beats);
% Prend les indice de début et fin de beat
indBegin = find(dBdt == 1);
indEnd = find(dBdt == -1);
% Garde le temps moyen du beat
Times = [];
BeatsMean = zeros(size(Beats));
T = NSamples*[0:NBlocks-1]/Fs;
for i = 1:length(indEnd)
    ind = ceil(indBegin(i) + 1 + (indEnd(i) - indBegin(i))/2);
    Times(i) = T(ind);
    BeatsMean(ind) = 1;
end
% Plot + calcul du BPM
stem(T,BeatsMean);
BPM = 60*sum(BeatsMean)/T(NBlocks-1)


%% Sortie d'un gif animé
videoFWriter = vision.VideoFileWriter


%% Résultats
% Semble peu précis et détecte des beats qui ne n'en sont pas
% Exemples de limites trouvées :
% Chansons où les battements ne sont pas forts (I Will Always Love You - Dolly Parton)
% Chansons électroniques (test avec tout l'album Discovery de Daft Punk, BPM
% supérieur à celui trouvé sur internet)
% Chanson où ça ne marche pas trop mal : Into You - Ariana Grande (Couplets
% principalement)