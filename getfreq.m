%% getfreq
% y_stereo : données audio sur 2 canaux
% Fs : Fréquence d'échantillonage de y_stereo
% dt : durée entre deux mesures (en seconde)
%
% F : matrice contenant les 3 fréquences max de chaque fenêtre
% A : matrice contenant les puissance spectrale fournie par les fréquences F 
function [F, A] = getfreq(y_stereo, Fs, dt)

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

nwindow = floor(Fs*dt);

%% Extraction des frequences et de leur amplitude
n = ceil((length(y_mono)/nwindow));
data = zeros(nwindow,n); % n vecteurs de 441 valeurs
for i = 1:n-1
    data(:,i) = y_mono([1:nwindow]+(i-1)*nwindow);
end
nb_zeros = nwindow-length(y_mono([nwindow*(n-1)+1:end]));
add_to_data = [y_mono([nwindow*(n-1)+1:end]);zeros(nb_zeros,1)];
data(:,n) = add_to_data;

F = zeros(n,3);
A = zeros(n,3);
for i = 1:n
    [ppx2,f] = pwelch(data(:,i),nwindow,floor(nwindow/2),Fs,Fs,'onesided','psd');
    [peaks, locs] = findpeaks(ppx2);
    if(isempty(peaks))
       peaks = 0;
       locs = 1;
    else
        pospeaks = f(locs);
        indsup = find(pospeaks<20000);
        indinf = find(pospeaks>20);
        ind = intersect(indsup,indinf);      
        if(isempty(ind))
            peaks = 0;
            locs = 1;
        else
            peaks = peaks(ind);
            locs = locs(ind);
        end

    end
    nF = 3;
    for j = 1:nF
        [M, I] = max(peaks);
        F(i,j) = f(locs(I));
        A(i,j) = M;
        peaks(I) = 0;
        locs(I) = 1;
    end
end

end
