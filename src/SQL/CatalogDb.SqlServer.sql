IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'CatalogDb')
  CREATE DATABASE CatalogDb
GO

USE CatalogDb
GO

IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;

GO

CREATE SEQUENCE [catalog_brand_hilo] START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

GO

CREATE SEQUENCE [catalog_hilo] START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

GO

CREATE SEQUENCE [catalog_type_hilo] START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

GO

CREATE TABLE [Baskets] (
    [Id] int NOT NULL,
    [BuyerId] nvarchar(max) NULL,
    CONSTRAINT [PK_Baskets] PRIMARY KEY ([Id])
);

GO

CREATE TABLE [CatalogBrand] (
    [Id] int NOT NULL,
    [Brand] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_CatalogBrand] PRIMARY KEY ([Id])
);

GO

CREATE TABLE [CatalogType] (
    [Id] int NOT NULL,
    [Type] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_CatalogType] PRIMARY KEY ([Id])
);

GO

CREATE TABLE [Orders] (
    [Id] int NOT NULL,
    [BuyerId] nvarchar(max) NULL,
    [OrderDate] datetimeoffset NOT NULL,
    [ShipToAddress_City] nvarchar(max) NULL,
    [ShipToAddress_Country] nvarchar(max) NULL,
    [ShipToAddress_State] nvarchar(max) NULL,
    [ShipToAddress_Street] nvarchar(max) NULL,
    [ShipToAddress_ZipCode] nvarchar(max) NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY ([Id])
);

GO

CREATE TABLE [BasketItem] (
    [Id] int NOT NULL,
    [BasketId] int NULL,
    [CatalogItemId] int NOT NULL,
    [Quantity] int NOT NULL,
    [UnitPrice] decimal(18, 2) NOT NULL,
    CONSTRAINT [PK_BasketItem] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_BasketItem_Baskets_BasketId] FOREIGN KEY ([BasketId]) REFERENCES [Baskets] ([Id]) ON DELETE NO ACTION
);

GO

CREATE TABLE [Catalog] (
    [Id] int NOT NULL,
    [CatalogBrandId] int NOT NULL,
    [CatalogTypeId] int NOT NULL,
    [Description] nvarchar(max) NULL,
    [Name] nvarchar(50) NOT NULL,
    [PictureUri] nvarchar(max) NULL,
    [Price] decimal(18, 2) NOT NULL,
    CONSTRAINT [PK_Catalog] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Catalog_CatalogBrand_CatalogBrandId] FOREIGN KEY ([CatalogBrandId]) REFERENCES [CatalogBrand] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_Catalog_CatalogType_CatalogTypeId] FOREIGN KEY ([CatalogTypeId]) REFERENCES [CatalogType] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [OrderItems] (
    [Id] int NOT NULL,
    [OrderId] int NULL,
    [UnitPrice] decimal(18, 2) NOT NULL,
    [Units] int NOT NULL,
    [ItemOrdered_CatalogItemId] int NOT NULL,
    [ItemOrdered_PictureUri] nvarchar(max) NULL,
    [ItemOrdered_ProductName] nvarchar(max) NULL,
    CONSTRAINT [PK_OrderItems] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([Id]) ON DELETE NO ACTION
);

GO

CREATE INDEX [IX_BasketItem_BasketId] ON [BasketItem] ([BasketId]);

GO

CREATE INDEX [IX_Catalog_CatalogBrandId] ON [Catalog] ([CatalogBrandId]);

GO

CREATE INDEX [IX_Catalog_CatalogTypeId] ON [Catalog] ([CatalogTypeId]);

GO

CREATE INDEX [IX_OrderItems_OrderId] ON [OrderItems] ([OrderId]);

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20171018175735_Initial', N'2.2.3-servicing-35854');

GO

DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_ZipCode');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var0 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_ZipCode] nvarchar(18) NOT NULL;

GO

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_Street');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_Street] nvarchar(180) NOT NULL;

GO

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_State');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_State] nvarchar(60) NULL;

GO

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_Country');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var3 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_Country] nvarchar(90) NOT NULL;

GO

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_City');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var4 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_City] nvarchar(100) NOT NULL;

GO

DECLARE @var5 sysname;
SELECT @var5 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_ProductName');
IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var5 + '];');
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_ProductName] nvarchar(50) NOT NULL;

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180725190153_AddExtraConstraints', N'2.2.3-servicing-35854');

GO


