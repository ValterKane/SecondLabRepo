# Этап 1: Сборка приложения
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем файлы проектов для восстановления зависимостей
COPY ["MyFirstCI.Api/MyFirstCI.Api.csproj", "MyFirstCI.Api/"]
COPY ["MyFirstCI.Tests/MyFirstCI.Tests.csproj", "MyFirstCI.Tests/"]
COPY ["MyFirstCI.sln", "./"]

# Восстанавливаем зависимости
RUN dotnet restore "MyFirstCI.Api/MyFirstCI.Api.csproj"

# Копируем все исходники
COPY . .

# Публикуем приложение
WORKDIR "/src/MyFirstCI.Api"
RUN dotnet publish "MyFirstCI.Api.csproj" -c Release -o /app/publish

# Этап 2: Финальный образ
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Создаем непривилегированного пользователя
RUN addgroup --system --gid 1000 appgroup && \
    adduser --system --uid 1000 --gid 1000 appuser
USER appuser

# Копируем собранное приложение из этапа сборки
COPY --from=build /app/publish .

# Открываем порт
EXPOSE 8080

# Настройка переменных окружения для Kestrel
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Точка входа
ENTRYPOINT ["dotnet", "MyFirstCI.Api.dll"]