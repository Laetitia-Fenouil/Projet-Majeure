clear all; close all; clc;

%% R�cup�re une musique et son path
[file,path] = uigetfile('*.mp3');

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage

%% Passage du stereo au mono
y_mono = y_stereo(:,1)+y_stereo(:,2);
y_mono = y_mono/2;

%% Extraction des fr�quences et de leur amplitude
n = ceil((length(y_mono)/441));
data = zeros(441,n); % n vecteurs de 441 valeurs
for i = 1:n-1
    data(:,i) = y_mono([1:441]+(i-1)*441);
end
nb_zeros = 441-length(y_mono([441*(n-1)+1:end]));
add_to_data = [y_mono([441*(n-1)+1:end]);zeros(nb_zeros,1)];
data(:,n) = add_to_data;

ppx2 = [];
result_f = [];
result_A = [];
y = [];
chanson_reconstruite = [];
for i = 1:n
    [ppx2(:,i),f] = pwelch(data(:,i),441,200,441,Fs,'onesided','power');
    y = [y;ppx2(:,i)];
    trame_equivalent = zeros(size(ppx2(:,i)));
    nF = 5;
    for j = 1:nF
    [M, I] = max(ppx2(:,i));
    while(f(I)>15000)
        ppx2(I,i) = 0;
        [M, I] = max(ppx2(:,i));
    end
    if(j==1)
    result_f(i) = f(I);
    result_A(i) = M;
    end
    ppx2(I,i) = 0;
    trame_equivalent(I) = M;
    end
    trame_equivalent = ifft(sqrt(trame_equivalent));
    chanson_reconstruite = [chanson_reconstruite; trame_equivalent];
end

figure(1)
plot(result_f);
xlabel('Time (s/100)')
ylabel('Frequency (Hz)')
figure(2)
plot(result_A)
xlabel('Time (s/100)')
ylabel('Magnitude (dB)')

audiowrite('our_song.wav',10*real(chanson_reconstruite),Fs/2);