-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: cross_border_transfer
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
-- Current Database: `cross_border_transfer`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cross_border_transfer` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `cross_border_transfer`;

--
-- Table structure for table `compliance_screenings`
--

DROP TABLE IF EXISTS `compliance_screenings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compliance_screenings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int DEFAULT NULL,
  `sender_id` int NOT NULL,
  `recipient_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `target_amount` decimal(12,2) NOT NULL,
  `aml_score` decimal(5,2) NOT NULL,
  `sanctions_score` decimal(5,2) NOT NULL,
  `pep_score` decimal(5,2) NOT NULL,
  `risk_score` decimal(5,2) NOT NULL,
  `requires_manual_review` tinyint(1) DEFAULT '0',
  `screening_data` json NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_risk_score` (`risk_score`),
  KEY `idx_requires_manual_review` (`requires_manual_review`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compliance_screenings`
--

LOCK TABLES `compliance_screenings` WRITE;
/*!40000 ALTER TABLE `compliance_screenings` DISABLE KEYS */;
/*!40000 ALTER TABLE `compliance_screenings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `current_rates`
--

DROP TABLE IF EXISTS `current_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `current_rates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `market_rate` decimal(10,6) NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_rate` (`source_currency`,`target_currency`),
  KEY `idx_source_target` (`source_currency`,`target_currency`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `current_rates`
--

LOCK TABLES `current_rates` WRITE;
/*!40000 ALTER TABLE `current_rates` DISABLE KEYS */;
INSERT INTO `current_rates` VALUES (1,'ZAR','USD',0.055000,'2026-02-08 19:26:03'),(2,'USD','ZAR',18.180000,'2026-02-08 19:26:03'),(3,'ZAR','EUR',0.051000,'2026-02-08 19:26:03'),(4,'EUR','ZAR',19.610000,'2026-02-08 19:26:03'),(5,'ZAR','GBP',0.044000,'2026-02-08 19:26:03'),(6,'GBP','ZAR',22.730000,'2026-02-08 19:26:03');
/*!40000 ALTER TABLE `current_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `to_email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data` json DEFAULT NULL,
  `status` enum('PENDING','SENT','FAILED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_to_email` (`to_email`(250)),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `liquidity_consumptions`
--

DROP TABLE IF EXISTS `liquidity_consumptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `liquidity_consumptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pool_id` int NOT NULL,
  `reservation_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `consumed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pool_id` (`pool_id`),
  KEY `idx_reservation_id` (`reservation_id`),
  KEY `idx_consumed_at` (`consumed_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `liquidity_consumptions`
--

LOCK TABLES `liquidity_consumptions` WRITE;
/*!40000 ALTER TABLE `liquidity_consumptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `liquidity_consumptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `liquidity_movements`
--

DROP TABLE IF EXISTS `liquidity_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `liquidity_movements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pool_id` int NOT NULL,
  `movement_type` enum('ADD','REMOVE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pool_id` (`pool_id`),
  KEY `idx_movement_type` (`movement_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `liquidity_movements`
--

LOCK TABLES `liquidity_movements` WRITE;
/*!40000 ALTER TABLE `liquidity_movements` DISABLE KEYS */;
/*!40000 ALTER TABLE `liquidity_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `liquidity_pools`
--

DROP TABLE IF EXISTS `liquidity_pools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `liquidity_pools` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_balance` decimal(15,2) DEFAULT '0.00',
  `available_balance` decimal(15,2) DEFAULT '0.00',
  `minimum_balance` decimal(15,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_pool` (`country`,`currency`),
  KEY `idx_country` (`country`),
  KEY `idx_currency` (`currency`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `liquidity_pools`
--

LOCK TABLES `liquidity_pools` WRITE;
/*!40000 ALTER TABLE `liquidity_pools` DISABLE KEYS */;
INSERT INTO `liquidity_pools` VALUES (1,'ZA','ZAR',1000000.00,1000000.00,100000.00,'2026-02-08 19:25:46','2026-02-08 19:25:46'),(2,'ZW','USD',50000.00,50000.00,5000.00,'2026-02-08 19:25:46','2026-02-08 19:25:46');
/*!40000 ALTER TABLE `liquidity_pools` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `liquidity_reservations`
--

DROP TABLE IF EXISTS `liquidity_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `liquidity_reservations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pool_id` int NOT NULL,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` enum('RESERVED','RELEASED','CONSUMED','EXPIRED') COLLATE utf8mb4_unicode_ci DEFAULT 'RESERVED',
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pool_id` (`pool_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `liquidity_reservations`
--

LOCK TABLES `liquidity_reservations` WRITE;
/*!40000 ALTER TABLE `liquidity_reservations` DISABLE KEYS */;
/*!40000 ALTER TABLE `liquidity_reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locked_rates`
--

DROP TABLE IF EXISTS `locked_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locked_rates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `market_rate` decimal(10,6) NOT NULL,
  `final_rate` decimal(10,6) NOT NULL,
  `urgency_markup` decimal(5,4) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `urgency` enum('STANDARD','EXPRESS','INSTANT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `locked_at` timestamp NOT NULL,
  `valid_until` timestamp NOT NULL,
  `source` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_valid_until` (`valid_until`),
  KEY `idx_source_target` (`source_currency`,`target_currency`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locked_rates`
--

LOCK TABLES `locked_rates` WRITE;
/*!40000 ALTER TABLE `locked_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `locked_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `transaction_id` int DEFAULT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` enum('EMAIL','SMS','EMAIL_SMS') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','SENT','FAILED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `resource` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_permission` (`resource`,`action`),
  KEY `idx_resource` (`resource`),
  KEY `idx_action` (`action`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'user','create','Create new users','2026-02-08 19:25:02','2026-02-08 19:25:02'),(2,'user','read','View user information','2026-02-08 19:25:02','2026-02-08 19:25:02'),(3,'user','update','Update user information','2026-02-08 19:25:02','2026-02-08 19:25:02'),(4,'user','delete','Delete users','2026-02-08 19:25:02','2026-02-08 19:25:02'),(5,'transaction','create','Create transactions','2026-02-08 19:25:02','2026-02-08 19:25:02'),(6,'transaction','read','View transaction information','2026-02-08 19:25:02','2026-02-08 19:25:02'),(7,'transaction','update','Update transaction information','2026-02-08 19:25:02','2026-02-08 19:25:02'),(8,'transaction','delete','Delete transactions','2026-02-08 19:25:02','2026-02-08 19:25:02'),(9,'compliance','review','Review compliance screenings','2026-02-08 19:25:02','2026-02-08 19:25:02'),(10,'liquidity','manage','Manage liquidity pools','2026-02-08 19:25:02','2026-02-08 19:25:02'),(11,'admin','system','System administration','2026-02-08 19:25:02','2026-02-08 19:25:02');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate_history`
--

DROP TABLE IF EXISTS `rate_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rate_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `market_rate` decimal(10,6) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_source_target` (`source_currency`,`target_currency`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate_history`
--

LOCK TABLES `rate_history` WRITE;
/*!40000 ALTER TABLE `rate_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `rate_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recipients`
--

DROP TABLE IF EXISTS `recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `province` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `street_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_document_type` enum('PASSPORT','NATIONAL_ID','DRIVING_LICENSE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_document_front_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_document_back_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_document_expiry` date NOT NULL,
  `id_issuing_country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `verification_status` enum('PENDING','REVIEW_REQUIRED','VERIFIED','REJECTED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `verification_level` enum('BASIC','ENHANCED','FULL') COLLATE utf8mb4_unicode_ci DEFAULT 'BASIC',
  `verified_at` timestamp NULL DEFAULT NULL,
  `verification_expires_at` timestamp NULL DEFAULT NULL,
  `risk_score` int DEFAULT '50',
  `risk_level` enum('LOW','MEDIUM','HIGH') COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `is_pep` tinyint(1) DEFAULT '0',
  `is_sanctioned` tinyint(1) DEFAULT '0',
  `last_screening_at` timestamp NULL DEFAULT NULL,
  `preferred_payout_method` enum('BANK_TRANSFER','MOBILE_MONEY','CASH_PICKUP') COLLATE utf8mb4_unicode_ci NOT NULL,
  `payout_details` json NOT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`(250)),
  KEY `idx_phone` (`phone`),
  KEY `idx_country` (`country`),
  KEY `idx_verification_status` (`verification_status`),
  KEY `idx_status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recipients`
--

LOCK TABLES `recipients` WRITE;
/*!40000 ALTER TABLE `recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_role_permission` (`role_id`,`permission_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_permission_id` (`permission_id`)
) ENGINE=MyISAM AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,1,1,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(2,1,2,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(3,1,3,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(4,1,4,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(5,1,5,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(6,1,6,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(7,1,7,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(8,1,8,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(9,1,9,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(10,1,10,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(11,1,11,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(12,2,9,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(13,2,5,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(14,2,8,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(15,2,6,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(16,2,7,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(17,2,1,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(18,2,4,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(19,2,2,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(20,2,3,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(21,3,9,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(22,3,5,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(23,3,8,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(24,3,6,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(25,3,7,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(26,3,1,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(27,3,4,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(28,3,2,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(29,3,3,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(30,4,1,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(31,4,5,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(32,4,2,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(33,4,6,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(34,5,1,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(35,5,5,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(36,5,2,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(37,5,6,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(38,5,3,'2026-02-08 19:25:28','2026-02-08 19:25:28'),(39,5,7,'2026-02-08 19:25:28','2026-02-08 19:25:28');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `system_role` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN','System Administrator',1,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(2,'OPERATOR','Operations Staff',1,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(3,'COMPLIANCE','Compliance Officer',1,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(4,'CUSTOMER','Regular Customer',0,'2026-02-08 19:25:02','2026-02-08 19:25:02'),(5,'BUSINESS','Business Customer',0,'2026-02-08 19:25:02','2026-02-08 19:25:02');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_logs`
--

DROP TABLE IF EXISTS `sms_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `to_phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','SENT','FAILED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_to_phone` (`to_phone`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_logs`
--

LOCK TABLES `sms_logs` WRITE;
/*!40000 ALTER TABLE `sms_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_events`
--

DROP TABLE IF EXISTS `transaction_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `event_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_data` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_events`
--

LOCK TABLES `transaction_events` WRITE;
/*!40000 ALTER TABLE `transaction_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT 'ZAR',
  `status` enum('PENDING','PROCESSING','COMPLETED','FAILED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `transaction_type` enum('SEND','RECEIVE','DEPOSIT','WITHDRAW') COLLATE utf8mb4_unicode_ci DEFAULT 'SEND',
  `reference_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,1,2,1000.00,'ZAR','COMPLETED','SEND','TXN202602081917101001','Test transaction 1','2026-02-08 19:17:10','2026-02-08 19:17:10'),(2,1,2,500.50,'ZAR','COMPLETED','SEND','TXN202602081917101002','Test transaction 2','2026-02-08 19:17:10','2026-02-08 19:17:10');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_otps`
--

DROP TABLE IF EXISTS `user_otps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_otps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `otp` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_otp` (`otp`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_otps`
--

LOCK TABLES `user_otps` WRITE;
/*!40000 ALTER TABLE `user_otps` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_otps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_permission` (`user_id`,`permission_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_permission_id` (`permission_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_role` (`user_id`,`role_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date NOT NULL,
  `nationality` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_document_type` enum('PASSPORT','NATIONAL_ID','DRIVING_LICENSE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `street_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `province` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `verification_status` enum('PENDING','REVIEW_REQUIRED','VERIFIED','REJECTED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `status` enum('ACTIVE','INACTIVE','SUSPENDED','LOCKED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'test@ziklac.com','+27123456789','$2y$10$8qMLyQ9sWaLwVZPWCLpxXuHA6Fz70rALBdEwIKsdig83T5U8KMdGy','Test','User','1990-01-01','ZAF','9001010001088','NATIONAL_ID','123 Test Street','Johannesburg','Gauteng','2000','ZAF','VERIFIED','ACTIVE','2026-02-08 19:17:09','2026-02-08 19:17:09'),(2,'receiver@example.com','+27123456780','$2y$10$CimCMjezTnXbt3SCgOQm0.j.u2s.y5AYvTGmu6ZF7aDIIoqRrgZVi','Receiver','One','1990-01-01','ZAF','9001010001099','NATIONAL_ID','456 Receiver St','Johannesburg','Gauteng','2001','ZAF','VERIFIED','ACTIVE','2026-02-08 19:17:10','2026-02-08 19:17:10');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification_documents`
--

DROP TABLE IF EXISTS `verification_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `recipient_id` int DEFAULT NULL,
  `document_type` enum('ID_FRONT','ID_BACK','ADDRESS_PROOF','SELFIE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `front_image_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `back_image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `extracted_data` json DEFAULT NULL,
  `verification_status` enum('PENDING','VERIFIED','REJECTED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `verification_notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_verification_status` (`verification_status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification_documents`
--

LOCK TABLES `verification_documents` WRITE;
/*!40000 ALTER TABLE `verification_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `verification_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'cross_border_transfer'
--

--
-- Dumping routines for database 'cross_border_transfer'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:29:07
