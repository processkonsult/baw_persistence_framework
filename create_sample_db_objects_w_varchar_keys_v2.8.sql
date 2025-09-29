/*
select * from dbo.ParentObject
select * from dbo.ChildObject
select * from dbo.NestedChildObject
select * from dbo.ReferenceObject
select * from dbo.ChildObject_ReferenceObject
select * from dbo.ChildListObject
select * from dbo.ChildListObject_ReferenceObject
*/

IF OBJECT_ID('dbo.SEQ') IS NOT NULL
	DROP SEQUENCE dbo.SEQ
GO
IF OBJECT_ID('dbo.ChildObject_ReferenceObject') IS NOT NULL
	DROP TABLE dbo.ChildObject_ReferenceObject
GO
IF OBJECT_ID('dbo.ChildListObject_ReferenceObject') IS NOT NULL
	DROP TABLE dbo.ChildListObject_ReferenceObject
GO
IF OBJECT_ID('dbo.ReferenceObject') IS NOT NULL
	DROP TABLE dbo.ReferenceObject
GO
IF OBJECT_ID('dbo.NestedChildListObject') IS NOT NULL
	DROP TABLE dbo.NestedChildListObject
GO
IF OBJECT_ID('dbo.ChildListObject') IS NOT NULL
	DROP TABLE dbo.ChildListObject
GO
IF OBJECT_ID('dbo.ParentObject') IS NOT NULL
	DROP TABLE dbo.ParentObject
GO
IF OBJECT_ID('dbo.ChildObject') IS NOT NULL
	DROP TABLE dbo.ChildObject
GO
IF OBJECT_ID('dbo.NestedChildObject') IS NOT NULL
	DROP TABLE dbo.NestedChildObject
GO

CREATE TABLE dbo.NestedChildObject (
	--NestedChildObjectId INTEGER NOT NULL CONSTRAINT PK_NestedChildObject_NestedChildObjectId PRIMARY KEY CLUSTERED,
	NestedChildObjectId VARCHAR(10) NOT NULL CONSTRAINT PK_NestedChildObject_NestedChildObjectId PRIMARY KEY CLUSTERED,
	StringAttribute NVARCHAR(100),
	IntegerAttribute INTEGER,
	DecimalAttribute DECIMAL(10,4),
	DateAttribute DATETIME,
	TimestampAttribute DATETIME,
	BitAttribute BIT
);

CREATE TABLE dbo.ChildObject (
	--ChildObjectId INTEGER NOT NULL CONSTRAINT PK_ChildObject_ChildObjectId PRIMARY KEY CLUSTERED,
	ChildObjectId VARCHAR(10) NOT NULL CONSTRAINT PK_ChildObject_ChildObjectId PRIMARY KEY CLUSTERED,
	--NestedChildObjectId INTEGER CONSTRAINT FK_ChildObject_NestedChildObjectId FOREIGN KEY REFERENCES NestedChildObject(NestedChildObjectId),
	NestedChildObjectId VARCHAR(10) CONSTRAINT FK_ChildObject_NestedChildObjectId FOREIGN KEY REFERENCES NestedChildObject(NestedChildObjectId),
	StringAttribute NVARCHAR(100),
	IntegerAttribute INTEGER,
	DecimalAttribute DECIMAL(10,4),
	DateAttribute DATETIME,
	TimestampAttribute DATETIME,
	BitAttribute BIT
);

CREATE TABLE dbo.ParentObject (
	--ParentObjectId INTEGER NOT NULL CONSTRAINT PK_ParentObject_ParentObjectId PRIMARY KEY CLUSTERED,
	ParentObjectId VARCHAR(10) NOT NULL CONSTRAINT PK_ParentObject_ParentObjectId PRIMARY KEY CLUSTERED,
	--ChildObjectId INTEGER CONSTRAINT FK_ParentObject_ChildObjectId FOREIGN KEY REFERENCES ChildObject(ChildObjectId),
	--ChildObjectId VARCHAR(10) CONSTRAINT FK_ParentObject_ChildObjectId FOREIGN KEY REFERENCES ChildObject(ChildObjectId),
	--ChildObject1Id INTEGER CONSTRAINT FK_ParentObject_ChildObject1Id FOREIGN KEY REFERENCES ChildObject(ChildObjectId),
	ChildObject1Id VARCHAR(10) CONSTRAINT FK_ParentObject_ChildObject1Id FOREIGN KEY REFERENCES ChildObject(ChildObjectId),
	--ChildObject2Id INTEGER CONSTRAINT FK_ParentObject_ChildObject2Id FOREIGN KEY REFERENCES ChildObject(ChildObjectId),
	ChildObject2Id VARCHAR(10) CONSTRAINT FK_ParentObject_ChildObject2Id FOREIGN KEY REFERENCES ChildObject(ChildObjectId),
	StringAttribute NVARCHAR(100),
	IntegerAttribute INTEGER,
	DecimalAttribute DECIMAL(10,4),
	DateAttribute DATETIME,
	TimestampAttribute DATETIME,
	BitAttribute BIT
);
GO

