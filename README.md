# Under the hood of an Azure IoT Suite Connected Factory pre-configured solution
This is a step-by-step walkthrough of the Azure IoT Suite Connected Factory pre-configured solution allowing you to take a look at the services deployed under the hood.

## Getting Started

1. Go to https://www.azureiotsuite.com/. Alternatively you could also run the build script in the [Connected Factory GitHub repo](https://github.com/Azure/azure-iot-connected-factory#run-the-build-script).
	
2. Create a Connected Factory deployment. When you create the solution, there are some explanation about what services are being spun up on your subscription. The biggest cost to this is Azure Time Series Insights so you may want to delete this solution after you're done with the hack. The GitHub repo lives here. For this hack, it is not recommended that you manually deploy this off the source templates.
	
3. It takes over 10 minutes to fully deploy the resource group in your Azure subscription. You will get an email from the Azure IoT Suite Team when your PCS is ready. 

## Access the VM
	
1. For this hack, let's delve in deeper. Go to your Connected Factory resource group in the Azure portal. Find the Linux VM, and reset password. User name is docker, and you may choose either to use a password or an SSH public key (if you have one already generated). The reset password operation takes about a minute to take effect.

2. Go to the network security group, you will see that the resources are pretty much locked in. Only outbound ports for MQTT (8883), AMQP (5671) and HTTPS (443) are allowed. But to access the VM we need to enable SSH. Go to Inbound Security Rues, and add an inbound security rule. Enter the destination port as 22, and name as SSH.

3. The VM need a public IP address. Go to the network interface resource. Under IP configurations, click ipconfig1 to edit. Click "Enabled" for public IP address. Configure required settings for IP Address. Create new. Then click Ok. Click Save.
	
4. Now the Connect button should be enabled. You should see the command you could use to establish an SSH session to your Linux VM. If you have Bash on Windows enabled run it. Otherwise use a tool like Putty. 
	
5. Take a look under the hood of the Docker containers created by the preconfigured solution. Run docker ps, you will see heaps of containers deployed and running. Each container representing a particular location (with IoT Edge OPC UA publisher and proxy modules, SCADA simulator, and MES simulator.
![Containers](/img/dockercontainers.png?raw=true "Containers")
	
When you do a ls, you can see shell scripts for startsimulation, stopsimulation and deletesimulation. You can also view config files, logs, and shared volume from the Docker containers. Muck around to create your new SCADA station, with its accompanying Azure IoT Edge proxy and publisher modules.
	
6. Learn about the size of the Docker containers. Run 
```
docker images
```
![images](/img/dockerimages.png?raw=true "images")

Some container images are pretty large especially for the OPC UA publisher module. This may require an industrial PC or a specialised IoT field gateway (physical hardware) with a capable processor, RAM, and storage. However you may also run this on a Raspberry Pi 3 for a PoC, just be conscious that the Docker images must be arm-hf ones.

## OPC UA Integration

If you have a PLC, a VSD or any brownfield assets within your factory shop floor and these components are compliant with OPC UA, you may use an OPC UA Server of your choice to connect to these industrial assets. This [next tutorial](/opcpublisher.md) provides you step-by-step on how to subscribe to the OPC UA nodes (which are tied to PLC tags) in the OPC UA Publisher, and publish the node values as a preset interval to Azure IoT Hub.
