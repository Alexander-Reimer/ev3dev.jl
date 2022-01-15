# ev3dev.jl

This is a program for controlling an EV3 Brick in Julia. As Julia doesn't run on the architecture of the EV3-Brick yet, another computer connected to the Brick is required. We personally use a Raspberry Pi 3B and originally made the package for it but any computer / SoC capable of running Julia and with enough performance should work as well.

I will further refer to the EV3-Brick as "brick" and the connected computer as "computer".

## Required Material

- An EV3-Brick
- A SD-Card
- A SD-Card Flasher
- A computer
- A mini USB cable

## Energy managment

If you have a computer with low energy consumption (for example a Raspberry Pi), you can use an USB-A cable to provide the computer with power over the battery of the brick, so you won't need to use an external energy source.

## Installation

This isn't a Julia package yet, so you need to download the source code.

### Installation using git

Open your Terminal, go to any directory, and type

``
git clone https://github.com/AR102/ev3dev.jl
``

This will create a directory named "ev3dev.jl".

### Installation from the browser

Click on the "Code" button at the top, and then "Download ZIP".

Now extract the folder wherever you want.

## Setup

1. Install ev3dev on your brick
    1. Follow steps 1 to 4 [here](https://www.ev3dev.org/docs/getting-started/).
    2. Now follow the instructions [here](https://www.ev3dev.org/docs/tutorials/connecting-to-the-internet-via-usb/)
    3. Then do step 6 (connecting with ssh)
2. Install sshfs on the computer
    * Ubuntu / Debian: ``sudo apt install sshfs``
    <!-- * Windows: [SSHFS-Win](https://github.com/billziss-gh/sshfs-win) -->
3. Mount root directory of the brick on the computer (you have to do this again after every reboot):
``sudo sshfs robot@ev3dev.local:/ path/to/ev3dev/mount``
4. To unmount again, just do ``sudo umount path/to/ev3dev/mount``

## Usage

First include ev3dev in your program with

``
include("path/to/ev3dev.jl")
``

(**Note:** Everything in the program will be brought into global scope so if you encounter problems, check if you may have redefined an important function. We hope to fix this soon.)

It assumes the mount directory is in mount/ in the current directory.
If you mounted it anywhere else, you can change it with 

``setup("path/to/mounting/location")``

The program should detect all ports automatically and saves them in ``Ports``.

They are named ``:outA``, ``:outB``, etc. for the motor ports, ``:in1``, ``:in2``, etc. for the input ports, and ``:mux1``, ``:mux2``, etc. if you have a port splitter connected.

To rescan, you can either rerun the code or do ``map_ports()``.

To setup a motor,

``some_motor = Motor(:outA)``

and to setup a light sensor,

``some_light_sensor = LightSensor(:in1)``

For a ``Motor`` the available commands are:

* ``drive(motor, speed)`` where the speed has to be an Integer between -100 and 100 (negative = reversed direction)
* ``stop(motor, stop_action)`` where the available stop actions are
    * :coast - Just stop spinning the motor and let it run out
    * :brake - Stop the motor actively
    * :hold - Stop the motors rotation and hold it still by applying force to counter any rotation


You can combine two ``Motor``s into a ``Robot``:

``robot = Robot(left_motor, right_motor)``

For a roboter the available commands are:

* ``drive(robot[, speed, turning_rate])``

For a light sensor the available commands are:

* ``mode(mode, sensors...)`` to change the mode of the sensors, where the available modes are
    * :reflection
    * :color
    * :ambient
    * :rgb
* ``value(light_sensor)`` to get the current readings of the sensor
    * Usually Integer as output
    * When light_sensor.mode is :rgb, it gives three Integers in a Tuple

I plan to add more sensors and functions for motors.

If you have any problems or requests, feel free to open an issue or E-Mail me (alexander.reimer2357@gmail.com).