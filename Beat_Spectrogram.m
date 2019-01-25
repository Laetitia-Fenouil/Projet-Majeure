function [BPM] = Beat_Spectrogram(y_stereo, Fs)

%% Lecture de la musique
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
    [T, B, Beat] = Beat_Spectrum(data(:,k+1),Fs, N, Beats);
    spectrogram = [spectrogram, B'];
    Beats = [Beats, Beat];
end
Beats = round(Beats);

%Trouve le BPM de la musique
Beats_repetition = [];
Beats_repetition(:,1) = unique(Beats);
Beats_repetition(:,2) = zeros(length(unique(Beats)),1);
for i = 1:length(Beats_repetition)
    for j = 1:length(Beats)
        if Beats(j) == Beats_repetition(i,1)
            Beats_repetition(i,2) = Beats_repetition(i,2) + 1;
        end
    end
end
[val,ind] = max(Beats_repetition(:,2));
BPM = Beats_repetition(ind,1);

end