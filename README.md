# Under the hood of an Azure IoT Suite Connected Factory pre-configured solution
This is a step-by-step walkthrough of the Azure IoT Suite Connected Factory pre-configured solution (PCS) allowing you to take a look at the services deployed under the hood.

## Getting Started

1. Go to https://www.azureiotsuite.com/. Alternatively you could also run the build script in the [Connected Factory GitHub repo](https://github.com/Azure/azure-iot-connected-factory#run-the-build-script).
	
2. Create a Connected Factory deployment. When you create the solution, there are some explanation about what services are being spun up on your subscription. The biggest cost to this is Azure Time Series Insights so you may want to delete this solution after you're done with the hack. The GitHub repo lives here. For this hack, it is not recommended that you manually deploy this off the source templates.
	
3. It takes over 10 minutes to fully deploy the resource group in your Azure subscription. You will get an email from the Azure IoT Suite Team when your PCS is ready. 

## Access the VM
	
1. For this hack, let's delve in deeper. Go to your Connected Factory resource group in the Azure portal. Find the Linux VM, and reset password. User name is docker, and you may choose either to use a password or an SSH public key (if you have one already generated). The reset password operation takes about a minute to take effect.

2. Go to the network security group, you will see that the resources are pretty much locked in. Only outbound ports for MQTT (8883), AMQP (5671) and HTTPS (443) are allowed. But to access the VM we need to enable SSH. Go to Inbound Security Rues, and add an inbound security rule. Enter the destination port as 22, and name as SSH.

3. The VM need a public IP address. Go to the network interface resource. Under IP configurations, click ipconfig1 to edit. Click "Enabled" for public IP address. Configure required settings for IP Address. Create new. Then click Ok. Click Save.
	
4. Now the Connect button should be enabled. You should see the command you could use to establish an SSH session to your Linux VM. If you have Bash on Windows enabled run it. Otherwise use a tool like Putty. 
	
5. Take a look under the hood of the Docker containers created by the preconfigured solution. Run docker ps, you will see heaps of containers deployed and running. Each container representing a particular factory location (with IoT Edge OPC UA publisher and proxy modules, SCADA simulator, and MES simulator.
![Containers](/doc/media/dockercontainers.png?raw=true "Containers")
	
When you do a ls, you can see shell scripts for startsimulation, stopsimulation and deletesimulation. You can also view config files, logs, and shared volume from the Docker containers. Muck around to create your new SCADA station, with its accompanying Azure IoT Edge proxy and publisher modules. You can refer to the startsimulation shell script to understand what command line parameters to use to create your own factory instances.
	
6. Learn about the size of the Docker containers. Run 
```
docker images
```
![images](/doc/media/dockerimages.png?raw=true "images")

Some container images are pretty large especially for the OPC UA publisher module. If you are deploying the field gateway on-premises to connect industrial IoT controllers, this may require an industrial PC or a specialised IoT field gateway (physical hardware) with a capable processor, RAM, and storage. 

## OPC UA Integration

If you have a PLC, a VSD or any brownfield assets within your factory shop floor and these components are compliant with OPC UA, you may use an OPC UA Server of your choice to connect to these industrial assets. 

### Follow this tutorial
This [next tutorial](/doc/opcpublisher.md) provides you step-by-step on how to subscribe to the OPC UA nodes (which are tied to PLC tags) in the OPC UA Publisher, and publish the node values as a preset interval to Azure IoT Hub.

## OPC UA Publishers as leaf devices through an Azure IoT Edge Transparent Gateway

The current implementation of the OPC UA Publisher runs either as one of the following options:
* Runs natively as a .NET Core application connecting directly to Azure IoT Hub using its own IoT Hub device identity
* Runs as a module in an Azure IoT Edge device, with message routing to other modules (if needed). This is mostly an opaque gateway because each gateway instance has one IoT Edge device identity for authentication, and also potentially a device ID defined by the OPC UA Publisher module. However you need to develop a custom module that performs identity mapping/translation and that's additional work. If you want to connect multiple OPC UA Publisher modules you can do so but there is a maximum number of modules which can be set for each Azure IoT Edge device (currently there is a max of 10 modules under Azure IoT Edge public preview).

To understand more about the purpose of gateways in IoT solutions, read [this Azure documentation article](https://docs.microsoft.com/en-us/azure/iot-edge/iot-edge-as-gateway) which explains 3 patterns for using IoT Edge device as a gateway; transparent, protocol translation and identity translation.

### High-level Architecture
![architecture](/doc/media/iotedgetransparentgw.JPG?raw=true "architecture")

There are good reasons for establishing each OPC UA Publisher as a leaf device of its own such as the following:
* Logical separation of industrial IoT assets. You can identify each domain of the shopfloor and also enforce device ID authentication with Azure IoT Hub. This also allows you to define a device twin for each shopfloor domain. This creates a digital twin of the physical connected site and also enriches the digital plant models with metadata and also telemetry data associated with each sensor type. 
* Each OPC UA Publisher either runs natively or runs as a module in its own IoT Edge device. Each OPC UA Publisher connects to an Azure IoT Edge transparent gateway. This results in each OPC UA Publisher having its own IoT Hub device identity. You could also avoid reaching the maximum number of modules that could be deployed on each IoT Edge device. 
* You can develop/deploy other supported modules on the IoT Edge transparent gateway device such as [Azure Stream Analytics](https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-deploy-stream-analytics), [Azure Functions](https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-deploy-function) and [Azure Machine Learning](https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-deploy-machine-learning) (operationalised ML model exposed as a web service on a container). You can also develop your own custom modules for doing edge processing tasks such as de-duplication, compression, encryption, [storing data at the edge](https://docs.microsoft.com/en-us/azure/iot-edge/sql-storage), etc. Hence all OPC UA Publisher instances (leaf devices) would send data to the transparent gateway and edge processing would be applied before ingestion in IoT Hub.

* The [IoT Hub throttles and quotas](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-quotas-throttling) apply to each device. Hence each OPC UA Publisher gets its own quota per IoT Hub device so as to speak. Subscribing to OPC nodes typically result in a lot of telemetry being ingested, multipled by the number of PLC/OPC tags, this quickly becomes a throttling issue if the quota is applied to one opaque IoT Edge gateway device. 

* Proper segregation/separation in process control network (PCN). The OPC UA Publisher can run in a locked down PCN in which the OPC UA Server is also deployed. The Azure IoT Edge can either sit in a PCN DMZ network or within the enterprise/corporate network which has network connectivity. Azure IoT Edge only maintains an outbound connection to IoT Hub, which is a good security from the ground up, leaving your precious PCN completely unreachable from the public internet.

* In the IoT Edge transparent gateway, all logical device conections are multiplex over one physical connection like AMQP.

### Follow this tutorial

This [IoT Edge transparent gateway tutorial](/doc/transparentgw.md) provides you step-by-step instructions about how to setup and connect your OPC UA Publishers as leaf devices to an IoT Edge transparent gateway device.
