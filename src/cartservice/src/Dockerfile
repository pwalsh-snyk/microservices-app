# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0.303-noble@sha256:e1713bad94cfeca3a44d837286728a5ed40a1f59cb90be2af8b456ca0050f8a1 AS builder
WORKDIR /app
COPY cartservice.csproj .
RUN dotnet restore cartservice.csproj -r linux-arm64
COPY . .
RUN dotnet publish cartservice.csproj \
    -p:PublishSingleFile=true \
    -r linux-arm64 \
    --self-contained true \
    -p:PublishTrimmed=true \
    -p:TrimMode=full \
    -c release \
    -o /cartservice

# Debug stage
FROM debian:bullseye-slim AS debug
WORKDIR /app
COPY --from=builder /cartservice .
# Install debugging tools and ICU
RUN apt-get update && apt-get install -y libicu-dev file bash
EXPOSE 7070
ENV DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=7070
USER 1000
ENTRYPOINT ["/app/cartservice"]

