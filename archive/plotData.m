function [fig1, fig2] = plotData(tableNormal, tableAbnormal, fieldBase, fieldSuffixes, fig1, fig2)
%PLOTDATA Plot data from two data tables.
%   Detailed explanation goes here
    if nargin < 5
        fig1 = figure();
        fig2 = figure();
    end
    
    nNormal = 1 : height(tableNormal);
    nAbnormal = 1 : height(tableAbnormal);
    figure(fig1.Number);
        i = 1;
        for s = fieldSuffixes
            subplot(length(fieldSuffixes), 2, i);
            name = strcat(fieldBase, s);
            plot(nNormal, tableNormal{:, name});
            title("Normal, \sigma^2 = "+string(var(tableNormal{:, name})));
            ylabel(name);
            xlabel('n[samples]');
            
            subplot(length(fieldSuffixes), 2, i+1);
            plot(nAbnormal, tableAbnormal{:, name});
            title("Abnormal, \sigma^2 = "+string(var(tableAbnormal{:, name})));
            ylabel(name);        
            xlabel('n[samples]');
            
            i = i+2;
        end
        sgtitle(fieldBase+" time plot");
        fig1.Name = fieldBase+" time plot";
    
    figure(fig2.Number);
        i = 1;
        for s = fieldSuffixes
            subplot(length(fieldSuffixes), 2, i);
            name = strcat(fieldBase, s);
            histogram(tableNormal{:, name});
            title("Normal, \sigma^2 = "+string(var(tableNormal{:, name})));
            ylabel(name);

            subplot(length(fieldSuffixes), 2, i+1);
            histogram(tableAbnormal{:, name});
            title("Abnormal, \sigma^2 = "+string(var(tableAbnormal{:, name})));
            ylabel(name);        

            i = i+2;
        end
        sgtitle(fieldBase+" histogram");
        fig2.Name = fieldBase+" histogram";

end
