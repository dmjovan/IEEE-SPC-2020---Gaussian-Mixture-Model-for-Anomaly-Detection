function [T] = bag2table(bag)
%BAG2TABLE Extract specific data from a ROS bag into table.
%   Extract '/mavros/imu/data', '/mavros/imu/mag', '/mavros/global_position/local'
%   and '/mavros/global_position/compass_hdg' topics from ROS bag and convert them into a table
    selection = {'Topic', {'/mavros/imu/data','/mavros/imu/mag', '/mavros/global_position/local', '/mavros/global_position/compass_hdg'}};
    N = size(selection{2}, 2);
    bagNormalSelected = cell(N, 1);

    M = inf;
    for i = 1 : N
        bagNormalSelected{i, 1} = select(bag, selection{1}, selection{2}{i});
        if bagNormalSelected{i, 1}.NumMessages < M
            M = bagNormalSelected{i, 1}.NumMessages;
        end
    end

    aux = readMessages(bagNormalSelected{1, 1}, "DataFormat", "struct");
    tableIMU = imuCell2table(aux(1:M));
    aux = readMessages(bagNormalSelected{2, 1}, "DataFormat", "struct");
    tableMag = magCell2table(aux(1:M));
    aux = readMessages(bagNormalSelected{3, 1}, "DataFormat", "struct");
    tableOdom = odomCell2table(aux(1:M));
    aux = readMessages(bagNormalSelected{4, 1}, "DataFormat", "struct");
    tableCompass = compassCell2table(aux(1:M));

    T = [tableIMU, tableOdom, tableMag, tableCompass];
end

