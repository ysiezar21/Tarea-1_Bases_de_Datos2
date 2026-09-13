USE AdventureWorks;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 1. INSERTAR
CREATE OR ALTER PROCEDURE sp_Person_Insert
    @FirstName   NVARCHAR(50),
    @LastName    NVARCHAR(50),
    @PersonType  NCHAR(2) = 'EM'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1) Insertar en la tabla padre (BusinessEntityID es IDENTITY, no lo damos)
        INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
        VALUES (NEWID(), GETDATE());

        -- 2) Capturar el ID autogenerado
        SET @NewID = SCOPE_IDENTITY();

        -- 3) Insertar en Person.Person con ese ID
        INSERT INTO Person.Person
            (BusinessEntityID, PersonType, NameStyle, Title,
             FirstName, MiddleName, LastName, Suffix,
             EmailPromotion, rowguid, ModifiedDate)
        VALUES
            (@NewID, @PersonType, 0, NULL,
             @FirstName, NULL, @LastName, NULL,
             0, NEWID(), GETDATE());

        COMMIT TRANSACTION;

        SELECT @NewID AS NewID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 2. ACTUALIZAR
CREATE OR ALTER PROCEDURE sp_Person_Update
    @BusinessEntityID INT,
    @FirstName        NVARCHAR(50),
    @LastName         NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Person.Person
    SET FirstName = @FirstName,
        LastName  = @LastName,
        ModifiedDate = GETDATE()
    WHERE BusinessEntityID = @BusinessEntityID;
END;
GO

-- 3. ELIMINAR
CREATE OR ALTER PROCEDURE sp_Person_Delete
    @BusinessEntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Person.Person WHERE BusinessEntityID = @BusinessEntityID;
END;
GO

-- 4. SELECCIONAR POR ID
CREATE OR ALTER PROCEDURE sp_Person_GetById
    @BusinessEntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT BusinessEntityID, PersonType, FirstName, MiddleName,
           LastName, EmailPromotion, ModifiedDate
    FROM Person.Person
    WHERE BusinessEntityID = @BusinessEntityID;
END;
GO

-- 5. BUSCAR TODOS (tabla completa)
CREATE OR ALTER PROCEDURE sp_Person_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 100 BusinessEntityID, PersonType, FirstName,
                   LastName, EmailPromotion, ModifiedDate
    FROM Person.Person
    ORDER BY BusinessEntityID;
END;
GO

-- 6. BUSCAR CON JOIN (Person + EmailAddress)
CREATE OR ALTER PROCEDURE sp_Person_GetWithEmail
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 100
        p.BusinessEntityID,
        p.FirstName,
        p.LastName,
        e.EmailAddress
    FROM Person.Person p
    INNER JOIN Person.EmailAddress e
        ON p.BusinessEntityID = e.BusinessEntityID
    ORDER BY p.BusinessEntityID;
END;
GO
