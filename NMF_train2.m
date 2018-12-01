function [Ws,Xs] = NMF_train2(M,R,C,n_iter)

%choose 100 bases
B = rand(R,100);
W = rand(100,C);
[p,q] = size(M);

% i am betting this is terribly slow
for n = 1:n_iter
   
    nb = (((M ./ (B * W)) * W') ./ (ones(p,q) * W'));
    B = B .* nb;
    
    nw = B' * (M ./ (B * W));
    nw = nw ./ (B' * ones(p,q));  
    W = W .* nw;

end

Ws = B;
Xs = W;

end