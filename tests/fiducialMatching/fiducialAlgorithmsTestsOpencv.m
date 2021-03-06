%%%%% TESING FIDUCIAL FINDING ALGORITHMS WITH OPENCV MEX %%%%%
%% preliminary %%

clc
clear all

show='off';

% Adding picture folder to path %

addpath('FiducialsPictures');
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Fiducial_images\Fiducial_chip_images_NewOptics_20190306')
addpath('F:\mexopencv');
addpath('F:\mexopencv\opencv_contrib')

% loading original figure and template %

image0=imread('Image_11_1_1.jpg');
template=imread('ATLAS_F.jpg');

template2=imread('F_outline.bmp');

sizeImage=size(image0);  % WHATCH OUT! size returns inverted coordinated respect to image processing standard rows-->Y  columns-->Y
sizeTemplate=size(template);
% sizeTemplate=size(template2);

% converting to grayscale %

I1 = rgb2gray(image0);
temp = rgb2gray(template);

       %%%%% creating ROI from original figure %%%%%

[Nrow,Ncol]=size(I1);
roiSize=1000;   %define size of the ROI nxn pixels
offset=[0,-150];  %displacement of the ROI respect to the center of the image
roiCenter=[Ncol/2+offset(1),Nrow/2+offset(2)]; %define center of my ROI
ver1=[roiCenter(1)-roiSize/2,roiCenter(2)-roiSize/2]; %define Vertex of my ROI [pixel x,pixel y];
ver2=[roiCenter(1)+roiSize/2,roiCenter(2)-roiSize/2];
ver3=[roiCenter(1)+roiSize/2,roiCenter(2)+roiSize/2];
ver4=[roiCenter(1)-roiSize/2,roiCenter(2)+roiSize/2];

xlim=[ver1(1) ver2(1) ver3(1) ver4(1)];
ylim=[ver1(2) ver2(2) ver3(2) ver4(2)];

BW = roipoly(I1,xlim,ylim);  % creating binary mask
Imask=I1;
Imask(BW == 0) = 0;

v=reshape(Imask,1,[]);
v (v==0)=[];

% extracting the ROI %

ROI=I1(ver1(2):ver3(2),ver1(1):ver3(1));


      %%%% Apply proccessing to ROI and template (general features+threshold+cleaning) %%%%

%% median blur (median filter): clean the image %%

kernel=5;
ROI_median=cv.medianBlur(ROI,'KSize',kernel);
temp_median=cv.medianBlur(temp,'KSize',kernel);

%% binary filter %%

ROI_bin=cv.threshold(ROI_median,'Otsu','Type','Binary','MaxValue',255);
temp_bin=cv.threshold(temp_median,'Otsu','Type','Binary','MaxValue',255);

%% appling adaptative local threshold (Gaussian+Binary inv) %%

