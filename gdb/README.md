## Eclipse C/C++ ROS Debugging 

#### Prerequisites:
-	Install Eclipse CDT (Tested on mars only)
-	Install ROS
-	Create a catkin workspace
-	Install all ROS and system dependencies required by your application in the caktin workspace

#### In Linux Terminal:
- Enable ptracing:  
  In linux 10.10 and greater, ptracing of non-child processes by non-root users is disabled by default. As a consequence, debugging with gdb through eclipse won't be possible.  To permanently allow it edit **/etc/sysctl.d/10-ptrace.conf** and change the line:
  
  `kernel.yama.ptrace_scope = 1`  
  
  To read  

  `kernel.yama.ptrace_scope = 0`
  
  For more on this issue see [here](https://askubuntu.com/questions/41629/after-upgrade-gdb-wont-attach-to-process)
  
- Create Eclipse Project  
  - Using [catkin-tools](http://catkin-tools.readthedocs.io/en/latest/#)  and the **catkin_build_eclipse** script, cd into the top level directory of your catkin workspace and run the following:
    ```
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Debug
    catkin_build_eclipse
    ```
  -	For **catkin_make**, cd into your catkin workspace directory and run the following:
  
   	```catkin_make -DCMAKE_BUILD_TYPE=Debug --force-cmake -G"Eclipse CDT4 - Unix Makefiles" ```
  - For more options on creating eclipse project files see the **Eclipse** section [here](http://wiki.ros.org/IDEs)

#### In Eclipse CDT:
-	Import Project:  

    - File->Import->General -> Existing Projects Into Workspace -> Browse to workspace “build” directory -> Finish
    - Rename Project [Optional] by right-clicking on the project header in the “Project Explorer” panel and click Rename.
    
-	Configure Project (Optional) :

    - Preprocessor Options: Properties -> C/C++ General -> Preprocessor Include Path, Macros etc
    - In the “Providers” tab find and check the “CDT GCC Built-in Compiler Settings [Shared]” checkbox then click “Apply” and “OK”.
    - Code Analysis Configuration: Properties -> C/C++ General -> Code Analysis and click “Configure Workspace Settings” in the “Code Analysis” panel.  
    -	In the Code Analysis Window uncheck everything except for the “Potential Programming Problems” checkbox then hit “Apply” and “OK”.
  
-	Configure Run/Debug Settings:

    - Windows -> Preferences -> Run/Debug -> Launching -> Default Launchers –
    - In Default Launchers Panel Click in the “C/C++ Attach to Application [Debug] “ option.
    - In the Preferred Launcher window select “GDB (DSF) Attach to Process Launcher” checkbox and click “Apply” and “OK”.
    
-	Configure GDB Pretty Print :
    - Clone the “ros_development_config” package 
    ```	git clone https://github.com/jrgnicho/ros_development_config.git ```
    - This package contains the “gdbinit” script which will be loaded by Eclipse in order to configure the gdb debugger.
    - For more details about this step see: http://help.eclipse.org/mars/index.jsp?topic=%2Forg.eclipse.cdt.doc.user%2Fconcepts%2Fcdt_c_whatsnew_80.htm
-	Debug Configurations
    - Access the “Debug Configurations” window by right-clicking on Project -> Debug  As -> Debug Configurations 
    - Under “C/C++ Attach to Application”, find the configuration for the current project; if there isn’t a configuration then double click in order to create one.
    - In the “Main” tab hit the “Browse” button under “C/C++ Application” and find the executable to be debugged and then click “Apply” and “Debug”; for example point to “/opt/ros/indigo/lib/moveit_ros_move_group/move_group” in order to debug the **move_group** executable.
    - Load the gdbinit file   
      *	Select the Debugger tab and click the “Browse” button next to the “GDB command file” textbox.
      * Browse to the location of the “~/ros_development_config/gdb/gdbinit” file downloaded earlier and click “OK”

    - In the “Select Process” window find the process to be debugged, in this example select “move_group” and click “OK”.  It is assumed that the process or program of interest is already running.


