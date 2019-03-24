CREATE DATABASE IF NOT EXISTS `CatalogDb`;
USE `CatalogDb`;

CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(95) NOT NULL,
    `ProductVersion` varchar(32) NOT NULL,
    CONSTRAINT `PK___EFMigrationsHistory` PRIMARY KEY (`MigrationId`)
);
-- CREATE SEQUENCE `catalog_brand_hilo` START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;
-- CREATE SEQUENCE `catalog_hilo` START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;
-- CREATE SEQUENCE `catalog_type_hilo` START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

CREATE TABLE `Baskets` (
    `Id` int NOT NULL,
    `BuyerId` TEXT NULL,
    CONSTRAINT `PK_Baskets` PRIMARY KEY (`Id`)
);

CREATE TABLE `CatalogBrand` (
    `Id` int NOT NULL,
    `Brand` nvarchar(100) NOT NULL,
    CONSTRAINT `PK_CatalogBrand` PRIMARY KEY (`Id`)
);

CREATE TABLE `CatalogType` (
    `Id` int NOT NULL,
    `Type` nvarchar(100) NOT NULL,
    CONSTRAINT `PK_CatalogType` PRIMARY KEY (`Id`)
);

CREATE TABLE `Orders` (
    `Id` int NOT NULL,
    `BuyerId` TEXT NULL,
    `OrderDate` timestamp NOT NULL,
    `ShipToAddress_City` TEXT NULL,
    `ShipToAddress_Country` TEXT NULL,
    `ShipToAddress_State` TEXT NULL,
    `ShipToAddress_Street` TEXT NULL,
    `ShipToAddress_ZipCode` TEXT NULL,
    CONSTRAINT `PK_Orders` PRIMARY KEY (`Id`)
);

CREATE TABLE `BasketItem` (
    `Id` int NOT NULL,
    `BasketId` int NULL,
    `CatalogItemId` int NOT NULL,
    `Quantity` int NOT NULL,
    `UnitPrice` decimal(18, 2) NOT NULL,
    CONSTRAINT `PK_BasketItem` PRIMARY KEY (`Id`),
    CONSTRAINT `FK_BasketItem_Baskets_BasketId` FOREIGN KEY (`BasketId`) REFERENCES `Baskets` (`Id`) ON DELETE RESTRICT
);
CREATE TABLE `Catalog` (
    `Id` int NOT NULL,
    `CatalogBrandId` int NOT NULL,
    `CatalogTypeId` int NOT NULL,
    `Description` TEXT NULL,
    `Name` nvarchar(50) NOT NULL,
    `PictureUri` TEXT NULL,
    `Price` decimal(18, 2) NOT NULL,
    CONSTRAINT `PK_Catalog` PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Catalog_CatalogBrand_CatalogBrandId` FOREIGN KEY (`CatalogBrandId`) REFERENCES `CatalogBrand` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_Catalog_CatalogType_CatalogTypeId` FOREIGN KEY (`CatalogTypeId`) REFERENCES `CatalogType` (`Id`) ON DELETE CASCADE
);
CREATE TABLE `OrderItems` (
    `Id` int NOT NULL,
    `OrderId` int NULL,
    `UnitPrice` decimal(18, 2) NOT NULL,
    `Units` int NOT NULL,
    `ItemOrdered_CatalogItemId` int NOT NULL,
    `ItemOrdered_PictureUri` TEXT NULL,
    `ItemOrdered_ProductName` TEXT NULL,
    CONSTRAINT `PK_OrderItems` PRIMARY KEY (`Id`),
    CONSTRAINT `FK_OrderItems_Orders_OrderId` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`) ON DELETE RESTRICT
);
CREATE INDEX `IX_BasketItem_BasketId` ON `BasketItem` (`BasketId`);
CREATE INDEX `IX_Catalog_CatalogBrandId` ON `Catalog` (`CatalogBrandId`);
CREATE INDEX `IX_Catalog_CatalogTypeId` ON `Catalog` (`CatalogTypeId`);
CREATE INDEX `IX_OrderItems_OrderId` ON `OrderItems` (`OrderId`);

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20171018175735_Initial', '2.2.2-servicing-10034');
ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_ZipCode` varchar(18) NOT NULL;
ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_Street` varchar(180) NOT NULL;
ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_State` varchar(60) NULL;
ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_Country` varchar(90) NOT NULL;
ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_City` varchar(100) NOT NULL;
ALTER TABLE `OrderItems` MODIFY COLUMN `ItemOrdered_ProductName` varchar(50) NOT NULL;
INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`) VALUES ('20180725190153_AddExtraConstraints', '2.2.2-servicing-10034');
