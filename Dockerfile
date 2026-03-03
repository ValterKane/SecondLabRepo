FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Копируем все файлы проекта
COPY . .

# Восстанавливаем и публикуем
RUN dotnet restore
RUN dotnet publish MyFirstCI.Api/MyFirstCI.Api.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "MyFirstCI.Api.dll"]