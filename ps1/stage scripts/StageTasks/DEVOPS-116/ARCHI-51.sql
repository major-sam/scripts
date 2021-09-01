CREATE TABLE CoefLogs
(
	Id bigint PRIMARY KEY IDENTITY,
	CoefId bigint NOT NULL,
	EventId int NOT NULL,
	Value float SPARSE NULL,
	Active bit SPARSE NULL,
	Result int SPARSE NULL,
	ChangeTime datetime2 NOT NULL
)
GO
CREATE NONCLUSTERED INDEX IX_CoefLogs ON dbo.CoefLogs
	(
	EventId
	)
go
CREATE NONCLUSTERED INDEX IX_CoefLogs_ChangeTime ON dbo.CoefLogs
	(
	ChangeTime
	)
go
ALTER TABLE Coefs ADD CoefName nvarchar(100) NULL, ResultTime datetime2 NULL
GO
ALTER TABLE BetEvents ADD Result int NULL, IsManual bit NULL, Comment nvarchar(100)
GO
ALTER VIEW [dbo].[BetEventResultView]
AS
SELECT 
BetEvents.BetId,
Events.EventCreationTime,
Events.EventStartTime,
Events.Live,
BetEvents.EventId,
ISNULL(BetEvents.CoefName,CoefTypes.CoefTypeName) as BetCoefName,
Events.EventTypeGroupID,
ISNULL(BetEvents.Result, Coefs.CoefWon) as CoefWon,
BetEvents.CoefValue,
ISNULL(BetEvents.Comment,Coefs.Comment) as MoneyBackComment,
Events.EventName,
CAST(CASE Events.ResultComment WHEN 'отмена' THEN 1 ELSE 0 END as bit) AS IsCanceled,
CAST(CASE WHEN Events.EventStartTime > GETDATE() THEN 1 ELSE 0 END as bit) AS IsOver,
EventComments.CommentRus as Comment,
EventComments.InfoRus as Info,
ST.SportTypeID,
Events.EventScore,
Events.EventResultText as EventResult,
EventGroupMembers.SortOrder as DrawingEventSortOrder,
GlobalTranslate.Rus as LeagueTitle
FROM BetEvents (nolock)
INNER JOIN Coefs (nolock) ON Coefs.CoefID = BetEvents.CoefID
INNER JOIN Events (nolock) ON Events.LineID = BetEvents.EventId
INNER JOIN LineMembers ST (nolock) ON Events.EventTypeGroupID = ST.LineMemberId
INNER JOIN LineMembers (nolock) ON Events.LineMemberId = LineMembers.LineMemberId
INNER JOIN GlobalTranslate (nolock) ON LineMembers.TranslateId = GlobalTranslate.Id
INNER JOIN CoefTypes (nolock) ON Coefs.CoefTypeID = CoefTypes.CoefTypeID
LEFT OUTER JOIN EventGroupMembers (nolock) ON BetEvents.BetEventId=EventGroupMembers.EventId
LEFT OUTER JOIN EventComments (nolock) ON EventComments.EventId = Events.LineID