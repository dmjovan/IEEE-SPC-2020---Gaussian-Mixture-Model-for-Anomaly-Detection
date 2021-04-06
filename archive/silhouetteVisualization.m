function [s, h] = silhouetteVisualization(D_test, y_test, numClasses, normal, abnormal, labelName, Lambda)
%SILHOUETTEVISUALIZATION Visualize silhouette data and draw silhouettes.
%   Draws a histogram of input data for silhouette analysis.
%   Draws the silhouettes.
    % Data for silhouette analysis histogram
    figure
        hold on
        for i = 1 : numClasses
            histogram(D_test(y_test == i), 200, "Normalization","pdf")    
        end
        title(['Lambda = ' num2str(Lambda)]);
        legend(labelName);
        hold off
    % Silhouettes
    figure
        [s,h] = silhouette(D_test, y_test);
        title(['Lambda = ' num2str(Lambda) ', normal - ' int2str(normal) ', abnormal - ' int2str(abnormal)])

end

