function [T] = magCell2table(magCell)
%MAGCELL2TABLE Converts cell array of MagneticField messages to a table.
%   Converts cell array of 'sensor_msgs/MagneticField' type messages from
%   a ROS bag to a table.
    T = mag2table(magCell{1});
    
    for i = 2 : length(magCell)
        T = [T; mag2table(magCell{i})];
    end
end

