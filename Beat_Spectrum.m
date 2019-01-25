function [T, B, BPM, D] = Beat_Spectrum(y,Fs,T_data,Beats)

%% Implement beat detection as described in Jonathan Foote's and Shingo Uchihashi's article "THE BEAT SPECTRUM: A NEW APPROACH TO RHYTHM ANALYSIS" (2001)
% 1 Audio parameterization

% Decoupe en fenetres de w points avec un overlap de 50%
data = y;
w = 512;
nov = w/2;
ind = 1;
windowed_data = [];
while((ind+1)*nov<length(data))
    windowed_data(:,ind) = 10*log(abs(fft(data((ind-1)*nov+1:(ind+1)*nov)))); %10*log(abs(...)) = magnitude du spectre
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
% Calcul du spectre de distance
B = zeros(1,Nw);
for i = 0:Nw-1
    ind = 1;
    sumD = 0;
    while(ind + i <= Nw)
    	sumD = sumD + D(ind, ind + i);
        ind = ind +1;
    end
    B(i+1) = sumD/(ind-1);
end
T = linspace(0,T_data, Nw);

B_lisse = movmean(movmean(B,floor(length(B)/50)), 10);
[peaks, locs] = findpeaks(B);
[peaks, locs_l] = findpeaks(B_lisse);

if isempty(locs_l)
    BPM1 = 0;
    BPM2 = 0;
else
    if length(locs_l)==1
        [m, I1] = min(abs(locs - locs_l(1)));
        BPM1 = 60/T(locs(I1));
        BPM2 = 0;
    else
        [m, I1] = min(abs(locs - locs_l(1)));
        [m, I2] = min(abs(locs - locs_l(2)));
        BPM1 = 60/T(locs(I1));
        BPM2 = 60/T(locs(I2));
    end
end
%% Choix du BPM
%% 
if(BPM1 > 220)
    BPM = BPM2;
elseif(BPM2 < 60)
    BPM = BPM1;
elseif(BPM2 > 220)
    BPM = BPM2;
elseif(BPM1 < 60)
    BPM = BPM1;
else
    if(isempty(Beats))
        BPM = BPM2;
    else
        mean_B = mean(Beats);
        diff1 = abs(mean_B - BPM1);
        diff2 = abs(mean_B - BPM2);
        if min(diff1,diff2) == diff1
            BPM = BPM1;
        else
            BPM = BPM2;
        end
    end
end
end