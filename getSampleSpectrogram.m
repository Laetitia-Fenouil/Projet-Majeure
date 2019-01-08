function [sample1, sample2, sample3] = getSampleSpectrogram(songdata, Fs)
    Ndata = length(songdata);
    start = [floor(0.25*Ndata), floor(0.5*Ndata), floor(0.75*Ndata)];
    n = 128*0.02*Fs;
    nfft = 254;
    nsc = round(2*n/129);
    nov = floor(nsc/2);
    data1 = songdata(start(1):start(1) + n - 1);
    data2 = songdata(start(2):start(2) + n - 1);
    data3 = songdata(start(3):start(3) + n - 1);

    sample1 = spectrogram(data1,hamming(nsc), nov, nfft, Fs, 'yaxis');
    sample2 = spectrogram(data2,hamming(nsc), nov, nfft, Fs, 'yaxis');
    sample3 = spectrogram(data3,hamming(nsc), nov, nfft, Fs, 'yaxis');

    %% Mise en forme de l'image
    sample1 = flip(10*log10(abs(sample1)));
    sample1 = sample1 - min(min(sample1));
    sample1 = sample1/max(max(sample1));
    
    sample2 = flip(10*log10(abs(sample2)));
    sample2 = sample2 - min(min(sample2));
    sample2 = sample2/max(max(sample2));
   
    sample3 = flip(10*log10(abs(sample3)));
    sample3 = sample3 - min(min(sample3));
    sample3 = sample3/max(max(sample3));
end