%% getbeat
% y_stereo : données audio sur 2 canaux
% Fs : Fréquence d'échantillonage de y_stereo
% dt : durée entre deux mesures (en seconde)
%
% B : vecteur contenant les amplitudes des battements
function [B] = getbeat(y_stereo, Fs, dt)

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
NSamples = floor(Fs*dt);
NBlocks = floor(L/NSamples)+1;
EBlocks = zeros(NBlocks,1); %%Energy of each block

% For each block, compute the mean energy
for i=1:NBlocks-1
    range = [1+(i-1)*NSamples:i*NSamples];
    EBlocks(i,:) = sum(y_stereo_filtre(range,1).^2 + y_stereo_filtre(range,2).^2);
end
range = [range(end)+1,L];
EBlocks(i+1,:) = sum(y_stereo_filtre(range,1).^2 + y_stereo_filtre(range,2).^2);

Beats = zeros(NBlocks,1);
BeatsDetect = zeros(NBlocks,1);
NWindow = floor(Fs/NSamples);
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
if(indEnd(1) < indBegin(1))
    indEnd = indEnd(2:end);
end
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

B = BeatsThresh;

end