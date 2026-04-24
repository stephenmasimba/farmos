-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: kayanne_logistics
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
-- Current Database: `kayanne_logistics`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `kayanne_logistics` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `kayanne_logistics`;

--
-- Table structure for table `accounting_transactions`
--

DROP TABLE IF EXISTS `accounting_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounting_transactions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_date` date NOT NULL,
  `posted_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `memo` text COLLATE utf8mb4_unicode_ci,
  `invoice_id` int unsigned DEFAULT NULL,
  `payment_id` int unsigned DEFAULT NULL,
  `shipment_id` int unsigned DEFAULT NULL,
  `status` enum('pending','posted','adjusted','void') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_by_user_id` int unsigned NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_number` (`transaction_number`),
  UNIQUE KEY `uq_transaction_uuid` (`uuid`),
  KEY `payment_id` (`payment_id`),
  KEY `shipment_id` (`shipment_id`),
  KEY `created_by_user_id` (`created_by_user_id`),
  KEY `idx_transaction_number` (`transaction_number`),
  KEY `idx_date` (`transaction_date`),
  KEY `idx_references` (`invoice_id`,`payment_id`,`shipment_id`),
  CONSTRAINT `accounting_transactions_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `accounting_transactions_ibfk_2` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `accounting_transactions_ibfk_3` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `accounting_transactions_ibfk_4` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounting_transactions`
--

LOCK TABLES `accounting_transactions` WRITE;
/*!40000 ALTER TABLE `accounting_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounting_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `client_id` varchar(64) DEFAULT NULL,
  `client_secret_hash` varchar(255) DEFAULT NULL,
  `token_hash` varchar(128) NOT NULL,
  `secret_enc` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `scopes` json NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_id` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_keys`
--

LOCK TABLES `api_keys` WRITE;
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
INSERT INTO `api_keys` VALUES (1,1,'Test Runner','test_client_0af3b2a4','bccfe0b37c0a147f5335243f11894faaeeaf67d02039fb74e42716d8b54b892e','legacy_placeholder_1766505166','',NULL,0,'[\"read:jobs\", \"write:jobs\"]');
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_rate_limits`
--

DROP TABLE IF EXISTS `api_rate_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_rate_limits` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `rate_limit_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `window_start` datetime NOT NULL,
  `window_end` datetime NOT NULL,
  `request_count` int unsigned NOT NULL DEFAULT '0',
  `limit_value` int unsigned NOT NULL DEFAULT '60',
  `user_id` int unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_rate_limit_key_window` (`rate_limit_key`,`window_start`),
  KEY `idx_user_ip` (`user_id`,`ip_address`),
  KEY `idx_window_end` (`window_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_rate_limits`
--

LOCK TABLES `api_rate_limits` WRITE;
/*!40000 ALTER TABLE `api_rate_limits` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_rate_limits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asset_maintenance`
--

