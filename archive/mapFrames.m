function T = mapFrames(bag)
%MAPFRAMES Matches IMU measurements with corresponding frame
%   Sorts IMU timestamps and measurements into table assigning each measurment
%   set a serial number of frame that first comes after
bagSelect = select(bag,'Time',[bag.StartTime bag.EndTime],'Topic','/mavros/imu/data');
imuData = timeseries(bagSelect,'AngularVelocity.X','AngularVelocity.Y','AngularVelocity.Z',...
    'LinearAcceleration.X','LinearAcceleration.Y','LinearAcceleration.Z');

bagSelect = select(bag,'Time',[bag.StartTime bag.EndTime],'Topic','/mavros/imu/mag');
imuMag = timeseries(bagSelect,'MagneticField_.X','MagneticField_.Y','MagneticField_.Z');

T = [zeros(length(imuData.Time),1) imuData.Time-bag.StartTime imuData.Data imuMag.Data];
bagSelect = select(bag,'Time',[bag.StartTime bag.EndTime],'Topic','/pylon_camera_node/image_raw');
frameTime = timeseries(bagSelect);
frameTime = frameTime.Time-bag.StartTime;
k = 1;
for i = 1:length(frameTime)
    while T(k,2) <= frameTime(i)
        T(k,1) = i;
        k = k+1;
    end
end

end

