function [PrunedData, DataZs, OutliersFlagged, NoOutliers] = BenStuff_MADoutlierRm( Data,CriticalZ)
%[PrunedData, DataZs, OutliersFlagged, NoOutliers]] = BenStuff_MADoutlierRm( Data,[CriticalZ])
%   Function to detect and prune outliers, based on robustly estimated Z
%
%   Z values are estimated as distance from median in units of 1.4826 MAD 
%   (median absolute deviation)
%
%   Data is expected to be a vector or 2D-Matrix (median for each column)
%   CriticalZ can be defined (defaults to 3)
%
%   PrunedData has NaN entries were  outliers used to be 
%   DataZs provides robust Z estimates for each datapoint
%   OutliersFlagged is a binary matrix matching Data's dimensions
%   NoOutliers is the number of outliers per column
%
%
%   cf. http://www.eng.tau.ac.il/~bengal/outlier.pdf
%       http://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
%

if nargin<2
    CriticalZ=3;
end

DataSize=size(Data);
if length(DataSize)>2
    error('Data is expected to be 2D at most!');
end

if iscell(Data)
    for i=1:length(Data)
        MADs(i)=mad(Data{i},1);
        Medians(i)=median(Data{i});
    end
else
    MADs=mad(Data,1); %determine MADs
    Medians=median(Data);
end

if length(Medians)>1 || iscell(Data) %if Data is 2D
    if iscell(Data)
        for i=1:length(Data)
            DataZs{i}=(Data{i}-Medians(i))./MADs(i);
        end
    else
        for i=1:length(Medians) %go through all medians
            DataZs(:,i)=(Data(:,i)-Medians(i))./MADs(i);%estimate robust Z values
        end
    end
else 
    DataZs=(Data-Medians)./MADs;
end

if iscell(Data)
        for i=1:length(Data)
            OutliersFlagged{i}=abs(DataZs{i})>CriticalZ;
        end
    else
    OutliersFlagged=abs(DataZs)>CriticalZ;%flag the ones exceeding set threshold
end

if iscell(Data)
    NoOutliers=sum(cellfun(@sum,OutliersFlagged));
else
    NoOutliers=sum(OutliersFlagged);
end

if iscell(Data)
    for i=1:length(OutliersFlagged)
        temp=Data{i};
        PrunedData{i}=temp(~OutliersFlagged{i});
    end
else
    if length(Medians)>1 %if Data is 2D
       for i=1:length(Medians) %go through all medians
            PrunedData{i}=Data(~OutliersFlagged(:,i),i);
       end
    else
        PrunedData=Data(~OutliersFlagged);
    end
end

end

