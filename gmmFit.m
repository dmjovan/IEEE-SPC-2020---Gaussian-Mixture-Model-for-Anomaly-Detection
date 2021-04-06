function [GMM, labelName, normal, abnormal, middle] = gmmFit(Z, numClasses, Lambda, Iterations)
%GMMFIT Fits GMM to data.
%   Computes Gaussian mixture model on data Z with given number of
%   classes and regularization value Lambda.
    GMM = fitgmdist(Z, numClasses, 'RegularizationValue', Lambda, 'Options',statset('MaxIter', Iterations));

    t = zeros(numClasses, 1);
    for i = 1 : numClasses
        t(i) = trace(GMM.Sigma(:,:,i));
    end
    
    [~, idx] = sort(t);
    
    labelName = cell(numClasses, 1);
    

    normal = idx(1);
    abnormal = idx(numClasses);

    labelName{normal} = 'normal';
    labelName{abnormal} = 'abnormal';

    if numClasses > 2
        middle = idx(2:end-1);
        for m = middle
            labelName{m} = 'middle';
        end
    else
        middle = 0;
    end
end

