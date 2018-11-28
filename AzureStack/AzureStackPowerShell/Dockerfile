# Indicates that the windowsservercore image will be used as the base image.
FROM microsoft/windowsservercore

# Metadata indicating an image maintainer.
LABEL MAINTAINER Masahiko ebisuda ebibibi@gmail.com

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /

RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force ; \
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted ; \
Install-Module -Name AzureRm.BootStrapper ; \
Use-AzureRmProfile -Profile 2017-03-09-profile -Force ; \
Install-Module -Name AzureStack -RequiredVersion 1.4.0

RUN Cd / ; \
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile C:\master.zip ; \
expand-archive C:\master.zip -DestinationPath . -Force

ENTRYPOINT [ "powershell.exe" ]