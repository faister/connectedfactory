# OPC UA Publisher

This is tutorial is based on the [OPC UA Publisher for Azure IoT Edge](https://github.com/Azure/iot-edge-opc-publisher) project.

## Getting Started

This is a step-by-step guide on how to simulate a factory/site shop floor consisting of PLC tags which are connected into an OPC UA Server. Most OPC UA Servers have existing add-ins which allow a number of connectivity options such as Modbus over TCP, etc. You will learn how to configure the OPC UA Publisher to subscribe to these OPC UA nodes and publish it to Azure IoT Hub. 

### Prerequisites

.1. Check if you have the latest .NET Core 2.x SDK installed by opening up a command prompt and enter this command:
```
dotnet --version
```

If you don't have latest .NET Core 2.x SDK on your machine, install it from the [Microsoft .NET Core download site](https://www.microsoft.com/net/download/windows)
	
2. Download and install the following files onto your local machine:
   * We are not recommending any particular vendor of an OPC UA Server, you still have you go through your own due diligence to select the right one for you based on your requirements. However in order for this tutorial to work out according to the instructions, we need to use an OPC UA Server, we are demonstrating this using the [Prosys OPC UA Simulation Server](https://www.prosysopc.com/products/opc-ua-simulation-server/). It is a multiplatform stand-alone OPC UA server that lets you configure your own simulation signals. You can request for a free download from their website. Alternatively [here is](https://scrapyard.blob.core.windows.net/share/prosys-opc-ua-simulation-server-2.3.2-146.exe) a cached copy of the installation file.
   * Pre-compiled [OPC UA Client](https://scrapyard.blob.core.windows.net/share/OPCUA.Client.Net4.zip) from OPC Foundations's [OPC UA .Net Standard Stack and Samples](https://github.com/OPCFoundation/UA-.NETStandard)
   * Download and install the latest Device Explorer installer (SetupDeviceExplorer.msi) from the Azure IoT Device Client SDK for .NET from the [releases section](https://github.com/Azure/azure-iot-sdk-csharp/releases).
	
3. Extract OPCUA.Client.Net4.zip onto your local machine. More details on the OPC UA .NET Standard Library web page. Microsoft engineers as part of the contributors to this GitHub repo at https://github.com/OPCFoundation/UA-.NETStandardLibrary
* After extracting the zip file onto your local machine, go to this folder path OPCUA.Client.Net4\Client.Net4\bin\Debug
* Run this executable - Opc.Ua.SampleClient.exe. You will get a warning from the smart screen filter, run anyway.
	
4. Git clone [OPC UA Publisher for Azure IoT Edge Git repo](https://github.com/Azure/iot-edge-opc-publisher.git)
	
5. Create an Azure IoT Hub in your own subscription. You can create a free tier if you like but please be aware that there is a daily quota of messages ingested. Under Setttings -> Shared access policies, copy the iothubowner connection string - primary key. You need this connection string to connect the OPA UA Publisher to IoT Hub in the later steps.  

6. Install and Run the Prosys OPC UA Simulation Server. If the Windows Defender Firewall alert pops up, Allow all networks.

7. In the status tab of Prosys OPC UA Simulation Server, copy the connection address (UA TCP). Copy this server connection address because you will need it to configure the OPC UA Publisher. For example, mine is:
```
opc.tcp://xxxxxx:53530/OPCUA/SimulationServer
```

### Running OPC UA Publisher

1. Go to the folder in which you have extracted iot-edge-opc-publisher.zip. Go to iot-edge-opc-publisher\src\
Note: We are not building a Docker container to make things simple. Besides the Azure IoT Edge architecture has changed a lot since the OPC UA Publisher IoT Edge module was published on GitHub.
	
2. Open a command prompt with elevated permission, (Run as Administrator). This step may take some time to run.
```
dotnet restore
```

3. Create a new folder named release under iot-edge-opc-publisher\src
	
4. Go back to your command prompt window, run the following:
```
dotnet publish --configuration Release --output release
```	

5. Go to the release folder.
	
6. Edit publishednodes.json with your favourite editor, i.e., [Visual Studio Code](https://code.visualstudio.com/).
	
7. Change the EndPointUrl with the one which you have copied in Step 7 from the Prosys OPC UA Simulation Server. Take note of the following in the OpcNodes
```
"ExpandedNodeId": "nsu=http://www.prosysopc.com/OPCUA/SimulationNodes;ns=5;s=Counter1",
```
This is for configuring the OPC UA Publisher IoT Edge module to subscribe to the simulated node. How do you know this is the right value? Go to the Prosys OPC UA Simulation Server, click the Address tab, expand Objects, then Simulation, click on Counter1. You see that the NodeID is ns=5;s=Counter1. However you do need to append the nsu property because this is the new OPC UA node ID format supported by the OPC UA Publisher.
![simulated node](/doc/media/simunodeid.png?raw=true "simunodeid")
	
8. Now we run the OPC UA Publisher IoT Edge module natively on Windows with the following command
```
dotnet OpcPublisher.dll <applicationname> [<iothubconnectionstring>] [options]
````		

Typically I set a number of command line options, and I would create a batch file or shell script to run this task with those options.
Please refer to [OPC UA Publisher command-line options](https://github.com/Azure/iot-edge-opc-publisher#running-the-application) for more options.




9. The OPC UA security model is based upon certificates, trusted certs are placed in iot-edge-opc-publisher\src\release\CertificateStores\trusted\certs while rejected certs are in iot-edge-opc-publisher\src\release\CertificateStores\rejected\certs.
	
10. This is the first time you are connecting from the OPC UA Publisher to the Prosys OPC UA Simulation Server, the cert is rejected by default. You need to manually move the rejected cert into the trusted cert folder.
	
11. Hit Enter your console window because we need to rerun the OPC UA Publisher.
	
12. Rerun step 8
	
13. Now you will receive an error that looks like the following:
```
Error establishing a connection: Error received from remote host: Bad_SecurityChecksFailed (code=0x80130000, description="An error occurred verifying security.")
```

14. Now you need to trust the OPC UA Publisher client certificate in the Prosys OPC UA Simulation Server. Go to the Certificates tab.
	
15. My application name was sydpublisher and you can see the cert was rejected. Right-mouse click on the rejected cert, and click Trust.
	
16. Hit Enter your console window because we need to rerun the OPC UA Publisher.
	
17. The next step is to simulate some telemetry from the Prosys OPC UA Simulation Server. Go to the Simulation tab. On Counter1, tick Visualize. Click Counter1, and make sure you click Apply in the Node settings. You may change the parameters as you wish. 
	
18. In order to view telemetry ingested into IoT Hub, we need to use a tool such as the Device Explorer. Run and install SetupDeviceExplorer.msi.
	
19. Paste the iothubowner connection string which you had copied in Prerequisites Step 5 onto the IoT Hub Connection String textbox. Click Update.
	
20. Go to the Management tab. You would also see that the OPC UA Publisher application name you provided in Step 16 now appears as a device in IoT Hub.
	
21. Go to the Data tab. Select your device, and click Monitor. Can you see telemetry flowing off the IoT Hub?

22. If the answer to the question above is No, tough luck! But are you going to give up? Time for some troubleshooting. Scroll down for more steps….

### Getting Published Nodes using an OPC UA Client

This application, apart from including an OPC UA client for connecting to existing OPC UA servers you have on your network, also includes an OPC UA server on port 62222 that can be used to manage what gets published.
From <https://github.com/Azure/iot-edge-opc-publisher> 	
1. Refer to Prerequisites Step 3 above.
	
2. You can connect to the OPC UA Publisher at opc.tcp://localhost:62222/UA/Publisher - [SignAndEncrypt:Basic256Sha256:Binary]
	
3. You need to trust the UA Sample Client certificate by  moving the cert from the rejected to trusted folder in your OPC UA Publisher module.
	
4. Reconnect after you have done step 3.
	
5. You can PublishNode, UnpublishNode, or GetPublishedNodes.
![uasampleclient](/doc/media/uasampleclient.png?raw=true "uasampleclient")

6. Right-mouse click on GetPublishedNodes and click Call.
![getpublishednodes](/doc/media/getpublishednodes.png?raw=true "getpublishednodes")

7. In the next pop-up window, click Call again.
	
8. Did you notice that the published nodes string is not quite right? NodeId":{"Identifier":"ns=65535;s=Counter1"}}. It's supposed to be ns=5;Counter=1. This seems like a bug, since the OPC UA Publisher IoT Edge module is completely open sourced on GitHub, any takers on fixing this and submitting a pull request?
![callmethod](/doc/media/callmethod.png?raw=true "callmethod")

9. To fix this, we have to publish the correct nodeID. Right-mouse click on PublishNode and click Call.
	
10. In the pop-up window, double click on the Value column for NodeId. Paste the following onto the value
```
ns=5;s=Counter1
```
11. Double-click Value for Endpoint Uri, enter Prosys OPC UA Simulation Server connection address (UA TCP) from Step 7 above.

12. Now make sure that your OPC UA Publisher IoT Edge module is still running, go back to Device Explorer and monitor events. You should see telemetry flowing in. Voila!

