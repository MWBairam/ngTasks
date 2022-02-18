#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#build and publish inside docker:
#=================================
#FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
#WORKDIR /app
#EXPOSE 80
#EXPOSE 443
#EXPOSE 5001
#EXPOSE 5000
#
#FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
#WORKDIR /src
#COPY ["ng_task1_web_project/ng_task1_web_project.csproj", "ng_task1_web_project/"]
#RUN dotnet restore "ng_task1_web_project/ng_task1_web_project.csproj"
#COPY . .
#WORKDIR "/src/ng_task1_web_project"
#RUN dotnet build "ng_task1_web_project.csproj" -c Release -o /app/build
#
#FROM build AS publish
#RUN dotnet publish "ng_task1_web_project.csproj" -c Release -o /app/publish
#
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "ng_task1_web_project.dll"]





#build outside docker:
#======================
#publish/create dll files:
#dotnet publish -c Release
#the app is published here:
#.....to_solution_dir\ng_task1_web_project\bin\Release\net5.0\publish
#now the ng_task1_web_project.dll can be run using $dotnet run command line
#to build an image:
#start from .NET 5.0 (... .NET Core 2.2 -> .NET 3.1 -> .NET 5.0 (in this version, microsoft removed the word "core"))
FROM mcr.microsoft.com/dotnet/aspnet:5.0
#copy dll files to a working directory
COPY bin/Release/net5.0/publish/ App/
WORKDIR /App
#the app can work on anyport, however, just leave it in this example on 80
EXPOSE 80
#EXPOSE 443
EXPOSE 5001
#EXPOSE 5000
#ENTRYPOINT ["dotnet", "ng_task1_web_project.dll", "--applicationUrl", "https://localhost:5001"]
ENTRYPOINT ["dotnet", "ng_task1_web_project.dll"]