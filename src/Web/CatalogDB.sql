CREATE DATABASE IF NOT EXISTS `CatalogDb`;
USE `CatalogDb`;

CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(95) NOT NULL,
    `ProductVersion` varchar(32) NOT NULL,
    CONSTRAINT `PK___EFMigrationsHistory` PRIMARY KEY (`MigrationId`)
);


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE SEQUENCE `catalog_brand_hilo` START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE SEQUENCE `catalog_hilo` START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE SEQUENCE `catalog_type_hilo` START WITH 1 INCREMENT BY 10 NO MINVALUE NO MAXVALUE NO CYCLE;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `Baskets` (
        `Id` int NOT NULL,
        `BuyerId` nvarchar(max) NULL,
        CONSTRAINT `PK_Baskets` PRIMARY KEY (`Id`)
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `CatalogBrand` (
        `Id` int NOT NULL,
        `Brand` nvarchar(100) NOT NULL,
        CONSTRAINT `PK_CatalogBrand` PRIMARY KEY (`Id`)
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `CatalogType` (
        `Id` int NOT NULL,
        `Type` nvarchar(100) NOT NULL,
        CONSTRAINT `PK_CatalogType` PRIMARY KEY (`Id`)
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `Orders` (
        `Id` int NOT NULL,
        `BuyerId` nvarchar(max) NULL,
        `OrderDate` datetimeoffset NOT NULL,
        `ShipToAddress_City` nvarchar(max) NULL,
        `ShipToAddress_Country` nvarchar(max) NULL,
        `ShipToAddress_State` nvarchar(max) NULL,
        `ShipToAddress_Street` nvarchar(max) NULL,
        `ShipToAddress_ZipCode` nvarchar(max) NULL,
        CONSTRAINT `PK_Orders` PRIMARY KEY (`Id`)
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `BasketItem` (
        `Id` int NOT NULL,
        `BasketId` int NULL,
        `CatalogItemId` int NOT NULL,
        `Quantity` int NOT NULL,
        `UnitPrice` decimal(18, 2) NOT NULL,
        CONSTRAINT `PK_BasketItem` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_BasketItem_Baskets_BasketId` FOREIGN KEY (`BasketId`) REFERENCES `Baskets` (`Id`) ON DELETE RESTRICT
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `Catalog` (
        `Id` int NOT NULL,
        `CatalogBrandId` int NOT NULL,
        `CatalogTypeId` int NOT NULL,
        `Description` nvarchar(max) NULL,
        `Name` nvarchar(50) NOT NULL,
        `PictureUri` nvarchar(max) NULL,
        `Price` decimal(18, 2) NOT NULL,
        CONSTRAINT `PK_Catalog` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_Catalog_CatalogBrand_CatalogBrandId` FOREIGN KEY (`CatalogBrandId`) REFERENCES `CatalogBrand` (`Id`) ON DELETE CASCADE,
        CONSTRAINT `FK_Catalog_CatalogType_CatalogTypeId` FOREIGN KEY (`CatalogTypeId`) REFERENCES `CatalogType` (`Id`) ON DELETE CASCADE
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE TABLE `OrderItems` (
        `Id` int NOT NULL,
        `OrderId` int NULL,
        `UnitPrice` decimal(18, 2) NOT NULL,
        `Units` int NOT NULL,
        `ItemOrdered_CatalogItemId` int NOT NULL,
        `ItemOrdered_PictureUri` nvarchar(max) NULL,
        `ItemOrdered_ProductName` nvarchar(max) NULL,
        CONSTRAINT `PK_OrderItems` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_OrderItems_Orders_OrderId` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`) ON DELETE RESTRICT
    );

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE INDEX `IX_BasketItem_BasketId` ON `BasketItem` (`BasketId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE INDEX `IX_Catalog_CatalogBrandId` ON `Catalog` (`CatalogBrandId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE INDEX `IX_Catalog_CatalogTypeId` ON `Catalog` (`CatalogTypeId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    CREATE INDEX `IX_OrderItems_OrderId` ON `OrderItems` (`OrderId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20171018175735_Initial') THEN

    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20171018175735_Initial', '2.2.2-servicing-10034');

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_ZipCode` varchar(18) NOT NULL;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_Street` varchar(180) NOT NULL;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_State` varchar(60) NULL;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_Country` varchar(90) NOT NULL;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    ALTER TABLE `Orders` MODIFY COLUMN `ShipToAddress_City` varchar(100) NOT NULL;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    ALTER TABLE `OrderItems` MODIFY COLUMN `ItemOrdered_ProductName` varchar(50) NOT NULL;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;


DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20180725190153_AddExtraConstraints') THEN

    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20180725190153_AddExtraConstraints', '2.2.2-servicing-10034');

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

