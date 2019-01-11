clear all; close all; clc;

%% R�cup�re une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Implement beat detection as described in Jonathan Foote's and Shingo Uchihashi's article "THE BEAT SPECTRUM: A NEW APPROACH TO RHYTHM ANALYSIS" (2001)
% 1 Audio parameterization

% Test sur 10 secondes de la chanson
range_begin = Fs*60;
range_end = Fs*65;
data = y_mono(range_begin:range_end);
t = linspace(range_begin,range_end, length(data))/Fs;
% % Filtre le signal
% fc = 300;
% order = 6;
% [b, a] = butter(order,fc/(Fs/2));
% % Apply the Butterworth filter.
% data = filter(b, a, data);

% Decoupe en fenetres de w points avec un overlap de 50%
w = 512;
nov = w/2;
ind = 1;
windowed_data = [];
while((ind+1)*nov<length(data))
    windowed_data(:,ind) = 10*log(abs(fft(data((ind-1)*nov+1:(ind+1)*nov))));
    ind = ind + 1;
end
Nw = length(windowed_data(1,:));
D = zeros(Nw);
% Calcul de la distance entre chaque fenêtre et stockage dans la matrice de
% similarite
for i=1:Nw
    for j=1:Nw
        D(i,j) = sum(windowed_data(:,i).*windowed_data(:,j))/(norm(windowed_data(:,i))*norm(windowed_data(:,j)));
        if(isnan(D(i,j)))
            D(i,j) = 0;
        end
    end
end
figure(1)
imagesc(t,t,D)
colormap('gray');
% Calcul du spectre de distance
B = zeros(1,Nw);
for i = 0:Nw-1
    ind = 1;
    Ddiag = diag(D, -i);
    B(i+1) = mean(Ddiag);
end

t_B = linspace(0,range_end-range_begin, Nw)/Fs;
figure(2)
plot(t_B,B)

B_lisse = movmean(smooth(movmean(B,floor(length(B)/50))),10);

figure(3)
plot(t_B, B_lisse)

[peaks, locs] = findpeaks(B);
[peaks, locs_l] = findpeaks(B_lisse);

[m, I1] = min(abs(locs - locs_l(1)));
[m, I2] = min(abs(locs - locs_l(2)));
BPM1 = 60/t_B(locs(I1));
BPM2 = 60/t_B(locs(I2));

%% Choix du BPM
if(BPM1 > 220)
    BPM = BPM2;
elseif(BPM2 < 60)
    BPM = BPM1;
elseif(BPM2 > 220)
    BPM = BPM2;
elseif(BPM1 < 60)
    BPM = BPM1;
else
    BPM = BPM2;
end
BPM