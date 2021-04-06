function [X_train, X_cv, X_test, idx_train, idx_cv, idx_test] = splitData(X, pct)
%SPLITDATA Split the given data into training, CV and test sets using given percent values for split.
%   Detailed explanation goes here
    M = size(X,1);
    rng(42); % For reproducibility
    idx = randperm(M);
    
    M_train = floor(M * pct(1) / 100);
    M_cv = floor(M * pct(2) / 100);

    idx_train = idx(1 : M_train);
    idx_cv = idx(M_train + (1 : M_cv));
    idx_test = idx(M_train + M_cv + 1 : end);

    X_cv = X(idx_cv, :);
    X_train = X(idx_train, :);
    X_test = X(idx_test, :);
end

