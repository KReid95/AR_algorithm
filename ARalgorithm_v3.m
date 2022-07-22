function mask = REID_ARalgorithm_v3(dataset,IVT_threshold,lati,latf,lat_res,loni,lonf,lon_res,length_threshold,aspect_ratio)
lat=[lati:lat_res:latf]';
lon=[loni:lon_res:lonf]';
dataset=dataset';
%it flips it back to col,rows at the end. Algorthim was designed in Matlab hence rows,col
mask_temp=zeros(size(dataset));

clear A B C D E F G
%create binary mask based on input threshold
A1=ones(size(dataset));
A2=dataset;
    for i=1:1:length(dataset(:,1))
        for j=1:1:length(dataset(1,:))
            if  dataset(i,j)<IVT_threshold
                A2(i,j)=NaN;
                A1(i,j)=0;
            end
        end
    end
Y=bwconncomp(A1);
%identifies regions to blobs above threshold and determines geometric characteristics
B=regionprops(Y,A2,'Centroid','Orientation','MajorAxisLength','MinorAxisLength','MaxIntensity','MeanIntensity','PixelList');


B=struct2cell(B);
B=B';
%converts centroid info from index to lat lon
C=[cell2mat(B(:,1)),cell2mat(B(:,2:4)),cell2mat(B(:,6:7))];
if isempty(C)
  mask=mask_temp';

    return
else
C(:,1:2)=round(C(:,1:2));

for i=1:1:length(C(:,1))
    C(i,2)=lon(C(i,2));
    C(i,1)=lat(C(i,1));
end
end

% Calculate length in km from 'major axis length'

for i=1:1:length(C(~isnan(C(:,1))))
a1=C(i,2); %centroid lat
b1=C(i,1); %centroid lon
o=-1*C(i,5); %orientation
L=(C(i,3)/2) * ((lat_res+lon_res)/2);
a2=a1+(L*sind(o));
r=6371000;

arc=acosd(sind(a1)*sind(a2)+cosd(a1)*(cosd(a2)*cosd(L*cosd(o))));

AR_length=2*r*(arc*(pi/180))/1000; %km

C(i,8)=AR_length;
end
b=B(:,5);
D=[];d=[];
%length of river must exceed...
for i=1:1:length(C(~isnan(C(:,1))))
    if C(i,8)>length_threshold
        D=[D;C(i,:)];
        d=[d;b(i)];
    end
end

 if isempty(D)
mask=mask_temp';
return
else

end
%aspect ratio and orientation angle test. Excludes systems within 5 degrees of equator (mostly artifacts)
E=[];e=[];
for i=1:1:length(D(:,1))
    if D(i,3)/D(i,4) >= aspect_ratio && abs(D(i,2))>5
        E=[E;D(i,:)];
        e=[e;d(i)];
    end
end
if isempty(E)
    mask=mask_temp';
    return
else
%Orientation angle is just to get rid of artifacts
F=[];f=[];
for i=1:1:length(E(:,1))
    if  abs(E(i,5))>10
        F=[F;E(i,:)];
        f=[f;e(i)];
    end
end
end
if isempty(F)
mask=mask_temp';
return
else
%maps pixels in the AR onto lat-lon array
for l=1:1:length(F(:,1))
    g=cell2mat(f(l));
    for i=1:1:length(g)
    mask_temp(g(i,2),g(i,1))=1;
    end
end
end
mask=mask_temp';
end
