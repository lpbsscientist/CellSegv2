# CellSeg2 User Guide

## Contents

1. Introduction

2. Startup Screen

3. Rectangle Detection Screen

4. Main Screen

5. The Output File

6. Behind the Scenes: Algorithms and their Parameters

   

## 1. Introduction

The CellSeg2 program was built to allow for quick and intuitive cell segmentation of yeast microscopy data. The resulting segmentation masks can then be used for measuring the fluorescence of every cell at different channels. The code for the CellSeg2 program can be found at https://github.com/lpbsscientist/CellSegv2. 

### Program Requirements

The program was developed on Matlab 2018b and tested on 2018a and 2019a using the appdesigner functionality of Matlab. Its use requires the Computer Vision Toolbox. Moreover, it relies on the open microscopy bioformats package to read ND2 files. The package can be found at https://www.openmicroscopy.org/bio-formats/downloads/.

### Program Structure

The program can be started by typing `startSeg` in Matlab or opening the `startSeg.mlapp` file. This opens a startup screen which allows to select the file to open, a save file as well as to define some parameters that are needed later on by the algorithms of the main program. Upon clicking confirm, the main screen is opened which allows to segment cells in a semi-automatic fashion. The results of the segmentation are saved in real time to the save file. To continue working on an existing project, one can simply open a previously created save file from the initial startup screen.

## 2. Startup Screen

The user will always start the program over the startup screen. In the following section, we detail the use of and reasoning behind the GUI elements of the startup screen.

### Select File

The very first thing the user has to specify is to select a file. Here, there are two situations: If the user selects the save file of a previously created project, the program immediately loads the main screen with all of the work that was already saved. If the user selects a `.nd2` file, he has to go on and set the remaining parameters necessary for the program. After selection of a `.nd2` file, all other buttons except of the Confirm button are activated.

Due to the way Matlab handles the file selection screen, the startup screen may "disappear" while Matlab moves to the foreground. The user just has to switch back to the startup screen. 

### Select Save File

Before running the main program, the user has to select a save file to which results are continuously saved. The created save file will be of the type `.mldatx`, a Matlab file format which allows to access and write parts of the file individually. Selecting a save file activates the Confirm button.

### Channel Selection

The underlying algorithms of the program require a light channel and a fluorescence channel. It will need the light channel to know where the cell borders are and the fluorescence to find the cell bodies. For the latter, it relies of the background fluorescence of cells. Therefore, if you have the choice between multiple fluorescence channels, select the one which has more background fluorescence, such that the entire cell body can visibly be distinguished from the background. In order to know which color channel number corresponds to which channel, the user can click on **Display Channels**, which will show an exemplary image for every channel with the corresponding number. If the chosen light channel is a phase contrast channel, the user has to specify this by clicking **Invert for Phase Contrast**. Note that the algorithms generally work better on phase contrast images.

### Identify Cell Containing Regions

Using the open microscopy `.nd2` interface, it is possible to only load crops of images to memory. This significantly improves performance, and the program becomes more fluid to the user. Moreover, the algorithms also are much faster on smaller images. Since often large amount of the microscopy image consists of uninterseting background, the user can exploit this improvement of performance by specifying in advance which rectangles on the microscopy image contain cells. This can be done in two fashions:

**Automatic Detection** runs an algorithm which automatically detects cell bodies and then draws bounding rectangles aroud the found areas. The algorithm does this at the very last time-step of the image, and therefore assumes that cells do not shrink or move throughout the experiment. Moreover, the algorithm relies on knowing the fluorescence channel, so make sure to have specified an appropriate fluorescence channel beforehand.

**Manual Detection** opens a second window which allows to manually specify rectangles. Further details about that window can be found in the corresponding chapter.

If neither manual nor automatic detection was performed, the program will not select any rectangles but just always display the entire microscopy image.

### Confirm

Hitting confirm transmits all entered data, opens the main program and closes the startup window.

## 3. Rectangle Detection Screen

This section describes the functionality of the manual rectangle detection screen, which is opened upon pressing the **Manual Detection** button on the startup screen, as described above. 

### Navigation

The spinners on the bottom left of the window allow to switch between positions, channels and time slots. Note that the drawn rectangles only change according to the XY position, but stay the same for Z-positions,  timeframes and channels. If there is only one position in the data, the spinner is disabled.

### Handle Rectangles

The section on the right side of the image allows to draw and delete rectangles on the screen.

