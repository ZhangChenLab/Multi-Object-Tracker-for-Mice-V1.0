clc
clear
%% camera calibration
for ci=4
CameraName=['camera' num2str(ci)];
disp(CameraName)
imageFileNamesPre=fullfile(pwd, CameraName);

images = imageDatastore(imageFileNamesPre);
imageFileNames = images.Files;

% Detect calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
squareSize = 30; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
I = readimage(images, 1); 
imageSize = [size(I, 1), size(I, 2)];
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
                                     'ImageSize', imageSize);
% figure
% subplot(131)
% showExtrinsics(cameraParams, 'CameraCentric');
% subplot(132)
% showExtrinsics(cameraParams, 'PatternCentric');
% subplot(133)
% showReprojectionErrors(cameraParams);
% set(gcf,'Position', [25 97 1317 551])

save([CameraName '.mat'],'cameraParams')
end
disp('----Done----')

%% image undistort
MultiCameraPara=[];

CameraName_T={'camera1','camera2','camera3','camera4'};
ImagesOrigi=[];
ImagesUndistort=[];
ImagesTform=cell(1,4);

ImInd=1;
% SizeOut=[1080 1920];
for cj=1 :4
    CameraName=CameraName_T{1,cj};
    imageFileNamesPre=fullfile(pwd, CameraName);
    images = imageDatastore(imageFileNamesPre);
    imageFileNames = images.Files;
    TRIm=imread(imageFileNames{ImInd,1});
    % TRIm=ImPadding_SF_V2(imresize(TRIm,0.90),SizeOut);  %  ************* 
    TRIm=uint8(TRIm);
    ImagesOrigi=cat(4,ImagesOrigi,TRIm);
    
    load([CameraName '.mat'],'cameraParams');
    TRImUndistort=undistortImage(TRIm,cameraParams);
    ImagesUndistort=cat(4,ImagesUndistort,TRImUndistort);
    MultiCameraPara(cj).cameraParams=cameraParams;
end
figure; montage(ImagesOrigi)
figure; montage(ImagesUndistort)

%% image registration  estimateGeometricTransform fitgeotrans
TarCamera=4;  % Target camera, main camera,top-view
% generate normalized checkboard features
ImagesUndistortFea=[];
ImagesUndistortFeaPoint=[];
for cj=1  :4
[ImagesUndistortFea_1, ImagesUndistortFeaSize] = detectCheckerboardPoints(ImagesUndistort(:,:,:,cj));
ImagesUndistortFea=cat(3,ImagesUndistortFea,ImagesUndistortFea_1);
Im=ImagesUndistort(:,:,:,cj);
Im=insertShape(Im,'FilledCircle',[ImagesUndistortFea(:,:,cj) ones(size(ImagesUndistortFea,1),1)*12],...
    'LineWidth',1,'Color','blue','Opacity' ,0.7);
ImagesUndistortFeaPoint=cat(4,ImagesUndistortFeaPoint,Im);
end
figure; montage(ImagesUndistortFeaPoint)

TR1=ImagesUndistortFea(:,:,TarCamera);  % (x y) | (col row)
TR2=reshape(TR1(:,1),ImagesUndistortFeaSize(1,1)-1,ImagesUndistortFeaSize(1,2)-1);
Delta_1=mean(mean(abs(TR2(2:end,:)-TR2(1:end-1,:))));
Delta_2=mean(mean(abs(TR2(:,2:end)-TR2(:,1:end-1))));
Delta=sqrt(Delta_1^2+Delta_2^2);
[xx,yy]=meshgrid(1:ImagesUndistortFeaSize(1,2)-1,1:ImagesUndistortFeaSize(1,1)-1);
xx=reshape(xx,[],1)*Delta;
yy=reshape(yy,[],1)*Delta;
xx=xx+round(size(ImagesUndistort,2)/2)-round(mean(xx));
yy=yy+round(size(ImagesUndistort,1)/2)-round(mean(yy))-40;
ImagesUndistortFeaTar=[xx yy];

ImageTformReg=[];
outputView = imref2d(size(ImagesUndistort(:,:,:,TarCamera)));
for cj=1  :4
    FeaFix=ImagesUndistortFeaTar;
    FeaMoveing=ImagesUndistortFea(:,:,cj);
    [tform,~,~] = estimateGeometricTransform(FeaMoveing,FeaFix,'projective');
    TRIm_warp=imwarp(ImagesUndistort(:,:,:,cj),tform,'OutputView',outputView);
    ImageTformReg = cat(4,ImageTformReg,TRIm_warp);
    MultiCameraPara(cj).tform=tform;
    MultiCameraPara(cj).outputView=outputView;
end
figure; montage(ImageTformReg)
save MultiCameraPara MultiCameraPara






