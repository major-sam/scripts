# Добавляем очередь в RabbitMQ

# Устанавливаем curl если необходимо
#Write-Host -ForegroundColor Green "[INFO] Installing curl"
#choco install curl -y

# Добавляем очередь с именем Cupis.Payout.ExecuteQueue
Write-Host -ForegroundColor Green "[INFO] Create queue Cupis.Payout.ExecuteQueue"
curl.exe -i -u guest:guest -H "content-type:application/json" -X PUT http://localhost:15672/api/queues/%2f/Cupis.Payout.ExecuteQueue -d"{'auto_delete':false,'durable':true,'arguments':{}}"
