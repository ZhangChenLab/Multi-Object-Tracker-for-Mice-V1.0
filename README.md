# Multi-Object Tracker for Mice (MOT-Mice)
**Keywords: Multi-object tracking, Multi-camera, Mouse group, Deep learning, Faster R-CNN, Tracklets fusion** <br>
Zhang Chen Lab, Capital Medical University

## Introduction
Multi-Object Tracker for Mice (MOT-Mice) was used to track mouse groups using deep learning techniques.
MOT-Mice was a multi-camera system with one top-view camera and three side-view cameras.

## File description
***code***: Original MATLAB code.  <br>
***20200606 checkboard XX***: Checkboard images used for camera calibration. <br>
***Videos of mouse group***: Multi-camera videos of mouse group. Top-view camera: camera4. Side-view cameras: camera1,2,3. <br>
***Faster R-CNN model***: Trained Faster R-CNN models to mouse detection for side-view and top-view cameras. <br>
***imgs***: Descriptional images.  <br>
MOT-Mice system was developed and tested in MATLAB R2019b.

## Steps
### Step 1: Camera calibration
Processing the files in the folder of ***20200606 checkboard XX***. <br>
Run the code file ***Step1_CameraCalibration_V1.m*** in the folder of ***code*** to achieve camera calibration. <br>
Get the results: ***camera1.mat, camera2.mat, camera3.mat, camera4.mat, MultiCameraPara.mat***  <br>
![image](https://github.com/ZhangChenLab/Multi-Object-Tracker-for-Mice/blob/master/imgs/20200606132509-camera4.png)
### Step 2: Mouse detection
Processing the files in the folder of ***Example Videos mice-4***. <br>
Detect all mouse individuals and generate tracklets for each camera.  <br>
Run the code file ***Step2_1_MouseDetection_CamTopview.m*** in the folder of ***code*** for the tracking of top-view camera (camera4) using Faster R-CNN model of ***FRCNN_resnet18_Camera_Top-view***.  <br>
Run the code file ***Step2_2_MouseDetection_CamTopview.m*** in the folder of ***code*** for the tracking of side-view cameras (camera1,2,3) using Faster R-CNN model of ***FRCNN_resnet18_Camera_Side-view***.  <br>
### Step 3: Tracklets fusion by trace prediction

### Step 4: Post-processing and manual correction
