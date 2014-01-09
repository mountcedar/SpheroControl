# Processing2 Sphero Project

## Getting Started

This project is a sample project for controlling sphero via Processing2.

Note: This is not a pure Processing code, directly controlling sphero via bluetooth serial communication, but a java wrapper of python sphero package using Py4j package.

## Setup

To use this package, you should install the following packages and libraries

* py4j: the python, java gateway package to use both codes from each other.
	* which can install from http://py4j.sourceforge.net/download.html
* sphero: the python package to controll sphero
	* which can install by
	```
	$ pip install sphero
	```
* slf4j: the java logging interface package
	* which can install from http://www.slf4j.org/download.html
	* download the latest version tarball
	* extract it and copy the following packages into the code directory
		* slf4j-api.jar
* logback: the implementation of logging package
	* which can install from http://logback.qos.ch/download.html
	* download the latest version tarball
	* extract it and copy the following packages into the code directory
		* logback-classic.jar
		* logback-core.jar

The sources can be cloned from github,

```
$ git clone 
```

After all preparation done, the source tree of the project should be like

```
SpheroControl/
├── GatewayServer.pde
├── README.md
├── SpheroControl.pde
├── code
│   ├── logback-classic-X.X.X.jar
│   ├── logback-core-X.X.X.jar
│   ├── py4jX.X.jar
│   └── slf4j-api-X.X.X.jar
└── engine
    ├── __init__.py
    └── gateway.py
```

## Sample Execution

Then all you have to do is to execute the SpheroControl.pde. The behavior of the sphero will be

0. Wakeup the sphero by shaking it.
1. execute the PDE
2. Waiting for the connection
3. The light pattern of the sphero will be a bright blue to show the connection is established.
4. Then the color of the light will be changed every draw timing.
5. By pressing ESC key, you can finalize the application.
	* Note: if you shutdown the application by close button operation, you should terminate python process from the activity monitor or kill command.

