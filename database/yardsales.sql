CREATE DATABASE  IF NOT EXISTS `yardsales` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_bin */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `yardsales`;
-- MySQL dump 10.13  Distrib 8.0.31, for macos12 (x86_64)
--
-- Host: 127.0.0.1    Database: yardsales
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ItemCategories`
--

DROP TABLE IF EXISTS `ItemCategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ItemCategories` (
  `Id` int unsigned NOT NULL,
  `Name` varchar(50) COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ParticipantItemCategories`
--

DROP TABLE IF EXISTS `ParticipantItemCategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ParticipantItemCategories` (
  `IdParticipant` int unsigned NOT NULL,
  `IdCategory` int unsigned NOT NULL,
  `Comment` text COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`IdParticipant`,`IdCategory`),
  KEY `FK_Categories` (`IdCategory`),
  CONSTRAINT `FK_Categories` FOREIGN KEY (`IdCategory`) REFERENCES `ItemCategories` (`Id`),
  CONSTRAINT `FK_Participants` FOREIGN KEY (`IdParticipant`) REFERENCES `SalesParticipant` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Sales`
--

DROP TABLE IF EXISTS `YardSales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `YardSales` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `EventStart` datetime NOT NULL,
  `EventEnd` datetime NOT NULL,
  `Title` varchar(255) COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `Logo` longblob,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SalesParticipant`
--

DROP TABLE IF EXISTS `SalesParticipant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SalesParticipant` (
  `Id` int unsigned NOT NULL,
  `SalesId` int unsigned NOT NULL,
  `Name` varchar(100) COLLATE utf8mb3_bin NOT NULL,
  `Street` varchar(100) COLLATE utf8mb3_bin NOT NULL,
  `Zip` char(5) COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `City` varchar(100) COLLATE utf8mb3_bin NOT NULL,
  `State` char(2) COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`),
  KEY `FK_SALES` (`SalesId`),
  CONSTRAINT `FK_SALES` FOREIGN KEY (`SalesId`) REFERENCES `YardSales` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-04-07 19:56:16
