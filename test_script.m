% [V,R,C] = make_V('horn');
% % % 
% % % HH = generate_RIR(650,32000);
% % % 
% % % % V is your W_s
% % % % Y is the reverberant signal - grab it 
% 
% % run for horn, violin, flute, marimba, sopsax
% % RIR 2 and 5
% file = '/Users/garrison/Desktop/mlsp_midterm/check.wav';
% [s, fs] = audioread(file);
% s = s(:,1);
% len = size(s);
% s = resample(s,16000,fs);
% % 
% Y = stft(s', 64, 16, 0, hann(64));
% M = abs(Y);
% phase = Y./(M + eps);
% %signal_hat = stft(M .* phase, 64, 16, 0, hann(64));
% %audiowrite('test.wav',signal_hat,16000);
% % 
% %[Ws2,Xs2] = NMF_train2(V,R,C,100);
% [Ws,Xs] = NMFB(V,50,200);
% % 
% G = R_NMF(Ws,Xs,abs(Y),92042);
% %
% S = zeros(size(G,1),size(G,2));
% for k = 1:size(G,1)
%     for n = 1:size(G,2)
%         S(k,n) = G(k,n) * M(k,n);
%     end
% end

nS = normc(S) .* phase;
signal_hat = stft(nS, 64, 16, 0, hann(64));
audiowrite('unchecked.wav',signal_hat,16000);
