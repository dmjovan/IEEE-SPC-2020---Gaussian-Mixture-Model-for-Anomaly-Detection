function [eval] = silhouetteEval(s, y, normal, w_normal, thresh)
%SILHOUETTEEVAL Evaluate the silhouettes for choosing best model.
%   Detailed explanation goes here
    if (nnz(isnan(s)) == 0) && (nnz(y == normal) > 0)  && (nnz(y ~= normal) > 0)
        eval = mean(s(y ~= normal))*(100 - w_normal)/100 + ...
               mean(s(y == normal))*(w_normal)/100;
        
%         eval = (sum(abs(s(y ~= normal))) - sum(s(y ~= normal) < thresh))/sum(abs(s(y ~= normal)))*(100 - w_normal) + ...
%                (sum(abs(s(y == normal))) - sum(s(y == normal) < thresh))/sum(abs(s(y == normal)))*w_normal;

%         eval = (nnz(y ~= normal) - nnz(s(y ~= normal) < thresh))/nnz(y ~= normal)*(100 - w_normal) + ...
%                (nnz(y == normal) - nnz(s(y == normal) < thresh))/nnz(y == normal)*w_normal;

%         eval = 0;
%         for i = 1 : numClasses
%             eval = eval + (nnz(y == i) - nnz(s(y == i) < 0))/nnz(y == i);
%         end

%         eval = (length(y) - nnz(s < 0.2))/length(y)*100;
    else
        eval = -1;
%         eval = 0;
    end
end

