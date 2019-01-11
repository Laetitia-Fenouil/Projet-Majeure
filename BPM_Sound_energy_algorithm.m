clear all; close all; clc;

%% R�cup�re une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage

%% Filtrage du morceau
order = 6;
fc = 400;
[b, a] = butter(order,fc/(Fs/2));
% Apply the Butterworth filter.
y_stereo_filtre = filter(b, a, y_stereo);

%% Implement beat detection as described in Marco Ziccardi's article "Beat Detection Algorithms (Part 1)" (05/28/2015)
%  First method : Sound energy algorithm
[L,C] = size(y_stereo_filtre);
% Number of blocks of 1024 samples
NSamples = 1024;
NBlocks = (L-mod(L,NSamples))/NSamples;
EBlocks = zeros(NBlocks,1); %%Energy of each block

% For each block, compute the mean energy
for i=1:NBlocks
    range = [1+(i-1)*NSamples:i*NSamples];
    EBlocks(i,:) = sum(y_stereo_filtre(range,1).^2 + y_stereo_filtre(range,2).^2);
end

Beats = zeros(NBlocks,1);
BeatsDetect = zeros(NBlocks,1);
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
       Beats(i) = mean(EW); 
       BeatsDetect(i) = 1;
    else
        Beats(i) = 0;
        BeatsDetect(i) = 0;
    end
end
figure(1)
T = NSamples*[0:NBlocks-1]/Fs;
plot(T, Beats)

%% FIN DE L'ALGO

%% Tentative de mise en forme des r�sultats
% d�rive le beat pour ne pas garder plusieurs valeurs pour un m�me beat
dBdt = diff(BeatsDetect);
if(dBdt(1)==-1)
    dBdt(1) = 0;
end
% Prend les indice de d�but et fin de beat
indBegin = find(dBdt>0);
indEnd = find(dBdt<0);
indBegin = indBegin + 1;
% Garde le temps moyen du beat
MeanDetectedAmp = mean(Beats(find(Beats ~= 0)));
BeatsMean = zeros(size(Beats));
BeatsThresh = zeros(size(Beats));
BeatsMeanThresh = zeros(size(Beats));
for i = 1:length(indEnd)
    range = [indBegin(i):indEnd(i)];
    indMiddle = round((indEnd(i)+indBegin(i))/2);
    BeatsMean(indMiddle) = max(Beats(range));
    if(BeatsMean(indMiddle) > 0.7*MeanDetectedAmp)
        BeatsThresh(range) = Beats(range);
        BeatsMeanThresh(indMiddle) = BeatsMean(indMiddle);
    end
end
% Plot + calcul du BPM
figure(2)
subplot(211)
stem(T, BeatsMean);
BPM = 60*sum(BeatsMean)/T(NBlocks-1)

subplot(212)
stem(T, BeatsMeanThresh);

figure(3)
plot(T,BeatsThresh)
%% R�sultats
% Semble peu pr�cis et d�tecte des beats qui ne n'en sont pas
% Exemples de limites trouv�es :
% Chansons o� les battements ne sont pas forts (I Will Always Love You - Dolly Parton)
% Chansons �lectroniques (test avec tout l'album Discovery de Daft Punk, BPM
% sup�rieur � celui trouv� sur internet)
% Chanson o� �a ne marche pas trop mal : Into You - Ariana Grande (Couplets
% principalement)

ind = find(BeatsThresh ~= 0);
audioBeat = zeros(size(y_stereo));
for i=1:length(ind)
    range = [1+(ind(i)-1)*NSamples:ind(i)*NSamples];
    audioBeat(range,:) = y_stereo_filtre(range,:);
end
audiowrite('beat.wav',audioBeat,Fs);
% 
% audiowrite('filter.wav',y_stereo_filtre,Fs);