**Add Rectangle** initializes adding a rectangle to the current position. After clicking the button, click on the image to specify where you want to place the top left (first click) and the bottom right corner (second click) of the rectangle. A (green) rectangle will appear. It is important to click _on_ the image, otherwise the click is not registered. A red circle will indicate the positioning of the top left corner. 

All rectangles that are drawn on the current XY position will be indicated as a list under **Select Rectangle**. By clicking on an item of the list, you can change the selection of the current rectangle. Note that the currently selected rectangle is shown in green, while the others are red. 

To delete a rectangle, select the rectangle you want to delete, and then press the **Delete Selected** button.

### Exclude Positions

If you don't draw any rectangles on a given position, the default behavior is to take the entire frame of the position. If you however want to exclude a position alltogether, you can select that position in the **Exclude Positions** list. Hold control to select multiple positions or to unselect a position. Note however that this is just for convenience but does not improve the performance of the main app.

### Confirm

After having drawn rectangles on all desired positions, hit **Confirm** to go back to the startup screen. Beware that currently, clicking again on "Manual Detection" will lead to the loss of all currently drawn rectangles.

## 4. Main Screen

Having now successfully started the application, the following section will describe how to use the main program. 

### Frame Selection

The leftmost menu panel is related to selecting the displayed frame. You can change the displayed region, z-position, timeframe and channel using the corresponding spinner. Note that every rectangle that was previously drawn during the startup is considered as one region, so changing through the regions means changing through the selected region. The field at the very bottom of the panel then specifies which microscopy position the selected region corresponds to. 

### Point Detection

Everytime a new frame is opened, the algorithm detects points in the cells. These points are then used as seeds for the segmentation algorithm, meaning that they are the start of cell detection. Whereas on the first frame every point will create an individual cell, in later timeframes multiple points can correspond to the same cell. This means that especially on later frames it is no problem if one cell has multiple points. It is more desireable on the first frame, but since one can easily merge cells it is not of utmost importance either. However, it is very important that every cell contains at least one point. In particular, the automatic detection algorithm sometimes fails to detect early buds, which makes human interference necessary. 

The point identification works better if you segmented the previous frame. If you want to recalculate the point positions after having properly segmented the previous frame, you can do so by clicking **Redetect**. 

However, it is very important that every cell contains at least one point. In particular, the automatic detection algorithm sometimes fails to detect early buds, which makes human interference necessary. 

In order to add a point to the image, select the **Add Point** option. Then left-click on the screen where you want to add the point. Keep left-clicking to keep adding points, and right-click to stop adding points.

In order to remove a point from the image, select the **Remove Point** option. Then left-click on the screen _near_ the point you want to delete. The program will delete the point closest to the click location. Right click to abort the point removal. Again, keep left-clicking to continuously add points, and right-click to stop. Note that Matlab 2019a makes it possible to select the points. However, point selection is not detected as a click on the image, so click to a point close to the point to delete, but not on the point itself.

You can toggle the point display on and off using the **Show Points** checkbox. 

### Segmentation

After having selected all points, you can segment the cells using the button **Segment**. Note that hitting this button recalculates the segmentation from the ground, i.e. disregarding any changes that have been made to the segmentation mask by the user. This is why hitting segment on an already segmented image will display a warning.

Since the segmentation algorithm isn't perfect, one sometimes needs to correct the area corresponding to a cell. This can be done using the button **Add to Region**. The idea behind this functionality is that you first select the region to which you want to add by left-clicking in that region, and then to draw a polygon around the pixels you want to add to that region. So if the cell is drawn to small, you select the cell by clicking and then draw around the part that it is missing. On the other hand if a cell is too big and contains a part of the background, you can solve this by "adding to the background". For this you first select the background by clicking on it, before drawing around the region of the cell that is too much. 

Selecting a region is handled slightly differently depending on your version of Matlab. In both cases, you select the region you want to add to by left-clicking any pixel within that region. If you have Matlab 2018a or lower, you then have to left-click multiple times on the image to draw a polygon which will then be added. After completion of the polygon, right-click to confirm. During the drawing of the polygon, you cannot see any immediate effect. The changes only take place after confirming with a right click. On Matlab 2018b or newer, you left-click and hold to draw the polygon, which you can see being drawn in real time. Release the click to confirm.

Every cell is automatically assigned an ID number. You can toggle on and off the display of this number using the corresponding switch.

### Labeling and New Cells

