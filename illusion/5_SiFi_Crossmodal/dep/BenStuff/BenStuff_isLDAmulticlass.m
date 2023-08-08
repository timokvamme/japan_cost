%% LDA multiclass?

function Classifications=BenStuff_isLDAmulticlass(NumTrainLabels, NumFeatures)

    if nargin<2
        NumFeatures=10;
    end
    
    TrainData=rand(50*NumTrainLabels/2,NumFeatures); %just some random crap 
    TestData=rand(5*NumTrainLabels,NumFeatures);


    TrainLabels=[1:NumTrainLabels];
    TrainLabelsVector=[]; %initialize
    for i=1:size(TrainData,1)/NumTrainLabels
        TrainLabelsVector=[TrainLabelsVector, TrainLabels];
    end
    TrainLabelsVector=TrainLabelsVector';

    [Classifications]=classify(TestData, TrainData, TrainLabelsVector);

end