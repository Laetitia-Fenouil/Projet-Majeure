clear all; close all; clc;
tic
folderfiledir = 'C:\Users\Paul\Desktop\Deep Learning';
folders = dir(fullfile(folderfiledir));
nfolders = length(folders);
% database = [];
% targetbase = [];
fileid = fopen('filelist.txt','w');
targetid = fopen('targetlist.txt','w');
for i = 3 : nfolders
    filesdir = strcat(folderfiledir,'\',folders(i).name);
    files = dir(fullfile(filesdir));
    nfiles = length(files);
    for j = 3:nfiles
        audidir = strcat(filesdir,'\',files(j).name);
        [y_stereo,Fs] = audioread(audidir); % y=musique échantillonnée, Fs = fréquence d'échantillonnage
        y_mono = y_stereo(:,1)+y_stereo(:,2);
        y_mono = y_mono/2;
        clear y_stereo;
        if (length(y_mono)<60*Fs)
           continue 
        end
        [s1,s2,s3] = getSampleSpectrogram(y_mono, Fs);
        if (length(s1(:))~=128*128)
           continue 
        end

        splitfile = strsplit(files(j).name, '.');
        filename = strcat(num2str(i-2), ' - ');
        for k = 1:length(splitfile)
            filename = strcat(filename, char(splitfile(k)), '-');
        end
        fprintf(fileid, strcat(filename,'-1.png\r\n'));
        fprintf(fileid, strcat(filename,'-2.png\r\n'));
        fprintf(fileid, strcat(filename,'-3.png\r\n'));
        fprintf(targetid, strcat(num2str(i-2),'\r\n'));
        fprintf(targetid, strcat(num2str(i-2),'\r\n'));
        fprintf(targetid, strcat(num2str(i-2),'\r\n'));

%         imwrite(s1, strcat(filename,'-' , '1', '.png'));
%         imwrite(s2, strcat(filename,'-' , '2', '.png'));
%         imwrite(s3, strcat(filename,'-' , '3', '.png'));
%         database = [database, s1(:), s2(:), s3(:)];
%         targetbase = [targetbase, i-2, i-2, i-2];
        
    end
end
fclose('all');
% imwrite(database, 'data.png')
% imwrite(targetbase, 'target.png')
toc
