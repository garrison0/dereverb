% [V,R,C] = make_V('marimba');
% 
% HH = generate_RIR(650,32000);
% 
% % V is your W_s
% % Y is the reverberant signal - grab it 
% file = '/Users/garrison/Desktop/mlsp_midterm/test/marimba/Marimba.rubber.ff.C4.stereo.aif_RIR5.wav';
% [s, fs] = audioread(file);
% s = s(:,1);
% len = size(s);
% s = resample(s,16000,fs);

Y = stft(s', 64, 16, 0, hann(64));
M = abs(Y);
phase = Y./(M + eps);

% [Ws,Xs] = NMF_train2(V,R,C,100);

%G = R_NMF(Ws,Y,92042);
% 
S = zeros(size(G,1),size(G,2));
for k = 1:size(G,1)
    for n = 1:size(G,2)
        S(k,n) = G(k,n) * Y(k,n);
    end
end

signal_hat = stft(S .* phase, 64, 16, 0, hann(64));
audiowrite('dereverb_marimba_big.wav',signal_hat,16000);
