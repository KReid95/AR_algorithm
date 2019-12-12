%AR algorithm V2 with intensity %edited latitude cut-off following manual
%obs
function [output] = ARalgorithm_v3(dataset,Threshold,lat_start,lat_end,lon_start,lon_end,res) 
clear A B C D E F G
lat=[lat_start:res:lat_end]';
lon=[lon_start:res:lon_end]';

A1=ones(size(dataset));
A2=dataset;
    for i=1:1:length(dataset(:,1))
        for j=1:1:length(dataset(1,:))
            if  dataset(i,j)<Threshold
                A2(i,j)=NaN;
                A1(i,j)=0;
            end
        end
    end


Y=bwconncomp(A1);

B=regionprops(Y,A2,'Centroid','Orientation','MajorAxisLength','MinorAxisLength','MaxIntensity','MeanIntensity');


B=struct2cell(B);
B=B';

C=cell2mat(B);
if isempty(C)
    output=[];
    return
end

C(:,1:2)=round(C(:,1:2));
for i=1:1:length(C(:,1)) 
    C(i,1)=lon(C(i,1));
    C(i,2)=lat(C(i,2));
end


%% Calculate length in km from 'major axis length'


for i=1:1:length(C(~isnan(C(:,1))))
a1=C(i,2); %centroid lat
b1=C(i,1); %centroid lon
o=-1*C(i,5); %orientation
L=(C(i,3)/2) * res;
a2=a1+(L*sind(o));
r=6371000;

arc=acosd(sind(a1)*sind(a2)+cosd(a1)*(cosd(a2)*cosd(L*cosd(o))));

AR_length=2*r*(arc*(pi/180))/1000; %km

C(i,8)=AR_length;
end


D=[];
%length of river must exceed...
for i=1:1:length(C(~isnan(C(:,1))))
    if C(i,8)>2000
        D=[D;C(i,:)];
    end
end

if isempty(D)
    output=[];
    return
end

E=[];
for i=1:1:length(D(:,1))
    if D(i,3)/D(i,4) >=2
        E=[E;D(i,:)];
    end
end
if isempty(E)
    output=[];
    return
end

F=[];
for i=1:1:length(E(:,1))
    if sign(E(i,2))~=sign(E(i,5)) && abs(E(i,5))>10
        F=[F;E(i,:)];
    end
end


output=F;
end
