function [T] = compassCell2table(compassCell)
%COMPASSCELL2TABLE Converts cell array of compass heading messages to a table.
%   Converts cell array of 'std_msgs/Float64' type messages from
%   a ROS bag to a table.
    compassHdg = compassCell{1}.Data;
    T = table(compassHdg);
    
    for i = 2 : length(compassCell)
        compassHdg = compassCell{i}.Data;
        T = [T; table(compassHdg)];
    end
end

