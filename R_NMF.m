function G = R_NMF(W_s,Y,len)
% given Y, the reverberant signal, along with the 
% clean signal bases, W_s, and the len of the 
% reverberant waveform (# of samples)
% perform the following algorithm (R-NMF) to recreate 
% the clean signal without reverb:
% First iterative step: 
%    Learn reverb activations 
%    (X_R) and H_1 (the frequency envelope of the RIR) 
%    from reverb spectrogram
% Second iterative step: 
%    Learn clean activations from the reverb activations

% init
L_h = 40;
[N,M] = size(W_s);
[Ny,My] = size(Y);
H_1 = ones(Ny,1);
X_s = rand(M,My);
X_r = rand(M,My);

%rank of 100 = 100 bases
R = 100;

ITER_N = 10;

for x = 1:ITER_N
    %generate Y_hat
    Y_hat = zeros(Ny,My);
    for k = 1:Ny
        for n = 1:My
            sum = 0;
            for r = 1:R
                t = W_s(k,r) * H_1(k);
                t = t * X_r(r,n);
                sum = sum + t;
            end
            Y_hat(k,n) = sum;
        end
    end
    
    %calc new H_1 (frequency envelope)
    for k = 1:size(H_1,1)
        num = 0;
        denom = 0;
        for n = 1:My
           for r = 1:R
               num_t = Y(k,n) / Y_hat(k,n);
               num_t = num_t * W_s(k,r) * X_r(k,r);
               num = num + num_t;
               
               denom_t = W_s(k,r) * X_r(k,r);
               denom = denom + denom_t;
           end
        end
        H_1(k) = H_1(k) * num / denom;
    end
    
    %calc new X_r (reverb activations)
    for r = 1:R
        for n = 1:My
            num = 0;
            denom = 0;
            for k = 1:size(H_1,1)
                num_t = Y(k,n) / Y_hat(k,n);
                num_t = num_t * H_1(k) * W_s(k,r);
                num = num + num_t;
                
                denom_t = H_1(k) * W_s(k,r);
                denom = denom + denom_t;
            end
            X_r(r,n) = X_r(r,n) * num / denom;
        end
    end
end

% second iteration: learn clean activations from X_r
% first, init H_2(n) as average of H(n,k) for different subbands
H_2 = generate_RIR(1000,len); 

%create X_rhat (= X_s(r,n) *_n H_2(n))
X_rhat = [];
for n = 1:min(size(H_2,2),size(X_s,2))
    new = X_s(:, n) * H_2(n); 
    X_rhat = [X_rhat new]; 
end

%this is really slow
for i = 1:ITER_N
   for r = 1:R
       for n = 1:size(X_s,2)
           num = 0;
           denom = 0;
           for p = 1:n
               num = num + X_r(r,n) * H_2(n-p+1);
               denom = denom + X_rhat(r,n) * H_2(n-p+1);
           end
           X_s(r,p) = X_s(r,p) * num / denom;
       end
   end
end

G = zeros(Ny,My);
for k = 1:Ny
    for n = 1:My
        term = 0;
        for r = 1:R
            term = term + W_s(k,r) * X_s(k,r);
        end
        G(k,n) = term / Y_hat(k,n);
    end
end


