ALTER TABLE BetEvents ADD LineEventId int NULL, CoefValue float NULL, CoefName nvarchar(100) NULL, Result int NULL, Comment nvarchar(100) NULL, IsManual bit NULL
GO
update BetEvents
set LineEventId = coefs.EventId,
CoefValue = coefs.CoefValue,
Result = coefs.CoefWon
from BetEvents
inner join coefs on coefs.CoefId = BetEvents.CoefID
inner join bets on bets.BetId = BetEvents.BetId
where bets.BetDeleted = 0 and bets.BetCreationTime>='20210101'
go
