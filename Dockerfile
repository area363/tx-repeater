FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app
ARG COMMIT

COPY ./repeater/repeater.csproj ./repeater/
RUN dotnet restore repeater

# Copy everything else and build
COPY . ./
RUN dotnet publish repeater/repeater.csproj \
    -c Release \
    -r linux-x64 \
    -o out \
    --self-contained \
    --version-suffix $COMMIT

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
RUN apt-get update && apt-get install -y libc6-dev
COPY --from=build-env /app/out .

VOLUME /data

ENTRYPOINT ["dotnet", "repeater.dll"]
