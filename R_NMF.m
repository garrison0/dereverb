function G = R_NMF(W_s,X_s,Y,len)
% Input:
%   W_s - The clear signal bases
%   X_s - The clean signal activations
%   Y - the reverberant signal
%   len - the # of samples of the reverberant waveform
%
% Performs the following algorithm (R-NMF) to recreate 
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
X_r = rand(M,My);
Xs = rand(size(X_s,1),size(X_s,2));
X_s = Xs;

%rank = number of 'bases'/templates
R = 50;

% for a different implementation: 
% init H_2(n) as average of H(n,k) for different subbands
% where each subband normalized 
% and maybe actually use the RIR if all else fails
H_2 = generate_RIR(700,len*2); 

%initial estimate of Y
Y_hat = zeros(Ny,My);
for k = 1:Ny
    for n = 1:My
        sum = 0;
        for r = 1:R
            %calculate X_r
            xr_sum = 0;
            for l = 0:min(L_h-1,n-1) 
                xr_sum = xr_sum + H_2(n) * X_s(r, n-l);
            end
            t = W_s(k,r) * H_1(k);
            t = t * xr_sum;
            sum = sum + t;
        end
        Y_hat(k,n) = sum;
    end
end

%rank of 100 = 100 bases
R = 50;

ITER_N = 10;

for x = 1:ITER_N
    %calc new H_1 (frequency envelope)
    for k = 1:size(H_1,1)
        num = 0;
        denom = 0;
        for n = 1:My
           foo = Y(k,n) / (Y_hat(k,n) + eps);
           for r = 1:R
               bar = W_s(k,r) * X_r(r,n);
               num = num + foo * bar;
               denom = denom + bar;
           end
        end
        H_1(k) = H_1(k) * (num/denom);
    end
    
    %normalize
    H_1 = H_1 / norm(H_1);
    
    %re-estimate Y
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
    
    %calc new X_r (reverb activations)
    for r = 1:R
        for n = 1:My
            num = 0;
            denom = 0;
            for k = 1:size(H_1,1)
                bar = Y(k,n) / (Y_hat(k,n) + eps);
                foo = H_1(k) * W_s(k,r);
                num = num + foo * bar;
                
                denom = denom + foo;
            end
            X_r(r,n) = X_r(r,n) * (num/denom);
        end
    end
    
    %re-estimate Y
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

    %find cost, display; it better be going down!
    c = 0;
    y_yhat_ratio = zeros(k,n);
    for n = 1:My
        for k = 1:Ny
            if (Y(k,n) ~= 0)
                y_yhat_ratio(k,n) = Y(k,n) / Y_hat(k,n);
                c = c + (Y(k,n)*log(Y(k,n) / Y_hat(k,n)) - Y(k,n)+Y_hat(k,n));
            end
        end
    end
    disp(c);
end

% second iteration: learn clean activations from X_r
% create X_rhat (= X_s(r,n) *_n H_2(n))
X_rhat = [];
for n = 2:min(size(H_2,2),size(X_s,2))
    s = 0;
    for l = 1:(n-1)
       s = s + H_2(l) * X_s(:,n-l); 
    end
    X_rhat = [X_rhat s]; 
end

disp("Now for the second cost function:");

%this is really slow
%should use conv := * in freq domain trick
for i = 1:ITER_N
   for r = 1:R
       for p = 1:size(X_r,2)
           num = 0;
           denom = 0;
           for n = (p+1):(min(size(X_r,2),size(H_2,2)))
               num = num + X_r(r,n) * H_2(n-p);
               denom = denom + X_rhat(r,n) * H_2(n-p);
           end
           X_s(r,p) = X_s(r,p) * num / (denom + eps);
       end
   end
   
   %need new estimate for X_rhat
   X_rhat = [];
   for n = 2:min(size(H_2,2),size(X_s,2))
        % should be convolving across frame index!!! l = 1:(n-1)
        % sum H_2(l) * X_s(r,n-l)
        s = 0;
        for l = 1:(n-1)
           s = s - H_2(l) * X_s(:,n-l); 
        end
        X_rhat = [X_rhat s]; 
   end
    
   %now compute this cost function - it should decrease
%    c = 0;
%    for ii = 1:M
%        for j = 1:My
%            c = c + X_r(ii,j) - X_rhat(ii,j);
%        end
%    end
%    disp(c);
end

%re-estimate Y
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

G = zeros(Ny,My);
for k = 1:Ny
    for n = 1:My
        term = 0;
        for r = 1:R
            term = term + W_s(k,r) * X_s(k,r);
        end
        G(k,n) = term / (Y_hat(k,n) + eps);
    end
end
