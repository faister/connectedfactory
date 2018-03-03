@echo off
set EdgeHubConnectionString=HostName=xxxxx.azure-devices.net;DeviceId=vsdpublisher01;SharedAccessKey=xxxxxxxxxxxxxxxxx;GatewayHostName=myGateway.local
dotnet OpcPublisher.dll vsdpublisher01 vsdpublisher01 --ih=Mqtt_Tcp_Only --cv=true --sd=VSDShopFloor01 --as=true --tm=true 