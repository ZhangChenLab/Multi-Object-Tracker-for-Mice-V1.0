clc
clear
% %% 加载数据：net模型 | 相机参数 | 视频文件夹（undistort/camera1,camera2,...）
% net模型
[file,path] = uigetfile('','Load ImageDetector...');
load(fullfile(path,file))
if exist('ImageDetector','var')
    disp('----Load ImageDetector done----')
else
    disp('----Load ImageDetector ERROR----')
    return
end
% 相机参数模型
[file,path] = uigetfile('','Load MultiCameraPara...');
load(fullfile(path,file))
if exist('MultiCameraPara','var')
    disp('----Load MultiCameraPara done----')
else
    disp('----Load MultiCameraPara ERROR----')
    return
end
%% 视频 camera1,2,3,4
% pathTar='G:\MultiCamera_video_V2\20200606 mulricamera m4-15\20200606-m6\Seg-2_undistort_Tar';
% fileAll={'20200606-123718-video1_1.avi';...
%          '20200606-123718-video2_1.avi';...
%          '20200606-123719-video3_1.avi';...
%          '*.avi'};
% pathTar='G:\MultiCamera_video_V2\20200606 mulricamera m4-15\20200606-m5\Seg-1_undistort_Tar';
% fileAll={'20200606-170302-video1.avi';...
%          '20200606-170303-video2.avi';...
%          '20200606-170303-video3.avi';...
%          '*.avi'};
% pathTar='G:\MultiCamera_video_V2\20200606 mulricamera m4-15\20200606-m4\Seg-2_undistort_Tar';
% fileAll={'20200606-211740-video1_3.avi';...
%          '20200606-211740-video2_3.avi';...
%          '20200606-211740-video3_3.avi';...
%          '*.avi'};
% pathTar='G:\MultiCamera_video_V2\20200606 mulricamera m4-15\20200606-m10\Seg-1_undistort_tar';
% fileAll={'20200606-220610-video1.avi';...
%          '20200606-220610-video2.avi';...
%          '20200606-220611-video3.avi';...
%          '*.avi'};
% pathTar='G:\MultiCamera_video_V2\20200605 multicamera m1-3\20200605-m3\Seg-1_undistort_Tar';
% fileAll={'20200605-172652-video1.avi';...
%          '20200605-172652-video2.avi';...
%          '20200605-172652-video3.avi';...
%          '*.avi'};
pathTar='G:\MultiCamera_video_V2\20200605 multicamera m1-3\20200605-m2\Seg-1_undistort_Tar';
fileAll={'20200605-163932-video1.avi';...
         '20200605-163932-video2.avi';...
         '20200605-163932-video3.avi';...
         '*.avi'};
     
for TarCamera=[1 2 3]
MainCamera=4;
CameraName_T={'video1','video2','video3','video4'}; 
% [file,path] = uigetfile('*.avi','Load target video...');
path=pathTar;
file=fileAll{TarCamera};

VideoPath=path;
MainFlag=contains(file,CameraName_T{MainCamera});
pathFull=fullfile(path,file);
VideoObj=VideoReader(pathFull);
disp(path)
disp(file)

% %% MCMO tracking
Scale=0.75;
if Scale==1
    VideoObj.CurrentTime=0;
    frame0 = readFrame(VideoObj);
    figure(1)
    imshow(frame0)
    h=drawrectangle;
    TRPosi=round(h.Position);
    WH=1024;
    TR_row=TRPosi(2):TRPosi(2)+TRPosi(4);
    TR_col=TRPosi(1):TRPosi(1)+TRPosi(3);
    frame1=frame0(:,TR_col,:);
    figure(1); clf
    imshow(frame1)
end

% %%
PlotFlag=  0  ;  % *********************
% %% tracking 相关设置
tracks_ind=0;
tracks = struct(...
    'frame', {}, ...
    'id', {}, ...
    'polybbox', {}, ...   % current  box
    'polybboxAll', {}, ...   % all  box
    'polyarea',{}, ... %  area of current box
    'kalmanFilter', {}, ...  
    'age', {}, ...    % the number of frames since the track was first detected
    'TVisiC', {}, ...  % total visible count (frames)
    'ConInvisiC', {});  % consecutive invisible count
tracks_back=tracks; % 记录终止段

VisiThre=2;
nextId=0;
FlagPred=false;
SizeOut=[1080 1920];
BboxYThre=SizeOut(1)*1/4;
NFrames=floor(VideoObj.Duration*VideoObj.Framerate); % ~number of frames

tic
cs_i=0;
VideoObj.CurrentTime=0;
while hasFrame(VideoObj)  && (~PlotFlag || cs_i<100)  % 按帧处理循环
    cs_i=cs_i+1;
    if rem(cs_i,20)==0
        disp([num2str(cs_i) ' ' num2str(NFrames) ' ' num2str(cs_i/NFrames*100) '% ' ...
            num2str(toc) 's']);
    end
    % 读帧+检测+变换
    frame0 = readFrame(VideoObj);     %  主摄像头 读取当前帧
    if Scale~=1
        bboxes=detect(ImageDetector, imresize(frame0,Scale),'NumStrongestRegions' ,600,...
            'Threshold',0.7);
        bboxes=round(bboxes/Scale);
    else
        bboxes=detect(ImageDetector, frame0(:,TR_col,:),'NumStrongestRegions' ,600,...
            'Threshold',0.7);
        bboxes(:,1)=bboxes(:,1)+TR_col(1)-1;
    end
    
    if ~MainFlag
         bboxes(bboxes(:,2)<=BboxYThre,:)=[];
    end
    PolyBbox = Bboxes2PolyBboxes(bboxes);
    [x,y]=transformPointsForward(MultiCameraPara(TarCamera).tform,PolyBbox(:,1),PolyBbox(:,2));
    PolyBboxtsform_1=[x y];  %  x y | reshape(~,4,[])
    
    frame_0=imwarp(frame0,MultiCameraPara(TarCamera).tform,'OutputView',MultiCameraPara(TarCamera).outputView);
    % % ---------- 2-level | level-1 main camera; level-2 4 cameras
    Level=2;
    [tracks,tracks_lost_1,nextId,FlagPred] = trackletsPolyBbox_V2(PolyBboxtsform_1,tracks,VisiThre,nextId,cs_i,Level );
    
    if ~isempty(tracks_lost_1)
        tracks_back(end+1:end+length(tracks_lost_1))=tracks_lost_1; % record lost tracks.
    end
    
    PolyBboxtsform_1=reshape(PolyBboxtsform_1,4,[],2);
    PolyBboxtsform_1=permute(PolyBboxtsform_1,[3 1 2]);
    PolyBboxtsform_1=reshape(PolyBboxtsform_1,8,[]);
    if PlotFlag
    figure(1);  cla; hold on
    frame_1=insertShape(frame_0, 'Polygon', PolyBboxtsform_1','Color','blue','LineWidth',2);  % 显示所有检测bbox
    imshow(imresize(frame_1,0.5))
    end
end

TimeChar=char(datetime);
TimeChar=strrep(TimeChar,' ','_');
TimeChar=strrep(TimeChar,'-','');
TimeChar=strrep(TimeChar,':','');
namemat=fullfile(VideoPath,['Tracelets_' CameraName_T{TarCamera} '_' TimeChar  '.mat']);
save(namemat)

disp('----Done----')


end


