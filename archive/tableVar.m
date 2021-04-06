function [T] = tableVar(inputTable)
%TABLEVAR Returns variances of table columns as a new single-row table.
%   Detailed explanation goes here
    T = inputTable(1, :);
    T{1,:} = var(inputTable{:,:});
end

