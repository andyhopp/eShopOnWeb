FROM amazonlinux:latest
WORKDIR /app
COPY . ./
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
ENV DB_PARAMETER_PREFIX <INSERT_PREFIX_HERE>

RUN /bin/bash -c 'chmod +x Web'

# Optional: Set this here if not setting it from docker-compose.yml
# ENV ASPNETCORE_ENVIRONMENT Development

ENTRYPOINT ["/app/Web"]
