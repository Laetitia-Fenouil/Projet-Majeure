close all, clear all, clc
tic
%% R�cup�re une musique et son path
[file,path] = uigetfile({'*.mp3';'*.m4a';'*.wav';'*.wma'});

%% Lecture de la musique
[y_stereo,Fs] = audioread(strcat(path,file)); % y=musique �chantillonn�e, Fs = fr�quence d'�chantillonnage

%% Processing
dt = 30/1000;
[F, A] = getfreq(y_stereo, Fs, dt);
B = getbeat(y_stereo, Fs, dt);
BPM = Beat_Spectrogram(y_stereo, Fs);
V = getvolume(y_stereo, Fs, dt);
V = -V;
V = movmean(V, 10);
V = V - min(V);
V = 239*V/max(V);

toc
tic

filesplit = strsplit(file, '.');
newfile = '';
for i=1:length(filesplit)-1
    newfile = strcat(newfile, char(filesplit(i)), '.');
end
newfile = strcat(newfile, 'wav');
filename = writeresults(A, F, B, BPM, V, newfile, '../data/', dt);
cd 'lecture_audio/data/';
if(~exist(newfile, 'file'))
    audiowrite(newfile,y_stereo,Fs);
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% call_exe
% Permet de lancer l'executable C++ depuis Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% on se place dans le dossier contenant l'executable
cd '../src/';

% on crée la commande (& permet d'executer l'executable et l'audio en mm tps)
command = ['./executable',' ',strcat('../../',filename)];

% % on récupère l'audio (sera récupéré directement grâce aux codes précédents)
% playerObj = audioplayer(y_stereo,Fs);
% 
% % on lance la commande executable et l'audio
[status] = system(command);
% pause(2);
% play(playerObj);
