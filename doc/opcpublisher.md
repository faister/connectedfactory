# OPC UA Publisher

This is tutorial is based on the [OPC UA Publisher for Azure IoT Edge](https://github.com/Azure/iot-edge-opc-publisher) project.

## Getting Started

These instructions will teach you how to simulate a shop floor environment consisting of PLC tags which are plugged into an OPC UA Server. You will learn how to configure the OPC UA Publisher to subscribe to these OPC UA nodes and publish it to Azure IoT Hub. 

### Prerequisites

1. Check if you have the latest .NET Core 2.x SDK installed by opening up a command prompt and enter this command:
```
dotnet --version
```

If you don't have latest .NET Core 2.x SDK on your machine, install it from the [Microsoft .NET Core download site](https://www.microsoft.com/net/download/windows)
	
2. Download and install the following files onto your local machine:
   * We are not recommending any particular vendor of an OPC UA Server, you still have you go through your own due diligence to select the right one for you based on your requirements. However in order for this tutorial to work out according to the instructions, we need to use an OPC UA Server, we are demonstaring this using the [Prosys OPC UA Simulation Server](https://www.prosysopc.com/products/opc-ua-simulation-server/). It is a multiplatform stand-alone OPC UA server that lets you configure your own simulation signals. You can request for a free download from their website. Alternatively [here is](https://scrapyard.blob.core.windows.net/share/prosys-opc-ua-simulation-server-2.3.2-146.exe) a cached copy of the installation file.
   * Pre-compiled [OPC UA Client](https://scrapyard.blob.core.windows.net/share/OPCUA.Client.Net4.zip) from OPC Foundations's [OPC UA .Net Standard Stack and Samples](https://github.com/OPCFoundation/UA-.NETStandard)
   * Download and install the latest Device Explorer installer (SetupDeviceExplorer.msi) from the Azure IoT Device Client SDK for .NET from the [releases section](https://github.com/Azure/azure-iot-sdk-csharp/releases).
	
3. Extract OPCUA.Client.Net4.zip onto your local machine. More details on the OPC UA .NET Standard Library web page. Microsoft engineers contribute to this GitHub repo at https://github.com/OPCFoundation/UA-.NETStandardLibrary
* After extracting the zip file onto your local machine, go to this folder path OPCUA.Client.Net4\Client.Net4\bin\Debug
* Run this executable - Opc.Ua.SampleClient.exe. You will get a warning from the smart screen filter, run anyway.
	
4. Git clone [OPC UA Publisher for Azure IoT Edge Git repo](https://github.com/Azure/iot-edge-opc-publisher.git)
	
5. Create an Azure IoT Hub in your own subscription. You can create a free tier if you like. Under Setttings -> Shared access policies, copy the iothubowner connection string - primary key. You need this connection string to connect the OPA UA Publisher to IoT Hub in the later steps.  
	
6. Install and Run the Prosys OPC UA Simulation Server. If the Windows Defender Firewall alert pops up, Allow all networks.

7. In the status tab of Prosys OPC UA Simulation Server, copy the connection address (UA TCP). Copy this server connection address because you will need it to configure the OPC UA Publisher. For example, mine is:
```
opc.tcp://xxxxxx:53530/OPCUA/SimulationServer
```
