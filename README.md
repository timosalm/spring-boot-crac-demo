# Running a Spring Boot application on VMware Tanzu Application Platform with [Coordinated Restore at Checkpoint (CRaC)](https://openjdk.org/projects/crac/)

Coordinated Restore at Checkpoint (CRaC) is an OpenJDK project to drastically reduce a Java application's start-up and warm-up times by taking a memory snapshot at runtime and restoring it in later executions.

[Azul initiated the OpenJDK CRaC project](https://www.azul.com/products/components/crac/) and provides an OpenJDK 17 distribution with built-in support for CRaC, which we're using in this demo.

## Run the demo on VMware Tanzu Application Platform

To run the demo on VMware Tanzu Application Platform (TAP), we have to make some adjustments to the out-of-the-box supply chains, the Knative configuration, and it for example also requires persistent volumes that can be accessed across nodes. The [run-with-customizations-on-tap.sh](run-with-customizations-on-tap.sh) script includes everything you need to run it on a full profile TAP installation. To run the script, cluster admin privileges are required!

```
git clone https://github.com/timosalm/spring-boot-crac-demo.git
cd spring-boot-crac-demo
export DEVELOPER_NS=developer-ns
./run-with-customizations-on-tap.sh
```
