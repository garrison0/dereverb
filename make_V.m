% makes a big spectrogram of all the notes of the requested instrument
% i.e., preparing for NMF 
function [V, R, C] = make_V(inst) 

myFolder = '/Users/garrison/Desktop/mlsp_midterm/train';
myFolder = strcat(myFolder, strcat('/',inst));

filePattern = fullfile(myFolder, '*.aif'); 
theFiles = dir(filePattern);

V = [];

% normally: 1 : length(theFiles)
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    
    [s, fs] = audioread(fullFileName);
    s = s(:,1);
    s = resample(s,16000,fs);
    spectrogram = stft(s', 64, 16, 0, hann(64));

    V = [V abs(spectrogram)];
end

[R,C] = size(V);

    