DROP SEQUENCE SEQ
DROP TABLE ChildObject_ReferenceObject
DROP TABLE ReferenceObject
DROP TABLE ChildObject
DROP TABLE ParentObject

CREATE TABLE ParentObject (
	ParentObjectId INTEGER NOT NULL,
	StringAttribute NVARCHAR(100),
	IntegerAttribute INTEGER,
	DecimalAttribute DECIMAL(10,4),
	DateAttribute TIMESTAMP,
	TimestampAttribute TIMESTAMP,
	BitAttribute CHAR(1),
	CONSTRAINT PK_ParentObject_ParentObjectId PRIMARY KEY (ParentObjectId)
);


CREATE TABLE ChildObject (
	ChildObjectId INTEGER NOT NULL,
	ParentObjectId INTEGER NOT NULL,
	StringAttribute NVARCHAR(100),
	IntegerAttribute INTEGER,
	DecimalAttribute DECIMAL(10,4),
	DateAttribute TIMESTAMP,
	TimestampAttribute TIMESTAMP,
	BitAttribute CHAR(1),
	CONSTRAINT PK_ChildObject_ChildObjectId PRIMARY KEY (ChildObjectId)
);

ALTER TABLE ChildObject
	ADD CONSTRAINT FK_ChildObject_ParentObject FOREIGN KEY (ParentObjectId)
	REFERENCES ParentObject (ParentObjectId)


CREATE SEQUENCE SEQ
	START WITH 1
	INCREMENT BY 1
  

CREATE TABLE ReferenceObject (
	ReferenceObjectId INTEGER NOT NULL,
	ReferenceObjectName VARCHAR(50) NOT NULL,
	CONSTRAINT PK_ReferenceObject_ReferenceObjectId PRIMARY KEY (ReferenceObjectId)
)

INSERT INTO ReferenceObject (ReferenceObjectId, ReferenceObjectName) VALUES (NEXT VALUE FOR SEQ, 'ReferenceObject1')
INSERT INTO ReferenceObject (ReferenceObjectId, ReferenceObjectName) VALUES (NEXT VALUE FOR SEQ, 'ReferenceObject2')


CREATE TABLE ChildObject_ReferenceObject (
	ChildObjectId INTEGER NOT NULL,
	ReferenceObjectId INTEGER NOT NULL,
	CONSTRAINT PK_ChildObject_ReferenceObject PRIMARY KEY (ChildObjectId, ReferenceObjectId)
)

ALTER TABLE ChildObject_ReferenceObject
	ADD CONSTRAINT FK_ChildObject_ReferenceObject_ChildObjectId FOREIGN KEY (ChildObjectId)
	REFERENCES ChildObject (ChildObjectId)

ALTER TABLE ChildObject_ReferenceObject
	ADD CONSTRAINT FK_ChildObject_ReferenceObject_ReferenceObjectId FOREIGN KEY (ReferenceObjectId)
	REFERENCES ReferenceObject (ReferenceObjectId)



