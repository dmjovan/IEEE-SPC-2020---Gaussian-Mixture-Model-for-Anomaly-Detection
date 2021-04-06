function [bagsTrain, bagsCV, bagsTest, yTrain, yCV, yTest] = bagSplit(...
    bagsNormal, bagsAbnormal,...
    trainNormal, trainAbnormal, CVNormal, CVAbnormal, testNormal, testAbnormal)
%BAGSPLIT Split the bags for training.
%   Split the ROS bags into training, cross-validation and test sets.
    
    MTrainNormal = trainNormal(2) - trainNormal(1) + 1;
    MTrainAbnormal = trainAbnormal(2) - trainAbnormal(1) + 1;
    MTrain = MTrainNormal + MTrainAbnormal;
    
    MCVNormal = CVNormal(2) - CVNormal(1) + 1;
    MCVAbnormal = CVAbnormal(2) - CVAbnormal(1) + 1;
    MCV = MCVNormal + MCVAbnormal;
    
    MTestNormal = testNormal(2) - testNormal(1) + 1;
    MTestAbnormal = testAbnormal(2) - testAbnormal(1) + 1;
    MTest = MTestNormal + MTestAbnormal;
    
    bagsTrain = cell(MTrain,1);
    bagsTrain(1:MTrainNormal) = bagsNormal(trainNormal(1):trainNormal(2));
    bagsTrain(MTrainNormal + (1:MTrainAbnormal)) = bagsAbnormal(trainAbnormal(1):trainAbnormal(2));

    bagsCV = cell(MCV,1);
    bagsCV(1:MCVNormal) = bagsNormal(CVNormal(1):CVNormal(2));
    bagsCV(MCVNormal + (1:MCVAbnormal)) = bagsAbnormal(CVAbnormal(1):CVAbnormal(2));

    bagsTest = cell(MTest,1);
    bagsTest(1:MTestNormal) = bagsNormal(testNormal(1):testNormal(2));
    bagsTest(MTestNormal + (1:MTestAbnormal)) = bagsAbnormal(testAbnormal(1):testAbnormal(2));

    yTrain = [zeros(MTrainNormal,1); ones(MTrainAbnormal, 1)];
    yCV = [zeros(MCVNormal, 1); ones(MCVAbnormal, 1)];
    yTest = [zeros(MTestNormal, 1); ones(MTestAbnormal, 1)];
    
end