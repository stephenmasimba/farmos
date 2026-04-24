-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: invoicing
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `invoicing`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `invoicing` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `invoicing`;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address_1` varchar(255) NOT NULL,
  `address_2` varchar(255) NOT NULL,
  `town` varchar(255) NOT NULL,
  `county` varchar(255) NOT NULL,
  `postcode` varchar(255) NOT NULL,
  `phone` varchar(100) NOT NULL,
  `name_ship` varchar(255) NOT NULL,
  `address_1_ship` varchar(255) NOT NULL,
  `address_2_ship` varchar(255) NOT NULL,
  `town_ship` varchar(255) NOT NULL,
  `county_ship` varchar(255) NOT NULL,
  `postcode_ship` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=65 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (43,'3','Anne B Ruch','anner@mail.com','4039 Overlook Drive','4039 Overlook Drive','Indianapolis','US','46225','1478500000','Anne B Ruch','4039 Overlook Drive','4039 Overlook Drive','Indianapolis','US','46225'),(44,'4','Albert M Dunford','albd@mail.com','1143 Kuhl Avenue','1143 Kuhl Avenue','Norcross','US','30092','8520000010','Albert M Dunford','1143 Kuhl Avenue','1143 Kuhl Avenue','Norcross','US','30092');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice` varchar(255) NOT NULL,
  `product` text NOT NULL,
  `qty` int NOT NULL,
  `price` varchar(255) NOT NULL,
  `discount` varchar(255) NOT NULL,
  `subtotal` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=117 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
INSERT INTO `invoice_items` VALUES (89,'4','Product Two - This is a sample product two.',21,'13','3','270.00');
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice` varchar(255) NOT NULL,
  `custom_email` text NOT NULL,
  `invoice_date` varchar(255) NOT NULL,
  `invoice_due_date` varchar(255) NOT NULL,
  `subtotal` decimal(10,0) NOT NULL,
  `shipping` decimal(10,0) NOT NULL,
  `discount` decimal(10,0) NOT NULL,
  `vat` decimal(10,0) NOT NULL,
  `total` decimal(10,0) NOT NULL,
  `notes` text NOT NULL,
  `invoice_type` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=77 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (42,'1','','12/11/2021','14/11/2021',523,55,6,58,636,'Completed!','invoice','paid'),(44,'2','','12/11/2021','13/11/2021',395,85,4,48,528,'none','invoice','paid'),(47,'3','','13/11/2021','15/11/2021',132,65,0,20,217,'none','invoice','paid'),(46,'4','','13/11/2021','17/11/2021',270,65,3,34,369,'','invoice','open'),(74,'17','','07/02/2024','13/02/2024',68,0,0,10,78,'','invoice','open');
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `product_name` text NOT NULL,
  `product_desc` text NOT NULL,
  `product_price` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (32,'Trench & backfill','25.2.7','180');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_customers`
--

DROP TABLE IF EXISTS `store_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address_1` varchar(255) NOT NULL,
  `address_2` varchar(255) NOT NULL,
  `town` varchar(255) NOT NULL,
  `county` varchar(255) NOT NULL,
  `postcode` varchar(255) NOT NULL,
  `phone` varchar(100) NOT NULL,
  `name_ship` varchar(255) NOT NULL,
  `address_1_ship` varchar(255) NOT NULL,
  `address_2_ship` varchar(255) NOT NULL,
  `town_ship` varchar(255) NOT NULL,
  `county_ship` varchar(255) NOT NULL,
  `postcode_ship` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=63 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_customers`
--

LOCK TABLES `store_customers` WRITE;
/*!40000 ALTER TABLE `store_customers` DISABLE KEYS */;
INSERT INTO `store_customers` VALUES (53,'Wendy Reilly','wendy@mail.com','3605 Cost Avenue','3605 Cost Avenue','Wharton','US','77488','3214444444','Wendy Reilly','3605 Cost Avenue','3605 Cost Avenue','Wharton','US','77488'),(54,'Albert M Dunford','albd@mail.com','1143 Kuhl Avenue','1143 Kuhl Avenue','Norcross','US','30092','8520000010','Albert M Dunford','1143 Kuhl Avenue','1143 Kuhl Avenue','Norcross','U','30092'),(55,'Anne B Ruch','anner@mail.com','4039 Overlook Drive','6939 Dt Drive','Indianapolis','US','46225','1478500000','Anne B Ruch','4039 Overlook Drive','6939 Dt Drive','Indianapolis','US','46225'),(56,'Celeste Prather','celeste@mail.com','421 Fincham Road','421 Fincham Road','San Diego','US','90000','8021111111','Celeste Prather','421 Fincham Road','421 Fincham Road','San Diego','US','90000'),(57,'Katharine Mayer','kathmay@mail.com','508 Bernardo Street','508 Bernardo Street','Tampa','US','90000','9014555500','Katharine Mayer','508 Bernardo Street','508 Bernardo Street','Tampa','US','90000'),(58,'Rose Thompson','thompsonr@mail.com','2374 Berkley Street','2374 Berkley Street','Northampton','US','01010','7410000020','Rose Thompson','2374 Berkley Street','2374 Berkley Street','Northampton','US','01010'),(59,'Ira Turner','iratur@mail.com','1387 Pine Street','1387 Pine Street','Pittsburgh','US','10005','7890002222','Ira Turner','1387 Pine Street','1387 Pine Street','Pittsburgh','US','10005'),(60,'Richards','richards@mail.com','311 Bchwood Drive','311 Bchwood Drive','Bridgeville','US','50005','7410000014','Richards','311 Bchwood Drive','311 Bchwood Drive','Bridgeville','US','50005'),(61,'Allan Deer','allande@mail.com','1702 Modoc Alley','1702 Modoc Alley','White Bird','US','55550','8520001450','Allan Deer','1702 Modoc Alley','1702 Modoc Alley','White Bird','US','55550'),(62,'Demo User','demouser@mail.com','115 Demo Address','116 Demo Address','DemoTown','DemoCn','00020','7777777777','Demo User','115 Demo Address','116 Demo Address','DemoTown','DemoCn','00020');
/*!40000 ALTER TABLE `store_customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(100) NOT NULL,
  `password` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Tino Stephen Masimba','admin','admin@gutakura.co.za','+27 69 731 6145','d00f5d5217896fb7fd601412cb890830');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'invoicing'
--

--
-- Dumping routines for database 'invoicing'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:30:09
