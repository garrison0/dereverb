instruments = ["cello","cymbals","flute","horn","sopsax","marimba","violin"];
 
RIR_sim1='./RIR/RIR_SimRoom1_near_AnglA.wav'; 
RIR_sim2='./RIR/RIR_SimRoom1_far_AnglA.wav';  
RIR_sim3='./RIR/RIR_SimRoom2_near_AnglA.wav'; 
RIR_sim4='./RIR/RIR_SimRoom3_far_AnglA.wav';
RIR_sim5='./RIR/octagon.wav';

for z = 1:size(instruments,2) 
    % load (sphere format) signal
    myFolder = '/Users/garrison/Desktop/mlsp_midterm/test';
    myFolder = strcat(myFolder, '/', instruments(z));

    filePattern = fullfile(myFolder, '*.aif'); 
    theFiles = dir(filePattern);
    
    for k = 1 : length(theFiles)
        disp(k);
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName);

        [x,fs]=audioread(fullFileName);
        x=x/(2^15);  % conversion from short-int to float
    
        % load RIR 
        RIR = audioread(RIR_sim1);
        RIR2 = audioread(RIR_sim2);
        RIR3 = audioread(RIR_sim3);
        RIR4 = audioread(RIR_sim4);
        RIR5 = audioread(RIR_sim5);

        % Generate reverberant data        
        y=gen_obs(x,RIR);
        y2=gen_obs(x,RIR2);
        y3=gen_obs(x,RIR3);
        y4=gen_obs(x,RIR4);
        y5=gen_obs(x,RIR5);

        % save reverberant speech y
        y=y/max(abs(y)); % common normalization
        y2=y2/max(abs(y2));
        y3=y3/max(abs(y3));
        y4=y4/max(abs(y4));
        y5=y5/max(abs(y5));

        % write y's to a wav files
        audiowrite(char(strcat(fullFileName, '_RIR1.wav')),y,fs);
        audiowrite(char(strcat(fullFileName, '_RIR2.wav')),y2,fs);
        audiowrite(char(strcat(fullFileName, '_RIR3.wav')),y3,fs);
        audiowrite(char(strcat(fullFileName, '_RIR4.wav')),y4,fs);
        audiowrite(char(strcat(fullFileName, '_RIR5.wav')),y5,fs);
    end
end


%%%%
function [y]=gen_obs(x,RIR)
% function to generate reverberant data
%convert RIR to mono
RIR = sum(RIR,2) / size(RIR,2);

%convert recording to mono
x = sum(x,2) / size(x,2);

% calculate direct+early reflection signal for calculating SNR
[val,delay]=max(RIR(:));

% obtain reverberant speech
rev_y = conv(x,RIR);

y = rev_y(delay:end);