The labels of the cell are assigned as follows: If the previous frame has no cell segmentation and thus no cell numbers, an integer is assigned to every cell. If the previous frame has a cell segmentation, the number of a cell is determined to be the cell number in the previous frame that has the majority of pixels in common with the current cell. This means that in the second frame multiple cells can be assigned the same cell number. This is convenient if you have multiple points that are automatically detected within each cell, meaning that you generally don't have to merge regions after the first frame. There is an exception to this behavior however: If a cell is determined to be background, the program assumes that it is a new bud that is forming. To this bud a new cell ID is assigned. 

The labeling is automatically performed after segmentation. If you want to recalculate the labeling after having made changes to the cell segmentation, you can do this with the **Redo Labels** button. Moreover, in case the algorithm fails, you can manually change the label with the **Change Label** button. The algorithm particularly struggles when the cells move by a lot with respect to the previous frame, or at the formation of a new bud.

If the program fails to detect a new cell or considers two cells as one, you can split the cell into two using the **New Cell in Area** button. For this, you first specify the area in which the "new cell" will be - either an existing cell if you want to split a cell into two, or the background if you want to capture a new bud. Then you draw a polygon around the region of the new cell. This is again by leftclicking the corner points of a polygon before confirming with a right click in Matlab 2018a, or by click-and-hold in 2018b or newer (see the subsection Segmentation for more details). The new cell will have a new number assigned to it. 

### Plot Fluorescence

After having segmented and properly assigned all cell labels, you can plot the average fluorescence at the currently selected color channel using the **Plot Selected** button. The resulting plot has a number at the leftmost point indicating to which cell every line corresponds to.

## 5. The Output File

The results of the program are saved to the specified output file in realtime, meaning that every change you make is automatically saved to disk. This allows in particular to avoid keeping large amount of data - such as the segmentation masks in particular - in memory, which would slow down the computer considerably in case of large files (which is the typical case). The tradeoff is that more time is needed to load new images and perform some crucial steps of the algorithms, possibly leading to small delays in case of slow disk access. 

The output file to which the data is continuously written can also be read separately by Matlab in case you want to directly access the data. Within this section we give a general overview of how the data is structured and how specific information can be accessed.

For direct access to the data, create a connection to the file using the function `mf = matfile(filepath)`, specifying the path to the output file. 

### Cell Fluorescence and Area 

There are two functions provided with the segmentation program that handle extracting the total cell fluorescence and the cell area of every individual cell given the output file: `extractFluorescence` and `extractArea`. They need as input the name of the output file of the program as well as the region number (as selected by the region spinner of the program), the z-position and the color channel number of the data you want to extract. The function then returns a matrix that contains for every cell (rows) the total fluorescence (or area, respectively) at every timestep (column). The row indices correspond to the cell number that is displayed on the program screen.

If you want to access the fluorescence and area data directly, you can access the data using the opened `mf` as `mf.cellFluo` and  `mf.cellArea`. Both slots contain a 4D Matlab cell with the data. The first dimension is the region, the second the z-stack, the third the color channel and the fourth the time. Every slot contains an `nx1` `double` array which contains the fluorescence (or area) of every detected cell for all `n` cells. If no segmentation mask was created for the region, z-stack and timeframe, the cell slot is empty. 

### Cell Points and Segmentation Masks

In case you need access to the cell points that were automatically detected, they are stored at `mf.cellpoints` as a 3D Matlab cell. The segmentation masks are stored in `mf.segMasks`, also a 3D Matlab cell. For both cells, the first dimension corresponds to the region, the second to the z-stack and the third to the time. 

For the cell points, every cell slot contains a `nx2` array of the x and y positions of all `n` detected points. If no points were detected yet, the slot is empty. For the segmentation masks, every cell slot contains an array equal in size to the amount of pixels of the selected region. The segmentation mask then determines for every pixel to which cell ID it corresponds. In case it is corresponds to background, it has the value `-1`. 

### Metadata

The `mf.meta` slot contains a structure of all metadata needed by the algorithms. The slot `.imgfile` names the image file to which the analysis file corresponds. In case you move the image file, you have to change this slot manually. `.savefilename` contains the name of the file you opened. `.zPos`, `.xyPos`, `.tPos` and `.cPos` as well as `.currseries` save at what frame the user was when he closed the file in his last session. `.param` saves the parameters of the algorithm that are used. `.rects` contains a cell of all rectangle regions that are to be considered by the program, either drawn manually at startup or detected automatically. Rectangles are specified with the x and y position of their topleft corner before their width and height. `.poslookup` saves to which `xy` position of the microscope every rectangle corresponds. So `.poslookup(5)` returns the xy position of the fifth rectangle in `.rects`. 

