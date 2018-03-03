# Connecting OPC UA Publishers as leaf devices through an Azure IoT Edge Transparent Gateway

This IoTtutorial provides you step-by-step instructions about how to setup and connect your OPC UA Publishers as leaf devices to an IoT Edge transparent gateway device.

## First steps

Good thing that there is already [an official Azure doco page](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-create-transparent-gateway) for how to setup an IoT edge device as a transparent gateway. Just follow the steps.

## Running OPC UA Publisher as leaf device

In order for the OPC UA Publisher native application to connect to the IoT Edge device transparent gateway, it requires a dependency on version 1.6.0-preview-001 of the Azure IoT Device Client SDK. Certainly this dependency will be on the latest version of the Azure IoT Device Client SDK once IoT Edge goes into general availability (GA).
![Azure IoT Device Client SDK version](/doc/media/azuresdkversion.JPG?raw=true "SDK version")

There was a hack I made in order to make things work, especially if you are running this OPC UA Publisher on Linux:
* By right running the OPC UA Publisher as an Edge module or leaf device requires cert verification especially if running under Linux. On my first attempt running this, I did get an issue. As a shortcut, I forced it to bypass cert verification regardless of OS. I changed [this line of code](https://github.com/Azure/iot-edge-opc-publisher/blob/master/src/IotHubMessaging.cs#L243) to the following:
```
bool bypassCertVerification = true;
```
As a good hack lab challenge, you should not try this hack on first instance of running it on Linux, give it a go yourself.

The default behaviour of the OPC UA Publisher is some IoT Hub operations and key handling such as to create a new device identity with IoT Hub (if one does not exist). However we want it to use an existing device ID.
This can be done by setting an environment variable called EdgeHubConnectionString with the IoT Hub device ID connection string.

I have created a simple batch file (which could be rewritten as a Shell script to run on Linux). [RunOPCUAPublisherLeafDevice.bat]((/script/RunOPCUAPublisherLeafDevice.bat)
In the command line options, you will notice that I explicitly set the communication protocol with "IoT Hub" as Mqtt_Tcp_Only. The reason for this is because the IoT Edge transparent gateway runtime, edgeHub exposes an MQTT endpoint for receiving input messages.
