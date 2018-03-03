@echo off
set EdgeHubConnectionString=HostName=ausmote17d80.azure-devices.net;DeviceId=vsdpublisher01;SharedAccessKey=yHl6egfnliYhxjaKb4INQ5hRy3RdJoUeMrDG9jd0XA4=;GatewayHostName=myGateway.local
dotnet OpcPublisher.dll vsdpublisher01 vsdpublisher01 --ih=Mqtt_Tcp_Only --cv=true --sd=VSDShopFloor01 --as=true --tm=true 