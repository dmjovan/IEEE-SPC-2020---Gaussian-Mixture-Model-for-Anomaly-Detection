function [frameIdx, Time, Data] = mapFrames(bags)
%MAPFRAMES Matches IMU measurements with corresponding frames.
%   Sorts IMU timestamps and measurements into table assigning each measurment
%   set a serial number of the frame that first comes after
bagSelect = select(bags{1},'Time',[bags{1}.StartTime bags{1}.EndTime],'Topic','/mavros/imu/data');
imuData = timeseries(bagSelect,'AngularVelocity.X','AngularVelocity.Y','AngularVelocity.Z',...
        'LinearAcceleration.X','LinearAcceleration.Y','LinearAcceleration.Z');
startTime = bags{1}.StartTime;    
bagSelect = select(bags{1},'Time',[bags{1}.StartTime bags{1}.EndTime],'Topic','/mavros/imu/mag');
imuMag = timeseries(bagSelect,'MagneticField_.X','MagneticField_.Y','MagneticField_.Z');

t1 = imuData.Time;
t2 = imuMag.Time;
L = min(length(t1),length(t2));
t1 = t1(1:L);
t2 = t2(1:L);
time = mean([t1';t2']);
time = time';

T = table(zeros(L,1), time-startTime, imuData.Data(1:L,1), imuData.Data(1:L,2), imuData.Data(1:L,3), ...
    imuData.Data(1:L,4), imuData.Data(1:L,5), imuData.Data(1:L,6), imuMag.Data(1:L,1), imuMag.Data(1:L,2), ...
    imuMag.Data(1:L,3), 'VariableNames', ...
    {'FrameIdx','Time','AngVelX', 'AngVelY', 'AngVelZ', 'LinAccX', 'LinAccY', 'LinAccZ', 'MagX', 'MagY', 'MagZ'});

bagSelect = select(bags{1},'Time',[bags{1}.StartTime bags{1}.EndTime],'Topic','/pylon_camera_node/image_raw');
frameTime = timeseries(bagSelect);
frameTime = frameTime.Time-startTime;
k = 1;
for i = 1:length(frameTime)
    while (k <= height(T) && T{k,2} <= frameTime(i))
        T{k,1} = i;
        k = k+1;
    end
end
prev_frame = T{k-1,1};

for b = 2:length(bags)
    bagSelect = select(bags{b},'Time',[bags{b}.StartTime bags{b}.EndTime],'Topic','/mavros/imu/data');
    imuData = timeseries(bagSelect,'AngularVelocity.X','AngularVelocity.Y','AngularVelocity.Z',...
        'LinearAcceleration.X','LinearAcceleration.Y','LinearAcceleration.Z');
    bagSelect = select(bags{b},'Time',[bags{b}.StartTime bags{b}.EndTime],'Topic','/mavros/imu/mag');
    imuMag = timeseries(bagSelect,'MagneticField_.X','MagneticField_.Y','MagneticField_.Z');
    
    t1 = imuData.Time;
    t2 = imuMag.Time;
    L = min(length(t1),length(t2));
    t1 = t1(1:L);
    t2 = t2(1:L);
    time = mean([t1';t2']);
    time = time';
    
    t = size(T,1);
    T{t+1:t+L,:} = [zeros(L,1), time-startTime, imuData.Data(1:L,1), imuData.Data(1:L,2), imuData.Data(1:L,3), ...
        imuData.Data(1:L,4), imuData.Data(1:L,5), imuData.Data(1:L,6), imuMag.Data(1:L,1), imuMag.Data(1:L,2), ...
        imuMag.Data(1:L,3)];
    
    bagSelect = select(bags{b},'Time',[bags{b}.StartTime bags{b}.EndTime],'Topic','/pylon_camera_node/image_raw');
    frameTime = timeseries(bagSelect);
    frameTime = frameTime.Time-startTime;
    k = t;
    for i = 1:length(frameTime)
        while (k <= height(T) && T{k,2} <= frameTime(i))
            T{k,1} = i+prev_frame;
            k = k+1;
        end
    end
    prev_frame = T{k-1,1};
end

frameIdx = T(:,1);
Time = T(:,2);
Data = T(:,3:end);

end

