function [T] = bagCell2table(bagCell)
%BAGCELL2TABLE Converts cell array of ROS bags to a table.
%   Converts cell array of ROS bags into one joint table using bag2table.
    T = bag2table(bagCell{1});
    
    for i = 2 : length(bagCell)
        T = [T; bag2table(bagCell{i})];
    end
end


