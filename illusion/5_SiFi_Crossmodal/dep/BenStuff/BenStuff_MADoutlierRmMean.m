function [OutliersMean, DataZs, PrunedData, OutliersFlagged, NoOutliers] = BenStuff_MADoutlierRmMean( Data,CriticalZ)
%[OutliersNaN, DataZs, PrunedData, OutliersFlagged, NoOutliers] = BenStuff_MADoutlierRm( Data,[CriticalZ])
%   Function to detect and prune outliers, based on robustly estimated Z;
%   ignores NaNs (also meaning these will not be flagged as outliers)
%
%   Z values are estimated as distance from median in units of 1.4826 MAD 
%   (median absolute deviation)
%
%   Data is expected to be a vector or 2D-Matrix (median for each column)
%   CriticalZ can be defined (defaults to 3)
%
%   PrunedData contains the data without outliers (cell if Data came as matrix) 
%   DataZs provides robust Z estimates for each datapoint
%   OutliersFlagged is a binary matrix matching Data's dimensions
%   NoOutliers is the number of outliers per column
%   OutliersMean   contains all data but replaces outliers with mean of the
%   remaining distribution
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
        Medians(i)=nanmedian(Data{i});
    end
else
    MADs=mad(Data,1); %determine MADs
    Medians=nanmedian(Data);
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
        temp(OutliersFlagged)=NaN;
        ColMeans=nanmean(temp);
        [row,col] = find(isnan(temp));
        temp(isnan(temp)) = ColMeans(col);
        OutliersMean{i}=temp;
        
    end
else
    if length(Medians)>1 %if Data is 2D
       for i=1:length(Medians) %go through all medians
            PrunedData{i}=Data(~OutliersFlagged(:,i),i);
       end
       OutliersMean=Data;
       OutliersMean(OutliersFlagged)=NaN;
       
       [row,col] = find(isnan(OutliersMean));
       ColMeans=nanmean(OutliersMean);
       OutliersMean(isnan(OutliersMean)) = ColMeans(col);
    else
        PrunedData=Data(~OutliersFlagged);
        OutliersMean=Data;
        OutliersMean(OutliersFlagged)=NaN;
        ColMeans=nanmean(OutliersMean);
        [row,col] = find(isnan(OutliersMean));
        OutliersMean(isnan(OutliersMean)) = ColMeans(col);
    end
end

end

