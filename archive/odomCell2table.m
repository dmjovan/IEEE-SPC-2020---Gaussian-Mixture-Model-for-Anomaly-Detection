function [T] = odomCell2table(odomCell)
%ODOMCELL2TABLE Converts cell array of odom messages to a table.
%   Converts cell array of 'nav_msgs/Odometry' messages from a ROS bag
%   to a table.
    T = odom2table(odomCell{1});
    
    for i = 2 : length(odomCell)
        T = [T; odom2table(odomCell{i})];
    end
end
    
    