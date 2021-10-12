# Добавление пользователя в RabbitMQ и назначение ему прав

# Устанавливаем curl если необходимо
# Write-Host -ForegroundColor Green "[INFO] Installing curl"
#choco install curl -y

# Добавляем пользователя test
Write-Host -ForegroundColor Green "[INFO] Create user "test""
curl.exe -i -u guest:guest -H "content-type:application/json" -X PUT http://localhost:15672/api/users/test -d"{'password':'test','tags':'administrator'}"

# Добавдляем права администратора для пользователя test
Write-Host -ForegroundColor Green "[INFO] Set permissions to user "test""
curl.exe -i -u guest:guest -H "content-type:application/json" -X PUT http://localhost:15672/api/permissions/%2f/test -d"{'configure':'.*','write':'.*','read':'.*'}"