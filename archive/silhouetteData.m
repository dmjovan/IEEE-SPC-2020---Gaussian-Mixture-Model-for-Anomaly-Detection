function [Data] = silhouetteData(GMM, Z, normal)
%SILHOUETTEDATA Calculates data to be used for silhouette analysis
%   Maps the data points using Mahalanobis distance.
    numClasses = GMM.NumComponents;
    %% Mahalanobis distance
    D = mahal(GMM, Z);
    
    % distance from normal gaussian minus others (in case of more classes)
    Data = D(:, normal) - sum(D(:, (1:numClasses) ~= normal), 2);
%     Data = P(:, normal) - sum(P(:, (1:numClasses) ~= normal), 2);
%     Data = abs(Data);
    
%     Data = zeros(length(y_cv), 1);        
%     for i = 1 : numClasses
%         Data(y_cv == i) = D(y_cv == i, i) - sum(D(y_cv == i, (1:numClasses) ~= i), 2);
% %         Data(y_cv == i) = P(y_cv == i, i) - sum(P(y_cv == i, (1:numClasses) ~= i), 2);
%     end
    
%     Data = abs(Data);
end