CREATE TABLE dbo.ChildListObject (
	--ChildListObjectId INTEGER NOT NULL CONSTRAINT PK_ChildListObject_ChildListObjectId PRIMARY KEY CLUSTERED,
	ChildListObjectId VARCHAR(10) NOT NULL CONSTRAINT PK_ChildListObject_ChildListObjectId PRIMARY KEY CLUSTERED,
	--ParentObjectId INTEGER NOT NULL CONSTRAINT FK_ChildListObject_ParentObjectId FOREIGN KEY REFERENCES ParentObject(ParentObjectId),
	ParentObjectId VARCHAR(10) CONSTRAINT FK_ChildListObject_ParentObjectId FOREIGN KEY REFERENCES ParentObject(ParentObjectId),
	--NestedChildObjectId INTEGER NOT NULL CONSTRAINT FK_ChildListObject_NestedChildObjectId FOREIGN KEY REFERENCES NestedChildObject(NestedChildObjectId),
	NestedChildObjectId VARCHAR(10) CONSTRAINT FK_ChildListObject_NestedChildObjectId FOREIGN KEY REFERENCES NestedChildObject(NestedChildObjectId),
	StringAttribute NVARCHAR(100),
	IntegerAttribute INTEGER,
	DecimalAttribute DECIMAL(10,4),
	DateAttribute DATETIME,
	TimestampAttribute DATETIME,
	BitAttribute BIT
);
GO

CREATE TABLE dbo.NestedChildListObject (
	NestedChildListObjectId VARCHAR(10) NOT NULL CONSTRAINT PK_NestedChildListObject PRIMARY KEY CLUSTERED,
	ChildListObjectId VARCHAR(10) NOT NULL CONSTRAINT FK_NestedChildListObject_ChildListObjectId FOREIGN KEY REFERENCES ChildListObject(ChildListObjectId),
	NestedChildListObjectValue VARCHAR(100) NOT NULL
);
GO

CREATE SEQUENCE dbo.SEQ
	START WITH 1
	INCREMENT BY 1
GO  

CREATE TABLE dbo.ReferenceObject (
	--ReferenceObjectId INTEGER NOT NULL CONSTRAINT PK_ReferenceObject_ReferenceObjectId PRIMARY KEY CLUSTERED,
	ReferenceObjectId VARCHAR(10) NOT NULL CONSTRAINT PK_ReferenceObject_ReferenceObjectId PRIMARY KEY CLUSTERED,
	ReferenceObjectName VARCHAR(50) NOT NULL
)
GO
INSERT INTO dbo.ReferenceObject (ReferenceObjectId, ReferenceObjectName) VALUES (1, 'ReferenceObject1')
INSERT INTO dbo.ReferenceObject (ReferenceObjectId, ReferenceObjectName) VALUES (2, 'ReferenceObject2')
GO

CREATE TABLE dbo.ChildObject_ReferenceObject (
	--ChildObjectId INTEGER NOT NULL CONSTRAINT FK_ChildObject_ReferenceObject_ChildObjectId FOREIGN KEY REFERENCES dbo.ChildObject(ChildObjectId),
	ChildObjectId VARCHAR(10) NOT NULL CONSTRAINT FK_ChildObject_ReferenceObject_ChildObjectId FOREIGN KEY REFERENCES dbo.ChildObject(ChildObjectId),
	--ReferenceObjectId INTEGER NOT NULL CONSTRAINT FK_ChildObject_ReferenceObject_ReferenceObjectId FOREIGN KEY REFERENCES dbo.ReferenceObject(ReferenceObjectId),
	ReferenceObjectId VARCHAR(10) NOT NULL CONSTRAINT FK_ChildObject_ReferenceObject_ReferenceObjectId FOREIGN KEY REFERENCES dbo.ReferenceObject(ReferenceObjectId),
	CONSTRAINT PK_ChildObject_ReferenceObject PRIMARY KEY CLUSTERED (ChildObjectId, ReferenceObjectId)
)
GO

CREATE TABLE dbo.ChildListObject_ReferenceObject (
	--ChildListObjectId INTEGER NOT NULL CONSTRAINT FK_ChildListObject_ReferenceObject_ChildListObjectId FOREIGN KEY REFERENCES dbo.ChildListObject(ChildListObjectId),
	ChildListObjectId VARCHAR(10) NOT NULL CONSTRAINT FK_ChildListObject_ReferenceObject_ChildListObjectId FOREIGN KEY REFERENCES dbo.ChildListObject(ChildListObjectId),
	--ReferenceObjectId INTEGER NOT NULL CONSTRAINT FK_ChildListObject_ReferenceObject_ReferenceObjectId FOREIGN KEY REFERENCES dbo.ReferenceObject(ReferenceObjectId),
	ReferenceObjectId VARCHAR(10) NOT NULL CONSTRAINT FK_ChildListObject_ReferenceObject_ReferenceObjectId FOREIGN KEY REFERENCES dbo.ReferenceObject(ReferenceObjectId),
	CONSTRAINT PK_ChildListObject_ReferenceObject PRIMARY KEY CLUSTERED (ChildListObjectId, ReferenceObjectId)
)
GO