## 6. Behind The Scenes

In the following section, we will explain how the main algorithms do their work and what parameters they use. When naming the parameters, we refer to their slot in the (previously described) `mf.meta.param` Matlab struct. Moreover, we point to where the algorithms may fail, and how. 

### Background Identification

All subsequent algorithms rely on the detection of regions we are sure to be background. This is done using the image of the background fluorescence, which is first smoothed using a gaussian filter with high variance  determined by `.bg.smoothing` (default value: 5). The resulting image is thresholded using OTSU thresholding, yielding a binary image identifying regions of the cell which emit background fluorescence and are thus cellular. The resulting mask is then dilated with a large parameter `.bg.dilate` (default: 10), drawing large margins around the detected cellular regions. The inverse of this is then taken as to be certainly background.

The algorithm works well as long as there is substantial backgorund fluorescence emitted at all locations in the cell cytoplasma. As soon as the fluorescence signal is highly localized within the cells, the algorithm may identify too much of the cells to be background. If this occurrs, the `.bg.dilate` parameter has to be increased. 

### Point in Cell Identification

The identification of points at every cell relies on the brightfield image and the previously determined background mask. We startoff by identifying the cell borders as a thresholded image. For this, we proceed as follows: First, the brightfield image is subjected to a Gaussian blur with parameter `.pic.blur` (default: 3). Then, OTSU thresholding is performed to create a binary image. The thresholded image is first eroded with parameter `.pic.erode` (default: 2) to remove small errors, and then dilated with parameter `.pic.dilate` (default: 4) to expand the thresholded image around the cell borders. The resulting image is then closed in order to close borders around cells with parameter `.pic.close` (default: 6). This yields a robust approximation of the cell borders.

Based on this thresholded border image, we calculate a distance transform. This means that for every pixel that is not part of the identified border, we calculate the distance to the nearest border element. The distance transform is highest in the middle of the cell, where the distance to the closest border is maximized. We first smooth the distance transform with Gaussian blur with parameter `.pic.distsmooth` (default: 2) to avoid small irregularities in the distance transform that yield many local maxima. Then, we identify local maxima of this and determine them to be points in cells. Finally, we exclude all points we fount that are within the identified background.

To this first algorithm, a second layer is added in case the previous frame was already segmented: After having identified cell centers as described above, the algorithm checks if all cells found in the previous frame have a point in them in the current layer. If that is not the case, the centroid of those "missing" cells are added to the cell points. 

This algorithm works particularly well for phase contrast images. Since regular brightfield images may sometimes be too irregular in their background, the algorithm may start to fail since the cell borders no longer stand out from the background noise. In that case the user has to resort to manually identify points in cells on the first image. However, due to the second layer of the algorithm, future frames know that there has to be a cell there, and the problem is largely resolved.

The algorithm moreover struggles with identifying buds at an early stage. In case early identification is important, the user has to manually add the new cells.

### Cell Segmentation

The cell segmentation is done using the watershed algorithm on the brightfield image. The image is first smoothed with a Gaussian filter with variance `.ws.smooth` (default: 2). Moreover, small circles with radius `.ws.center_dilate` (default: 2) are drawn around every identified cell point. Those circles are then used together with the identified background as seed for the watershed algorithm. 

The watershed algorithm works as follows: It sets the values of the seeds to be a local minimum. It then greedily adds all pixels with a light intensity lower than a threshold that are adjacent to the seeds to the areas. The thresholds are increased, leading to growing cell areas. As soon as two cells meet, a border is created at the meeting point.

This algorithm works poorly if the brightfiled image is highly irregular, such as if cellular compartments are strongly visible. In such cases, it can help to put multiple seeds for the algorithm within the same cell. In the first frame, this creates distinct cells which have to be merged manually. Later frames detect that those are just fragments of the same cell and assign them correctly.

### Cell Labeling

In case the previous frame doesn't have a cell segmentation, the cells are labeled with an integer. The background is also assigned a number at first, which is then changed to -1. The background number is 1 in most cases, which is why the number one is often missing as a cell ID.

In case the previous cell has a cell segmentation, the algorithm compares the current segmentation with the previous one. For every region in the current frame, it counts how many of its pixels corresponded to which cell in the previous cell. It then assigns the cell number that had the most pixels in common on the previous image to the current cell. This means that in later frames, multiple cell regions can belong to the same cell. 

This has one exception: If the majority detected region is the background, we assume that a budding event took place, and a new cell ID is assigned to the region.





