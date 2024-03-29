# Multi-Object Tracker for Mice (MOT-Mice)
**Keywords: Multi-object tracking, Multi-camera, Mouse group, Deep learning, Object detection, Faster R-CNN, Tracklets fusion** <br>
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
MOT-Mice was developed and tested on MATLAB R2019b using an Nvidia GeForce GTX 1080 Ti GPU with 11 GB memory.

## Run MOT-Mice system
- Use **EasyRun** step to test the MOT-Mice quickly. <br>
- Use **Step-by-Step** to test the MOT-Mice step-by-step. <br>
### EasyRun
Run ***EasyTest.m*** to test the MOT-Mice quickly. Pre-processed camera calibration and mouse detection files were used.
### Step-by-Step
#### Step 1: Camera calibration
Processing the files in the folder of ***20200606 checkboard XX***. <br>
Run ***Step1_CameraCalibration_V1.m*** in the folder of ***code*** to achieve camera calibration. Get the results: ***camera1.mat, camera2.mat, camera3.mat, camera4.mat, MultiCameraPara.mat.***  <br>
<img src="imgs/20200606132509-camera4.png" height="200px" width="auto"/> 
#### Step 2: Mouse detection
Processing the files in the folder of ***Videos of mouse group***. <br>
Detect all mouse individuals and generate tracklets for each video.  <br>
Run ***Step2_1_MouseDetection_CamTopview.m*** in the folder of ***code*** for the tracking of top-view camera (camera4) using Faster R-CNN model of ***FRCNN_resnet18_Camera_Top-view***. Get a result file of ***Tracelets_....mat***. <br>
Run ***Step2_2_MouseDetection_CamTopview.m*** in the folder of ***code*** for the tracking of side-view cameras (camera1,2,3) using Faster R-CNN model of ***FRCNN_resnet18_Camera_Side-view***. Get a result file of ***Tracelets_....mat***.  <br>
#### Step 3: Tracklets fusion by trace prediction
Run ***Step3_1_TrackletsFusion_SingleCamera.m*** in the folder of ***code*** to achieve single-camera tracklets fusion. Get a result file of ***..._FusionSingleCam.mat***.<br>
Run ***Step3_2_TrackletsFusion_MultiCamera.m*** in the folder of ***code*** to achieve multi-camera tracklets fusion. Get a result file of ***..._FusionMultiCam.mat***. <br>
#### Step 4: Post-processing and manual correction
