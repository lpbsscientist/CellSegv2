# CellSeg2 User Guide

## Contents

1. Introduction
2. Startup Screen
3. Rectangle Detection Screen
4. Main Screen
5. Behind the Scenes: Algorithms and their Parameters
6. Troubleshooting



## Introduction

The CellSeg2 program was built to allow for quick and intuitive cell segmentation of yeast microscopy data. The resulting segmentation masks can then be used for measuring the fluorescence of every cell at different channels. The code for the CellSeg2 program can be found at https://github.com/lpbsscientist/CellSegv2. 

### Program Requirements

The program was developed on Matlab 2018b and tested on 2018a and 2019a using the appdesigner functionality of Matlab. Its use requires the Computer Vision Toolbox. Moreover, it relies on the open microscopy bioformats package to read ND2 files. The package can be found at https://www.openmicroscopy.org/bio-formats/downloads/.

### Program Structure

The program can be started by typing `startSeg` in Matlab or opening the `startSeg.mlapp` file. This opens a startup screen which allows to select the file to open, a save file as well as to define some parameters that are needed later on by the algorithms of the main program. Upon clicking confirm, the main screen is opened which allows to segment cells in a semi-automatic fashion. The results of the segmentation are saved in real time to the save file. To continue working on an existing project, one can simply open a previously created save file from the initial startup screen.

## Startup Screen

The user will always start the program over the startup screen. In the following section, we detail the use of and reasoning behind the GUI elements of the startup screen.

### Select File

The very first thing the user has to specify is to select a file. Here, there are two situations: If the user selects the save file of a previously created project, the program immediately loads the main screen with all of the work that was already saved. If the user selects a `.nd2` file, he has to go on and set the remaining parameters necessary for the program. After selection of a `.nd2` file, all other buttons except of the Confirm button are activated.

Due to the way Matlab handles the file selection screen, the startup screen may "disappear" while Matlab moves to the foreground. The user just has to switch back to the startup screen. 

### Select Save File

Before running the main program, the user has to select a save file to which results are continuously saved. The created save file will be of the type `.mldatx`, a Matlab file format which allows to access and write parts of the file individually. Selecting a save file activates the Confirm button.

### Channel Selection

The underlying algorithms of the program require a light channel and a fluorescence channel. It will need the light channel to know where the cell borders are and the fluorescence to find the cell bodies. For the latter, it relies of the background fluorescence of cells. Therefore, if you have the choice between multiple fluorescence channels, select the one which has more background fluorescence, such that the entire cell body can visibly be distinguished from the background. In order to know which color channel number corresponds to which channel, the user can click on "Display Channels", which will show an exemplary image for every channel with the corresponding number. If the chosen light channel is a phase contrast channel, the user has to specify this by clicking "Invert for Phase Contrast". Note that the algorithms generally work better on phase contrast images.

### Identify Cell Containing Regions

Using the open microscopy `.nd2` interface, it is possible to only load crops of images to memory. This significantly improves performance, and the program becomes more fluid to the user. Moreover, the algorithms also are much faster on smaller images. Since often large amount of the microscopy image consists of uninterseting background, the user can exploit this improvement of performance by specifying in advance which rectangles on the microscopy image contain cells. This can be done in two fashions:

Automatic Detection runs an algorithm which automatically detects cell bodies and then draws bounding rectangles aroud the found areas. The algorithm does this at the very last time-step of the image, and therefore assumes that cells do not shrink or move throughout the experiment. Moreover, the algorithm relies on knowing the fluorescence channel, so make sure to have specified an appropriate fluorescence channel beforehand.

Manual Detection opens a second window which allows to manually specify rectangles. Further details about that window can be found in the corresponding chapter.

If neither manual nor automatic detection was performed, the program will not select any rectangles but just always display the entire microscopy image.

### Confirm

Hitting confirm transmits all entered data, opens the main program and closes the startup window.

## Rectangle Detection Screen

This section describes the functionality of the manual rectangle detection screen, which is opened upon pressing the "Manual Detection" button on the startup screen, as described above. 

### Navigation

The spinners on the bottom left of the window allow to switch between positions, channels and time slots. Note that the drawn rectangles only change according to the XY position, but stay the same for Z-positions,  timeframes and channels. If there is only one position in the data, the spinner is disabled.

### Handle Rectangles

The section on the right side of the image allows to draw and delete rectangles on the screen.

Add Rectangle initializes adding a rectangle to the current position. After clicking the button, click on the image to specify where you want to place the top left (first click) and the bottom right corner (second click) of the rectangle. A (green) rectangle will appear. It is important to click _on_ the image, otherwise the click is not registered. A red circle will indicate the positioning of the top left corner. 

All rectangles that are drawn on the current XY position will be indicated as a list under "Select Rectangle". By clicking on an item of the list, you can change the selection of the current rectangle. Note that the currently selected rectangle is shown in green, while the others are red. 

To delete a rectangle, select the rectangle you want to delete, and then press the "Delete Selected" button.

### Exclude Positions

If you don't draw any rectangles on a given position, the default behavior is to take the entire frame of the position. If you however want to exclude a position alltogether, you can select that position in the "Exclude Positions" list. Hold control to select multiple positions or to unselect a position. Note however that this is just for convenience but does not improve the performance of the main app.

### Confirm

After having drawn rectangles on all desired positions, hit confirm to go back to the startup screen. Beware that currently, clicking again on "Manual Detection" will lead to the loss of all currently drawn rectangles.

## Main Screen

Having now successfully started the application, the following section will describe how to use the main program. 

### Frame Selection

The leftmost menu panel is related to selecting the displayed frame. You can change the displayed region, z-position, timeframe and channel using the corresponding spinner. Note that every rectangle that was previously drawn during the startup is considered as one region, so changing through the regions means changing through the selected region. The field at the very bottom of the panel then specifies which microscopy position the selected region corresponds to. 

### Point Detection

Everytime a new frame is opened, the algorithm detects points in the cells. These points are then used as seeds for the segmentation algorithm, meaning that they are the start of cell detection. Whereas on the first frame every point will create an individual cell, in later timeframes multiple points can correspond to the same cell. This means that especially on later frames it is no problem if one cell has multiple points. It is more desireable on the first frame, but since one can easily merge cells it is not of utmost importance either.

However, it is very important that every cell contains at least one point. In particular, the automatic detection algorithm sometimes fails to detect early buds, which makes human interference necessary. 

In order to add a point to the image, select the "Add Point" option. Then left-click on the screen where you want to add the point. Right click to abort the point addition. 

In order to remove a point from the image, select the "Remove Point" option. Then left-click on the screen _near_ the point you want to delete. The program will delete the point closest to the click location. Right click to abort the point removal. Note that Matlab 2019a makes it possible to select the points. However, point selection is not detected as a click on the image, so click to a point close to the point to delete, but not on the point itself.



### 



