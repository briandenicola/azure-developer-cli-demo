FROM mcr.microsoft.com/dotnet/sdk:6.0.300-bullseye-slim AS builder
WORKDIR /src/
COPY . .
RUN dotnet restore 
RUN dotnet publish -c Release --nologo -o publish/linux 

FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html
COPY --from=builder /src/publish/linux/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf 