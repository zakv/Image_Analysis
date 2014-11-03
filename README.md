Image Analysis
==============

Purpose
-------
This code is designed to store and process the data from the camera that
images the MOT.

To Do:
------
  * Make class that handles arrays of Image instances
  * Fix behavior for file names with dots in them
  * Make sure there's an easy way to see if image.image is loaded because isempty(image.image) calls image.calc_image if image.has_raw_data is true
  * Make Image_Array have nicer behavior when there are no files with the given name
