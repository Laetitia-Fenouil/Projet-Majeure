%% getvolume
% y_stereo : données audio sur 2 canaux
% Fs : Fréquence d'échantillonage de y_stereo
% dt : durée entre deux mesures (en seconde)
%
% V : matrice contenant l'intensité audio instantannée
function [V] = getvolume(y_stereo, Fs, dt)

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

nwindow = floor(Fs*dt);
n = ceil((length(y_mono)/nwindow));
data1 = zeros(nwindow,n); % n vecteurs de 441 valeurs
data2 = zeros(nwindow,n); % n vecteurs de 441 valeurs
for i = 1:n-1
    data1(:,i) = y_stereo([1:nwindow]+(i-1)*nwindow,1);
    data2(:,i) = y_stereo([1:nwindow]+(i-1)*nwindow,2);
end

nb_zeros = nwindow-length(y_mono([nwindow*(n-1)+1:end]));
add_to_data = [y_stereo([nwindow*(n-1)+1:end], 1);zeros(nb_zeros,1)];
data1(:,n) = add_to_data;

add_to_data = [y_stereo([nwindow*(n-1)+1:end], 2);zeros(nb_zeros,1)];
data2(:,n) = add_to_data;

V = zeros(n,1);
for i = 1:n
    % Poids des canaux
    MomentaryPow1 = mean(data1(:,i).^2);
    MomentaryPow2 = mean(data2(:,i).^2);
    Gc = 0.5;
    if(MomentaryPow2 + MomentaryPow2 == 0)
        V(i) = -70;
    else
        V(i) = -0.691 + 10*log10(Gc*(MomentaryPow1 + MomentaryPow2));
    end
end

end
