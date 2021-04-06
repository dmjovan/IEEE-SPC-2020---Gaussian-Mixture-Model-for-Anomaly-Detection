function f_names = mostAbnormalFeatures(Z, GMM, normal, U, mu_pca, scalingFactor, mu, kLast, feature_names)
%MOSTABNORMALFEATURES Finds most abnormal features from
%   asdf
    Sigma = diag(GMM.Sigma(:, :, normal));
    
    Z_norm = (Z - GMM.mu(normal, :)) ./ Sigma';
    [~, idx] = max(abs(Z_norm), [], 2);
    
    Z_mask = Z_norm;
    for i = 1 : length(idx)
        Z_mask(i, :) = 0;
        Z_mask(i, idx(i)) = 3*Sigma(idx(i));
    end
    
    X_mask = (Z_mask * U' + mu_pca)/scalingFactor + mu;
    X_mask = abs(X_mask);
    
    n_features = size(X_mask, 2)/(kLast+1);
    for k = 1 : kLast
        X_mask(:, 1:n_features) = X_mask(:, 1:n_features) + X_mask(:, k*n_features + (1:n_features));
    end
    X_mask = X_mask(:, 1:n_features);
    X_mask = X_mask / (kLast+1);
    
    [~, f_idx] = max(X_mask, [], 2);
    
    f_names = cell(length(f_idx), 1);
    for i = 1 : length(f_idx)
        f_names(i) = feature_names(f_idx(i));
    end
end