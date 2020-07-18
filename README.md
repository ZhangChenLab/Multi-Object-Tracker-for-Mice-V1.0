# Multi-Object Tracker for Mice
Keywords: Multi-object tracking, Multi-camera, Mouse group, Deep learning, Faster R-CNN, Tracklets fusion. <br>
Zhang Chen Lab, Capital Medical University

## Introduction
Multi-Object Tracker for Mice (MOT-Mice) was used to track mouse groups using deep learning techniques.
MOT-Mice was a multi-camera system with one top-view camera and three side-view cameras.

## File description
***20200606 checkboard XX***: Checkboard images used for camera calibration. <br>
***Faster R-CNN model***: Trained Faster R-CNN models to mouse detection for side-view and top-view cameras. <br>
***imgs***: Descriptional images.

## Steps
### Step 1: Camera calibration
Run the code file ***CameraCalibration_V1.m*** in ***20200606 checkboard XX*** to achieve camera calibration. <br>
Get the results: ***camera1.mat, camera2.mat, camera3.mat, camera4.mat, MultiCameraPara.mat***  <br>
![image](https://github.com/ZhangChenLab/Multi-Object-Tracker-for-Mice/blob/master/imgs/20200606132509-camera4.png)
### Step 2: Mouse detection
