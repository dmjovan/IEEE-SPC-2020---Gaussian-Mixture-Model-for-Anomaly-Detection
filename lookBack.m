function [M] = lookBack(inputMatrix, k)
%LOOKBACK For each row in the input matrix, append k last rows to the right.
%   Detailed explanation goes here

    m = size(inputMatrix, 1);
    if k >= m
        M = inputMatrix;
        return;
    end
    
    M = inputMatrix(k+1 : m, :);
    % size(M, 1) == m - k
    
    for i = 1 : k
        M = [M, inputMatrix( k+1 -i : m -i, :)];
    end
end

