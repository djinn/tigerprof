🐯Tiger Profiler 
=================
Tiger Profiler is a code derived from [Light Weight Java Profiler](https://code.google.com/p/lightweight-java-profiler/). Tiger Profiler is resurrection of already very good profiler. The profiler is now capable of profiling on Mac OS X and Linux. The minor amount of Intel specific code has been replaced with portable equivalent of C++. 

## What will [tigerprof](https://github.com/djinn/tigerprof) accomplish for you?
tigerprof is uses the [JVM tooling interface](https://docs.oracle.com/javase/8/docs/technotes/guides/jvmti/) gather telemetry about running Java Code. It generates traces which can be used to identify performance bottlenecks in the running code. 

## How to run [tigerprof](https://github.com/djinn/tigerprof)?
tigerprof requires JDK environment to compile. The code also requires C++20 capable compiler like GCC or Clang and finally make. You can compile the code 

```
$ JAVA_HOME=/usr/local/java-11 make 
```
Replace JAVA_HOME with suitable path for your environment. The make builds the code in a newly created directory called *build* as libtigerprof.so. To run the profiler

```
$ java -agenpath:build/libtigerprof.so -jar spark-bench-launch-2.3.jar com.ibm.sparktc.sparkbench.sparklaunch.SparkLaunch
```
When the Java execution will be finished, the profiler creates a traces.txt file in current working directory.

## How to make these traces actionable?
There is a repository of code by Brenden Gregg called [Flamegraph](http://github.com/brendangregg/FlameGraph). This repo contains a script which can generate visualisation from traces.txt.

```
$ ./stackcollapse-ljp.awk < ../traces.txt | ./flamegraph.pl > ../traces.svg
```




