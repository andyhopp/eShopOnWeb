FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS builder
WORKDIR /
COPY src/ src/
WORKDIR /src/Web
RUN dotnet publish -c Release -r linux-x64 -o /app

FROM amazonlinux:latest as production
WORKDIR /app
COPY --from=builder /app .
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
ENV DB_PARAMETER_PREFIX <INSERT_PREFIX_HERE>

RUN /bin/bash -c 'chmod +x Web'

# Optional: Set this here if not setting it from docker-compose.yml
# ENV ASPNETCORE_ENVIRONMENT Development

ENTRYPOINT ["/app/Web"]