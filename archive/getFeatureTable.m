function [T] = getFeatureTable(bagCell)
%GETFEATURETABLE Converts cell array of ROS bags to a feature table.
%   Detailed explanation goes here.
    
    Vector3Suffixes = ["X" "Y" "Z"];
    selection = ["IMUAngularVelocity", "IMULinearAcceleration", "MagneticFieldDerivative", "compassHdgDerivative"];
    suffixes = {Vector3Suffixes, Vector3Suffixes, Vector3Suffixes, ""};

    finalSelection = [];
    for i = 1 : length(selection)
        for s = suffixes{i}
            finalSelection = [finalSelection selection(i)+s];
        end
    end

    T = table();
    for i = 1 : length(bagCell)
        temp = bag2table(bagCell{i});
        temp = addDerivative(temp, "MagneticField", Vector3Suffixes);
        temp = addDerivative(temp, "compassHdg");
        
        temp = temp(:, finalSelection);

        sigma = tableVar(temp);
        T = [T; sigma];
    end
end


