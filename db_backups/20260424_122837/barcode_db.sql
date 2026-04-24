-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: barcode_db
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
-- Current Database: `barcode_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `barcode_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `barcode_db`;

--
-- Table structure for table `api_tokens`
--

DROP TABLE IF EXISTS `api_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_hash` varchar(128) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `role` enum('admin','librarian','viewer') NOT NULL DEFAULT 'librarian',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `api_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_tokens`
--

LOCK TABLES `api_tokens` WRITE;
/*!40000 ALTER TABLE `api_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `barcode_number` varchar(64) NOT NULL,
  `title` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `isbn` varchar(64) DEFAULT NULL,
  `publication_year` int DEFAULT NULL,
  `publisher` varchar(255) DEFAULT NULL,
  `asset_type` varchar(50) NOT NULL DEFAULT 'book',
  `status` varchar(50) NOT NULL DEFAULT 'active',
  `generated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `generated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `barcode_number` (`barcode_number`),
  KEY `fk_assets_generated_by` (`generated_by`),
  CONSTRAINT `fk_assets_generated_by` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
INSERT INTO `assets` VALUES (1,'202600005','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(2,'202600006','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(3,'202600007','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(4,'202600008','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(5,'202600009','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(6,'202600010','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(7,'202600011','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(8,'202600012','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(9,'202600013','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(10,'202600014','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:00:13',NULL),(11,'202600015','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(12,'202600016','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(13,'202600017','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(14,'202600018','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(15,'202600019','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(16,'202600020','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(17,'202600021','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(18,'202600022','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(19,'202600023','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(20,'202600024','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:03:37',NULL),(21,'202600025','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(22,'202600026','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(23,'202600027','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(24,'202600028','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(25,'202600029','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(26,'202600030','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(27,'202600031','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(28,'202600032','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(29,'202600033','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(30,'202600034','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:08:57',NULL),(31,'202600035','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:16:04',NULL),(32,'202600036','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:16:04',NULL),(33,'202600037','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:16:04',NULL),(34,'202600038','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:16:04',NULL),(35,'202600039','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:16:04',NULL),(36,'202600040','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:51:29',NULL),(37,'202600041','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:51:29',NULL),(38,'202600042','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:51:29',NULL),(39,'202600043','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:51:29',NULL),(40,'202600044','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:51:29',NULL),(41,'202600045','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:20',NULL),(42,'202600046','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:20',NULL),(43,'202600047','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:20',NULL),(44,'202600048','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:20',NULL),(45,'202600049','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:20',NULL),(46,'202600050','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:38',NULL),(47,'202600051','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:38',NULL),(48,'202600052','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:38',NULL),(49,'202600053','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 10:59:38',NULL),(50,'202600054','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:05:38',NULL),(51,'202600055','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:05:38',NULL),(52,'202600056','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:05:38',NULL),(53,'202600057','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:05:38',NULL),(54,'202600058','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:07:39',NULL),(55,'202600059','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:07:39',NULL),(56,'202600060','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:07:39',NULL),(57,'202600061','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:07:39',NULL),(58,'202600062','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:09:44',NULL),(59,'202600063','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:09:44',NULL),(60,'202600064','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:09:44',NULL),(61,'202600065','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:09:44',NULL),(62,'202600066','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:18:38',NULL),(63,'202600067','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:18:38',NULL),(64,'202600068','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:18:38',NULL),(65,'202600069','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:33:11',NULL),(66,'202600070','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:33:11',NULL),(67,'202600071','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:33:11',NULL),(68,'202600072','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:35:02',NULL),(69,'202600073','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:35:02',NULL),(70,'202600074','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(71,'202600075','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(72,'202600076','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(73,'202600077','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(74,'202600078','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(75,'202600079','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(76,'202600080','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL),(77,'202600081','Auto Generated Asset','System',NULL,NULL,NULL,'book','active','2026-03-27 11:41:07',NULL);
/*!40000 ALTER TABLE `assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `barcode_sequence`
--

DROP TABLE IF EXISTS `barcode_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `barcode_sequence` (
  `id` int NOT NULL AUTO_INCREMENT,
  `prefix` varchar(32) NOT NULL DEFAULT '2026',
  `current_number` int NOT NULL DEFAULT '0',
  `last_generated` varchar(64) DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `barcode_sequence`
--

LOCK TABLES `barcode_sequence` WRITE;
/*!40000 ALTER TABLE `barcode_sequence` DISABLE KEYS */;
INSERT INTO `barcode_sequence` VALUES (1,'2026',81,'202600081','2026-03-27 11:41:07');
/*!40000 ALTER TABLE `barcode_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generation_batch_assets`
--

DROP TABLE IF EXISTS `generation_batch_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `generation_batch_assets` (
  `batch_id` int NOT NULL,
  `barcode_number` varchar(64) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`batch_id`,`barcode_number`),
  KEY `barcode_number` (`barcode_number`),
  CONSTRAINT `generation_batch_assets_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `generation_batches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `generation_batch_assets_ibfk_2` FOREIGN KEY (`barcode_number`) REFERENCES `assets` (`barcode_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generation_batch_assets`
--

LOCK TABLES `generation_batch_assets` WRITE;
/*!40000 ALTER TABLE `generation_batch_assets` DISABLE KEYS */;
INSERT INTO `generation_batch_assets` VALUES (1,'202600005','2026-03-27 10:00:13'),(1,'202600006','2026-03-27 10:00:13'),(1,'202600007','2026-03-27 10:00:13'),(1,'202600008','2026-03-27 10:00:13'),(1,'202600009','2026-03-27 10:00:13'),(1,'202600010','2026-03-27 10:00:13'),(1,'202600011','2026-03-27 10:00:13'),(1,'202600012','2026-03-27 10:00:13'),(1,'202600013','2026-03-27 10:00:13'),(1,'202600014','2026-03-27 10:00:13'),(2,'202600015','2026-03-27 10:03:37'),(2,'202600016','2026-03-27 10:03:37'),(2,'202600017','2026-03-27 10:03:37'),(2,'202600018','2026-03-27 10:03:37'),(2,'202600019','2026-03-27 10:03:37'),(2,'202600020','2026-03-27 10:03:37'),(2,'202600021','2026-03-27 10:03:37'),(2,'202600022','2026-03-27 10:03:37'),(2,'202600023','2026-03-27 10:03:37'),(2,'202600024','2026-03-27 10:03:37'),(3,'202600025','2026-03-27 10:08:57'),(3,'202600026','2026-03-27 10:08:57'),(3,'202600027','2026-03-27 10:08:57'),(3,'202600028','2026-03-27 10:08:57'),(3,'202600029','2026-03-27 10:08:57'),(3,'202600030','2026-03-27 10:08:57'),(3,'202600031','2026-03-27 10:08:57'),(3,'202600032','2026-03-27 10:08:57'),(3,'202600033','2026-03-27 10:08:57'),(3,'202600034','2026-03-27 10:08:57'),(4,'202600035','2026-03-27 10:16:04'),(4,'202600036','2026-03-27 10:16:04'),(4,'202600037','2026-03-27 10:16:04'),(4,'202600038','2026-03-27 10:16:04'),(4,'202600039','2026-03-27 10:16:04'),(5,'202600040','2026-03-27 10:51:29'),(5,'202600041','2026-03-27 10:51:29'),(5,'202600042','2026-03-27 10:51:29'),(5,'202600043','2026-03-27 10:51:29'),(5,'202600044','2026-03-27 10:51:29'),(6,'202600045','2026-03-27 10:59:20'),(6,'202600046','2026-03-27 10:59:20'),(6,'202600047','2026-03-27 10:59:20'),(6,'202600048','2026-03-27 10:59:20'),(6,'202600049','2026-03-27 10:59:20'),(7,'202600050','2026-03-27 10:59:38'),(7,'202600051','2026-03-27 10:59:38'),(7,'202600052','2026-03-27 10:59:38'),(7,'202600053','2026-03-27 10:59:38'),(8,'202600054','2026-03-27 11:05:38'),(8,'202600055','2026-03-27 11:05:38'),(8,'202600056','2026-03-27 11:05:38'),(8,'202600057','2026-03-27 11:05:38'),(9,'202600058','2026-03-27 11:07:39'),(9,'202600059','2026-03-27 11:07:39'),(9,'202600060','2026-03-27 11:07:39'),(9,'202600061','2026-03-27 11:07:39'),(10,'202600062','2026-03-27 11:09:44'),(10,'202600063','2026-03-27 11:09:44'),(10,'202600064','2026-03-27 11:09:44'),(10,'202600065','2026-03-27 11:09:44'),(11,'202600066','2026-03-27 11:18:38'),(11,'202600067','2026-03-27 11:18:38'),(11,'202600068','2026-03-27 11:18:38'),(12,'202600069','2026-03-27 11:33:11'),(12,'202600070','2026-03-27 11:33:11'),(12,'202600071','2026-03-27 11:33:11'),(13,'202600072','2026-03-27 11:35:02'),(13,'202600073','2026-03-27 11:35:02'),(14,'202600074','2026-03-27 11:41:07'),(14,'202600075','2026-03-27 11:41:07'),(14,'202600076','2026-03-27 11:41:07'),(14,'202600077','2026-03-27 11:41:07'),(14,'202600078','2026-03-27 11:41:07'),(14,'202600079','2026-03-27 11:41:07'),(14,'202600080','2026-03-27 11:41:07'),(14,'202600081','2026-03-27 11:41:07');
/*!40000 ALTER TABLE `generation_batch_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generation_batches`
--

DROP TABLE IF EXISTS `generation_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `generation_batches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_name` varchar(255) DEFAULT NULL,
  `total_records` int NOT NULL DEFAULT '0',
  `start_barcode` varchar(64) DEFAULT NULL,
  `end_barcode` varchar(64) DEFAULT NULL,
  `generated_by` int DEFAULT NULL,
  `generated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_generation_batches_generated_by` (`generated_by`),
  CONSTRAINT `fk_generation_batches_generated_by` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `generation_batches_ibfk_1` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generation_batches`
--

LOCK TABLES `generation_batches` WRITE;
/*!40000 ALTER TABLE `generation_batches` DISABLE KEYS */;
INSERT INTO `generation_batches` VALUES (1,'auto_generation',10,'202600005','202600014',NULL,'2026-03-27 10:00:13'),(2,'auto_generation',10,'202600015','202600024',NULL,'2026-03-27 10:03:37'),(3,'auto_generation',10,'202600025','202600034',NULL,'2026-03-27 10:08:57'),(4,'auto_generation',5,'202600035','202600039',NULL,'2026-03-27 10:16:04'),(5,'auto_generation',5,'202600040','202600044',NULL,'2026-03-27 10:51:29'),(6,'auto_generation',5,'202600045','202600049',NULL,'2026-03-27 10:59:20'),(7,'auto_generation',4,'202600050','202600053',NULL,'2026-03-27 10:59:38'),(8,'auto_generation',4,'202600054','202600057',NULL,'2026-03-27 11:05:38'),(9,'auto_generation',4,'202600058','202600061',NULL,'2026-03-27 11:07:39'),(10,'auto_generation',4,'202600062','202600065',NULL,'2026-03-27 11:09:44'),(11,'auto_generation',3,'202600066','202600068',NULL,'2026-03-27 11:18:38'),(12,'auto_generation',3,'202600069','202600071',NULL,'2026-03-27 11:33:11'),(13,'auto_generation',2,'202600072','202600073',NULL,'2026-03-27 11:35:02'),(14,'auto_generation',8,'202600074','202600081',NULL,'2026-03-27 11:41:07');
/*!40000 ALTER TABLE `generation_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `key` varchar(64) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('barcode_prefix','2026');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin','librarian','viewer') NOT NULL DEFAULT 'librarian',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2y$10$fZIrfrSdrixlgNO69TR1LOI2odAny7EvehAQbJWK.vwCbD1pSNCkG','admin','2026-03-26 18:59:27');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'barcode_db'
--

--
-- Dumping routines for database 'barcode_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:28:58