ROI_inv=cv.adaptiveThreshold(ROI_bin,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',5,'C',2);
temp_inv=cv.adaptiveThreshold(temp_bin,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',5,'C',2);

%% invert the binary image, cleaning small particles, and invert again %%

structElem=cv.getStructuringElement('Shape','Rect','KSize',[7,7]);


ROI_final = cv.morphologyEx(ROI_inv,'Close', 'Element',structElem);
temp_final = cv.morphologyEx(temp_inv,'Close', 'Element',structElem);

ROI_clean=ROI_inv;
temp_clean=temp_inv;

         %%%% applying pattern recognition algorithm (SURF) %%%%

%% Find the SURF features. %%

detector=cv.SURF;
detector.clear();

[keypointsImage, descriptorsImage] = detector.detectAndCompute(ROI_final);
[keypointsTemp, descriptorsTemp] = detector.detectAndCompute(temp_final);

detector.delete();

%% match features in both images %%

matcher=cv.DescriptorMatcher;
matches=matcher.knnMatch(descriptorsTemp,descriptorsImage,2);
[indexPairs,matchmetric] = matchFeatures(descriptorsTemp,descriptorsImage);

%% select good quality matches %%
n=length(matches);
lowRatio=0.7;
cont=1;
for i=1:n
if (matches{i}(1).distance < matches{i}(2).distance*lowRatio) 
    SortedMatches(cont).queryIdx=matches{cont}(1).queryIdx;
    SortedMatches(cont).trainIdx=matches{cont}(1).trainIdx;
    SortedMatches(cont).imgIdx=matches{cont}(1).imgIdx;
    SortedMatches(cont).distance=matches{cont}(1).distance;
    cont=cont+1;
end
end

for i=1:length(matchmetric)
   if matchmetric(i)<(0.001)
       matchesMatlab(i,:)=indexPairs(i,:);
   end
end

%% checking we have enough matches %%

min=4;
if length(SortedMatches)<4
    disp('We have no enough matches!!')
end

%% finding de object (Affine transformation) %%

objeto=cell(1,length(SortedMatches));
scene=cell(1,length(SortedMatches));

for i=1:length(SortedMatches)
   indxObj=SortedMatches(i).queryIdx;
   indxScene=SortedMatches(i).trainIdx;  
    
   objeto{i}=[keypointsTemp(indxObj+1).pt(1), keypointsTemp(indxObj+1).pt(2)];
   scene{i}=[keypointsImage(indxScene+1).pt(1), keypointsImage(indxScene+1).pt(2)];
end



%% filtering for high quality matches %%

[distCentObj,distSimPointObjX,distSimPointObjY]=filterPoints(objeto);
[distCentSce,distSimPointSceX,distSimPointSceY]=filterPoints(scene);
newcont=1;
for i=1:length(distCentObj)
    threshold_1=0.2;
    threshold_2=0.2;
    if (abs(distCentObj(i)-distCentSce(i))<threshold_1)  &&  abs((distSimPointObjX(i)-distSimPointSceX(i))<threshold_2)...
            abs((distSimPointObjY(i)-distSimPointSceY(i))<threshold_2)
       
     newobjeto{newcont}=objeto{i};
     newscene{newcont}=scene{i};
       newcont=newcont+1 ;
    end
        
end

clearvars objeto scene
objeto=newobjeto;
scene=newscene;


%% plotting %%
% figure(1)
% for i=1:length(objeto)
% hold on
% plot(objeto{i}(1),objeto{i}(2),'*')
% end
% 
% figure(2)
% for i=1:length(scene)
% hold on
% plot(scene{i}(1),scene{i}(2),'*')
% end

%% transformation fiducial to image %%

H = cv.estimateAffinePartial2D(objeto',scene','Method','Ransac');
H2 = fitgeotrans(vec2mat(cell2mat(objeto),2),vec2mat(cell2mat(scene),2),'NonreflectiveSimilarity');

%% PLOTING %%

% 
% matchImg=imread('matched.jpg');
% roiFeatures=imread('roiFeatures.jpg');
% tempFeatures=imread('tempFeatures.jpg');
% ypos=0.09;
% 
% map=figure('visible',show,'Position', get(0,'Screensize'));
% s(1)=subplot(2,9,1); imshow(image0); s(1).Position=s(1).Position+[-0.12 -0.04 0.1 0.1]+[0 -ypos 0 0 ]; title('Original Image processing -->')
% s(2)=subplot(2,9,2); imshow(ROI);  s(2).Position=s(2).Position+[-0.04 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Extracting ROI')
% s(3)=subplot(2,9,3); imshow(ROI_median);  s(3).Position=s(3).Position+[-0.038 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Median filter')
% s(4)=subplot(2,9,4); imshow(ROI_bin);  s(4).Position=s(4).Position+[-0.035 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Binary filter')
% % s(18)=subplot(2,9,5); imshow(ROI_thr);  s(4).Position=s(4).Position+[-0.035 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Binary filter')
% s(5)=subplot(2,9,5); imshow(ROI_inv);  s(5).Position=s(5).Position+[-0.033 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Local Adaptative threshold')
% s(6)=subplot(2,9,6); imshow(ROI_clean);  s(6).Position=s(6).Position+[-0.033 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Removing particles')
% s(7)=subplot(2,9,7); imshow(ROI_final);  s(7).Position=s(7).Position+[-0.031 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Inverting')
% s(8)=subplot(2,9,8); imshow(roiFeatures);  s(8).Position=s(8).Position+[-0.014 0 0.035 0.035]+[0 -ypos 0 0 ]; title('Finding Features (SURF)')
% s(9)=subplot(2,9,9); imshow(matchImg);  s(9).Position=s(9).Position+[0.01 -0.22 0.08 0.08]+[0 -ypos 0 0 ]; title('Matching both features maps')
% 
% s(10)=subplot(2,9,10); imshow(template);  s(10).Position=s(10).Position+[-0.12 -0.04 0.1 0.1]; title('Template processing -->')
% s(11)=subplot(2,9,11); imshow(temp);  s(11).Position=s(11).Position+[-0.04 0 0.021 0.021];
% s(12)=subplot(2,9,12); imshow(temp_median);  s(12).Position=s(12).Position+[-0.038 0 0.021 0.021];
% s(13)=subplot(2,9,13); imshow(temp_bin);  s(13).Position=s(13).Position+[-0.035 0 0.021 0.021];
% % s(19)=subplot(2,9,15); imshow(temp_thr);  s(19).Position=s(19).Position+[-0.035 0 0.021 0.021];
% s(14)=subplot(2,9,14); imshow(temp_inv);  s(14).Position=s(14).Position+[-0.033 0 0.021 0.021];
% s(15)=subplot(2,9,15); imshow(temp_clean);  s(15).Position=s(15).Position+[-0.033 0 0.021 0.021];
% s(16)=subplot(2,9,16); imshow(temp_final);  s(16).Position=s(16).Position+[-0.031 0 0.021 0.021];
% s(17)=subplot(2,9,17); imshow(tempFeatures);  s(17).Position=s(17).Position+[-0.016 0 0.04 0.04];
% saveas(map, 'FiducialsPictures\fullProcess.fig');

%% plotting matlab matches %%
% 
% figure(7)
% for i=1:length(matchmetric)
% hold on
% indx=(indexPairs(i,1));
% indy=(indexPairs(i,2));
% plot(keypointsTemp(indx).pt(1),keypointsTemp(indy).pt(2),'*','color','b')
% hold on
% plot(keypointsImage(indx).pt(1),keypointsImage(indy).pt(2),'*','color','r')
% end
% 
% hold on
% for i=1:length(matchmetric)
% line([objeto{i}(1),scene{i}(1)],[objeto{i}(2),scene{i}(2)]);
% end


%% plotting again %%
ScaRot=H(1:2,1:2);
xDelta=H(1,3);
yDelta=H(2,3);
angle=asin(H(2,1));
% ScaRot=[cos(angle) H(1,2);H(2,1) cos(angle)];
% objeto_vec=cell2mat(objeto);
% objeto_mat=vec2mat(objeto_vec);
% objeto_transformed=H*objeto_mat;

figure(1)
for i=1:length(objeto)
hold on
obj=ScaRot*[objeto{i}(1),objeto{i}(2)]'+[xDelta,yDelta];
plot(objeto{i}(1),objeto{i}(2),'*','color','b')
end

hold on
for i=1:length(scene)
hold on
plot(scene{i}(1),scene{i}(2),'*','color','r')
end

% for i=1:length(scene)
% hold on
% [xpoint,ypoint]=transformPointsForward(H2,objeto{i}(1),objeto{i}(2));
% plot(xpoint,ypoint,'*','color','g')
% end

for i=1:length(objeto)
    children = get(gca, 'children');
delete(children(1));
line([objeto{i}(1),scene{i}(1)],[objeto{i}(2),scene{i}(2)]);
end


%%  plotting template over original image %%

% angle=asin(H(2,1));
% ScaRot=[cos(angle) H(1,2);H(2,1) cos(angle)];
ScaRot=H(1:2,1:2);
xDelta=H(1,3);
yDelta=H(2,3);
trans=[xDelta,yDelta];
% original coordinates of template %
fig='on';

vertexTemp{1}=[0 0];
vertexTemp{2}=[sizeTemplate(2) 0];
vertexTemp{3}=[sizeTemplate(2) sizeTemplate(1)];
vertexTemp{4}=[0 sizeTemplate(1)];
center=[sizeTemplate(2)/2,sizeTemplate(1)/2];

% Vertices template transformados %

if (ScaRot==0)
vertexTrans{1}=vertexTemp{1}+trans;
vertexTrans{2}=vertexTemp{2}+trans;
vertexTrans{3}=vertexTemp{3}+trans;
vertexTrans{4}=vertexTemp{4}+trans; 
centerTrans=center+trans;
else
vertexTrans{1}=vertexTemp{1}*ScaRot+trans;
vertexTrans{2}=vertexTemp{2}*ScaRot+trans;
vertexTrans{3}=vertexTemp{3}*ScaRot+trans;
vertexTrans{4}=vertexTemp{4}*ScaRot+trans;
centerTrans=center*ScaRot+trans;
end

%% display template with point in the center %%

figure,
imshow(temp);
axis on
hold on;

% Plot cross at row 100, column 50
plot(sizeTemplate(2)/2,sizeTemplate(1)/2, 'r+', 'MarkerSize', 30, 'LineWidth', 2);


%% Display ROI figure with the located area %%

figure,
imshow(ROI);
axis on
hold on;
centerX=centerTrans(1);
centerY=centerTrans(2);
% Plot cross at row 100, column 50
plot(centerTrans(1),roiSize-centerTrans(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on 
line([vertexTrans{1}(1),vertexTrans{2}(1)],roiSize-[vertexTrans{1}(2),vertexTrans{2}(2)]);
line([vertexTrans{2}(1),vertexTrans{3}(1)],roiSize-[vertexTrans{2}(2),vertexTrans{3}(2)]);
line([vertexTrans{3}(1),vertexTrans{4}(1)],roiSize-[vertexTrans{3}(2),vertexTrans{4}(2)]);
line([vertexTrans{4}(1),vertexTrans{1}(1)],roiSize-[vertexTrans{4}(2),vertexTrans{1}(2)]);


%% error numerico %%





