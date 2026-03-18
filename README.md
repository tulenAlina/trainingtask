# trainingtask

iOS тренировочный проект для управления задачами.

## Системные требования

- macOS
- Xcode 16.2
- iOS 15.0+
- Ruby 3.2.0+ (рекомендуется)

## Инструкция по сборке

1. Клонировать репозиторий:
    ```bash
    git clone https://github.com/your-username/trainingtask.git
    cd trainingtask
    ```
2. Установить зависимости:
    ```bash
    bundle install
    ```
3. Открыть проект в Xcode:
    ```bash
    open trainingtask.xcworkspace
    ```
4. Выбрать целевое устройство и нажать Cmd+R для запуска

5. Собрать через fastlane:
    ```bash
    bundle exec fastlane ios build
    ```
