# FROM mcr.microsoft.com/windows/servercore:1809_amd64
FROM mcr.microsoft.com/windows:ltsc2019-amd64

# Set our shell to PowerShell and specify error handling
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]
RUN PowerShell Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

ADD https://dist.nuget.org/win-x86-commandline/latest/nuget.exe C:\\TEMP\\nuget.exe
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools19.exe
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools17.exe
COPY scripts/Install-VCTools.ps1 C:\\TEMP\\Install-VCTools.ps1
COPY scripts/7z.exe C:\\TEMP\\7z.exe
COPY scripts/7z.dll C:\\TEMP\\7z.dll
COPY scripts/Install-WDK.ps1 C:\\TEMP\\Install-WDK.ps1
COPY scripts/wdksetup.exe C:\\TEMP\\wdksetup.exe

RUN PowerShell -ExecutionPolicy ByPass -File C:\\TEMP\\Install-VCTools.ps1
RUN PowerShell C:\\TEMP\\Install-WDK.ps1

ARG nim_version=1.6.2
ARG nim_uri="https://nim-lang.org/download/nim-"$nim_version"_x64.zip"

# Download compiled Nim binaries
RUN Invoke-WebRequest -Uri $env:nim_uri -OutFile nim.zip
RUN Expand-Archive -Path 'nim.zip' -DestinationPath 'c:\\'

# Rename the resulting extracted directory
RUN Get-ChildItem -Path 'c:\\' | Where-Object { $_.Name -like 'nim-*' } | %{ Rename-Item -LiteralPath $_.FullName -NewName 'nim' }

# https://stackoverflow.com/questions/37885795/how-do-i-set-system-path-in-my-dockerfile-for-a-windows-container
ENV NIM_PATH="C:\nim"

ARG mingit_uri="https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/MinGit-2.42.0.2-64-bit.zip"

# Download compatible mingw binaries as mingw.7z
RUN curl 'https://nim-lang.org/download/mingw64.7z' -o C:\\nim\\dist\\mingw64.7z
# RUN curl "https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z" -o C:\\nim\\dist\\mingw64.7z

RUN cd C:\\TEMP
RUN C:\\TEMP\\7z.exe x C:\\nim\\dist\\mingw64.7z -oC:\\nim\\dist
# RUN Remove-Item -Path C:\\nim\\dist\\mingw64.7z

# Download compiled MinGit binaries
RUN echo "$env:mingit_uri": $env:mingit_uri
RUN Invoke-WebRequest -Uri $env:mingit_uri -OutFile mingit.zip
# Expand mingit.zip to c:\nim\dist\mingit\
RUN Expand-Archive -Path 'mingit.zip' -DestinationPath 'c:\\nim\\dist\\mingit\\'
RUN Remove-Item -Path mingit.zip

# https://github.com/sirredbeard/nim-windows-container/blob/main/Dockerfile
# Set the Path environment variable to include nim, mingw, mingit, and nimble locations
RUN "[Environment]::SetEnvironmentVariable('Path', '${env:Path};C:\nim\bin;C:\nim\dist\mingw64\bin;${env:USERPROFILE}\.nimble\bin;c:\nim\dist\mingit\cmd;C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\TEMP', [System.EnvironmentVariableTarget]::User)"

# COPY --from=build "c:\nim" "c:\nim"
RUN cd C:\\nim
RUN C:\\nim\\finish.exe -y
# RUN "nimble update"
RUN C:\\nim\\bin\\nimble update
RUN Remove-Item -Path "C:\\nim.zip"
RUN Remove-Item -Path 'C:\\TEMP\\nuget.exe'
RUN Remove-Item -Path 'C:\\TEMP\\vs_buildtools19.exe'
RUN Remove-Item -Path 'C:\\TEMP\\vs_buildtools17.exe'
RUN Remove-Item -Path 'C:\\TEMP\\Install-VCTools.ps1'
RUN Remove-Item -Path 'C:\\TEMP\\7z.exe'
RUN Remove-Item -Path 'C:\\TEMP\\7z.dll'
RUN Remove-Item -Path 'C:\\TEMP\\Install-WDK.ps1'
RUN Remove-Item -Path 'C:\\TEMP\\wdksetup.exe'