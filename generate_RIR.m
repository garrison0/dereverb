function H = generate_RIR(RIR,len)
% RIR = RT60 (in ms)
% sample rate = 16000

h = zeros(len,1);
a = wgn(len,1,0);
delta = 3 * log(10) / RIR;
for n = 1:len
    h(n) = a(n) * exp(-1 * delta * n);
end

%normalize
h = h / (sqrt(sum(abs(h .^2)) / size(h,1)));
H = stft(h',64, 16, 0, hann(64));
H = sum(H,1) / size(H,1);

end