DROP TABLE IF EXISTS `asset_maintenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asset_maintenance` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL,
  `maintenance_type` enum('preventive','corrective','inspection','emergency','tire_replacement','oil_change') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `service_date` date NOT NULL,
  `next_service_date` date DEFAULT NULL,
  `mileage_at_service` int unsigned DEFAULT NULL,
  `service_provider` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_cost` decimal(10,2) NOT NULL DEFAULT '0.00',
  `labor_cost` decimal(10,2) DEFAULT NULL,
  `parts_cost` decimal(10,2) DEFAULT NULL,
  `status` enum('scheduled','in_progress','completed','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'completed',
  `receipt_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warranty_expiration` date DEFAULT NULL,
  `performed_by_user_id` int unsigned DEFAULT NULL,
  `performed_by_vendor` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `performed_by_user_id` (`performed_by_user_id`),
  KEY `idx_asset_service` (`asset_id`,`service_date`),
  KEY `idx_next_service` (`next_service_date`),
  KEY `idx_status` (`status`),
  CONSTRAINT `asset_maintenance_ibfk_1` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `asset_maintenance_ibfk_2` FOREIGN KEY (`performed_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asset_maintenance`
--

LOCK TABLES `asset_maintenance` WRITE;
/*!40000 ALTER TABLE `asset_maintenance` DISABLE KEYS */;
/*!40000 ALTER TABLE `asset_maintenance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assets` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `asset_type` enum('truck','trailer','equipment','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `asset_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `owned_by` int unsigned DEFAULT NULL COMMENT 'User ID of owner/operator',
  `ownership_type` enum('company','owner_operator','leased') COLLATE utf8mb4_unicode_ci NOT NULL,
  `make` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `model` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` year DEFAULT NULL,
  `vin` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `license_plate` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `license_state` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fuel_type` enum('diesel','gasoline','electric','cng') COLLATE utf8mb4_unicode_ci DEFAULT 'diesel',
  `weight_capacity` decimal(10,2) DEFAULT NULL COMMENT 'In pounds',
  `length` decimal(6,2) DEFAULT NULL COMMENT 'In feet',
  `status` enum('available','dispatched','maintenance','out_of_service','sold') COLLATE utf8mb4_unicode_ci DEFAULT 'available',
  `current_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_mileage` int unsigned DEFAULT NULL,
  `last_maintenance_mileage` int unsigned DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `purchase_price` decimal(12,2) DEFAULT NULL,
  `current_value` decimal(12,2) DEFAULT NULL,
  `monthly_lease_payment` decimal(10,2) DEFAULT NULL,
  `insurance_policy_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_expiration_date` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `retired_at` datetime DEFAULT NULL,
  `mc_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_service_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_number` (`asset_number`),
  UNIQUE KEY `uq_asset_uuid` (`uuid`),
  UNIQUE KEY `vin` (`vin`),
  KEY `idx_asset_type_status` (`asset_type`,`status`),
  KEY `idx_owned_by` (`owned_by`),
  CONSTRAINT `assets_ibfk_1` FOREIGN KEY (`owned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
INSERT INTO `assets` VALUES (1,'','truck','TRK-001','Big Rig #1',NULL,'company','Kenworth','T680',2022,'1XKWDB9X7MJ123456','ABC123','CA',NULL,'diesel',NULL,NULL,'available','Los Angeles, CA',125000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-14 18:00:45','2025-12-14 18:00:45',NULL,NULL,NULL);
/*!40000 ALTER TABLE `assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `user_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `previous_hash` char(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hash` char(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'info',
  `event_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `entity_uuid` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `changed_fields` json DEFAULT NULL,
  `request_method` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_code` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `region_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_action` (`user_id`,`action`,`created_at`),
  KEY `idx_entity` (`entity_type`,`entity_id`,`created_at`),
  KEY `idx_event_type` (`event_type`,`created_at`),
  KEY `idx_created` (`created_at`),
  KEY `idx_client` (`client_id`),
  KEY `idx_severity` (`severity`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (2,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',NULL,NULL,'logout','info','','auth',NULL,NULL,NULL,'[]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-14 20:16:26'),(3,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',NULL,NULL,'login_failed','info','','auth',NULL,NULL,NULL,'{\"email\": \"admin@kayannelogistics.com\", \"reason\": \"invalid_password\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-14 20:18:01'),(4,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36',NULL,NULL,'login_failed','info','','auth',NULL,NULL,NULL,'{\"email\": \"admin@kayannelogistics.com\", \"reason\": \"invalid_password\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 13:01:22'),(5,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 14:09:44'),(6,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 14:49:21'),(7,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 14:49:31'),(8,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'report_viewed','info','','reports',NULL,NULL,NULL,'{\"action\": \"dashboard_view\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 14:56:29'),(9,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'report_viewed','info','','reports',NULL,NULL,NULL,'{\"action\": \"dashboard_view\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 15:23:58'),(10,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 16:24:13'),(11,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 16:24:26'),(12,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 16:24:26'),(13,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:06:51'),(14,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:07:25'),(15,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:07:25'),(16,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:46:11'),(17,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:46:47'),(18,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:46:47'),(19,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'profile_updated','info','','employees',2,NULL,NULL,'{\"name\": \"System Administrator\", \"phone\": \"0649186091\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:47:21'),(20,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 17:47:37'),(21,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 18:25:42'),(22,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 18:28:09'),(23,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 18:28:09'),(24,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 19:09:00'),(25,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'user_updated','info','','employees',1,NULL,NULL,'{\"name\": \"System Account\", \"role\": \"admin\", \"email\": \"system@kayannelogistics.com\", \"status\": \"active\", \"mc_number\": \"001\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 19:32:51'),(26,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'user_password_reset','info','','employees',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 19:34:18'),(27,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'view','info','','page_view',0,NULL,NULL,'{\"method\": \"GET\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 19:46:37'),(28,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 OPR/124.0.0.0',NULL,NULL,'view','info','','page_view',0,NULL,NULL,'{\"method\": \"GET\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-21 19:49:06'),(29,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36',NULL,NULL,'login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:54:19'),(30,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36',NULL,NULL,'dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:54:20'),(31,1,NULL,NULL,NULL,NULL,'0000000000000000000000000000000000000000000000000000000000000000','112583ac2ae40593dd5f5f4f35a3a298dd0291c60ad0e2acf999bd445158e3c4','test_action','info','','system',1,NULL,NULL,'{\"test\": \"value\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 15:38:33'),(32,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','112583ac2ae40593dd5f5f4f35a3a298dd0291c60ad0e2acf999bd445158e3c4','05268c91b682eaf3eaf945cfc8c1afe282bfc1ddf09d0715d6e8b5395c5a8344','logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 15:50:44'),(33,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','05268c91b682eaf3eaf945cfc8c1afe282bfc1ddf09d0715d6e8b5395c5a8344','20c56bf597f75520ae41c8926f022e2bac321aac8aa86ea1fc6fbae9f3093b58','login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 15:50:56'),(34,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','20c56bf597f75520ae41c8926f022e2bac321aac8aa86ea1fc6fbae9f3093b58','89695d31b95de2022201d8d7181411e8375d5bb58174e8061322c63dfeedbd6f','dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 15:50:56'),(35,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','89695d31b95de2022201d8d7181411e8375d5bb58174e8061322c63dfeedbd6f','f7a824ebbb123d739a5d08bef04dc9d742eb315eab60dd6923f3976ffe89b93c','dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 15:51:20'),(36,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','f7a824ebbb123d739a5d08bef04dc9d742eb315eab60dd6923f3976ffe89b93c','b32d97afed217e8d71f69d32aa33251100a0e61c9785b99b5b597abe387ef96b','logout','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:39:10'),(37,1,NULL,NULL,'::1',NULL,'b32d97afed217e8d71f69d32aa33251100a0e61c9785b99b5b597abe387ef96b','f175774d47afb1e4eb2c18dafc44bb2cabc7f7e202fca5b7e46d58da1da9f1be','api_login_success','info','','api_key',3,NULL,NULL,'{\"client_id\": \"test_sec_client\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:45:16'),(38,1,NULL,NULL,'::1',NULL,'f175774d47afb1e4eb2c18dafc44bb2cabc7f7e202fca5b7e46d58da1da9f1be','0ddb6fe59931a08a4fff0d803ddbe4821be68ac5c23cf62e6fe4dad7782e170f','api_login_success','info','','api_key',3,NULL,NULL,'{\"client_id\": \"test_sec_client\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:45:16'),(39,1,NULL,NULL,'::1',NULL,'0ddb6fe59931a08a4fff0d803ddbe4821be68ac5c23cf62e6fe4dad7782e170f','ef1df4ea3f9415bbe3dbd0e4c193de774a5e4a5f76b0eac9686407f99343497b','security_alert','info','','refresh_token',3,NULL,NULL,'{\"reason\": \"token_reuse_attempt\", \"client_id\": \"test_sec_client\", \"family_id\": \"a87f13314b2a34d655a4d45d4309e780\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:45:16'),(40,1,NULL,NULL,'::1',NULL,'ef1df4ea3f9415bbe3dbd0e4c193de774a5e4a5f76b0eac9686407f99343497b','105a34f52c57bfcc033c566fdecafd54b6e76a0f5ec498bc86a07471fe4e8b6c','security_alert','info','','refresh_token',4,NULL,NULL,'{\"reason\": \"token_reuse_attempt\", \"client_id\": \"test_sec_client\", \"family_id\": \"a87f13314b2a34d655a4d45d4309e780\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 16:45:16'),(41,NULL,NULL,NULL,NULL,NULL,'105a34f52c57bfcc033c566fdecafd54b6e76a0f5ec498bc86a07471fe4e8b6c','804e18db7303b21e773e1057ced815b60efdfa18c880828e3208fb9b8a96a9c4','test_action_info','info','','system',1,NULL,NULL,'{\"msg\": \"Just info\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 17:01:14'),(42,NULL,NULL,NULL,NULL,NULL,'804e18db7303b21e773e1057ced815b60efdfa18c880828e3208fb9b8a96a9c4','3c92d80da769cdc056546ef044c0de2c420ef80fdb15951cc2cc53597ed4bdf8','test_action_info','info','','system',1,NULL,NULL,'{\"msg\": \"Just info\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 17:01:46'),(43,NULL,NULL,NULL,NULL,NULL,'3c92d80da769cdc056546ef044c0de2c420ef80fdb15951cc2cc53597ed4bdf8','a27b2c77cd146a485bb5ae05aae59e800db53b66a9503dc84793d6759bf4ccf7','test_action_warn','warning','','system',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 17:01:46'),(44,NULL,NULL,NULL,NULL,NULL,'a27b2c77cd146a485bb5ae05aae59e800db53b66a9503dc84793d6759bf4ccf7','bc1f68aae4a26af28e083108b2166318cab039d7a879b41b1c06795d532401c0','security_alert_login','high','','auth',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 17:01:46'),(45,NULL,NULL,NULL,NULL,NULL,'bc1f68aae4a26af28e083108b2166318cab039d7a879b41b1c06795d532401c0','77486e37f504943754366d4cb5aed87805067fe35fca84e59ebffd3fee430610','data_breach_detected','critical','','system',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 17:01:46'),(46,1,NULL,NULL,NULL,NULL,'77486e37f504943754366d4cb5aed87805067fe35fca84e59ebffd3fee430610','82400ca9a36c78f45ab8fad499daff12a1b4c8b7380406fdb91d4242d23753b9','manual_breach_test','critical','','system',999,NULL,NULL,'{\"reason\": \"testing siem\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 17:09:57'),(47,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 OPR/125.0.0.0','82400ca9a36c78f45ab8fad499daff12a1b4c8b7380406fdb91d4242d23753b9','cca104c825970fc974acce5591b53a316d62423e86083225401e2dd4738c4cd5','login_success','info','','auth',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-31 13:02:07'),(48,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 OPR/125.0.0.0','cca104c825970fc974acce5591b53a316d62423e86083225401e2dd4738c4cd5','b388f6a4502bb9754da13be1afa083f070f14a2f9b7502d646d1de3930ced9bf','dashboard_viewed','info','','dashboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-31 13:02:08'),(49,2,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,NULL,'login_failed','info','','auth',NULL,NULL,NULL,'{\"email\": \"admin@kayannelogistics.com\", \"reason\": \"invalid_password\"}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-10 11:05:53');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bidders`
--

DROP TABLE IF EXISTS `bidders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bidders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` text,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bidders`
--

LOCK TABLES `bidders` WRITE;
/*!40000 ALTER TABLE `bidders` DISABLE KEYS */;
INSERT INTO `bidders` VALUES (1,'Kayanne Logistics','dispatch@kayannelogistics.com',NULL,NULL,1,'2025-12-21 14:24:43','2025-12-21 14:24:43');
/*!40000 ALTER TABLE `bidders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bids` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `load_opportunity_id` int unsigned DEFAULT NULL,
  `bidder_id` int unsigned DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `employee_id` int unsigned DEFAULT NULL COMMENT 'Employee (PHP app) who placed the bid',
  `platform_job_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `load_details` json DEFAULT NULL,
  `route` text COLLATE utf8mb4_unicode_ci,
  `bid_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payout_estimate` decimal(12,2) DEFAULT NULL,
  `bid_amount` decimal(10,2) NOT NULL,
  `counter_offer_amount` decimal(10,2) DEFAULT NULL,
  `client_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_to` varchar(190) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pickup_location` text COLLATE utf8mb4_unicode_ci,
  `delivery_location` text COLLATE utf8mb4_unicode_ci,
  `pickup_date` date DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `proposed_pickup_date` datetime DEFAULT NULL,
  `proposed_delivery_date` datetime DEFAULT NULL,
  `proposed_equipment` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `body` text COLLATE utf8mb4_unicode_ci,
  `status` enum('draft','submitted','countered','accepted','rejected','withdrawn','expired') COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `email_body` text COLLATE utf8mb4_unicode_ci,
  `email_sent_at` datetime DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `accepted_at` datetime DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL,
  `won_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bid_uuid` (`uuid`),
  UNIQUE KEY `bid_number` (`bid_number`),
  KEY `idx_bidder_status` (`bidder_id`,`status`),
  KEY `idx_employee` (`employee_id`),
  KEY `idx_load_status` (`load_opportunity_id`,`status`),
  KEY `idx_bid_number` (`bid_number`),
  KEY `idx_platform_job` (`platform_job_id`),
  KEY `idx_submitted` (`submitted_at`),
  KEY `client_id` (`client_id`),
  CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`load_opportunity_id`) REFERENCES `load_opportunities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`bidder_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bids_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids`
--

LOCK TABLES `bids` WRITE;
/*!40000 ALTER TABLE `bids` DISABLE KEYS */;
INSERT INTO `bids` VALUES (2,'',NULL,NULL,1,2,NULL,NULL,NULL,'BID-20251223-5FAAF5',12.00,0.00,NULL,'John Smith','john@smithmfg.com',NULL,'john@smithmfg.com','12','hh',NULL,NULL,NULL,NULL,NULL,NULL,'jki','',NULL,NULL,'2025-12-23 18:07:28',NULL,NULL,NULL,'2025-12-23 18:07:28','2025-12-23 18:07:28'),(3,'9b4f21c5-502d-43b4-a43b-bb02d6f3dbe3',NULL,NULL,NULL,1,NULL,NULL,NULL,'BID-TEST-20251223160913',1500.50,0.00,NULL,'Test Client CLI','test@example.com',NULL,'recipient@example.com','123 Origin St, City, ST 12345','456 Dest Rd, Town, ST 67890',NULL,NULL,NULL,NULL,NULL,NULL,'Test bid body content.','',NULL,NULL,'2025-12-23 18:09:13',NULL,NULL,NULL,'2025-12-23 18:09:13','2025-12-23 18:09:13'),(4,'9aa18320-bbbb-4ea2-9450-47e9231be210',NULL,NULL,NULL,1,NULL,NULL,NULL,'BID-TEST-20251223160958',1500.50,0.00,NULL,'Test Client CLI','test@example.com',NULL,'recipient@example.com','123 Origin St, City, ST 12345','456 Dest Rd, Town, ST 67890',NULL,NULL,NULL,NULL,NULL,NULL,'Test bid body content.','',NULL,NULL,'2025-12-23 18:09:58',NULL,NULL,NULL,'2025-12-23 18:09:58','2025-12-23 18:09:58');
/*!40000 ALTER TABLE `bids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `sender_type` enum('employee','client') DEFAULT 'employee',
  `receiver_type` enum('employee','client') DEFAULT 'employee',
  `message` text,
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
INSERT INTO `chat_messages` VALUES (1,2,1,'employee','client','good day',NULL,'2025-12-21 16:40:04');
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_addresses`
--

DROP TABLE IF EXISTS `client_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_addresses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `address_type` enum('primary','billing','shipping','warehouse') COLLATE utf8mb4_unicode_ci DEFAULT 'primary',
  `address_line1` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` char(2) COLLATE utf8mb4_unicode_ci DEFAULT 'US',
  `contact_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hours_of_operation` text COLLATE utf8mb4_unicode_ci,
  `dock_count` tinyint unsigned DEFAULT NULL,
  `appointment_required` tinyint(1) DEFAULT '0',
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client_type` (`client_id`,`address_type`),
  KEY `idx_state_city` (`state`,`city`),
  CONSTRAINT `client_addresses_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_addresses`
--

LOCK TABLES `client_addresses` WRITE;
/*!40000 ALTER TABLE `client_addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_interactions`
--

DROP TABLE IF EXISTS `client_interactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_interactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `type` enum('call','email','meeting','note','other') DEFAULT 'note',
  `notes` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_interactions`
--

LOCK TABLES `client_interactions` WRITE;
/*!40000 ALTER TABLE `client_interactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_interactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('shipper','receiver','broker','carrier') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','inactive','lead') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `email` varchar(190) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fax` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_terms` enum('net_15','net_30','net_45','prepaid','cod') COLLATE utf8mb4_unicode_ci DEFAULT 'net_30',
  `credit_limit` decimal(12,2) DEFAULT '0.00',
  `balance` decimal(12,2) DEFAULT '0.00',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tenant_id` int unsigned NOT NULL DEFAULT '1',
  `mc_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_client_uuid` (`uuid`),
  KEY `idx_name` (`name`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (1,'','John Smith','Smith Manufacturing','shipper','active','john@smithmfg.com',NULL,'555-1001',NULL,NULL,'net_30',50000.00,0.00,NULL,'2025-12-14 18:00:45','2025-12-14 18:00:45',1,NULL);
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_field_values`
--

DROP TABLE IF EXISTS `custom_field_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_field_values` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `record_id` int NOT NULL,
  `value` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_field_values`
--

LOCK TABLES `custom_field_values` WRITE;
/*!40000 ALTER TABLE `custom_field_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_field_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_fields`
--

DROP TABLE IF EXISTS `custom_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_fields` (
  `id` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) NOT NULL,
  `field_name` varchar(50) NOT NULL,
  `field_label` varchar(100) NOT NULL,
  `field_type` enum('text','number','date','select') DEFAULT 'text',
  `options` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_fields`
--

LOCK TABLES `custom_fields` WRITE;
/*!40000 ALTER TABLE `custom_fields` DISABLE KEYS */;
INSERT INTO `custom_fields` VALUES (1,'clients','022','022','text',NULL,'2025-12-21 17:18:43');
/*!40000 ALTER TABLE `custom_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_signatures`
--

DROP TABLE IF EXISTS `document_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_signatures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_type` enum('rate_con','bol','invoice','other') NOT NULL,
  `document_id` int NOT NULL,
  `signer_name` varchar(100) DEFAULT NULL,
  `signature_data` longtext NOT NULL,
  `signed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_signatures`
--

LOCK TABLES `document_signatures` WRITE;
/*!40000 ALTER TABLE `document_signatures` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_signatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` enum('shipment','client','asset','user','invoice','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int unsigned NOT NULL,
  `document_type` enum('bol','pod','invoice','quote','contract','insurance','license','maintenance','photo','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size_bytes` int unsigned DEFAULT NULL,
  `mime_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_hash` char(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA-256 for integrity verification',
  `uploaded_by_user_id` int unsigned NOT NULL,
  `uploaded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `status` enum('active','expired','replaced','deleted') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `verified_by_user_id` int unsigned DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verification_notes` text COLLATE utf8mb4_unicode_ci,
  `ocr_text` longtext COLLATE utf8mb4_unicode_ci,
  `extracted_data` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_document_uuid` (`uuid`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_uploaded_by` (`uploaded_by_user_id`),
  KEY `idx_validity` (`valid_until`),
  KEY `idx_status` (`status`),
  KEY `verified_by_user_id` (`verified_by_user_id`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`uploaded_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`verified_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver_schedules`
--

DROP TABLE IF EXISTS `driver_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('available','booked','off','sick') DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `driver_id` (`driver_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_schedules`
--

LOCK TABLES `driver_schedules` WRITE;
/*!40000 ALTER TABLE `driver_schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `driver_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `edi_configs`
--

DROP TABLE IF EXISTS `edi_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `edi_configs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `edi_type` varchar(50) DEFAULT NULL,
  `ftp_host` varchar(255) DEFAULT NULL,
  `ftp_user` varchar(255) DEFAULT NULL,
  `ftp_pass` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `edi_configs`
--

LOCK TABLES `edi_configs` WRITE;
/*!40000 ALTER TABLE `edi_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `edi_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `edi_logs`
--

DROP TABLE IF EXISTS `edi_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `edi_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `partner_id` int DEFAULT NULL,
  `direction` enum('in','out') NOT NULL,
  `document_type` varchar(10) DEFAULT NULL,
  `status` enum('pending','processed','failed','sent') DEFAULT 'pending',
  `content` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `partner_id` (`partner_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `edi_logs`
--

LOCK TABLES `edi_logs` WRITE;
/*!40000 ALTER TABLE `edi_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `edi_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `edi_partners`
--

DROP TABLE IF EXISTS `edi_partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `edi_partners` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `partner_name` varchar(100) NOT NULL,
  `isa_sender_id` varchar(20) DEFAULT NULL,
  `isa_receiver_id` varchar(20) DEFAULT NULL,
  `gs_sender_id` varchar(20) DEFAULT NULL,
  `gs_receiver_id` varchar(20) DEFAULT NULL,
  `ftp_host` varchar(100) DEFAULT NULL,
  `ftp_user` varchar(50) DEFAULT NULL,
  `ftp_pass` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `edi_partners`
--

LOCK TABLES `edi_partners` WRITE;
/*!40000 ALTER TABLE `edi_partners` DISABLE KEYS */;
INSERT INTO `edi_partners` VALUES (1,NULL,'Test Partner','TEST','KAYANNE',NULL,NULL,'ftp.example.com',NULL,NULL,'2025-12-21 17:27:49');
/*!40000 ALTER TABLE `edi_partners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `recipient_email` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` mediumtext COLLATE utf8mb4_unicode_ci,
  `template_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `template_variables` json DEFAULT NULL,
  `metadata` text COLLATE utf8mb4_unicode_ci,
  `entity_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `status` enum('queued','sent','delivered','opened','clicked','bounced','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'queued',
  `message_id` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider_response` text COLLATE utf8mb4_unicode_ci,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `sent_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `opened_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_recipient` (`recipient_email`),
  KEY `idx_status` (`status`),
  KEY `idx_created` (`created_at`),
  KEY `idx_entity` (`entity_type`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','employee','dispatcher','driver','accountant','mc_owner','client') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'employee',
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mc_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `sso_provider` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sso_subject` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tenant_id` int unsigned NOT NULL DEFAULT '1',
  `password_changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_sso` (`sso_provider`,`sso_subject`),
  KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'System Account','system@kayannelogistics.com','admin','0649186001','001','','$2y$10$fRq61W0F2EyBA2a1h9hvsO3KkYfRYdWxK/eLtFtTPpsHCa8zEf.0G','active',NULL,'2025-12-14 18:00:45','2025-12-21 19:34:18',NULL,NULL,NULL,1,'2025-12-21 11:28:05'),(2,'System Administrator','admin@kayannelogistics.com','admin','0649186091',NULL,'uploads/avatars/AVT_2_1766332041.jpg','$2y$10$5ekkx3.sKzc6ftsWV9UfH.I2uC6SLi2HhUST5f7cyImQB1M7.1fC2','active','2025-12-31 15:02:07','2025-12-14 18:00:45','2025-12-31 15:02:07',NULL,NULL,NULL,1,'2025-12-21 11:28:05');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fuel_entries`
--

DROP TABLE IF EXISTS `fuel_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fuel_entries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int NOT NULL,
  `entry_date` date DEFAULT NULL,
  `gallons` decimal(10,2) DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `odometer` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `asset_id` (`asset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fuel_entries`
--

LOCK TABLES `fuel_entries` WRITE;
/*!40000 ALTER TABLE `fuel_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `fuel_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_line_items`
--

DROP TABLE IF EXISTS `invoice_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_line_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `invoice_id` int unsigned NOT NULL,
  `line_number` smallint unsigned NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` decimal(10,3) NOT NULL DEFAULT '1.000',
  `unit_price` decimal(10,2) NOT NULL,
  `unit_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'each',
  `discount_percentage` decimal(5,2) DEFAULT '0.00',
  `line_total` decimal(10,2) GENERATED ALWAYS AS (((`quantity` * `unit_price`) * (1 - (`discount_percentage` / 100)))) STORED,
  `shipment_id` int unsigned DEFAULT NULL,
  `gl_account_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `revenue_category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_invoice_line` (`invoice_id`,`line_number`),
  KEY `idx_shipment` (`shipment_id`),
  CONSTRAINT `invoice_line_items_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `invoice_line_items_ibfk_2` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_line_items`
--

LOCK TABLES `invoice_line_items` WRITE;
/*!40000 ALTER TABLE `invoice_line_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoice_line_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `invoice_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `job_id` int unsigned DEFAULT NULL,
  `shipment_id` int unsigned DEFAULT NULL,
  `client_id` int unsigned NOT NULL,
  `client_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_date` date NOT NULL,
  `due_date` date NOT NULL,
  `paid_date` date DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `total_amount` decimal(10,2) GENERATED ALWAYS AS ((`subtotal` + `tax_amount`)) STORED,
  `amount_paid` decimal(10,2) DEFAULT '0.00',
  `balance_due` decimal(10,2) GENERATED ALWAYS AS ((`total_amount` - `amount_paid`)) STORED,
  `payment_terms` enum('net_15','net_30','net_45','prepaid','cod') COLLATE utf8mb4_unicode_ci DEFAULT 'net_30',
  `late_fee_percentage` decimal(5,2) DEFAULT '0.00',
  `status` enum('draft','sent','viewed','partial','paid','overdue','void') COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `last_reminder_sent_at` datetime DEFAULT NULL,
  `payment_method` enum('check','ach','credit_card','wire','cash') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_reference` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pdf_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_via_email` tinyint(1) DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `internal_notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  UNIQUE KEY `uq_invoice_uuid` (`uuid`),
  KEY `job_id` (`job_id`),
  KEY `shipment_id` (`shipment_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_invoice_number` (`invoice_number`),
  KEY `idx_client_name` (`client_name`),
  KEY `idx_client_email` (`client_email`),
  KEY `idx_client_status` (`client_id`,`status`),
  KEY `idx_due_date` (`due_date`),
  KEY `idx_paid_date` (`paid_date`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `invoices_ibfk_3` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `invoices_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_blacklist`
--

DROP TABLE IF EXISTS `ip_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ip_blacklist` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) NOT NULL,
  `blocked_until` timestamp NULL DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ip_blocked` (`ip_address`,`blocked_until`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_blacklist`
--

LOCK TABLES `ip_blacklist` WRITE;
/*!40000 ALTER TABLE `ip_blacklist` DISABLE KEYS */;
INSERT INTO `ip_blacklist` VALUES (2,'127.0.0.99','2025-12-23 18:33:43','Too many failed login attempts','2025-12-23 17:33:43');
/*!40000 ALTER TABLE `ip_blacklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_queue`
--

DROP TABLE IF EXISTS `job_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_queue` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `queue_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default',
  `job_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` json NOT NULL,
  `status` enum('pending','reserved','processing','completed','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `attempts` tinyint unsigned DEFAULT '0',
  `max_attempts` tinyint unsigned DEFAULT '3',
  `available_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `reserved_at` datetime DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `error_stack` text COLLATE utf8mb4_unicode_ci,
  `progress_current` int unsigned DEFAULT '0',
  `progress_total` int unsigned DEFAULT '0',
  `priority` tinyint unsigned DEFAULT '5' COMMENT '1=highest, 10=lowest',
  `result` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_queue_status` (`queue_name`,`status`,`priority`,`available_at`),
  KEY `idx_job_type` (`job_type`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_queue`
--

LOCK TABLES `job_queue` WRITE;
/*!40000 ALTER TABLE `job_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bid_id` int unsigned DEFAULT NULL,
  `driver_id` int unsigned DEFAULT NULL,
  `client_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mc_used` enum('company','external') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'company',
  `mc_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payout_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `load_details` json DEFAULT NULL,
  `pickup_location` text COLLATE utf8mb4_unicode_ci,
  `delivery_location` text COLLATE utf8mb4_unicode_ci,
  `pickup_date` date DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `actual_pickup_date` datetime DEFAULT NULL,
  `actual_delivery_date` datetime DEFAULT NULL,
  `status` enum('assigned','in_transit','completed','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'assigned',
  `scheduled_pickup_time` datetime NOT NULL,
  `scheduled_delivery_time` datetime NOT NULL,
  `assigned_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  `invoice_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commission_calculated` tinyint(1) DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `bid_id` (`bid_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_driver` (`driver_id`),
  KEY `idx_status` (`status`),
  KEY `idx_mc_used` (`mc_used`),
  KEY `idx_completed` (`completed_at`),
  KEY `idx_assigned` (`assigned_at`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`id`) ON DELETE SET NULL,
  CONSTRAINT `jobs_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `employees` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `jobs_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_entries`
--

DROP TABLE IF EXISTS `journal_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_entries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` int unsigned NOT NULL,
  `account_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_type` enum('asset','liability','equity','revenue','expense') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `entry_type` enum('debit','credit') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_transaction` (`transaction_id`),
  KEY `idx_account` (`account_code`),
  KEY `idx_type_amount` (`entry_type`,`amount`),
  CONSTRAINT `journal_entries_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `accounting_transactions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entries`
--

LOCK TABLES `journal_entries` WRITE;
/*!40000 ALTER TABLE `journal_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `journal_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `load_opportunities`
--

DROP TABLE IF EXISTS `load_opportunities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `load_opportunities` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `external_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ID from external platform (DAT, TruckStop, etc.)',
  `source_platform` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `load_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin_address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `origin_city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `origin_state` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `origin_postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin_country` char(2) COLLATE utf8mb4_unicode_ci DEFAULT 'US',
  `destination_address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `destination_city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `destination_state` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `destination_postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `destination_country` char(2) COLLATE utf8mb4_unicode_ci DEFAULT 'US',
  `earliest_pickup` datetime DEFAULT NULL,
  `latest_pickup` datetime DEFAULT NULL,
  `earliest_delivery` datetime DEFAULT NULL,
  `latest_delivery` datetime DEFAULT NULL,
  `cargo_description` text COLLATE utf8mb4_unicode_ci,
  `cargo_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo_weight` decimal(10,2) DEFAULT NULL COMMENT 'In pounds',
  `cargo_weight_unit` enum('lbs','kg') COLLATE utf8mb4_unicode_ci DEFAULT 'lbs',
  `cargo_pieces` int unsigned DEFAULT NULL,
  `cargo_value` decimal(12,2) DEFAULT NULL,
  `equipment_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trailer_type` enum('dry_van','reefer','flatbed','step_deck','lowboy','other') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temperature_requirements` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hazmat` tinyint(1) DEFAULT '0',
  `hazmat_class` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rate` decimal(10,2) NOT NULL,
  `rate_type` enum('flat','per_mile','percent') COLLATE utf8mb4_unicode_ci DEFAULT 'flat',
  `fuel_surcharge_included` tinyint(1) DEFAULT '0',
  `all_in_rate` decimal(10,2) DEFAULT NULL,
  `estimated_miles` int unsigned DEFAULT NULL,
  `broker_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `broker_mc_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `broker_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('posted','bidding','awarded','expired','removed') COLLATE utf8mb4_unicode_ci DEFAULT 'posted',
  `raw_data` json DEFAULT NULL COMMENT 'Original data from platform',
  `scraped_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_load_uuid` (`uuid`),
  UNIQUE KEY `uq_external_load` (`external_id`,`source_platform`),
  KEY `idx_load_number` (`load_number`),
  KEY `idx_origin` (`origin_state`,`origin_city`),
  KEY `idx_destination` (`destination_state`,`destination_city`),
  KEY `idx_pickup_time` (`earliest_pickup`),
  KEY `idx_status_expires` (`status`,`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `load_opportunities`
--

LOCK TABLES `load_opportunities` WRITE;
/*!40000 ALTER TABLE `load_opportunities` DISABLE KEYS */;
/*!40000 ALTER TABLE `load_opportunities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loads`
--

DROP TABLE IF EXISTS `loads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reference` varchar(255) NOT NULL,
  `origin_city` varchar(100) DEFAULT NULL,
  `origin_state` varchar(50) DEFAULT NULL,
  `destination_city` varchar(100) DEFAULT NULL,
  `destination_state` varchar(50) DEFAULT NULL,
  `pickup_date` date DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `weight_kg` decimal(10,2) DEFAULT NULL,
  `equipment` varchar(100) DEFAULT NULL,
  `rate_usd` decimal(10,2) DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `notes` text,
  `mc_number` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `mc_number` (`mc_number`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loads`
--

LOCK TABLES `loads` WRITE;
/*!40000 ALTER TABLE `loads` DISABLE KEYS */;
/*!40000 ALTER TABLE `loads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_failures`
--

DROP TABLE IF EXISTS `login_failures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_failures` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `occurred_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ip_time` (`ip_address`,`occurred_at`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_failures`
--

LOCK TABLES `login_failures` WRITE;
/*!40000 ALTER TABLE `login_failures` DISABLE KEYS */;
INSERT INTO `login_failures` VALUES (11,'127.0.0.99','user_test','2025-12-23 17:33:43'),(12,'127.0.0.99','user_test','2025-12-23 17:33:43'),(13,'127.0.0.99','user_test','2025-12-23 17:33:43'),(14,'127.0.0.99','user_test','2025-12-23 17:33:43'),(15,'127.0.0.99','user_test','2025-12-23 17:33:43'),(16,'127.0.0.99','user_test','2025-12-23 17:33:43'),(17,'127.0.0.99','user_test','2025-12-23 17:33:43'),(18,'127.0.0.99','user_test','2025-12-23 17:33:43'),(19,'127.0.0.99','user_test','2025-12-23 17:33:43'),(20,'127.0.0.99','user_test','2025-12-23 17:33:43');
/*!40000 ALTER TABLE `login_failures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_logs`
--

DROP TABLE IF EXISTS `maintenance_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int NOT NULL,
  `service_date` date DEFAULT NULL,
  `maintenance_type` varchar(100) DEFAULT NULL,
  `description` text,
  `cost` decimal(10,2) DEFAULT NULL,
  `service_provider` varchar(255) DEFAULT NULL,
  `mileage` int DEFAULT NULL,
  `next_service_date` date DEFAULT NULL,
  `status` enum('scheduled','in_progress','completed','cancelled') DEFAULT 'completed',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `asset_id` (`asset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_logs`
--

LOCK TABLES `maintenance_logs` WRITE;
/*!40000 ALTER TABLE `maintenance_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `maintenance_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_prefs`
--

DROP TABLE IF EXISTS `notification_prefs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_prefs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `notify_bid_updates` tinyint(1) DEFAULT '1',
  `notify_job_assigned` tinyint(1) DEFAULT '1',
  `notify_job_completed` tinyint(1) DEFAULT '1',
  `notify_payment_received` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_notification_prefs_user` (`user_id`),
  CONSTRAINT `notification_prefs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_prefs`
--

LOCK TABLES `notification_prefs` WRITE;
/*!40000 ALTER TABLE `notification_prefs` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_prefs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int unsigned DEFAULT NULL COMMENT 'NULL for broadcast notifications',
  `notification_type` enum('shipment_status','bid_update','payment_received','invoice_due','maintenance_due','system_alert','message') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `action_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') COLLATE utf8mb4_unicode_ci DEFAULT 'normal',
  `delivery_method` enum('in_app','email','sms','push') COLLATE utf8mb4_unicode_ci DEFAULT 'in_app',
  `delivered` tinyint(1) DEFAULT '0',
  `delivery_attempts` tinyint unsigned DEFAULT '0',
  `scheduled_for` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_notification_uuid` (`uuid`),
  KEY `idx_user_read` (`user_id`,`is_read`,`created_at`),
  KEY `idx_type_created` (`notification_type`,`created_at`),
  KEY `idx_expires` (`expires_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_history`
--

DROP TABLE IF EXISTS `password_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_history`
--

LOCK TABLES `password_history` WRITE;
/*!40000 ALTER TABLE `password_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `token` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int unsigned NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_token` (`token`),
  KEY `idx_user_expires` (`user_id`,`expires_at`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `password_reset_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `invoice_id` int unsigned NOT NULL,
  `client_id` int unsigned NOT NULL,
  `payment_date` date NOT NULL,
  `payment_method` enum('check','ach','credit_card','wire','cash') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `reference_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_four_digits` char(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','processing','completed','failed','refunded') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `processed_by_user_id` int unsigned DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_number` (`payment_number`),
  UNIQUE KEY `uq_payment_uuid` (`uuid`),
  KEY `processed_by_user_id` (`processed_by_user_id`),
  KEY `idx_payment_number` (`payment_number`),
  KEY `idx_invoice` (`invoice_id`),
  KEY `idx_client_date` (`client_id`,`payment_date`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`processed_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_subscriptions`
--

DROP TABLE IF EXISTS `push_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `endpoint` text NOT NULL,
  `p256dh` text NOT NULL,
  `auth` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_subscriptions`
--

LOCK TABLES `push_subscriptions` WRITE;
/*!40000 ALTER TABLE `push_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate_limits`
--

DROP TABLE IF EXISTS `rate_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rate_limits` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` varchar(50) NOT NULL,
  `window_start` int unsigned NOT NULL,
  `request_count` int unsigned DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client_window` (`client_id`,`window_start`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate_limits`
--

LOCK TABLES `rate_limits` WRITE;
/*!40000 ALTER TABLE `rate_limits` DISABLE KEYS */;
/*!40000 ALTER TABLE `rate_limits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate_tables`
--

DROP TABLE IF EXISTS `rate_tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rate_tables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `origin_zip` varchar(10) DEFAULT NULL,
  `destination_zip` varchar(10) DEFAULT NULL,
  `rate_per_mile` decimal(10,2) DEFAULT NULL,
  `flat_rate` decimal(10,2) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate_tables`
--

LOCK TABLES `rate_tables` WRITE;
/*!40000 ALTER TABLE `rate_tables` DISABLE KEYS */;
/*!40000 ALTER TABLE `rate_tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `family_id` varchar(64) DEFAULT NULL,
  `token_hash` varchar(64) NOT NULL,
  `client_id` varchar(64) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `scopes` text,
  `expires_at` datetime NOT NULL,
  `revoked` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `idx_token` (`token_hash`),
  KEY `client_id` (`client_id`),
  KEY `idx_family` (`family_id`),
  CONSTRAINT `refresh_tokens_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `api_keys` (`client_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (1,NULL,'f9e9fe36ef39f740d78afbd028a84a60169f8d2d2c1cb812ad67395c801eae1d','test_client_0af3b2a4',1,'[\"read:jobs\",\"write:jobs\"]','2026-01-22 17:52:48',0,'2025-12-23 17:52:48');
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int unsigned NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `last_activity` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `revoked` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_session_id` (`session_id`),
  KEY `idx_user_last_activity` (`user_id`,`last_activity`),
  KEY `idx_revoked` (`revoked`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipment_assignments`
--

DROP TABLE IF EXISTS `shipment_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipment_assignments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shipment_id` int unsigned NOT NULL,
  `driver_id` int unsigned NOT NULL,
  `asset_id` int unsigned NOT NULL,
  `assigned_by_user_id` int unsigned NOT NULL,
  `assignment_type` enum('primary','backup','team','interim') COLLATE utf8mb4_unicode_ci DEFAULT 'primary',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `start_mileage` int unsigned DEFAULT NULL,
  `end_mileage` int unsigned DEFAULT NULL,
  `total_miles` int unsigned GENERATED ALWAYS AS ((ifnull(`end_mileage`,0) - ifnull(`start_mileage`,0))) STORED,
  `start_fuel_level` decimal(5,2) DEFAULT NULL COMMENT 'Percentage',
  `end_fuel_level` decimal(5,2) DEFAULT NULL,
  `fuel_purchased_gallons` decimal(8,2) DEFAULT NULL,
  `fuel_purchased_cost` decimal(8,2) DEFAULT NULL,
  `status` enum('scheduled','active','completed','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'scheduled',
  `scheduled_start` datetime DEFAULT NULL,
  `scheduled_end` datetime DEFAULT NULL,
  `actual_start` datetime DEFAULT NULL,
  `actual_end` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_active_shipment_driver` (`shipment_id`,`driver_id`,`status`),
  KEY `assigned_by_user_id` (`assigned_by_user_id`),
  KEY `idx_driver_status` (`driver_id`,`status`),
  KEY `idx_asset_status` (`asset_id`,`status`),
  CONSTRAINT `shipment_assignments_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `shipment_assignments_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `shipment_assignments_ibfk_3` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `shipment_assignments_ibfk_4` FOREIGN KEY (`assigned_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipment_assignments`
--

LOCK TABLES `shipment_assignments` WRITE;
/*!40000 ALTER TABLE `shipment_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipment_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipment_stops`
--

DROP TABLE IF EXISTS `shipment_stops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipment_stops` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shipment_id` int unsigned NOT NULL,
  `stop_sequence` tinyint unsigned NOT NULL,
  `stop_type` enum('pickup','delivery','drop','live_load','live_unload') COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `location_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address_line1` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address_line2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` char(2) COLLATE utf8mb4_unicode_ci DEFAULT 'US',
  `contact_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `appointment_required` tinyint(1) DEFAULT '0',
  `earliest_arrival` datetime DEFAULT NULL,
  `latest_arrival` datetime DEFAULT NULL,
  `appointment_confirmation` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scheduled_arrival` datetime DEFAULT NULL,
  `scheduled_departure` datetime DEFAULT NULL,
  `actual_arrival` datetime DEFAULT NULL,
  `actual_departure` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `documents_required` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','arrived','departed','problem','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_shipment_stop_sequence` (`shipment_id`,`stop_sequence`),
  KEY `client_id` (`client_id`),
  KEY `idx_shipment_type` (`shipment_id`,`stop_type`),
  KEY `idx_arrival_times` (`earliest_arrival`,`latest_arrival`),
  CONSTRAINT `shipment_stops_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `shipment_stops_ibfk_2` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipment_stops`
--

LOCK TABLES `shipment_stops` WRITE;
/*!40000 ALTER TABLE `shipment_stops` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipment_stops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipments`
--

DROP TABLE IF EXISTS `shipments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `shipment_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pro_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bol_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_reference` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bid_id` int unsigned DEFAULT NULL,
  `load_opportunity_id` int unsigned DEFAULT NULL,
  `shipper_id` int unsigned NOT NULL,
  `consignee_id` int unsigned NOT NULL,
  `bill_to_id` int unsigned DEFAULT NULL,
  `cargo_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `cargo_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo_weight` decimal(10,2) DEFAULT NULL,
  `cargo_weight_unit` enum('lbs','kg') COLLATE utf8mb4_unicode_ci DEFAULT 'lbs',
  `cargo_pieces` int unsigned DEFAULT NULL,
  `cargo_class` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nmfc_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hazmat` tinyint(1) DEFAULT '0',
  `hazmat_class` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temperature_min` decimal(5,2) DEFAULT NULL,
  `temperature_max` decimal(5,2) DEFAULT NULL,
  `requires_liftgate` tinyint(1) DEFAULT '0',
  `requires_appointment` tinyint(1) DEFAULT '1',
  `rate` decimal(10,2) NOT NULL,
  `rate_type` enum('flat','per_mile','percent') COLLATE utf8mb4_unicode_ci DEFAULT 'flat',
  `fuel_surcharge` decimal(10,2) DEFAULT '0.00',
  `accessorial_charges` decimal(10,2) DEFAULT '0.00',
  `total_charges` decimal(10,2) GENERATED ALWAYS AS (((`rate` + `fuel_surcharge`) + `accessorial_charges`)) STORED,
  `commission_rate` decimal(5,2) DEFAULT '0.00',
  `commission_amount` decimal(10,2) GENERATED ALWAYS AS ((`total_charges` * (`commission_rate` / 100))) STORED,
  `status` enum('quoting','booked','planning','assigned','at_origin','in_transit','at_destination','delivered','completed','cancelled','problem') COLLATE utf8mb4_unicode_ci DEFAULT 'quoting',
  `priority` enum('low','normal','high','hot') COLLATE utf8mb4_unicode_ci DEFAULT 'normal',
  `booked_at` datetime DEFAULT NULL,
  `assigned_at` datetime DEFAULT NULL,
  `picked_up_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shipment_number` (`shipment_number`),
  UNIQUE KEY `uq_shipment_uuid` (`uuid`),
  UNIQUE KEY `pro_number` (`pro_number`),
  UNIQUE KEY `bol_number` (`bol_number`),
  KEY `bid_id` (`bid_id`),
  KEY `load_opportunity_id` (`load_opportunity_id`),
  KEY `shipper_id` (`shipper_id`),
  KEY `consignee_id` (`consignee_id`),
  KEY `bill_to_id` (`bill_to_id`),
  KEY `idx_shipment_number` (`shipment_number`),
  KEY `idx_pro_number` (`pro_number`),
  KEY `idx_status_created` (`status`,`created_at`),
  KEY `idx_dates` (`booked_at`,`picked_up_at`,`delivered_at`),
  CONSTRAINT `shipments_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`id`) ON DELETE SET NULL,
  CONSTRAINT `shipments_ibfk_2` FOREIGN KEY (`load_opportunity_id`) REFERENCES `load_opportunities` (`id`) ON DELETE SET NULL,
  CONSTRAINT `shipments_ibfk_3` FOREIGN KEY (`shipper_id`) REFERENCES `clients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `shipments_ibfk_4` FOREIGN KEY (`consignee_id`) REFERENCES `clients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `shipments_ibfk_5` FOREIGN KEY (`bill_to_id`) REFERENCES `clients` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipments`
--

LOCK TABLES `shipments` WRITE;
/*!40000 ALTER TABLE `shipments` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int unsigned DEFAULT NULL,
  `employee_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `account_type` enum('AR','AP','Revenue','Expense','Commission','Asset','Liability') COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `debit_credit` enum('debit','credit') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','posted','reconciled','void') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `posted_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `reconciled_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `invoice_id` (`invoice_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_job` (`job_id`),
  KEY `idx_employee` (`employee_id`),
  KEY `idx_account_type` (`account_type`),
  KEY `idx_status` (`status`),
  KEY `idx_posted` (`posted_at`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL,
  CONSTRAINT `transactions_ibfk_3` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `transactions_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_security`
--

DROP TABLE IF EXISTS `user_security`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_security` (
  `user_id` int unsigned NOT NULL,
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `recovery_codes` text COLLATE utf8mb4_unicode_ci,
  `failed_attempts` int NOT NULL DEFAULT '0',
  `locked_until` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_security_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_security`
--

LOCK TABLES `user_security` WRITE;
/*!40000 ALTER TABLE `user_security` DISABLE KEYS */;
INSERT INTO `user_security` VALUES (1,0,'[\"$2y$10$L.NrSPqpjuDTytKh0XmTAuPukZNvcHRz7LtxCUmhtKlu1F\\/K5rXhi\",\"$2y$10$fVrVHsAVg7CUCZd5wyiAFO9lYVmMaT0GkktSQEL3xMalslXe8aFyS\",\"$2y$10$WerRPn8v.SkgXOs\\/.2rbLu5deF.TOBkaqZexAodzHn48CcSsGqJaG\",\"$2y$10$m7gWTQGvfnYqputPykPNneJxWArpIRwURRvvIbDgPPWZaPEBYeBEm\",\"$2y$10$P7ezhy4KqujqL9AGJ9u1suSqlAw7dCtuWGittuRkU5\\/cMksVAJpdW\",\"$2y$10$IgoCQxcWon1tUdtj6sGFouPsgjzgvfYb.S\\/jHrTSRseFlGd5KDBK.\",\"$2y$10$ZnfsmXOwx6VS0gMXZI\\/7Aeoqc3CYpmXDnr2DDVJwamVlFBY2UOR.y\",\"$2y$10$qOClZYSQd7uew3laqPRZQeCKfc\\/dO2cA8ACkA\\/b\\/BncpRQL3VJ17m\",\"$2y$10$4ZnA6qJ7VVUeXZjc3i9d2udbm.2uXQ3scD.Ey99DdZdq468jKGQf.\"]',0,NULL,'2025-12-23 18:51:11'),(2,0,NULL,1,NULL,'2026-03-10 11:05:53');
/*!40000 ALTER TABLE `user_security` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_security_settings`
--

DROP TABLE IF EXISTS `user_security_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_security_settings` (
  `user_id` int unsigned NOT NULL,
  `two_factor_enabled` tinyint(1) DEFAULT '0',
  `two_factor_secret` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `failed_login_attempts` tinyint unsigned DEFAULT '0',
  `locked_until` datetime DEFAULT NULL,
  `password_changed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `last_password_reset_request` datetime DEFAULT NULL,
  `require_2fa_for_login` tinyint(1) DEFAULT '0',
  `require_2fa_for_payment` tinyint(1) DEFAULT '1',
  `session_timeout_minutes` smallint unsigned DEFAULT '120',
  PRIMARY KEY (`user_id`),
  KEY `idx_locked_until` (`locked_until`),
  CONSTRAINT `user_security_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_security_settings`
--

LOCK TABLES `user_security_settings` WRITE;
/*!40000 ALTER TABLE `user_security_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_security_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int unsigned NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `last_activity_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `revoked` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_session_id` (`session_id`),
  KEY `idx_user_last_activity` (`user_id`,`last_activity_at`),
  KEY `idx_expires` (`expires_at`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_signatures`
--

DROP TABLE IF EXISTS `user_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_signatures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `user_type` enum('employee','client') DEFAULT 'employee',
  `signature_data` longtext,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_signatures`
--

LOCK TABLES `user_signatures` WRITE;
/*!40000 ALTER TABLE `user_signatures` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_signatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','dispatcher','driver','accountant','owner_operator','client','system') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'driver',
  `status` enum('active','inactive','suspended','pending') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mc_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dot_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `license_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `license_state` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `driver_rating` decimal(3,2) DEFAULT '0.00',
  `total_jobs_completed` int unsigned DEFAULT '0',
  `total_earnings` decimal(12,2) DEFAULT '0.00',
  `last_login_at` datetime DEFAULT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `archived_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `uq_uuid` (`uuid`),
  KEY `idx_role_status` (`role`,`status`),
  KEY `idx_email` (`email`),
  KEY `idx_mc_number` (`mc_number`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'0c732f95-d906-11f0-81ee-005056c00001','system@kayannelogistics.com','$2y$10$5ekkx3.sKzc6ftsWV9UfH.I2uC6SLi2HhUST5f7cyImQB1M7.1fC2','system','active','System','Account',NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,0.00,NULL,NULL,'2025-12-14 18:00:45','2025-12-21 14:09:22',NULL),(2,'','admin@kayannelogistics.com','$2y$10$5ekkx3.sKzc6ftsWV9UfH.I2uC6SLi2HhUST5f7cyImQB1M7.1fC2','admin','active','System','Administrator','555-0001',NULL,NULL,NULL,NULL,NULL,0.00,0,0.00,NULL,NULL,'2025-12-14 18:00:45','2025-12-21 14:09:30',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_active_shipments`
--

DROP TABLE IF EXISTS `v_active_shipments`;
/*!50001 DROP VIEW IF EXISTS `v_active_shipments`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_active_shipments` AS SELECT 
 1 AS `shipment_number`,
 1 AS `pro_number`,
 1 AS `shipment_status`,
 1 AS `cargo_description`,
 1 AS `origin`,
 1 AS `destination`,
 1 AS `driver_name`,
 1 AS `truck_number`,
 1 AS `assignment_status`,
 1 AS `total_charges`,
 1 AS `created_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_driver_performance`
--

DROP TABLE IF EXISTS `v_driver_performance`;
/*!50001 DROP VIEW IF EXISTS `v_driver_performance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_driver_performance` AS SELECT 
 1 AS `id`,
 1 AS `driver_name`,
 1 AS `driver_rating`,
 1 AS `total_jobs_completed`,
 1 AS `total_earnings`,
 1 AS `total_shipments`,
 1 AS `on_time_deliveries`,
 1 AS `avg_delivery_time_days`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_financial_summary`
--

DROP TABLE IF EXISTS `v_financial_summary`;
/*!50001 DROP VIEW IF EXISTS `v_financial_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_financial_summary` AS SELECT 
 1 AS `month`,
 1 AS `invoice_count`,
 1 AS `total_invoiced`,
 1 AS `total_received`,
 1 AS `total_outstanding`,
 1 AS `avg_days_to_pay`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `webhook_deliveries`
--

DROP TABLE IF EXISTS `webhook_deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_deliveries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `webhook_id` int NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `payload` json NOT NULL,
  `response_code` int DEFAULT NULL,
  `response_body` text,
  `status` enum('pending','success','failed') DEFAULT NULL,
  `attempt_count` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `webhook_id` (`webhook_id`),
  KEY `ix_webhook_deliveries_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_deliveries`
--

LOCK TABLES `webhook_deliveries` WRITE;
/*!40000 ALTER TABLE `webhook_deliveries` DISABLE KEYS */;
INSERT INTO `webhook_deliveries` VALUES (1,0,'invoice.paid','{\"id\": 1, \"test\": true}',405,'<!DOCTYPE html>\n<html lang=en>\n  <meta charset=utf-8>\n  <meta name=viewport content=\"initial-scale=1, minimum-scale=1, width=device-width\">\n  <title>Error 405 (Method Not Allowed)!!1</title>\n  <style>\n    *{margin:0;padding:0}html,code{font:15px/22px arial,sans-serif}html{background:#fff;color:#222;padding:15px}body{margin:7% auto 0;max-width:390px;min-height:180px;padding:30px 0 15px}* > body{background:url(//www.google.com/images/errors/robot.png) 100% 5px no-repeat;padding-right:205px}p{margin:11px 0 22px;overflow:hidden}ins{color:#777;text-decoration:none}a img{border:0}@media screen and (max-width:772px){body{background:none;margin-top:0;max-width:none;padding-right:0}}#logo{background:url(//www.google.com/images/branding/googlelogo/1x/googlelogo_color_150x54dp.png) no-repeat;margin-left:-5px}@media only screen and (min-resolution:192dpi){#logo{background:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat 0% 0%/100% 100%;-moz-border-image:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) 0}}@media only screen and (-webkit-min-device-pixel-ratio:2){#logo{background:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat;-webkit-background-size:100% 100%}}#logo{display:inline-block;height:54px;width:150px}\n  </style>\n  <a href=//www.google.com/><span id=logo aria-label=Google></span></a>\n  <p><b>405.</b> <ins>ThatΓÇÖs an error.</ins>\n  <p>The request method <code>POST</code> is inappropriate for the URL <code>/</code>.  <ins>ThatΓÇÖs all we know.</ins>\n','failed',1,'2025-12-18 10:16:51','2025-12-18 10:16:53');
/*!40000 ALTER TABLE `webhook_deliveries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhooks`
--

DROP TABLE IF EXISTS `webhooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhooks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `target_url` varchar(500) NOT NULL,
  `event_events` json NOT NULL,
  `secret_key` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_webhooks_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhooks`
--

LOCK TABLES `webhooks` WRITE;
/*!40000 ALTER TABLE `webhooks` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhooks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kayanne_logistics'
--

--
-- Dumping routines for database 'kayanne_logistics'
--
/*!50003 DROP PROCEDURE IF EXISTS `AddLegacyJobColumns` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddLegacyJobColumns`()
BEGIN

    DECLARE done INT DEFAULT FALSE;

    DECLARE col_name VARCHAR(64);

    DECLARE col_def TEXT;

    DECLARE col_cursor CURSOR FOR SELECT name, definition FROM temp_cols;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_cols (

        name VARCHAR(64),

        definition TEXT

    );

    

    TRUNCATE TABLE temp_cols;

    

    INSERT INTO temp_cols VALUES

        ('pickup_location', 'TEXT NULL'),

        ('delivery_location', 'TEXT NULL'),

        ('pickup_date', 'DATE NULL'),

        ('delivery_date', 'DATE NULL'),

        ('invoice_number', 'VARCHAR(50) NULL'),

        ('commission_calculated', 'BOOLEAN DEFAULT FALSE'),

        ('scheduled_pickup_time', 'DATETIME NULL'),

        ('scheduled_delivery_time', 'DATETIME NULL');

    

    OPEN col_cursor;

    read_loop: LOOP

        FETCH col_cursor INTO col_name, col_def;

        IF done THEN LEAVE read_loop; END IF;

        

        SET @ce := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 

                   WHERE TABLE_SCHEMA = DATABASE() 

                   AND TABLE_NAME = 'jobs' 

                   AND COLUMN_NAME = col_name);

                   

        SET @ddl := IF(@ce = 0, 

                      CONCAT('ALTER TABLE jobs ADD COLUMN ', col_name, ' ', col_def), 

                      'SELECT 1');

        

        PREPARE stmt FROM @ddl; 

        EXECUTE stmt; 

        DEALLOCATE PREPARE stmt;

    END LOOP;

    

    CLOSE col_cursor;

    DROP TEMPORARY TABLE temp_cols;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_calculate_driver_commission` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_calculate_driver_commission`(

    IN p_shipment_id INT UNSIGNED

)
BEGIN

    DECLARE v_total_charges DECIMAL(10,2);

    DECLARE v_commission_rate DECIMAL(5,2);

    DECLARE v_driver_id INT UNSIGNED;

    DECLARE v_commission_amount DECIMAL(10,2);

    

    -- Get shipment details

    SELECT s.total_charges, s.commission_rate, sa.driver_id

    INTO v_total_charges, v_commission_rate, v_driver_id

    FROM shipments s

    JOIN shipment_assignments sa ON s.id = sa.shipment_id

    WHERE s.id = p_shipment_id

    AND s.status = 'delivered'

    AND sa.status = 'completed';

    

    IF v_driver_id IS NOT NULL THEN

        -- Calculate commission

        SET v_commission_amount = v_total_charges * (v_commission_rate / 100);

        

        -- Update driver earnings

        UPDATE users 

        SET total_earnings = total_earnings + v_commission_amount,

            total_jobs_completed = total_jobs_completed + 1

        WHERE id = v_driver_id;

        

        -- Log commission transaction (simplified)

        INSERT INTO accounting_transactions (

            transaction_number,

            transaction_date,

            description,

            shipment_id,

            status,

            created_by_user_id

        ) VALUES (

            CONCAT('COMM', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND() * 1000), 3, '0')),

            CURDATE(),

            CONCAT('Driver commission for shipment #', p_shipment_id),

            p_shipment_id,

            'posted',

            1

        );

        

        SELECT v_commission_amount as commission_amount;

    ELSE

        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver not found or shipment not delivered';

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_shipment_from_bid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_shipment_from_bid`(

    IN p_bid_id INT UNSIGNED,

    IN p_created_by_user_id INT UNSIGNED

)
BEGIN

    DECLARE v_load_opportunity_id INT UNSIGNED;

    DECLARE v_shipment_number VARCHAR(50);

    

    -- Generate shipment number

    SET v_shipment_number = CONCAT('SH', DATE_FORMAT(NOW(), '%Y%m'), LPAD(FLOOR(RAND() * 10000), 4, '0'));

    

    -- Get load opportunity from bid

    SELECT load_opportunity_id INTO v_load_opportunity_id

    FROM bids WHERE id = p_bid_id AND status = 'accepted';

    

    IF v_load_opportunity_id IS NOT NULL THEN

        -- Insert shipment (simplified - in reality would copy more fields)

        INSERT INTO shipments (

            shipment_number,

            bid_id,

            load_opportunity_id,

            status,

            booked_at,

            created_at,

            updated_at

        ) VALUES (

            v_shipment_number,

            p_bid_id,

            v_load_opportunity_id,

            'booked',

            NOW(),

            NOW(),

            NOW()

        );

        

        -- Update bid status

        UPDATE bids SET status = 'won' WHERE id = p_bid_id;

        

        SELECT LAST_INSERT_ID() as shipment_id, v_shipment_number as shipment_number;

    ELSE

        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bid not found or not accepted';

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `kayanne_logistics`
--

USE `kayanne_logistics`;

--
-- Final view structure for view `v_active_shipments`
--

/*!50001 DROP VIEW IF EXISTS `v_active_shipments`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_active_shipments` AS select `s`.`shipment_number` AS `shipment_number`,`s`.`pro_number` AS `pro_number`,`s`.`status` AS `shipment_status`,`s`.`cargo_description` AS `cargo_description`,concat(`p`.`city`,', ',`p`.`state`) AS `origin`,concat(`d`.`city`,', ',`d`.`state`) AS `destination`,concat(`u`.`first_name`,' ',`u`.`last_name`) AS `driver_name`,`a`.`asset_number` AS `truck_number`,`sa`.`status` AS `assignment_status`,`s`.`total_charges` AS `total_charges`,`s`.`created_at` AS `created_at` from (((((((`shipments` `s` left join `shipment_assignments` `sa` on((`s`.`id` = `sa`.`shipment_id`))) left join `users` `u` on((`sa`.`driver_id` = `u`.`id`))) left join `assets` `a` on((`sa`.`asset_id` = `a`.`id`))) left join (select `ss`.`shipment_id` AS `shipment_id`,min(`ss`.`stop_sequence`) AS `min_seq` from `shipment_stops` `ss` where (`ss`.`stop_type` = 'pickup') group by `ss`.`shipment_id`) `pm` on((`pm`.`shipment_id` = `s`.`id`))) left join `shipment_stops` `p` on(((`p`.`shipment_id` = `s`.`id`) and (`p`.`stop_type` = 'pickup') and (`p`.`stop_sequence` = `pm`.`min_seq`)))) left join (select `ss`.`shipment_id` AS `shipment_id`,max(`ss`.`stop_sequence`) AS `max_seq` from `shipment_stops` `ss` where (`ss`.`stop_type` in ('delivery','drop','live_unload')) group by `ss`.`shipment_id`) `dm` on((`dm`.`shipment_id` = `s`.`id`))) left join `shipment_stops` `d` on(((`d`.`shipment_id` = `s`.`id`) and (`d`.`stop_sequence` = `dm`.`max_seq`)))) where (`s`.`status` in ('assigned','in_transit','at_origin','at_destination')) order by `s`.`created_at` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_driver_performance`
--

/*!50001 DROP VIEW IF EXISTS `v_driver_performance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_driver_performance` AS select `u`.`id` AS `id`,concat(`u`.`first_name`,' ',`u`.`last_name`) AS `driver_name`,`u`.`driver_rating` AS `driver_rating`,`u`.`total_jobs_completed` AS `total_jobs_completed`,`u`.`total_earnings` AS `total_earnings`,count(distinct `s`.`id`) AS `total_shipments`,sum((case when (`s`.`status` = 'delivered') then 1 else 0 end)) AS `on_time_deliveries`,avg((to_days(`s`.`delivered_at`) - to_days(`s`.`picked_up_at`))) AS `avg_delivery_time_days` from ((`users` `u` left join `shipment_assignments` `sa` on((`u`.`id` = `sa`.`driver_id`))) left join `shipments` `s` on((`sa`.`shipment_id` = `s`.`id`))) where (`u`.`role` = 'driver') group by `u`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_financial_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_financial_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_financial_summary` AS select date_format(`i`.`invoice_date`,'%Y-%m') AS `month`,count(0) AS `invoice_count`,sum(`i`.`total_amount`) AS `total_invoiced`,sum(`i`.`amount_paid`) AS `total_received`,sum(`i`.`balance_due`) AS `total_outstanding`,avg((to_days(coalesce(`i`.`paid_date`,curdate())) - to_days(`i`.`invoice_date`))) AS `avg_days_to_pay` from `invoices` `i` where (`i`.`status` <> 'void') group by date_format(`i`.`invoice_date`,'%Y-%m') order by `month` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:30:18
