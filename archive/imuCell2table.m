function [T] = imuCell2table(imuCell)
%IMUCELL2TABLE Converts cell array of IMU messages to a table.
%   Converts cell array of IMU messages from a ROS bag
%   to a table.
    T = imu2table(imuCell{1});
    
    for i = 2 : length(imuCell)
        T = [T; imu2table(imuCell{i})];
    end
end

