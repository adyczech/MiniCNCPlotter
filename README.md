# MiniCNCPlotter
This repository is related to my project: https://youtu.be/pRecbFCnvJI

* **plotter.ino**
  - Arduino code running on  plotter
  - Supported commands:
    * G0, G1 - Linear motion
    * G90, G91 - Absolute and relative distance mode
    * M1 - Pauses program for pen changing
    * M114 - Reports position
    * M300 S30 - Pen down
    * M300 S50 - Pen up
* **plotterGUI**
  - Processing control program running on PC
  - Features:
    * Visualizing a pen trajectory
    * Sending individual commands
    * Manual control of a pen position
    * Streaming Gcode to a plotter
    * Simulation of Gcode
* **rasterToGcode**
  - MATLAB script for generating Gcode from raster image            
