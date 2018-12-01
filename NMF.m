function [Ws,Xs] = NMF(V,R,C) 

% choose to have 100 bases
% where V = Ws * Xs
% initialize Ws, Xs randomly - (i,j)th element between 0,1
Ws = rand(R,100);
Xs = rand(100,C);

%iterate 100 times (chosen arbitrarily)
for n = 1:100 
    %update Xs via update rule 
    for i = 1:100
        for j = 1:C
            num = Ws';
            num = num(i,:) * V(:,j);
            denom = Ws';
            
            jth_col = zeros(size(Ws,1),1);
            for m = 1:size(Ws,1)
                jth_col(m) = Ws(m,:) * Xs(:,j);
            end
            
            denom = denom(i,:) * jth_col;
            Xs(i,j) = Xs(i,j) * num / denom;
        end
    end
    
    %update Ws via update rule
    for i = 1:R
        for j = 1:100
            % higher lambda imposes greater sparsity in the weights
            % lambda of 10 chosen arbitrarily
            lambda = 10;
            num = Xs';
            num = V(i,:) * num(:,j);
            
            jth_col = zeros(size(Xs,1));
            for m = 1:size(Xs,1)
                Xs_t = Xs';
                jth_col(m) = Xs(m,:) * Xs_t(:,j);
            end
            
            denom = Ws(i,:) * jth_col * lambda;
            Ws = Ws(i,j) * num / denom;
        end
    end
end