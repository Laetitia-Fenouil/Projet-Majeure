clear all; close all; clc;

%% R�cup�re une musique et son path
[file,path] = uigetfile('*.mp3');

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Extraction des fr�quences et de leur amplitude
Nit = floor(length(y_mono)/(10*Fs));
Nx = 10*Fs;
nfft = 2*(Fs/100 - 1);
w = floor((2*Nx)/1001);
noverlap = floor(w/2);
reconstruction = [];
for i=1:Nit
    range = [1+(i-1)*Nx:i*Nx];
    data = y_mono(range);
    [s,f,t] = spectrogram(data,hamming(w),noverlap,nfft, Fs);
    for j=1:length(t)
        sample_reconstruction = zeros(length(f),1);
        for k=1:30
           [M,I] = max(s(:,j));
           while(f(I)>20000)
                s(I,j) = 0;
                [M, I] = max(s(:,j));
            end
           sample_reconstruction(I) = M;
           s(I,j) = min(s(:,j));
        end
        reconstruction = [reconstruction; real(ifft(sqrt(sample_reconstruction)))];
    end
end

audiowrite('song.wav',reconstruction,Fs);