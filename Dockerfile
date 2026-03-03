# Этап 1: Сборка приложения
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем файлы проекта и восстанавливаем зависимости
COPY ["MyFirstCI.Api/MyFirstCI.Api.csproj", "MyFirstCI.Api/"]
COPY ["MyFirstCI.sln", "."]
RUN dotnet restore "MyFirstCI.Api/MyFirstCI.Api.csproj"

# Копируем весь код и собираем приложение
COPY . .
WORKDIR "/src/MyFirstCI.Api"
RUN dotnet publish "MyFirstCI.Api.csproj" -c Release -o /app/publish

# Этап 2: Финальный образ
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Устанавливаем переменные окружения
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80

# Создаем непривилегированного пользователя
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /app
USER appuser

# Копируем собранное приложение из этапа сборки
COPY --from=build /app/publish .

# Открываем порт и указываем точку входа
EXPOSE 80
ENTRYPOINT ["dotnet", "MyFirstCI.Api.dll"]