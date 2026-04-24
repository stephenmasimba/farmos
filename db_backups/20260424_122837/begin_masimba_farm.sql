-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: begin_masimba_farm
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
-- Current Database: `begin_masimba_farm`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `begin_masimba_farm` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `begin_masimba_farm`;

--
-- Table structure for table `access_audit_log`
--

DROP TABLE IF EXISTS `access_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `access_audit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `event_type` varchar(120) NOT NULL,
  `target_user_id` int DEFAULT NULL,
  `actor_user_id` int DEFAULT NULL,
  `farm_id` int DEFAULT NULL,
  `metadata_json` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_access_audit_event` (`event_type`),
  KEY `idx_access_audit_target` (`target_user_id`),
  KEY `idx_access_audit_actor` (`actor_user_id`),
  KEY `idx_access_audit_created` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access_audit_log`
--

LOCK TABLES `access_audit_log` WRITE;
/*!40000 ALTER TABLE `access_audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `access_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alert_rules`
--

DROP TABLE IF EXISTS `alert_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alert_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `device_type` varchar(50) NOT NULL,
  `sensor_type` varchar(50) NOT NULL,
  `condition_type` enum('above','below','equals','between') NOT NULL,
  `threshold_min` decimal(10,2) DEFAULT NULL,
  `threshold_max` decimal(10,2) DEFAULT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `enabled` tinyint(1) DEFAULT '1',
  `notification_channels` json DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alert_rules`
--

LOCK TABLES `alert_rules` WRITE;
/*!40000 ALTER TABLE `alert_rules` DISABLE KEYS */;
INSERT INTO `alert_rules` VALUES (1,'temperature','temperature','above',NULL,32.00,'high',1,'[\"in_app\", \"email\"]',1,'2026-01-11 17:34:12'),(2,'temperature','temperature','below',NULL,20.00,'medium',1,'[\"in_app\"]',1,'2026-01-11 17:34:12'),(3,'humidity','humidity','above',NULL,80.00,'medium',1,'[\"in_app\"]',1,'2026-01-11 17:34:12'),(4,'humidity','humidity','below',NULL,30.00,'low',1,'[\"in_app\"]',1,'2026-01-11 17:34:12'),(5,'ph','ph','above',NULL,8.50,'high',1,'[\"in_app\", \"email\"]',1,'2026-01-11 17:34:12'),(6,'ph','ph','below',NULL,5.50,'high',1,'[\"in_app\", \"email\"]',1,'2026-01-11 17:34:12'),(7,'ammonia','ammonia','above',NULL,25.00,'critical',1,'[\"in_app\", \"email\"]',1,'2026-01-11 17:34:12');
/*!40000 ALTER TABLE `alert_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allocations`
--

DROP TABLE IF EXISTS `allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allocations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `cost_center_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `percentage` decimal(5,2) DEFAULT NULL,
  `allocation_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `cost_center_id` (`cost_center_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocations`
--

LOCK TABLES `allocations` WRITE;
/*!40000 ALTER TABLE `allocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `animal_events`
--

DROP TABLE IF EXISTS `animal_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `animal_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `description` text,
  `event_date` date NOT NULL,
  `performed_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `performed_by` (`performed_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `animal_events`
--

LOCK TABLES `animal_events` WRITE;
/*!40000 ALTER TABLE `animal_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `animal_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `key_hash` varchar(255) NOT NULL,
  `prefix` varchar(10) NOT NULL,
  `status` enum('active','revoked') DEFAULT 'active',
  `created_by` int DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_keys`
--

LOCK TABLES `api_keys` WRITE;
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_request_logs`
--

DROP TABLE IF EXISTS `api_request_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_request_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `method` varchar(10) NOT NULL,
  `path` varchar(255) NOT NULL,
  `status_code` int NOT NULL,
  `duration_ms` int NOT NULL,
  `ip` varchar(64) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_path` (`path`(250)),
  KEY `idx_status_code` (`status_code`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_request_logs`
--

LOCK TABLES `api_request_logs` WRITE;
/*!40000 ALTER TABLE `api_request_logs` DISABLE KEYS */;
INSERT INTO `api_request_logs` VALUES (1,'POST','/api/auth/login',422,5026,'::1',NULL,NULL,'2026-04-12 14:28:35'),(2,'POST','/api/auth/login',200,5066,'::1',NULL,NULL,'2026-04-12 14:29:31'),(3,'POST','/api/auth/login',200,5659,'::1',NULL,NULL,'2026-04-12 14:39:16'),(4,'GET','/api/dashboard/summary',401,4292,'::1',NULL,NULL,'2026-04-12 14:44:13'),(5,'GET','/api/dashboard/summary',401,4090,'::1',NULL,NULL,'2026-04-12 14:44:18'),(6,'GET','/api/dashboard/summary',401,4106,'::1',NULL,NULL,'2026-04-12 14:44:24'),(7,'GET','/api/dashboard/summary',401,4105,'::1',NULL,NULL,'2026-04-12 14:44:29'),(8,'GET','/api/dashboard/summary',401,4079,'::1',NULL,NULL,'2026-04-12 14:44:33'),(9,'GET','/api/dashboard/summary',401,4082,'::1',NULL,NULL,'2026-04-12 14:44:38'),(10,'GET','/api/users',401,4266,'::1',NULL,NULL,'2026-04-12 14:45:49'),(11,'GET','/api/users',401,4174,'::1',NULL,NULL,'2026-04-12 14:45:54'),(12,'GET','/api/dashboard/summary',401,4106,'::1',NULL,NULL,'2026-04-12 14:46:00'),(13,'GET','/api/dashboard/summary',401,4086,'::1',NULL,NULL,'2026-04-12 14:46:04'),(14,'GET','/api/dashboard/summary',401,4103,'::1',NULL,NULL,'2026-04-12 14:46:09'),(15,'GET','/api/dashboard/summary',401,4101,'::1',NULL,NULL,'2026-04-12 14:46:13'),(16,'POST','/api/users',401,4139,'::1',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-04-12 14:47:10'),(17,'POST','/api/users',401,6161,'::1',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-04-12 15:10:16'),(18,'POST','/api/users',401,6099,'::1',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-04-12 15:10:16'),(19,'GET','/api/reports/types',401,6331,'::1',NULL,NULL,'2026-04-12 16:46:05'),(20,'POST','/api/auth/refresh',200,12163,'::1',NULL,NULL,'2026-04-12 16:46:06'),(21,'GET','/api/reports/types',401,4345,'::1',NULL,NULL,'2026-04-12 16:46:09'),(22,'GET','/api/dashboard/summary',401,4586,'::1',NULL,NULL,'2026-04-12 16:46:21'),(23,'GET','/api/dashboard/summary',401,4481,'::1',NULL,NULL,'2026-04-12 16:46:28'),(24,'GET','/api/dashboard/summary',401,4998,'::1',NULL,NULL,'2026-04-12 16:46:36'),(25,'GET','/api/dashboard/summary',401,4136,'::1',NULL,NULL,'2026-04-12 16:46:41'),(26,'GET','/api/weather/current',401,4227,'::1',NULL,NULL,'2026-04-12 16:46:48'),(27,'GET','/api/weather/current',401,4208,'::1',NULL,NULL,'2026-04-12 16:46:54'),(28,'GET','/api/weather/history',401,4152,'::1',NULL,NULL,'2026-04-12 16:46:59'),(29,'GET','/api/weather/history',401,4205,'::1',NULL,NULL,'2026-04-12 16:47:08'),(30,'POST','/api/auth/login',200,10251,'::1',NULL,NULL,'2026-04-20 17:50:34'),(31,'GET','/api/inventory-platform/warehouses',401,6921,'::1',NULL,NULL,'2026-04-20 17:50:41'),(32,'GET','/api/inventory-platform/reconcile',401,5263,'::1',NULL,NULL,'2026-04-20 17:50:48'),(33,'POST','/api/auth/login',200,4763,'::1',NULL,NULL,'2026-04-20 17:54:09'),(34,'GET','/api/inventory-platform/warehouses',500,4391,'::1',6,NULL,'2026-04-20 17:54:13'),(35,'GET','/api/inventory-platform/reconcile',500,4422,'::1',6,NULL,'2026-04-20 17:54:18'),(36,'POST','/api/auth/login',200,4752,'::1',NULL,NULL,'2026-04-20 18:04:44'),(37,'GET','/api/inventory-platform/warehouses',200,5397,'::1',6,NULL,'2026-04-20 18:04:49'),(38,'GET','/api/inventory-platform/reconcile',500,4320,'::1',6,NULL,'2026-04-20 18:04:54'),(39,'POST','/api/auth/login',200,4784,'::1',NULL,NULL,'2026-04-20 18:08:44'),(40,'GET','/api/inventory-platform/reconcile',200,4338,'::1',6,NULL,'2026-04-20 18:08:49'),(41,'POST','/api/auth/login',200,4507,'::1',NULL,NULL,'2026-04-20 18:09:16'),(42,'GET','/api/inventory',500,4118,'::1',6,NULL,'2026-04-20 18:09:20'),(43,'POST','/api/auth/login',200,4471,'::1',NULL,NULL,'2026-04-20 18:12:25'),(44,'GET','/api/inventory',200,4097,'::1',6,NULL,'2026-04-20 18:12:29'),(45,'POST','/api/auth/login',200,4524,'::1',NULL,NULL,'2026-04-20 18:13:51'),(46,'GET','/api/inventory-platform/warehouses',200,4237,'::1',6,NULL,'2026-04-20 18:13:56'),(47,'POST','/api/auth/login',200,4492,'::1',NULL,NULL,'2026-04-20 18:14:51'),(48,'POST','/api/inventory-platform/movements',201,4281,'::1',6,NULL,'2026-04-20 18:14:55'),(49,'POST','/api/inventory-platform/reservations',201,4266,'::1',6,NULL,'2026-04-20 18:15:00'),(50,'POST','/api/auth/login',200,4510,'::1',NULL,NULL,'2026-04-20 18:15:56'),(51,'POST','/api/inventory-platform/purchase-orders',201,4335,'::1',6,NULL,'2026-04-20 18:16:01'),(52,'POST','/api/inventory-platform/purchase-orders/1/approve',200,4218,'::1',6,NULL,'2026-04-20 18:16:05'),(53,'POST','/api/inventory-platform/purchase-orders/1/receive',201,4247,'::1',6,NULL,'2026-04-20 18:16:09'),(54,'POST','/api/auth/login',200,6258,'::1',NULL,NULL,'2026-04-20 19:35:38'),(55,'POST','/api/financial/category-mappings',201,4580,'::1',6,NULL,'2026-04-20 19:35:43'),(56,'POST','/api/financial/records',500,5386,'::1',6,NULL,'2026-04-20 19:35:48'),(57,'GET','/api/financial/budget-vs-actual',500,4131,'::1',6,NULL,'2026-04-20 19:35:52'),(58,'POST','/api/bi/connectors',201,4314,'::1',6,NULL,'2026-04-20 19:35:57'),(59,'POST','/api/bi/reports/run',500,4254,'::1',6,NULL,'2026-04-20 19:36:01'),(60,'GET','/api/financial-analytics/forecast',500,4297,'::1',6,NULL,'2026-04-20 19:36:05'),(61,'POST','/api/auth/login',200,4904,'::1',NULL,NULL,'2026-04-20 19:54:12'),(62,'POST','/api/financial/category-mappings',201,4131,'::1',6,NULL,'2026-04-20 19:54:16'),(63,'POST','/api/financial/records',500,4293,'::1',6,NULL,'2026-04-20 19:54:21'),(64,'POST','/api/financial/budgets',201,4126,'::1',6,NULL,'2026-04-20 19:54:25'),(65,'GET','/api/financial/budget-vs-actual',200,4128,'::1',6,NULL,'2026-04-20 19:54:29'),(66,'POST','/api/bi/reports/run',200,4124,'::1',6,NULL,'2026-04-20 19:54:33'),(67,'POST','/api/bi/connectors',201,4132,'::1',6,NULL,'2026-04-20 19:54:37'),(68,'GET','/api/financial-analytics/forecast',200,4202,'::1',6,NULL,'2026-04-20 19:54:42'),(69,'POST','/api/auth/login',200,4476,'::1',NULL,NULL,'2026-04-20 19:57:01'),(70,'POST','/api/financial/records',500,4276,'::1',6,NULL,'2026-04-20 19:57:05'),(71,'POST','/api/auth/login',200,4626,'::1',NULL,NULL,'2026-04-20 19:58:38'),(72,'POST','/api/financial/records',500,4241,'::1',6,NULL,'2026-04-20 19:58:43'),(73,'POST','/api/auth/login',200,5425,'::1',NULL,NULL,'2026-04-20 20:01:46'),(74,'POST','/api/financial/records',201,6252,'::1',6,NULL,'2026-04-20 20:01:52'),(75,'POST','/api/auth/login',200,5172,'::1',NULL,NULL,'2026-04-20 20:03:30'),(76,'GET','/api/bi/reports/drilldown',200,4156,'::1',6,NULL,'2026-04-20 20:03:34'),(77,'POST','/api/auth/login',200,5408,'::1',NULL,NULL,'2026-04-20 20:05:11'),(78,'POST','/api/financial/budgets',201,4114,'::1',6,NULL,'2026-04-20 20:05:16'),(79,'GET','/api/financial/budget-vs-actual',200,4204,'::1',6,NULL,'2026-04-20 20:05:20');
/*!40000 ALTER TABLE `api_request_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_versions`
--

DROP TABLE IF EXISTS `api_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_versions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `version` varchar(20) NOT NULL,
  `status` enum('active','deprecated','retired') DEFAULT 'active',
  `description` text,
  `deprecation_date` datetime DEFAULT NULL,
  `retirement_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `version` (`version`),
  KEY `idx_version` (`version`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_versions`
--

LOCK TABLES `api_versions` WRITE;
/*!40000 ALTER TABLE `api_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `resource_type` varchar(100) DEFAULT NULL,
  `resource_id` varchar(100) DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `session_id` varchar(255) DEFAULT NULL,
  `success` tinyint(1) DEFAULT '1',
  `error_message` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_resource` (`resource_type`,`resource_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auto_scaling_configs`
--

DROP TABLE IF EXISTS `auto_scaling_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auto_scaling_configs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_name` varchar(200) NOT NULL,
  `provider_name` varchar(100) NOT NULL,
  `min_instances` int DEFAULT '1',
  `max_instances` int DEFAULT '10',
  `scaling_policy` enum('manual','scheduled','reactive','predictive') DEFAULT 'reactive',
  `cpu_threshold_high` float DEFAULT '80',
  `cpu_threshold_low` float DEFAULT '20',
  `memory_threshold_high` float DEFAULT '85',
  `memory_threshold_low` float DEFAULT '30',
  `scale_up_cooldown_seconds` int DEFAULT '300',
  `scale_down_cooldown_seconds` int DEFAULT '300',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_service_name` (`service_name`),
  KEY `idx_provider_name` (`provider_name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auto_scaling_configs`
--

LOCK TABLES `auto_scaling_configs` WRITE;
/*!40000 ALTER TABLE `auto_scaling_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `auto_scaling_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_rules`
--

DROP TABLE IF EXISTS `automation_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `rule_name` varchar(255) NOT NULL,
  `trigger_type` varchar(50) DEFAULT NULL,
  `trigger_conditions` text,
  `actions` text,
  `is_active` tinyint(1) DEFAULT '1',
  `priority` int DEFAULT '1',
  `last_triggered` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_automation_tenant` (`tenant_id`),
  KEY `idx_automation_active` (`is_active`),
  KEY `idx_automation_rules_tenant_active` (`tenant_id`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_rules`
--

LOCK TABLES `automation_rules` WRITE;
/*!40000 ALTER TABLE `automation_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bi_connectors`
--

DROP TABLE IF EXISTS `bi_connectors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bi_connectors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `name` varchar(191) NOT NULL,
  `token` varchar(80) NOT NULL,
  `scope_json` text NOT NULL,
  `format` varchar(10) NOT NULL DEFAULT 'json',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_bi_connector_token` (`token`),
  KEY `idx_bi_connectors_farm` (`farm_id`,`active`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bi_connectors`
--

LOCK TABLES `bi_connectors` WRITE;
/*!40000 ALTER TABLE `bi_connectors` DISABLE KEYS */;
INSERT INTO `bi_connectors` VALUES (1,1,'Test','a359550718529e20146578eb94ad45c484b729fdf2f90442','{\"resources\":[\"financial_records\"]}','json',1,'2026-04-20 19:35:57',NULL),(2,1,'Test','9533aee74da3f304703fce4ac4ca1b4cbd300848b85230ba','{\"resources\":[\"financial_records\"]}','json',1,'2026-04-20 19:54:37',NULL);
/*!40000 ALTER TABLE `bi_connectors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bi_dashboard_widgets`
--

DROP TABLE IF EXISTS `bi_dashboard_widgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bi_dashboard_widgets` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dashboard_id` bigint NOT NULL,
  `widget_type` varchar(40) NOT NULL,
  `config_json` text,
  `position_json` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bi_widgets_dash` (`dashboard_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bi_dashboard_widgets`
--

LOCK TABLES `bi_dashboard_widgets` WRITE;
/*!40000 ALTER TABLE `bi_dashboard_widgets` DISABLE KEYS */;
/*!40000 ALTER TABLE `bi_dashboard_widgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bi_dashboards`
--

DROP TABLE IF EXISTS `bi_dashboards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bi_dashboards` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(191) NOT NULL,
  `layout_json` text,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bi_dash_farm_user` (`farm_id`,`user_id`,`is_default`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bi_dashboards`
--

LOCK TABLES `bi_dashboards` WRITE;
/*!40000 ALTER TABLE `bi_dashboards` DISABLE KEYS */;
/*!40000 ALTER TABLE `bi_dashboards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bi_report_definitions`
--

DROP TABLE IF EXISTS `bi_report_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bi_report_definitions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(191) NOT NULL,
  `report_type` varchar(40) NOT NULL,
  `definition_json` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bi_reports_farm_user` (`farm_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bi_report_definitions`
--

LOCK TABLES `bi_report_definitions` WRITE;
/*!40000 ALTER TABLE `bi_report_definitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `bi_report_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biogas_systems`
--

DROP TABLE IF EXISTS `biogas_systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biogas_systems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `total_capacity_m3` float DEFAULT NULL,
  `current_pressure_bar` float DEFAULT NULL,
  `max_safe_pressure` float DEFAULT NULL,
  `min_safe_pressure` float DEFAULT NULL,
  `production_rate_m3h` float DEFAULT NULL,
  `consumption_rate_m3h` float DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `leak_detection_enabled` tinyint(1) DEFAULT NULL,
  `last_maintenance` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_biogas_systems_id` (`id`),
  KEY `ix_biogas_systems_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biogas_systems`
--

LOCK TABLES `biogas_systems` WRITE;
/*!40000 ALTER TABLE `biogas_systems` DISABLE KEYS */;
/*!40000 ALTER TABLE `biogas_systems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biogas_zones`
--

DROP TABLE IF EXISTS `biogas_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biogas_zones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `system_id` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `zone_type` varchar(50) DEFAULT NULL,
  `current_pressure` float DEFAULT NULL,
  `flow_rate` float DEFAULT NULL,
  `valve_status` varchar(20) DEFAULT NULL,
  `leak_sensor_status` varchar(20) DEFAULT NULL,
  `pressure_drop_rate` float DEFAULT NULL,
  `isolation_possible` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `system_id` (`system_id`),
  KEY `ix_biogas_zones_id` (`id`),
  KEY `ix_biogas_zones_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biogas_zones`
--

LOCK TABLES `biogas_zones` WRITE;
/*!40000 ALTER TABLE `biogas_zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `biogas_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blockchain_transactions`
--

DROP TABLE IF EXISTS `blockchain_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blockchain_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `transaction_hash` varchar(64) DEFAULT NULL,
  `block_number` bigint DEFAULT NULL,
  `transaction_type` varchar(50) DEFAULT NULL,
  `reference_id` int DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `data` text,
  `timestamp` timestamp NULL DEFAULT NULL,
  `confirmed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_blockchain_tenant` (`tenant_id`),
  KEY `idx_blockchain_hash` (`transaction_hash`),
  KEY `idx_blockchain_reference` (`reference_id`,`reference_type`),
  KEY `idx_blockchain_tenant_hash` (`tenant_id`,`transaction_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blockchain_transactions`
--

LOCK TABLES `blockchain_transactions` WRITE;
/*!40000 ALTER TABLE `blockchain_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `blockchain_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `breeding_records`
--

DROP TABLE IF EXISTS `breeding_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `breeding_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `dam_batch_id` int DEFAULT NULL,
  `sire_batch_id` int DEFAULT NULL,
  `animal_id` varchar(50) DEFAULT NULL,
  `breeding_date` varchar(20) DEFAULT NULL,
  `expected_birth_date` varchar(20) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `offspring_batch_id` int DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `dam_batch_id` (`dam_batch_id`),
  KEY `sire_batch_id` (`sire_batch_id`),
  KEY `offspring_batch_id` (`offspring_batch_id`),
  KEY `ix_breeding_records_tenant_id` (`tenant_id`),
  KEY `ix_breeding_records_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `breeding_records`
--

LOCK TABLES `breeding_records` WRITE;
/*!40000 ALTER TABLE `breeding_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `breeding_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `breeding_records_enhanced`
--

DROP TABLE IF EXISTS `breeding_records_enhanced`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `breeding_records_enhanced` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `dam_batch_id` int DEFAULT NULL,
  `sire_batch_id` int DEFAULT NULL,
  `animal_id` varchar(50) DEFAULT NULL,
  `breeding_date` date DEFAULT NULL,
  `expected_birth_date` date DEFAULT NULL,
  `actual_birth_date` date DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `offspring_batch_id` int DEFAULT NULL,
  `genetic_markers` text,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_breeding_tenant` (`tenant_id`),
  KEY `idx_breeding_date` (`breeding_date`),
  KEY `idx_breeding_records_tenant_date` (`tenant_id`,`breeding_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `breeding_records_enhanced`
--

LOCK TABLES `breeding_records_enhanced` WRITE;
/*!40000 ALTER TABLE `breeding_records_enhanced` DISABLE KEYS */;
/*!40000 ALTER TABLE `breeding_records_enhanced` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bsf_cycles`
--

DROP TABLE IF EXISTS `bsf_cycles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bsf_cycles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `cycle_name` varchar(100) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `waste_input_kg` float DEFAULT NULL,
  `expected_yield_kg` float DEFAULT NULL,
  `actual_yield_kg` float DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_bsf_cycles_id` (`id`),
  KEY `ix_bsf_cycles_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bsf_cycles`
--

LOCK TABLES `bsf_cycles` WRITE;
/*!40000 ALTER TABLE `bsf_cycles` DISABLE KEYS */;
/*!40000 ALTER TABLE `bsf_cycles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `budget_categories`
--

DROP TABLE IF EXISTS `budget_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `budget_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `budget_id` varchar(50) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `budgeted_amount` decimal(15,2) NOT NULL,
  `actual_amount` decimal(15,2) DEFAULT '0.00',
  `variance` decimal(15,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_budget_id` (`budget_id`),
  KEY `idx_category_name` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `budget_categories`
--

LOCK TABLES `budget_categories` WRITE;
/*!40000 ALTER TABLE `budget_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `budget_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `budgets`
--

DROP TABLE IF EXISTS `budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `budgets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `limit` float DEFAULT NULL,
  `period` varchar(20) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `spent` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_budgets_tenant_id` (`tenant_id`),
  KEY `ix_budgets_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `budgets`
--

LOCK TABLES `budgets` WRITE;
/*!40000 ALTER TABLE `budgets` DISABLE KEYS */;
/*!40000 ALTER TABLE `budgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_entries`
--

DROP TABLE IF EXISTS `cache_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_entries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cache_key` varchar(255) NOT NULL,
  `cache_value` longtext,
  `cache_type` varchar(50) DEFAULT 'string',
  `ttl_seconds` int DEFAULT '3600',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime DEFAULT NULL,
  `access_count` int DEFAULT '0',
  `last_accessed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cache_key` (`cache_key`),
  KEY `idx_cache_key` (`cache_key`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_entries`
--

LOCK TABLES `cache_entries` WRITE;
/*!40000 ALTER TABLE `cache_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `camera_streams`
--

DROP TABLE IF EXISTS `camera_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `camera_streams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `camera_name` varchar(100) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `stream_url` varchar(500) DEFAULT NULL,
  `rtsp_url` varchar(500) DEFAULT NULL,
  `status` enum('online','offline','error') DEFAULT 'offline',
  `resolution` varchar(20) DEFAULT NULL,
  `fps` int DEFAULT '25',
  `motion_detection_enabled` tinyint(1) DEFAULT '1',
  `recording_enabled` tinyint(1) DEFAULT '1',
  `storage_path` varchar(500) DEFAULT NULL,
  `last_motion_detected` datetime DEFAULT NULL,
  `motion_sensitivity` int DEFAULT '50',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_camera_name` (`camera_name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `camera_streams`
--

LOCK TABLES `camera_streams` WRITE;
/*!40000 ALTER TABLE `camera_streams` DISABLE KEYS */;
/*!40000 ALTER TABLE `camera_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cdn_configurations`
--

DROP TABLE IF EXISTS `cdn_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cdn_configurations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_name` varchar(100) NOT NULL,
  `provider_type` enum('cloudflare','aws_cloudfront','azure_cdn','fastly','akamai') NOT NULL,
  `api_key` varchar(500) DEFAULT NULL,
  `api_secret` varchar(500) DEFAULT NULL,
  `zone_id` varchar(100) DEFAULT NULL,
  `distribution_id` varchar(100) DEFAULT NULL,
  `endpoint` varchar(500) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_name` (`provider_name`),
  KEY `idx_provider_type` (`provider_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cdn_configurations`
--

LOCK TABLES `cdn_configurations` WRITE;
/*!40000 ALTER TABLE `cdn_configurations` DISABLE KEYS */;
/*!40000 ALTER TABLE `cdn_configurations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compliance_requirements`
--

DROP TABLE IF EXISTS `compliance_requirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compliance_requirements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `standard` varchar(100) DEFAULT NULL,
  `section` varchar(100) DEFAULT NULL,
  `description` text,
  `status` varchar(20) DEFAULT NULL,
  `last_audit_date` varchar(20) DEFAULT NULL,
  `auditor` varchar(100) DEFAULT NULL,
  `evidence_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_compliance_requirements_id` (`id`),
  KEY `ix_compliance_requirements_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compliance_requirements`
--

LOCK TABLES `compliance_requirements` WRITE;
/*!40000 ALTER TABLE `compliance_requirements` DISABLE KEYS */;
/*!40000 ALTER TABLE `compliance_requirements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compost_piles`
--

DROP TABLE IF EXISTS `compost_piles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compost_piles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `temperature_c` float DEFAULT NULL,
  `moisture_pct` float DEFAULT NULL,
  `ph` float DEFAULT NULL,
  `days_active` int DEFAULT NULL,
  `last_turned` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_compost_piles_tenant_id` (`tenant_id`),
  KEY `ix_compost_piles_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compost_piles`
--

LOCK TABLES `compost_piles` WRITE;
/*!40000 ALTER TABLE `compost_piles` DISABLE KEYS */;
/*!40000 ALTER TABLE `compost_piles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contract_agreements`
--

DROP TABLE IF EXISTS `contract_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contract_agreements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contract_number` varchar(50) NOT NULL,
  `farmer_name` varchar(100) NOT NULL,
  `farmer_id_number` varchar(50) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('draft','active','completed','terminated') DEFAULT 'draft',
  `terms` text,
  `total_value` decimal(15,2) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_number` (`contract_number`),
  KEY `created_by` (`created_by`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contract_agreements`
--

LOCK TABLES `contract_agreements` WRITE;
/*!40000 ALTER TABLE `contract_agreements` DISABLE KEYS */;
INSERT INTO `contract_agreements` VALUES (1,'CTR-2025-001','John Doe',NULL,'2026-01-12','0000-00-00','draft',NULL,1500.00,3,'2026-01-12 16:45:17');
/*!40000 ALTER TABLE `contract_agreements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contracts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `grower_name` varchar(100) DEFAULT NULL,
  `crop` varchar(50) DEFAULT NULL,
  `acreage` float DEFAULT NULL,
  `agreed_price_per_kg` float DEFAULT NULL,
  `start_date` varchar(20) DEFAULT NULL,
  `end_date` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_contracts_id` (`id`),
  KEY `ix_contracts_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
INSERT INTO `contracts` VALUES (1,'default','Test Grower','Soy',10,5,'2024-01-01','2024-12-31','Active'),(2,'default','Test Grower','Soy',10,5,'2024-01-01','2024-12-31','Active');
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cost_allocations`
--

DROP TABLE IF EXISTS `cost_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cost_allocations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `transaction_id` int DEFAULT NULL,
  `cost_center_id` int DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `percentage` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `cost_center_id` (`cost_center_id`),
  KEY `ix_cost_allocations_id` (`id`),
  KEY `ix_cost_allocations_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cost_allocations`
--

LOCK TABLES `cost_allocations` WRITE;
/*!40000 ALTER TABLE `cost_allocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `cost_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cost_centers`
--

DROP TABLE IF EXISTS `cost_centers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cost_centers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `budget_limit` decimal(15,2) DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` varchar(50) DEFAULT 'default',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `parent_id` (`parent_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cost_centers`
--

LOCK TABLES `cost_centers` WRITE;
/*!40000 ALTER TABLE `cost_centers` DISABLE KEYS */;
INSERT INTO `cost_centers` VALUES (1,'CC-001','Crop Production',NULL,5000.00,NULL,'active','2026-01-12 16:44:47','default'),(2,'CC-002','Livestock Operations',NULL,8000.00,NULL,'active','2026-01-12 16:44:47','default'),(3,'CC-003','Machinery Maintenance',NULL,2000.00,NULL,'active','2026-01-12 16:44:47','default');
/*!40000 ALTER TABLE `cost_centers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_leads`
--

DROP TABLE IF EXISTS `crm_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_leads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `lead_id` varchar(50) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `company` varchar(200) DEFAULT NULL,
  `source` varchar(100) DEFAULT NULL,
  `status` enum('new','contacted','qualified','converted','lost') DEFAULT 'new',
  `lead_score` int DEFAULT '0',
  `estimated_value` decimal(15,2) DEFAULT NULL,
  `probability_close` int DEFAULT '0',
  `expected_close_date` date DEFAULT NULL,
  `assigned_to` varchar(100) DEFAULT NULL,
  `notes` text,
  `tags` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lead_id` (`lead_id`),
  KEY `idx_lead_id` (`lead_id`),
  KEY `idx_status` (`status`),
  KEY `idx_lead_score` (`lead_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_leads`
--

LOCK TABLES `crm_leads` WRITE;
/*!40000 ALTER TABLE `crm_leads` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crop_history`
--

DROP TABLE IF EXISTS `crop_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crop_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `planting_date` date DEFAULT NULL,
  `harvest_date` date DEFAULT NULL,
  `yield_amount` decimal(10,2) DEFAULT NULL,
  `yield_unit` varchar(20) DEFAULT NULL,
  `notes` text,
  `recorded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `recorded_by` (`recorded_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crop_history`
--

LOCK TABLES `crop_history` WRITE;
/*!40000 ALTER TABLE `crop_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `crop_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crops`
--

DROP TABLE IF EXISTS `crops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `variety` varchar(100) DEFAULT NULL,
  `planting_date` date DEFAULT NULL,
  `harvest_date` date DEFAULT NULL,
  `field_location` varchar(100) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'planted',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crops`
--

LOCK TABLES `crops` WRITE;
/*!40000 ALTER TABLE `crops` DISABLE KEYS */;
/*!40000 ALTER TABLE `crops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `ix_customers_tenant_id` (`tenant_id`),
  KEY `ix_customers_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_encryption`
--

DROP TABLE IF EXISTS `data_encryption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_encryption` (
  `id` int NOT NULL AUTO_INCREMENT,
  `data_type` varchar(100) NOT NULL,
  `encrypted_data` longtext NOT NULL,
  `encryption_algorithm` varchar(50) DEFAULT 'Fernet',
  `key_version` varchar(20) DEFAULT '1.0',
  `encrypted_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_data_type` (`data_type`),
  KEY `idx_encrypted_at` (`encrypted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_encryption`
--

LOCK TABLES `data_encryption` WRITE;
/*!40000 ALTER TABLE `data_encryption` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_encryption` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `energy_loads`
--

DROP TABLE IF EXISTS `energy_loads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `energy_loads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `load_type` varchar(50) DEFAULT NULL,
  `power_watts` float DEFAULT NULL,
  `is_essential` tinyint(1) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_energy_loads_tenant_id` (`tenant_id`),
  KEY `ix_energy_loads_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `energy_loads`
--

LOCK TABLES `energy_loads` WRITE;
/*!40000 ALTER TABLE `energy_loads` DISABLE KEYS */;
/*!40000 ALTER TABLE `energy_loads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `energy_logs`
--

DROP TABLE IF EXISTS `energy_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `energy_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `battery_voltage` float DEFAULT NULL,
  `battery_percentage` int DEFAULT NULL,
  `consumption_watts` float DEFAULT NULL,
  `solar_generation_watts` float DEFAULT NULL,
  `grid_status` varchar(20) DEFAULT NULL,
  `load_id` int DEFAULT NULL,
  `consumption_kwh` float DEFAULT NULL,
  `cost_estimate` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `load_id` (`load_id`),
  KEY `ix_energy_logs_id` (`id`),
  KEY `ix_energy_logs_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `energy_logs`
--

LOCK TABLES `energy_logs` WRITE;
/*!40000 ALTER TABLE `energy_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `energy_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `serial_number` varchar(50) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `purchase_price` decimal(10,2) DEFAULT NULL,
  `status` enum('active','maintenance','retired') DEFAULT 'active',
  `last_maintenance_date` date DEFAULT NULL,
  `next_maintenance_date` date DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` varchar(50) DEFAULT 'default',
  `vibration_baseline` float DEFAULT '0',
  `temperature_baseline` float DEFAULT '0',
  `current_draw_baseline` float DEFAULT '0',
  `last_maintenance` datetime DEFAULT NULL,
  `next_maintenance` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (1,'Test Tractor','SN-1770976013','2024-02-13',45000.00,'','2024-01-15',NULL,'Test equipment for validation','2026-02-13 09:46:53','1',0,0,0,NULL,NULL);
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_formulations`
--

DROP TABLE IF EXISTS `feed_formulations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_formulations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `target_protein` float DEFAULT NULL,
  `final_cost_per_kg` float DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `ingredients_json` text,
  PRIMARY KEY (`id`),
  KEY `ix_feed_formulations_tenant_id` (`tenant_id`),
  KEY `ix_feed_formulations_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_formulations`
--

LOCK TABLES `feed_formulations` WRITE;
/*!40000 ALTER TABLE `feed_formulations` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_formulations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_formulations_enhanced`
--

DROP TABLE IF EXISTS `feed_formulations_enhanced`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_formulations_enhanced` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `formulation_code` varchar(50) NOT NULL,
  `formulation_name` varchar(255) DEFAULT NULL,
  `target_animal` varchar(50) NOT NULL,
  `target_stage` varchar(50) DEFAULT NULL,
  `protein_target` decimal(5,2) DEFAULT NULL,
  `fat_target` decimal(5,2) DEFAULT NULL,
  `fiber_target` decimal(5,2) DEFAULT NULL,
  `ingredients` text NOT NULL,
  `total_batch_kg` decimal(10,2) DEFAULT NULL,
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `nutritional_analysis` text,
  `status` varchar(20) DEFAULT 'active',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tenant_formulation` (`tenant_id`,`formulation_code`),
  KEY `idx_formulations_tenant` (`tenant_id`),
  KEY `idx_formulations_animal` (`target_animal`),
  KEY `idx_feed_formulations_tenant_animal` (`tenant_id`,`target_animal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_formulations_enhanced`
--

LOCK TABLES `feed_formulations_enhanced` WRITE;
/*!40000 ALTER TABLE `feed_formulations_enhanced` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_formulations_enhanced` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_ingredients`
--

DROP TABLE IF EXISTS `feed_ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_ingredients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `protein_content` float DEFAULT NULL,
  `quantity_kg` float DEFAULT NULL,
  `cost_per_kg` float DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `ix_feed_ingredients_tenant_id` (`tenant_id`),
  KEY `ix_feed_ingredients_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_ingredients`
--

LOCK TABLES `feed_ingredients` WRITE;
/*!40000 ALTER TABLE `feed_ingredients` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_ingredients_enhanced`
--

DROP TABLE IF EXISTS `feed_ingredients_enhanced`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_ingredients_enhanced` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `ingredient_name` varchar(255) NOT NULL,
  `ingredient_type` varchar(50) DEFAULT NULL,
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `availability` varchar(20) DEFAULT NULL,
  `supplier` varchar(255) DEFAULT NULL,
  `origin` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tenant_ingredient` (`tenant_id`,`ingredient_name`),
  KEY `idx_ingredients_tenant` (`tenant_id`),
  KEY `idx_ingredients_type` (`ingredient_type`),
  KEY `idx_feed_ingredients_tenant_name` (`tenant_id`,`ingredient_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_ingredients_enhanced`
--

LOCK TABLES `feed_ingredients_enhanced` WRITE;
/*!40000 ALTER TABLE `feed_ingredients_enhanced` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_ingredients_enhanced` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_logs`
--

DROP TABLE IF EXISTS `feed_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feed_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int NOT NULL,
  `feed_item_id` int DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `feeding_date` date NOT NULL,
  `notes` text,
  `recorded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `feed_item_id` (`feed_item_id`),
  KEY `recorded_by` (`recorded_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_logs`
--

LOCK TABLES `feed_logs` WRITE;
/*!40000 ALTER TABLE `feed_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_history`
--

DROP TABLE IF EXISTS `field_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `field_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `field_id` int DEFAULT NULL,
  `action` varchar(100) DEFAULT NULL,
  `details` text,
  `date` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `ix_field_history_tenant_id` (`tenant_id`),
  KEY `ix_field_history_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_history`
--

LOCK TABLES `field_history` WRITE;
/*!40000 ALTER TABLE `field_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fields`
--

DROP TABLE IF EXISTS `fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fields` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `area_size` decimal(10,2) DEFAULT NULL,
  `location_coordinates` varchar(255) DEFAULT NULL,
  `current_crop` varchar(100) DEFAULT NULL,
  `planting_date` date DEFAULT NULL,
  `expected_harvest_date` date DEFAULT NULL,
  `status` enum('fallow','planted','harvested','prepared') DEFAULT 'fallow',
  `soil_type` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` int DEFAULT NULL,
  `area` float DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `crop` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_fields_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fields`
--

LOCK TABLES `fields` WRITE;
/*!40000 ALTER TABLE `fields` DISABLE KEYS */;
INSERT INTO `fields` VALUES (1,'North Pasture',15.50,'North Section','Grass',NULL,NULL,'planted','Clay Loam',NULL,'2026-01-12 13:25:57',NULL,NULL,NULL,NULL),(2,'South Crops',22.00,'South Section','Maize',NULL,NULL,'planted','Sandy Loam',NULL,'2026-01-12 13:25:58',NULL,NULL,NULL,NULL),(3,'East Orchard',5.00,'East Section',NULL,NULL,NULL,'fallow','Silt',NULL,'2026-01-12 13:25:58',NULL,NULL,NULL,NULL),(4,'North Field',10.50,NULL,'Maize',NULL,NULL,'','Loam',NULL,'2026-01-12 16:44:47',NULL,NULL,NULL,NULL),(5,'South Field',5.20,NULL,'Soybeans',NULL,NULL,'','Clay',NULL,'2026-01-12 16:44:47',NULL,NULL,NULL,NULL),(6,'East Greenhouse',0.80,NULL,'Tomatoes',NULL,NULL,'','Potting Mix',NULL,'2026-01-12 16:44:47',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_analytics_forecast`
--

DROP TABLE IF EXISTS `financial_analytics_forecast`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_analytics_forecast` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `period` varchar(20) NOT NULL,
  `projected_revenue` decimal(12,2) NOT NULL DEFAULT '0.00',
  `projected_expenses` decimal(12,2) NOT NULL DEFAULT '0.00',
  `net_cash_flow` decimal(12,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fin_forecast_farm` (`farm_id`,`period`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_analytics_forecast`
--

LOCK TABLES `financial_analytics_forecast` WRITE;
/*!40000 ALTER TABLE `financial_analytics_forecast` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_analytics_forecast` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_assets`
--

DROP TABLE IF EXISTS `financial_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_assets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `asset_name` varchar(180) NOT NULL,
  `type` varchar(80) NOT NULL,
  `purchase_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `current_value` decimal(12,2) NOT NULL DEFAULT '0.00',
  `annual_depreciation` decimal(12,2) NOT NULL DEFAULT '0.00',
  `purchase_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fin_assets_farm` (`farm_id`,`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_assets`
--

LOCK TABLES `financial_assets` WRITE;
/*!40000 ALTER TABLE `financial_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_audit_events`
--

DROP TABLE IF EXISTS `financial_audit_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_audit_events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `event_type` varchar(80) NOT NULL,
  `entity_type` varchar(80) NOT NULL,
  `entity_id` varchar(80) NOT NULL,
  `payload_json` longtext,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fin_audit_farm_date` (`farm_id`,`created_at`),
  KEY `idx_fin_audit_entity` (`entity_type`,`entity_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_audit_events`
--

LOCK TABLES `financial_audit_events` WRITE;
/*!40000 ALTER TABLE `financial_audit_events` DISABLE KEYS */;
INSERT INTO `financial_audit_events` VALUES (1,1,'record.created','financial_record','1','{\"type\":\"expense\",\"amount\":12.5,\"category\":\"Fuel\",\"category_source\":\"mapped\"}',6,'2026-04-20 20:01:52');
/*!40000 ALTER TABLE `financial_audit_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_budget_lines`
--

DROP TABLE IF EXISTS `financial_budget_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_budget_lines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `category` varchar(191) NOT NULL,
  `period` enum('monthly','yearly') NOT NULL DEFAULT 'monthly',
  `year` int NOT NULL,
  `month` int DEFAULT NULL,
  `limit_amount` decimal(14,2) NOT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_budget_lines_farm_year` (`farm_id`,`year`),
  KEY `idx_budget_lines_category` (`farm_id`,`category`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_budget_lines`
--

LOCK TABLES `financial_budget_lines` WRITE;
/*!40000 ALTER TABLE `financial_budget_lines` DISABLE KEYS */;
INSERT INTO `financial_budget_lines` VALUES (1,1,'Fuel','monthly',2026,4,50.00,6,'2026-04-20 19:54:25','2026-04-20 17:54:25'),(2,1,'Fuel','monthly',2026,4,50.00,6,'2026-04-20 20:05:16','2026-04-20 18:05:16');
/*!40000 ALTER TABLE `financial_budget_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_budgets`
--

DROP TABLE IF EXISTS `financial_budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_budgets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `budget_id` varchar(50) NOT NULL,
  `name` varchar(200) NOT NULL,
  `fiscal_year` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_budgeted_amount` decimal(15,2) NOT NULL,
  `budget_categories` json DEFAULT NULL,
  `variance_threshold` decimal(5,2) DEFAULT '10.00',
  `status` enum('draft','active','closed') DEFAULT 'draft',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `budget_id` (`budget_id`),
  KEY `idx_budget_id` (`budget_id`),
  KEY `idx_fiscal_year` (`fiscal_year`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_budgets`
--

LOCK TABLES `financial_budgets` WRITE;
/*!40000 ALTER TABLE `financial_budgets` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_budgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_categories`
--

DROP TABLE IF EXISTS `financial_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `name` varchar(191) NOT NULL,
  `type` enum('income','expense','both') NOT NULL DEFAULT 'both',
  `parent_id` int DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_fin_categories` (`farm_id`,`name`),
  KEY `idx_fin_categories_farm` (`farm_id`,`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_categories`
--

LOCK TABLES `financial_categories` WRITE;
/*!40000 ALTER TABLE `financial_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_category_mappings`
--

DROP TABLE IF EXISTS `financial_category_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_category_mappings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `keyword` varchar(191) NOT NULL,
  `category` varchar(191) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `match_field` varchar(40) NOT NULL DEFAULT 'combined',
  `match_type` varchar(20) NOT NULL DEFAULT 'contains',
  `priority` int NOT NULL DEFAULT '0',
  `tags_json` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_financial_category_mappings_farm` (`farm_id`),
  KEY `idx_financial_category_mappings_keyword` (`keyword`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_category_mappings`
--

LOCK TABLES `financial_category_mappings` WRITE;
/*!40000 ALTER TABLE `financial_category_mappings` DISABLE KEYS */;
INSERT INTO `financial_category_mappings` VALUES (1,1,'fuel','Fuel',1,'description','contains',10,NULL,6,'2026-04-20 19:35:43','2026-04-20 17:35:43'),(2,1,'fuel','Fuel',1,'description','contains',10,NULL,6,'2026-04-20 19:54:16','2026-04-20 17:54:16');
/*!40000 ALTER TABLE `financial_category_mappings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_close_checklist`
--

DROP TABLE IF EXISTS `financial_close_checklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_close_checklist` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `period_id` int NOT NULL,
  `check_key` varchar(80) NOT NULL,
  `status` enum('pending','passed','failed') NOT NULL DEFAULT 'pending',
  `notes` varchar(255) DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_fin_close_check` (`farm_id`,`period_id`,`check_key`),
  KEY `idx_fin_close_period` (`farm_id`,`period_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_close_checklist`
--

LOCK TABLES `financial_close_checklist` WRITE;
/*!40000 ALTER TABLE `financial_close_checklist` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_close_checklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_invoices`
--

DROP TABLE IF EXISTS `financial_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `invoice_number` varchar(64) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `items` text,
  `amount` decimal(12,2) NOT NULL,
  `due_date` date NOT NULL,
  `status` enum('unpaid','paid','overdue','cancelled') NOT NULL DEFAULT 'unpaid',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_financial_invoices_number` (`invoice_number`),
  KEY `idx_financial_invoices_farm` (`farm_id`,`created_at`),
  KEY `idx_financial_invoices_status` (`farm_id`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_invoices`
--

LOCK TABLES `financial_invoices` WRITE;
/*!40000 ALTER TABLE `financial_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_periods`
--

DROP TABLE IF EXISTS `financial_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_periods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  `period_type` enum('monthly','yearly') NOT NULL DEFAULT 'monthly',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `closed_at` datetime DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_financial_periods_farm` (`farm_id`),
  KEY `idx_financial_periods_dates` (`start_date`,`end_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_periods`
--

LOCK TABLES `financial_periods` WRITE;
/*!40000 ALTER TABLE `financial_periods` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_records`
--

DROP TABLE IF EXISTS `financial_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` enum('income','expense') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text,
  `date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `vendor` varchar(191) DEFAULT NULL,
  `tags_json` text,
  `category_source` varchar(20) NOT NULL DEFAULT 'manual',
  `mapped_rule_id` int DEFAULT NULL,
  `period_id` int DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `reference_number` varchar(191) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'completed',
  `notes` text,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_records`
--

LOCK TABLES `financial_records` WRITE;
/*!40000 ALTER TABLE `financial_records` DISABLE KEYS */;
INSERT INTO `financial_records` VALUES (1,'expense',12.50,'Fuel','fuel purchase','2026-04-20','2026-04-20 20:01:52','Shell',NULL,'mapped',1,NULL,6,6,'USD','R4','cash','completed','test',NULL);
/*!40000 ALTER TABLE `financial_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_roi_projects`
--

DROP TABLE IF EXISTS `financial_roi_projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_roi_projects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `project_name` varchar(180) NOT NULL,
  `investment` decimal(12,2) NOT NULL DEFAULT '0.00',
  `roi_percentage` decimal(8,2) NOT NULL DEFAULT '0.00',
  `payback_months` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fin_roi_farm` (`farm_id`,`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_roi_projects`
--

LOCK TABLES `financial_roi_projects` WRITE;
/*!40000 ALTER TABLE `financial_roi_projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_roi_projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_transactions`
--

DROP TABLE IF EXISTS `financial_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_financial_transactions_tenant_id` (`tenant_id`),
  KEY `ix_financial_transactions_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_transactions`
--

LOCK TABLES `financial_transactions` WRITE;
/*!40000 ALTER TABLE `financial_transactions` DISABLE KEYS */;
INSERT INTO `financial_transactions` VALUES (1,'default','income','Sales',5000,'Sold 5 steers','2023-09-15',NULL),(2,'default','expense','Inputs',1200,'Purchased Fertilizer','2023-09-20',NULL),(3,'default','expense','Labor',800,'Casual labor wages','2023-09-30',NULL),(4,'1','EXPENSE','MAINTENANCE',1500,'Test equipment maintenance cost','2024-02-13',NULL);
/*!40000 ALTER TABLE `financial_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `harvest_logs`
--

DROP TABLE IF EXISTS `harvest_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `harvest_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `field_id` int DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `crop` varchar(50) DEFAULT NULL,
  `yield_amount` float DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `target_yield` float DEFAULT NULL,
  `location_lat` float DEFAULT NULL,
  `location_lng` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `ix_harvest_logs_tenant_id` (`tenant_id`),
  KEY `ix_harvest_logs_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `harvest_logs`
--

LOCK TABLES `harvest_logs` WRITE;
/*!40000 ALTER TABLE `harvest_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `harvest_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `harvest_records`
--

DROP TABLE IF EXISTS `harvest_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `harvest_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `harvest_date` date NOT NULL,
  `crop_variety` varchar(100) DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `quality_grade` varchar(50) DEFAULT NULL,
  `storage_location` varchar(100) DEFAULT NULL,
  `notes` text,
  `recorded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `recorded_by` (`recorded_by`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `harvest_records`
--

LOCK TABLES `harvest_records` WRITE;
/*!40000 ALTER TABLE `harvest_records` DISABLE KEYS */;
INSERT INTO `harvest_records` VALUES (1,4,'2026-01-12','SC727',500.00,'kg',NULL,NULL,NULL,4,'2026-01-12 16:45:17'),(2,4,'2026-01-12','SC727',500.00,'kg',NULL,NULL,NULL,4,'2026-01-12 19:25:34'),(3,4,'2026-01-12','SC727',500.00,'kg',NULL,NULL,NULL,4,'2026-01-12 19:28:11');
/*!40000 ALTER TABLE `harvest_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `health_records`
--

DROP TABLE IF EXISTS `health_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int NOT NULL,
  `record_date` date NOT NULL,
  `condition_name` varchar(100) DEFAULT NULL,
  `diagnosis` text,
  `treatment` text,
  `medication_used` varchar(100) DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `veterinarian` varchar(100) DEFAULT NULL,
  `outcome` text,
  `recorded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `recorded_by` (`recorded_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_records`
--

LOCK TABLES `health_records` WRITE;
/*!40000 ALTER TABLE `health_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `health_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `reorder_level` decimal(10,2) NOT NULL,
  `cost_per_unit` decimal(10,2) DEFAULT NULL,
  `supplier_id` int DEFAULT NULL,
  `description` text,
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,'Cattle Feed A','Feed',510.00,'kg',100.00,NULL,NULL,'Barn 1','2026-04-20 18:14:55'),(2,'Antibiotics X','Medicine',53.00,'doses',10.00,NULL,NULL,'Office Fridge','2026-04-20 18:16:09'),(3,'Tractor Fuel','Fuel',200.00,'liters',50.00,NULL,NULL,'Shed','2026-01-12 13:25:58'),(4,'Corn Seeds','Seeds',20.00,'bags',5.00,NULL,NULL,'Shed','2026-01-12 13:25:58');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_audit_events`
--

DROP TABLE IF EXISTS `inventory_audit_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_audit_events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `event_type` varchar(40) NOT NULL,
  `entity_type` varchar(60) NOT NULL,
  `entity_id` varchar(80) NOT NULL,
  `payload_json` longtext,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_farm_date` (`farm_id`,`created_at`),
  KEY `idx_audit_entity` (`entity_type`,`entity_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_audit_events`
--

LOCK TABLES `inventory_audit_events` WRITE;
/*!40000 ALTER TABLE `inventory_audit_events` DISABLE KEYS */;
INSERT INTO `inventory_audit_events` VALUES (1,1,'movement.recorded','inventory_movement','1','{\"movement_type\":\"in\",\"warehouse_id\":1,\"location_id\":0,\"item_id\":1,\"lot_id\":0,\"quantity\":10}',6,'2026-04-20 18:14:55'),(2,1,'reservation.created','inventory_reservation','1','{\"qty\":2}',6,'2026-04-20 18:15:00'),(3,1,'po.created','purchase_order','1','[]',6,'2026-04-20 18:16:01'),(4,1,'po.approved','purchase_order','1','[]',6,'2026-04-20 18:16:05'),(5,1,'po.received','purchase_order','1','{\"receipt_id\":1,\"warehouse_id\":1}',6,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_audit_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_cogs`
--

DROP TABLE IF EXISTS `inventory_cogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_cogs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `warehouse_id` int NOT NULL DEFAULT '0',
  `lot_id` bigint NOT NULL DEFAULT '0',
  `qty` decimal(14,3) NOT NULL,
  `total_cost` decimal(14,4) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL,
  `reference_type` varchar(40) DEFAULT NULL,
  `reference_id` varchar(80) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cogs_farm_date` (`farm_id`,`created_at`),
  KEY `idx_cogs_item` (`farm_id`,`item_id`,`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_cogs`
--

LOCK TABLES `inventory_cogs` WRITE;
/*!40000 ALTER TABLE `inventory_cogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_cogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_cost_layers`
--

DROP TABLE IF EXISTS `inventory_cost_layers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_cost_layers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `warehouse_id` int NOT NULL DEFAULT '0',
  `lot_id` bigint NOT NULL DEFAULT '0',
  `received_at` datetime NOT NULL,
  `qty_received` decimal(14,3) NOT NULL,
  `qty_remaining` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL,
  `reference_type` varchar(40) DEFAULT NULL,
  `reference_id` varchar(80) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_layers_item` (`farm_id`,`item_id`,`warehouse_id`,`received_at`),
  KEY `idx_layers_remaining` (`farm_id`,`item_id`,`qty_remaining`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_cost_layers`
--

LOCK TABLES `inventory_cost_layers` WRITE;
/*!40000 ALTER TABLE `inventory_cost_layers` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_cost_layers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_item_cost_state`
--

DROP TABLE IF EXISTS `inventory_item_cost_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_item_cost_state` (
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `avg_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`farm_id`,`item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_item_cost_state`
--

LOCK TABLES `inventory_item_cost_state` WRITE;
/*!40000 ALTER TABLE `inventory_item_cost_state` DISABLE KEYS */;
INSERT INTO `inventory_item_cost_state` VALUES (1,1,2.5000,'2026-04-20 18:14:55'),(1,2,3.7500,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_item_cost_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_item_costing`
--

DROP TABLE IF EXISTS `inventory_item_costing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_item_costing` (
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `method` varchar(20) NOT NULL DEFAULT 'wavg',
  `standard_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`farm_id`,`item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_item_costing`
--

LOCK TABLES `inventory_item_costing` WRITE;
/*!40000 ALTER TABLE `inventory_item_costing` DISABLE KEYS */;
INSERT INTO `inventory_item_costing` VALUES (1,1,'wavg',0.0000,'USD','2026-04-20 18:14:55'),(1,2,'wavg',0.0000,'USD','2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_item_costing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_items`
--

DROP TABLE IF EXISTS `inventory_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `quantity` float DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `low_stock_threshold` float DEFAULT NULL,
  `qr_code` varchar(50) DEFAULT NULL,
  `item_code` varchar(50) DEFAULT NULL,
  `subcategory` varchar(50) DEFAULT NULL,
  `storage_conditions` json DEFAULT NULL,
  `quality_grade` varchar(20) DEFAULT NULL,
  `certifications` json DEFAULT NULL,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_inventory_items_qr_code` (`qr_code`),
  UNIQUE KEY `unique_tenant_item` (`tenant_id`,`item_code`),
  KEY `ix_inventory_items_tenant_id` (`tenant_id`),
  KEY `ix_inventory_items_name` (`name`),
  KEY `ix_inventory_items_id` (`id`),
  KEY `idx_inventory_tenant_category` (`tenant_id`,`category`),
  KEY `idx_inventory_category_location` (`category`,`location`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_items`
--

LOCK TABLES `inventory_items` WRITE;
/*!40000 ALTER TABLE `inventory_items` DISABLE KEYS */;
INSERT INTO `inventory_items` VALUES (1,'default','Maize Seed (SC727)','Seeds',250,'kg','Shed A',10,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'default','Compound D Fertilizer','Fertilizer',1000,'kg','Shed B',10,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'default','Diesel','Fuel',500,'liters','Fuel Tank',10,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'default','Cattle Dip','Chemicals',20,'liters','Chemical Store',10,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(5,'1','Test Animal Feed','Feed',1000,'kg','Main Storage',200,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `inventory_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_ledger`
--

DROP TABLE IF EXISTS `inventory_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_ledger` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int NOT NULL DEFAULT '0',
  `location_id` int NOT NULL DEFAULT '0',
  `item_id` int NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `serial_id` bigint NOT NULL DEFAULT '0',
  `entry_type` varchar(40) NOT NULL,
  `qty_delta` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `reference_type` varchar(40) DEFAULT NULL,
  `reference_id` varchar(80) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ledger_farm_date` (`farm_id`,`created_at`),
  KEY `idx_ledger_item` (`farm_id`,`item_id`,`created_at`),
  KEY `idx_ledger_ref` (`reference_type`,`reference_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_ledger`
--

LOCK TABLES `inventory_ledger` WRITE;
/*!40000 ALTER TABLE `inventory_ledger` DISABLE KEYS */;
INSERT INTO `inventory_ledger` VALUES (1,1,1,0,1,0,0,'receipt',10.000,5.0000,'USD','movement','1',NULL,6,'2026-04-20 18:14:55'),(2,1,1,0,1,0,0,'reserve',0.000,0.0000,'USD','reservation','1',NULL,6,'2026-04-20 18:15:00'),(3,1,1,0,2,1,0,'receipt',3.000,7.5000,'USD','receipt','1',NULL,6,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_locations`
--

DROP TABLE IF EXISTS `inventory_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `code` varchar(60) NOT NULL,
  `name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_location` (`warehouse_id`,`code`),
  KEY `idx_locations_farm_wh` (`farm_id`,`warehouse_id`,`is_active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_locations`
--

LOCK TABLES `inventory_locations` WRITE;
/*!40000 ALTER TABLE `inventory_locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_lots`
--

DROP TABLE IF EXISTS `inventory_lots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_lots` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `lot_number` varchar(80) NOT NULL,
  `expiry_date` date DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `supplier` varchar(180) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_lot` (`farm_id`,`item_id`,`lot_number`),
  KEY `idx_lots_item_expiry` (`farm_id`,`item_id`,`expiry_date`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_lots`
--

LOCK TABLES `inventory_lots` WRITE;
/*!40000 ALTER TABLE `inventory_lots` DISABLE KEYS */;
INSERT INTO `inventory_lots` VALUES (1,1,2,'LOT-T1','2026-05-10','2026-04-20 20:16:09','Test Supplier',NULL,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_lots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_movements`
--

DROP TABLE IF EXISTS `inventory_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_movements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int DEFAULT NULL,
  `item_id` int NOT NULL,
  `movement_type` varchar(20) NOT NULL,
  `quantity` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `reference_no` varchar(80) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movements_farm_date` (`farm_id`,`created_at`),
  KEY `idx_movements_item` (`item_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_movements`
--

LOCK TABLES `inventory_movements` WRITE;
/*!40000 ALTER TABLE `inventory_movements` DISABLE KEYS */;
INSERT INTO `inventory_movements` VALUES (1,1,1,1,'in',10.000,5.0000,NULL,NULL,6,'2026-04-20 18:14:55');
/*!40000 ALTER TABLE `inventory_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_receipt_lines`
--

DROP TABLE IF EXISTS `inventory_receipt_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_receipt_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `receipt_id` bigint NOT NULL,
  `item_id` int NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `lot_number` varchar(80) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `qty_received` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_receipt_lines` (`receipt_id`,`item_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_receipt_lines`
--

LOCK TABLES `inventory_receipt_lines` WRITE;
/*!40000 ALTER TABLE `inventory_receipt_lines` DISABLE KEYS */;
INSERT INTO `inventory_receipt_lines` VALUES (1,1,2,1,'LOT-T1','2026-05-10',3.000,7.5000,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_receipt_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_receipts`
--

DROP TABLE IF EXISTS `inventory_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_receipts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `po_id` bigint NOT NULL DEFAULT '0',
  `warehouse_id` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'received',
  `received_at` datetime NOT NULL,
  `reference_no` varchar(80) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_receipts` (`farm_id`,`warehouse_id`,`received_at`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_receipts`
--

LOCK TABLES `inventory_receipts` WRITE;
/*!40000 ALTER TABLE `inventory_receipts` DISABLE KEYS */;
INSERT INTO `inventory_receipts` VALUES (1,1,1,1,'received','2026-04-20 20:16:09',NULL,6,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_reservations`
--

DROP TABLE IF EXISTS `inventory_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_reservations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `item_id` int NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `serial_id` bigint NOT NULL DEFAULT '0',
  `qty` decimal(14,3) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'open',
  `reference_type` varchar(40) DEFAULT NULL,
  `reference_id` varchar(80) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_res_farm_status` (`farm_id`,`status`,`created_at`),
  KEY `idx_res_item` (`farm_id`,`item_id`,`status`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_reservations`
--

LOCK TABLES `inventory_reservations` WRITE;
/*!40000 ALTER TABLE `inventory_reservations` DISABLE KEYS */;
INSERT INTO `inventory_reservations` VALUES (1,1,1,0,1,0,0,2.000,'open',NULL,NULL,NULL,6,'2026-04-20 18:15:00',NULL);
/*!40000 ALTER TABLE `inventory_reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_serials`
--

DROP TABLE IF EXISTS `inventory_serials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_serials` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `serial_number` varchar(120) NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `warehouse_id` int NOT NULL DEFAULT '0',
  `location_id` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'in_stock',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_serial` (`farm_id`,`serial_number`),
  KEY `idx_serials_item_status` (`farm_id`,`item_id`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_serials`
--

LOCK TABLES `inventory_serials` WRITE;
/*!40000 ALTER TABLE `inventory_serials` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_serials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_stock_levels`
--

DROP TABLE IF EXISTS `inventory_stock_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_stock_levels` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `item_id` int NOT NULL,
  `qty_on_hand` decimal(14,3) NOT NULL DEFAULT '0.000',
  `qty_reserved` decimal(14,3) NOT NULL DEFAULT '0.000',
  `reorder_point` decimal(14,3) NOT NULL DEFAULT '0.000',
  `reorder_qty` decimal(14,3) NOT NULL DEFAULT '0.000',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_stock_level` (`warehouse_id`,`item_id`),
  KEY `idx_stock_farm_item` (`farm_id`,`item_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_stock_levels`
--

LOCK TABLES `inventory_stock_levels` WRITE;
/*!40000 ALTER TABLE `inventory_stock_levels` DISABLE KEYS */;
INSERT INTO `inventory_stock_levels` VALUES (1,1,1,1,10.000,2.000,0.000,0.000,'2026-04-20 18:15:00'),(2,1,1,2,3.000,0.000,0.000,0.000,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_stock_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_stock_positions`
--

DROP TABLE IF EXISTS `inventory_stock_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_stock_positions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `item_id` int NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `serial_id` bigint NOT NULL DEFAULT '0',
  `qty_on_hand` decimal(14,3) NOT NULL DEFAULT '0.000',
  `qty_reserved` decimal(14,3) NOT NULL DEFAULT '0.000',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_pos` (`farm_id`,`warehouse_id`,`location_id`,`item_id`,`lot_id`,`serial_id`),
  KEY `idx_pos_item` (`farm_id`,`item_id`),
  KEY `idx_pos_wh` (`farm_id`,`warehouse_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_stock_positions`
--

LOCK TABLES `inventory_stock_positions` WRITE;
/*!40000 ALTER TABLE `inventory_stock_positions` DISABLE KEYS */;
INSERT INTO `inventory_stock_positions` VALUES (1,1,1,0,1,0,0,10.000,2.000,'2026-04-20 18:15:00'),(2,1,1,0,2,1,0,3.000,0.000,'2026-04-20 18:16:09');
/*!40000 ALTER TABLE `inventory_stock_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_stocktake_lines`
--

DROP TABLE IF EXISTS `inventory_stocktake_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_stocktake_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stocktake_id` bigint NOT NULL,
  `item_id` int NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `system_qty` decimal(14,3) NOT NULL DEFAULT '0.000',
  `counted_qty` decimal(14,3) DEFAULT NULL,
  `variance_qty` decimal(14,3) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_stocktake_lines` (`stocktake_id`,`item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_stocktake_lines`
--

LOCK TABLES `inventory_stocktake_lines` WRITE;
/*!40000 ALTER TABLE `inventory_stocktake_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_stocktake_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_stocktakes`
--

DROP TABLE IF EXISTS `inventory_stocktakes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_stocktakes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'open',
  `started_at` datetime NOT NULL,
  `posted_at` datetime DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_stocktakes` (`farm_id`,`warehouse_id`,`status`,`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_stocktakes`
--

LOCK TABLES `inventory_stocktakes` WRITE;
/*!40000 ALTER TABLE `inventory_stocktakes` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_stocktakes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `transaction_type` enum('in','out','adjustment') NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `total_cost` decimal(10,2) DEFAULT NULL,
  `reason` varchar(100) DEFAULT NULL,
  `reference_id` varchar(50) DEFAULT NULL,
  `performed_by` int DEFAULT NULL,
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` varchar(50) DEFAULT 'default',
  `type` varchar(20) DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `performed_by` (`performed_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transfer_headers`
--

DROP TABLE IF EXISTS `inventory_transfer_headers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transfer_headers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `from_warehouse_id` int NOT NULL,
  `to_warehouse_id` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'draft',
  `reference_no` varchar(80) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `shipped_at` datetime DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transfer_hdr` (`farm_id`,`status`,`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transfer_headers`
--

LOCK TABLES `inventory_transfer_headers` WRITE;
/*!40000 ALTER TABLE `inventory_transfer_headers` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_transfer_headers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transfer_lines`
--

DROP TABLE IF EXISTS `inventory_transfer_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transfer_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transfer_id` bigint NOT NULL,
  `item_id` int NOT NULL,
  `lot_id` bigint NOT NULL DEFAULT '0',
  `qty` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transfer_lines` (`transfer_id`,`item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transfer_lines`
--

LOCK TABLES `inventory_transfer_lines` WRITE;
/*!40000 ALTER TABLE `inventory_transfer_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_transfer_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transfers`
--

DROP TABLE IF EXISTS `inventory_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transfers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `item_id` int NOT NULL,
  `from_warehouse_id` int NOT NULL,
  `to_warehouse_id` int NOT NULL,
  `quantity` decimal(14,3) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'completed',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transfers_farm_date` (`farm_id`,`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transfers`
--

LOCK TABLES `inventory_transfers` WRITE;
/*!40000 ALTER TABLE `inventory_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_warehouses`
--

DROP TABLE IF EXISTS `inventory_warehouses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_warehouses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `name` varchar(150) NOT NULL,
  `location` varchar(180) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_wh_farm_active` (`farm_id`,`is_active`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_warehouses`
--

LOCK TABLES `inventory_warehouses` WRITE;
/*!40000 ALTER TABLE `inventory_warehouses` DISABLE KEYS */;
INSERT INTO `inventory_warehouses` VALUES (1,1,'Main Warehouse',NULL,1,'2026-04-20 18:13:56');
/*!40000 ALTER TABLE `inventory_warehouses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `invoice_number` varchar(50) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `due_date` varchar(20) DEFAULT NULL,
  `items` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `ix_invoices_tenant_id` (`tenant_id`),
  KEY `ix_invoices_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iot_alerts`
--

DROP TABLE IF EXISTS `iot_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iot_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `device_id` int NOT NULL,
  `alert_type` varchar(50) NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `message` text NOT NULL,
  `sensor_value` decimal(10,2) DEFAULT NULL,
  `threshold_value` decimal(10,2) DEFAULT NULL,
  `status` enum('active','acknowledged','resolved') DEFAULT 'active',
  `acknowledged_by` int DEFAULT NULL,
  `acknowledged_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `device_id` (`device_id`),
  KEY `acknowledged_by` (`acknowledged_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iot_alerts`
--

LOCK TABLES `iot_alerts` WRITE;
/*!40000 ALTER TABLE `iot_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `iot_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iot_devices`
--

DROP TABLE IF EXISTS `iot_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iot_devices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `device_id` varchar(100) NOT NULL,
  `device_name` varchar(100) NOT NULL,
  `device_type` varchar(50) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive','maintenance','offline') DEFAULT 'active',
  `last_seen` timestamp NULL DEFAULT NULL,
  `battery_level` decimal(5,2) DEFAULT NULL,
  `firmware_version` varchar(20) DEFAULT NULL,
  `configuration` json DEFAULT NULL,
  `registered_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_id` (`device_id`),
  KEY `registered_by` (`registered_by`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iot_devices`
--

LOCK TABLES `iot_devices` WRITE;
/*!40000 ALTER TABLE `iot_devices` DISABLE KEYS */;
INSERT INTO `iot_devices` VALUES (1,'temp-sensor-001','Main Barn Temperature Sensor','temperature','Main Barn - Section A','active',NULL,NULL,'1.2.3','{\"update_interval\": 300, \"calibration_offset\": 0.5}',1,'2026-01-11 17:34:12','2026-01-11 17:34:12'),(2,'humidity-sensor-001','Main Barn Humidity Sensor','humidity','Main Barn - Section A','active',NULL,NULL,'1.1.0','{\"sensor_range\": \"0-100%\", \"update_interval\": 300}',1,'2026-01-11 17:34:12','2026-01-11 17:34:12'),(3,'ph-sensor-001','Fish Pond pH Sensor','ph','Fish Pond 1','active',NULL,NULL,'2.0.1','{\"update_interval\": 600, \"calibration_date\": \"2024-01-15\"}',1,'2026-01-11 17:34:12','2026-01-11 17:34:12'),(4,'water-level-001','Feed Water Tank Level Sensor','water_level','Feed Storage Area','active',NULL,NULL,'1.3.2','{\"tank_capacity\": 5000, \"alert_threshold\": 20}',1,'2026-01-11 17:34:12','2026-01-11 17:34:12'),(5,'ammonia-sensor-001','Barn Air Quality Sensor','ammonia','Main Barn - Ventilation Area','active',NULL,NULL,'1.0.5','{\"alarm_threshold\": 25, \"update_interval\": 900}',1,'2026-01-11 17:34:12','2026-01-11 17:34:12'),(6,'102','Fimy','water_level','kij','active',NULL,NULL,'011','{}',2,'2026-01-12 20:00:13','2026-01-12 20:00:13');
/*!40000 ALTER TABLE `iot_devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `irrigation_events`
--

DROP TABLE IF EXISTS `irrigation_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `irrigation_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `zone_id` int DEFAULT NULL,
  `scheduled_time` datetime DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `zone_id` (`zone_id`),
  KEY `ix_irrigation_events_id` (`id`),
  KEY `ix_irrigation_events_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `irrigation_events`
--

LOCK TABLES `irrigation_events` WRITE;
/*!40000 ALTER TABLE `irrigation_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `irrigation_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `irrigation_schedules`
--

DROP TABLE IF EXISTS `irrigation_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `irrigation_schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `zone_id` varchar(50) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `duration_minutes` int NOT NULL,
  `water_volume` decimal(10,2) DEFAULT NULL,
  `status` enum('scheduled','running','completed','cancelled','failed') DEFAULT 'scheduled',
  `method` varchar(50) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `created_by` (`created_by`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `irrigation_schedules`
--

LOCK TABLES `irrigation_schedules` WRITE;
/*!40000 ALTER TABLE `irrigation_schedules` DISABLE KEYS */;
INSERT INTO `irrigation_schedules` VALUES (1,5,NULL,'2026-01-13 18:45:18',120,5000.00,'scheduled','drip',4,'2026-01-12 16:45:17'),(2,5,NULL,'2026-01-13 21:25:34',120,5000.00,'scheduled','drip',4,'2026-01-12 19:25:34'),(3,5,NULL,'2026-01-13 21:28:12',120,5000.00,'scheduled','drip',4,'2026-01-12 19:28:12');
/*!40000 ALTER TABLE `irrigation_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `irrigation_zones`
--

DROP TABLE IF EXISTS `irrigation_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `irrigation_zones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `field_id` int DEFAULT NULL,
  `moisture_threshold` float DEFAULT NULL,
  `current_moisture` float DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `ix_irrigation_zones_id` (`id`),
  KEY `ix_irrigation_zones_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `irrigation_zones`
--

LOCK TABLES `irrigation_zones` WRITE;
/*!40000 ALTER TABLE `irrigation_zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `irrigation_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jwt_blacklist`
--

DROP TABLE IF EXISTS `jwt_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jwt_blacklist` (
  `jti` varchar(64) NOT NULL,
  `user_id` int NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`jti`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jwt_blacklist`
--

LOCK TABLES `jwt_blacklist` WRITE;
/*!40000 ALTER TABLE `jwt_blacklist` DISABLE KEYS */;
/*!40000 ALTER TABLE `jwt_blacklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listings`
--

DROP TABLE IF EXISTS `listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `listings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `seller_id` int DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `description` text,
  `category` varchar(50) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `quantity` float DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_id` (`seller_id`),
  KEY `ix_listings_tenant_id` (`tenant_id`),
  KEY `ix_listings_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listings`
--

LOCK TABLES `listings` WRITE;
/*!40000 ALTER TABLE `listings` DISABLE KEYS */;
INSERT INTO `listings` VALUES (1,'default',6,'Test Crop','Test Description','Crops',100,'kg',490,'Barn 1','active','2026-01-12T20:46:09.321373'),(2,'default',6,'Test Crop','Test Description','Crops',100,'kg',490,'Barn 1','active','2026-01-12T20:48:57.379166');
/*!40000 ALTER TABLE `listings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livestock`
--

DROP TABLE IF EXISTS `livestock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livestock` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tag_number` varchar(50) NOT NULL,
  `species` varchar(50) NOT NULL,
  `breed` varchar(50) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `status` varchar(20) DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tag_number` (`tag_number`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livestock`
--

LOCK TABLES `livestock` WRITE;
/*!40000 ALTER TABLE `livestock` DISABLE KEYS */;
/*!40000 ALTER TABLE `livestock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livestock_batches`
--

DROP TABLE IF EXISTS `livestock_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livestock_batches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `count` int DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `breed` varchar(50) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `notes` text,
  `batch_code` varchar(50) DEFAULT NULL,
  `genetic_line` varchar(50) DEFAULT NULL,
  `performance_metrics` json DEFAULT NULL,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tenant_batch` (`tenant_id`,`batch_code`),
  KEY `ix_livestock_batches_tenant_id` (`tenant_id`),
  KEY `ix_livestock_batches_type` (`type`),
  KEY `ix_livestock_batches_id` (`id`),
  KEY `idx_livestock_tenant_active` (`tenant_id`,`status`),
  KEY `idx_livestock_batch_location` (`location`,`status`),
  CONSTRAINT `check_count_positive` CHECK ((`count` >= 0)),
  CONSTRAINT `check_quantity_positive` CHECK ((`quantity` >= 0))
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livestock_batches`
--

LOCK TABLES `livestock_batches` WRITE;
/*!40000 ALTER TABLE `livestock_batches` DISABLE KEYS */;
INSERT INTO `livestock_batches` VALUES (1,'1','Cattle','Batch TEST-BATCH-001',NULL,25,'HEALTHY','2024-02-13 00:00:00','Mixed','Main Farm','Test batch for validation','TEST-BATCH-001',NULL,NULL,NULL),(2,'1','Poultry','Batch Broiler 001',NULL,1000,'HEALTHY','2026-02-13 00:00:00','White Chicken','Main Farm','New broiler batch for testing','Broiler 001',NULL,NULL,NULL),(3,'1','Poultry','Batch Broiler 002',NULL,1000,'HEALTHY','2026-02-03 00:00:00','White Chicken','Main Farm','Test with entry_date field','Broiler 002',NULL,NULL,NULL),(4,'1','Poultry','Batch Broiler-1770978788',NULL,1000,'HEALTHY','2026-02-03 00:00:00','White Chicken','Main Farm','New broiler batch for testing','Broiler-1770978788',NULL,NULL,NULL);
/*!40000 ALTER TABLE `livestock_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livestock_events`
--

DROP TABLE IF EXISTS `livestock_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livestock_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int DEFAULT NULL,
  `tenant_id` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `details` text,
  `performed_by` varchar(100) DEFAULT NULL,
  `cost` float DEFAULT NULL,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `ix_livestock_events_tenant_id` (`tenant_id`),
  KEY `ix_livestock_events_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livestock_events`
--

LOCK TABLES `livestock_events` WRITE;
/*!40000 ALTER TABLE `livestock_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `livestock_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livestock_growth`
--

DROP TABLE IF EXISTS `livestock_growth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livestock_growth` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int NOT NULL,
  `record_date` date NOT NULL,
  `average_weight` decimal(10,2) DEFAULT NULL,
  `average_height` decimal(10,2) DEFAULT NULL,
  `notes` text,
  `recorded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `recorded_by` (`recorded_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livestock_growth`
--

LOCK TABLES `livestock_growth` WRITE;
/*!40000 ALTER TABLE `livestock_growth` DISABLE KEYS */;
/*!40000 ALTER TABLE `livestock_growth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `load_tests`
--

DROP TABLE IF EXISTS `load_tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `load_tests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `test_id` varchar(100) NOT NULL,
  `test_name` varchar(200) NOT NULL,
  `test_type` enum('load_test','stress_test','spike_test','endurance_test','volume_test') NOT NULL,
  `target_url` varchar(500) NOT NULL,
  `method` varchar(10) DEFAULT 'GET',
  `concurrent_users` int DEFAULT '10',
  `duration_seconds` int DEFAULT '60',
  `ramp_up_seconds` int DEFAULT '30',
  `think_time_ms` int DEFAULT '1000',
  `status` enum('pending','running','completed','failed','cancelled') DEFAULT 'pending',
  `total_requests` int DEFAULT '0',
  `successful_requests` int DEFAULT '0',
  `failed_requests` int DEFAULT '0',
  `average_response_time` float DEFAULT '0',
  `p95_response_time` float DEFAULT '0',
  `throughput` float DEFAULT '0',
  `error_rate` float DEFAULT '0',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `test_id` (`test_id`),
  KEY `idx_test_id` (`test_id`),
  KEY `idx_test_type` (`test_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `load_tests`
--

LOCK TABLES `load_tests` WRITE;
/*!40000 ALTER TABLE `load_tests` DISABLE KEYS */;
/*!40000 ALTER TABLE `load_tests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_logs`
--

DROP TABLE IF EXISTS `maintenance_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `equipment_id` int NOT NULL,
  `maintenance_date` date NOT NULL,
  `description` text NOT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `performed_by` varchar(100) DEFAULT NULL,
  `next_maintenance_due` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` varchar(50) DEFAULT 'default',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `vibration` float DEFAULT NULL,
  `temperature` float DEFAULT NULL,
  `current_draw` float DEFAULT NULL,
  `risk_score` float DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `equipment_id` (`equipment_id`)
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
-- Table structure for table `maintenance_predictions`
--

DROP TABLE IF EXISTS `maintenance_predictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_predictions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `equipment_id` int NOT NULL,
  `prediction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `failure_probability` float DEFAULT '0',
  `predicted_failure_date` datetime DEFAULT NULL,
  `maintenance_type` varchar(100) DEFAULT NULL,
  `priority` enum('low','medium','high','critical') DEFAULT 'medium',
  `confidence_score` float DEFAULT '0',
  `model_version` varchar(50) DEFAULT NULL,
  `features_json` json DEFAULT NULL,
  `status` enum('pending','scheduled','completed','false_positive') DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_equipment_id` (`equipment_id`),
  KEY `idx_predicted_date` (`predicted_failure_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_predictions`
--

LOCK TABLES `maintenance_predictions` WRITE;
/*!40000 ALTER TABLE `maintenance_predictions` DISABLE KEYS */;
/*!40000 ALTER TABLE `maintenance_predictions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfa_setups`
--

DROP TABLE IF EXISTS `mfa_setups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfa_setups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `mfa_type` enum('totp','sms','email') DEFAULT 'totp',
  `secret_key` varchar(255) DEFAULT NULL,
  `is_enabled` tinyint(1) DEFAULT '0',
  `backup_codes` json DEFAULT NULL,
  `setup_initiated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `verified_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_enabled` (`is_enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfa_setups`
--

LOCK TABLES `mfa_setups` WRITE;
/*!40000 ALTER TABLE `mfa_setups` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfa_setups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `type` enum('info','warning','success','error','email','sms') NOT NULL DEFAULT 'info',
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `listing_id` int DEFAULT NULL,
  `buyer_id` int DEFAULT NULL,
  `quantity` float DEFAULT NULL,
  `total_price` float DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `listing_id` (`listing_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `ix_orders_tenant_id` (`tenant_id`),
  KEY `ix_orders_id` (`id`),
  KEY `idx_orders_date_status` (`created_at`,`status`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'default',1,6,10,1000,'pending','2026-01-12T20:46:09.425133'),(2,'default',2,6,10,1000,'pending','2026-01-12T20:48:57.418660');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `email` varchar(100) NOT NULL,
  `token` varchar(190) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  KEY `email` (`email`),
  KEY `token` (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performance_metrics`
--

DROP TABLE IF EXISTS `performance_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `performance_metrics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `metric_type` varchar(50) DEFAULT NULL,
  `reference_id` int DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `metric_date` date DEFAULT NULL,
  `metrics` text,
  `calculated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_performance_tenant` (`tenant_id`),
  KEY `idx_performance_type` (`metric_type`),
  KEY `idx_performance_date` (`metric_date`),
  KEY `idx_performance_metrics_tenant_type` (`tenant_id`,`metric_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performance_metrics`
--

LOCK TABLES `performance_metrics` WRITE;
/*!40000 ALTER TABLE `performance_metrics` DISABLE KEYS */;
/*!40000 ALTER TABLE `performance_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_tracking`
--

DROP TABLE IF EXISTS `product_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_tracking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tracking_id` varchar(50) NOT NULL,
  `product_id` varchar(50) NOT NULL,
  `product_name` varchar(200) DEFAULT NULL,
  `product_type` varchar(100) DEFAULT NULL,
  `batch_number` varchar(100) DEFAULT NULL,
  `origin_node_id` varchar(50) DEFAULT NULL,
  `current_node_id` varchar(50) DEFAULT NULL,
  `tracking_status` enum('in_transit','delivered','lost') DEFAULT 'in_transit',
  `quality_grade` varchar(50) DEFAULT 'standard',
  `certifications` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tracking_id` (`tracking_id`),
  KEY `idx_tracking_id` (`tracking_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_tracking`
--

LOCK TABLES `product_tracking` WRITE;
/*!40000 ALTER TABLE `product_tracking` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_tracking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_order_lines`
--

DROP TABLE IF EXISTS `purchase_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `po_id` bigint NOT NULL,
  `item_id` int NOT NULL,
  `qty_ordered` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `qty_received` decimal(14,3) NOT NULL DEFAULT '0.000',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_po_lines` (`po_id`,`item_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_order_lines`
--

LOCK TABLES `purchase_order_lines` WRITE;
/*!40000 ALTER TABLE `purchase_order_lines` DISABLE KEYS */;
INSERT INTO `purchase_order_lines` VALUES (1,1,2,3.000,7.5000,3.000,'2026-04-20 18:16:01');
/*!40000 ALTER TABLE `purchase_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `farm_id` int NOT NULL,
  `supplier` varchar(180) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'draft',
  `order_date` date DEFAULT NULL,
  `expected_date` date DEFAULT NULL,
  `reference_no` varchar(80) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_po_farm_status` (`farm_id`,`status`,`created_at`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (1,1,'Test Supplier','approved','2026-04-20',NULL,NULL,NULL,6,'2026-04-20 18:16:01','2026-04-20 18:16:05');
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_codes_enhanced`
--

DROP TABLE IF EXISTS `qr_codes_enhanced`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qr_codes_enhanced` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `qr_code` varchar(255) NOT NULL,
  `reference_id` int DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `product_info` text,
  `supply_chain_data` text,
  `generated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `qr_code` (`qr_code`),
  UNIQUE KEY `unique_qr_code` (`qr_code`),
  KEY `idx_qr_tenant` (`tenant_id`),
  KEY `idx_qr_reference` (`reference_id`,`reference_type`),
  KEY `idx_qr_code` (`qr_code`),
  KEY `idx_qr_codes_tenant_active` (`tenant_id`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_codes_enhanced`
--

LOCK TABLES `qr_codes_enhanced` WRITE;
/*!40000 ALTER TABLE `qr_codes_enhanced` DISABLE KEYS */;
/*!40000 ALTER TABLE `qr_codes_enhanced` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quality_checks`
--

DROP TABLE IF EXISTS `quality_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quality_checks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `check_type` varchar(50) DEFAULT NULL,
  `reference_id` int DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `check_date` date DEFAULT NULL,
  `result` varchar(20) DEFAULT NULL,
  `parameters` text,
  `performed_by` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_quality_tenant` (`tenant_id`),
  KEY `idx_quality_date` (`check_date`),
  KEY `idx_quality_type` (`check_type`),
  KEY `idx_quality_checks_tenant_type` (`tenant_id`,`check_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quality_checks`
--

LOCK TABLES `quality_checks` WRITE;
/*!40000 ALTER TABLE `quality_checks` DISABLE KEYS */;
/*!40000 ALTER TABLE `quality_checks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate_limit_counters`
--

DROP TABLE IF EXISTS `rate_limit_counters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rate_limit_counters` (
  `identifier` varchar(128) NOT NULL,
  `limit_name` varchar(20) NOT NULL,
  `bucket` int NOT NULL,
  `count` int NOT NULL,
  `expires_at` int NOT NULL,
  PRIMARY KEY (`identifier`,`limit_name`,`bucket`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate_limit_counters`
--

LOCK TABLES `rate_limit_counters` WRITE;
/*!40000 ALTER TABLE `rate_limit_counters` DISABLE KEYS */;
INSERT INTO `rate_limit_counters` VALUES ('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776004080','auth',1776004080,1,1776004140),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776004140','auth',1776004140,1,1776004200),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776004740','auth',1776004740,1,1776004800),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776012360','auth',1776012360,1,1776012420),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776707400','auth',1776707400,1,1776707460),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776707640','auth',1776707640,1,1776707700),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708240','auth',1776708240,1,1776708300),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708480','auth',1776708480,1,1776708540),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708540','auth',1776708540,1,1776708600),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708720','auth',1776708720,1,1776708780),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708780','auth',1776708780,1,1776708840),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708840','auth',1776708840,1,1776708900),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776708900','auth',1776708900,1,1776708960),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776713700','auth',1776713700,1,1776713760),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776714840','auth',1776714840,1,1776714900),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776715020','auth',1776715020,1,1776715080),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776715080','auth',1776715080,1,1776715140),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776715260','auth',1776715260,1,1776715320),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776715380','auth',1776715380,1,1776715440),('eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3:auth:1776715500','auth',1776715500,1,1776715560);
/*!40000 ALTER TABLE `rate_limit_counters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate_limits`
--

DROP TABLE IF EXISTS `rate_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rate_limits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_identifier` varchar(255) NOT NULL,
  `endpoint` varchar(255) NOT NULL,
  `request_count` int DEFAULT '0',
  `window_start` datetime DEFAULT CURRENT_TIMESTAMP,
  `window_seconds` int DEFAULT '60',
  `limit_per_window` int DEFAULT '100',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_client_endpoint` (`client_identifier`,`endpoint`),
  KEY `idx_window_start` (`window_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate_limits`
--

LOCK TABLES `rate_limits` WRITE;
/*!40000 ALTER TABLE `rate_limits` DISABLE KEYS */;
/*!40000 ALTER TABLE `rate_limits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_hash` varchar(128) NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`)
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (1,6,'2124af379d09fba767301156c9cae0031ee1a7743b9bce603610580dfa72525a','2026-05-12 16:29:31',NULL,'2026-04-12 16:29:31'),(2,2,'f1a448afe01880d1233b82f941be4ecfb54222c72ae9c32e5b719b7920200638','2026-05-12 16:39:16','2026-04-12 18:46:06','2026-04-12 16:39:16'),(3,2,'306a1a55f5853744688e9947c588ede4fb52a869e54b1651c2db4dc6d4be557b','2026-05-12 18:46:06',NULL,'2026-04-12 18:46:06'),(4,6,'93308305ef21f813dfb2ac727c7d25e5c5a414f7ad9c2639adb8c3ae7b19ace2','2026-05-20 19:50:33',NULL,'2026-04-20 19:50:33'),(5,6,'6992d117f119bcdb55844c6f09b9b536153ea39f00f5460ea368e34eef1d2ded','2026-05-20 19:54:09',NULL,'2026-04-20 19:54:09'),(6,6,'d1f2b0a2eaa5ea9196c967f23c9d41b692e59d0acb39a12ffb77c9f645436175','2026-05-20 20:04:44',NULL,'2026-04-20 20:04:44'),(7,6,'29aef7edd268de69142e08a3fc80e5f1afb730bc1949d551370e7fcf703f8aa6','2026-05-20 20:08:44',NULL,'2026-04-20 20:08:44'),(8,6,'6792b4efb86bd53691c3f5c8996cc04ef48dfc9e43333d75ada9c5e88c27cd3c','2026-05-20 20:09:16',NULL,'2026-04-20 20:09:16'),(9,6,'8117e420dc3e9e1e70424516a681f0f8acb46ba620aeca03920c87629c6c982b','2026-05-20 20:12:25',NULL,'2026-04-20 20:12:25'),(10,6,'072f09a30f9628dd4bc5978eefbf99e4abd256f246da6dec17908d225b43a48e','2026-05-20 20:13:51',NULL,'2026-04-20 20:13:51'),(11,6,'344401c2e59fc1ae02c22fed3073f30776522ee8b23fa3c21f6646019966144e','2026-05-20 20:14:51',NULL,'2026-04-20 20:14:51'),(12,6,'568901524c1f75f9750a44b8c66fa49cfda26ce178657e5bd8a10bbbde6fefad','2026-05-20 20:15:56',NULL,'2026-04-20 20:15:56'),(13,6,'892fad921f1deef979c68c95df6b282178217e5c54768b766085d12e92e23935','2026-05-20 21:35:38',NULL,'2026-04-20 21:35:38'),(14,6,'bec0bb7ecb5619c338b233bfd8568f1310c84dc6dabe07124993532dbec7c2ad','2026-05-20 21:54:12',NULL,'2026-04-20 21:54:12'),(15,6,'4089ac646eb8c111c2e8356bea9b7525f06ed4401f700ff2c7591393932f3ede','2026-05-20 21:57:01',NULL,'2026-04-20 21:57:01'),(16,6,'123c5f965bc9c96b0f10df927ed635fa90b5abf5ce61f473757ec2767a77453c','2026-05-20 21:58:38',NULL,'2026-04-20 21:58:38'),(17,6,'27e87e99f375e7d4b083d063b3dd78d2c2a86505126c5b1976bc41b9ab39a36e','2026-05-20 22:01:46',NULL,'2026-04-20 22:01:46'),(18,6,'db7fa5711211013de7f1fb0fb4f68f7803842bff6d187082eeff38703150db5a','2026-05-20 22:03:30',NULL,'2026-04-20 22:03:30'),(19,6,'095ee658b783c76ed8e9211d960162f7867a0cf736987e38c52d6b04ee82ec31','2026-05-20 22:05:11',NULL,'2026-04-20 22:05:11');
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(80) NOT NULL,
  `permission` varchar(120) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_role_permission` (`role_name`,`permission`),
  KEY `idx_role_permissions_role` (`role_name`)
) ENGINE=MyISAM AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,'super_admin','*','2026-04-20 20:04:49'),(2,'admin','users.view','2026-04-20 20:04:49'),(3,'admin','users.create','2026-04-20 20:04:49'),(4,'admin','users.update','2026-04-20 20:04:49'),(5,'admin','users.delete','2026-04-20 20:04:49'),(6,'admin','users.permissions.manage','2026-04-20 20:04:49'),(7,'admin','settings.read','2026-04-20 20:04:49'),(8,'admin','settings.update','2026-04-20 20:04:49'),(9,'admin','reports.read','2026-04-20 20:04:49'),(10,'admin','reports.generate','2026-04-20 20:04:49'),(11,'admin','analytics.read','2026-04-20 20:04:49'),(12,'admin','tasks.read','2026-04-20 20:04:49'),(13,'admin','tasks.create','2026-04-20 20:04:49'),(14,'admin','tasks.update','2026-04-20 20:04:49'),(15,'admin','tasks.complete','2026-04-20 20:04:49'),(16,'admin','inventory.read','2026-04-20 20:04:49'),(17,'admin','inventory.create','2026-04-20 20:04:49'),(18,'admin','inventory.update','2026-04-20 20:04:49'),(19,'admin','inventory.adjust','2026-04-20 20:04:49'),(20,'admin','inventory.transfer','2026-04-20 20:04:49'),(21,'admin','financial.read','2026-04-20 20:04:49'),(22,'admin','financial.create','2026-04-20 20:04:49'),(23,'admin','financial.update','2026-04-20 20:04:49'),(24,'admin','accounting.read','2026-04-20 20:04:49'),(25,'admin','accounting.post','2026-04-20 20:04:49'),(26,'admin','livestock.read','2026-04-20 20:04:49'),(27,'admin','livestock.create','2026-04-20 20:04:49'),(28,'admin','livestock.update','2026-04-20 20:04:49'),(29,'admin','livestock.platform','2026-04-20 20:04:49'),(30,'admin','iot.read','2026-04-20 20:04:49'),(31,'admin','iot.manage','2026-04-20 20:04:49'),(32,'admin','compliance.read','2026-04-20 20:04:49'),(33,'admin','compliance.manage','2026-04-20 20:04:49'),(34,'admin','marketplace.read','2026-04-20 20:04:49'),(35,'admin','marketplace.manage','2026-04-20 20:04:49'),(36,'admin','admin.access','2026-04-20 20:04:49'),(37,'manager','users.view','2026-04-20 20:04:49'),(38,'manager','reports.read','2026-04-20 20:04:49'),(39,'manager','reports.generate','2026-04-20 20:04:49'),(40,'manager','analytics.read','2026-04-20 20:04:49'),(41,'manager','tasks.read','2026-04-20 20:04:49'),(42,'manager','tasks.create','2026-04-20 20:04:49'),(43,'manager','tasks.update','2026-04-20 20:04:49'),(44,'manager','tasks.complete','2026-04-20 20:04:49'),(45,'manager','inventory.read','2026-04-20 20:04:49'),(46,'manager','inventory.create','2026-04-20 20:04:49'),(47,'manager','inventory.update','2026-04-20 20:04:49'),(48,'manager','inventory.adjust','2026-04-20 20:04:49'),(49,'manager','inventory.transfer','2026-04-20 20:04:49'),(50,'manager','financial.read','2026-04-20 20:04:49'),(51,'manager','financial.create','2026-04-20 20:04:49'),(52,'manager','financial.update','2026-04-20 20:04:49'),(53,'manager','accounting.read','2026-04-20 20:04:49'),(54,'manager','livestock.read','2026-04-20 20:04:49'),(55,'manager','livestock.create','2026-04-20 20:04:49'),(56,'manager','livestock.update','2026-04-20 20:04:49'),(57,'manager','livestock.platform','2026-04-20 20:04:49'),(58,'manager','iot.read','2026-04-20 20:04:49'),(59,'manager','compliance.read','2026-04-20 20:04:49'),(60,'manager','marketplace.read','2026-04-20 20:04:49'),(61,'finance_manager','financial.read','2026-04-20 20:04:49'),(62,'finance_manager','financial.create','2026-04-20 20:04:49'),(63,'finance_manager','financial.update','2026-04-20 20:04:49'),(64,'finance_manager','accounting.read','2026-04-20 20:04:49'),(65,'finance_manager','accounting.post','2026-04-20 20:04:49'),(66,'finance_manager','reports.read','2026-04-20 20:04:49'),(67,'finance_manager','reports.generate','2026-04-20 20:04:49'),(68,'finance_manager','analytics.read','2026-04-20 20:04:49'),(69,'inventory_manager','inventory.read','2026-04-20 20:04:49'),(70,'inventory_manager','inventory.create','2026-04-20 20:04:49'),(71,'inventory_manager','inventory.update','2026-04-20 20:04:49'),(72,'inventory_manager','inventory.adjust','2026-04-20 20:04:49'),(73,'inventory_manager','inventory.transfer','2026-04-20 20:04:49'),(74,'inventory_manager','reports.read','2026-04-20 20:04:49'),(75,'inventory_manager','analytics.read','2026-04-20 20:04:49'),(76,'livestock_manager','livestock.read','2026-04-20 20:04:49'),(77,'livestock_manager','livestock.create','2026-04-20 20:04:49'),(78,'livestock_manager','livestock.update','2026-04-20 20:04:49'),(79,'livestock_manager','livestock.platform','2026-04-20 20:04:49'),(80,'livestock_manager','reports.read','2026-04-20 20:04:49'),(81,'livestock_manager','analytics.read','2026-04-20 20:04:49'),(82,'auditor','users.view','2026-04-20 20:04:49'),(83,'auditor','settings.read','2026-04-20 20:04:49'),(84,'auditor','reports.read','2026-04-20 20:04:49'),(85,'auditor','analytics.read','2026-04-20 20:04:49'),(86,'auditor','inventory.read','2026-04-20 20:04:49'),(87,'auditor','financial.read','2026-04-20 20:04:49'),(88,'auditor','accounting.read','2026-04-20 20:04:49'),(89,'auditor','livestock.read','2026-04-20 20:04:49'),(90,'auditor','compliance.read','2026-04-20 20:04:49'),(91,'field_worker','tasks.read','2026-04-20 20:04:49'),(92,'field_worker','tasks.complete','2026-04-20 20:04:49'),(93,'field_worker','inventory.read','2026-04-20 20:04:49'),(94,'field_worker','livestock.read','2026-04-20 20:04:49'),(95,'field_worker','iot.read','2026-04-20 20:04:49'),(96,'worker','tasks.read','2026-04-20 20:04:49'),(97,'worker','tasks.complete','2026-04-20 20:04:49'),(98,'worker','inventory.read','2026-04-20 20:04:49'),(99,'worker','livestock.read','2026-04-20 20:04:49'),(100,'user','tasks.read','2026-04-20 20:04:49'),(101,'user','inventory.read','2026-04-20 20:04:49'),(102,'user','livestock.read','2026-04-20 20:04:49');
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
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin',NULL,1,'2026-04-20 20:04:49'),(2,'manager',NULL,1,'2026-04-20 20:04:49'),(3,'general_hand',NULL,1,'2026-04-20 20:04:49'),(4,'super_admin','Super admin role',1,'2026-04-20 20:04:49'),(5,'finance_manager','Finance manager role',1,'2026-04-20 20:04:49'),(6,'inventory_manager','Inventory manager role',1,'2026-04-20 20:04:49'),(7,'livestock_manager','Livestock manager role',1,'2026-04-20 20:04:49'),(8,'auditor','Auditor role',1,'2026-04-20 20:04:49'),(9,'field_worker','Field worker role',1,'2026-04-20 20:04:49'),(10,'worker','Worker role',1,'2026-04-20 20:04:49'),(11,'user','User role',1,'2026-04-20 20:04:49');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rotation_plans`
--

DROP TABLE IF EXISTS `rotation_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rotation_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `field_id` int DEFAULT NULL,
  `year` int DEFAULT NULL,
  `season` varchar(20) DEFAULT NULL,
  `planned_crop` varchar(50) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `ix_rotation_plans_id` (`id`),
  KEY `ix_rotation_plans_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rotation_plans`
--

LOCK TABLES `rotation_plans` WRITE;
/*!40000 ALTER TABLE `rotation_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `rotation_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `start_time` varchar(20) DEFAULT NULL,
  `end_time` varchar(20) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_schedules_tenant_id` (`tenant_id`),
  KEY `ix_schedules_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scouting_logs`
--

DROP TABLE IF EXISTS `scouting_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scouting_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `field_id` int DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `observer` varchar(100) DEFAULT NULL,
  `pest_disease_name` varchar(100) DEFAULT NULL,
  `severity` varchar(20) DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `notes` text,
  `location_lat` float DEFAULT NULL,
  `location_lng` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `ix_scouting_logs_tenant_id` (`tenant_id`),
  KEY `ix_scouting_logs_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scouting_logs`
--

LOCK TABLES `scouting_logs` WRITE;
/*!40000 ALTER TABLE `scouting_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `scouting_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scouting_reports`
--

DROP TABLE IF EXISTS `scouting_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scouting_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `scout_date` date NOT NULL,
  `growth_stage` varchar(50) DEFAULT NULL,
  `pest_severity` enum('none','low','medium','high','critical') DEFAULT 'none',
  `disease_severity` enum('none','low','medium','high','critical') DEFAULT 'none',
  `weed_severity` enum('none','low','medium','high','critical') DEFAULT 'none',
  `notes` text,
  `images` json DEFAULT NULL,
  `scouted_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `scouted_by` (`scouted_by`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scouting_reports`
--

LOCK TABLES `scouting_reports` WRITE;
/*!40000 ALTER TABLE `scouting_reports` DISABLE KEYS */;
INSERT INTO `scouting_reports` VALUES (1,4,'2026-01-12','Vegetative','low','none','none','Looking good',NULL,5,'2026-01-12 16:45:17'),(2,4,'2026-01-12','Vegetative','low','none','none','Looking good',NULL,5,'2026-01-12 19:25:34'),(3,4,'2026-01-12','Vegetative','low','none','none','Looking good',NULL,5,'2026-01-12 19:28:11');
/*!40000 ALTER TABLE `scouting_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_events`
--

DROP TABLE IF EXISTS `security_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `event_type` varchar(100) NOT NULL,
  `details` json DEFAULT NULL,
  `severity` enum('info','low','medium','high','critical') DEFAULT 'info',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_events`
--

LOCK TABLES `security_events` WRITE;
/*!40000 ALTER TABLE `security_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `security_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sensor_data`
--

DROP TABLE IF EXISTS `sensor_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor_data` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sensor_type` varchar(50) NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `unit` varchar(10) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` varchar(50) DEFAULT 'default',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensor_data`
--

LOCK TABLES `sensor_data` WRITE;
/*!40000 ALTER TABLE `sensor_data` DISABLE KEYS */;
INSERT INTO `sensor_data` VALUES (1,'temperature',28.50,'┬░C','Main Barn - Section A','2026-01-11 17:34:12','default'),(2,'humidity',65.20,'%','Main Barn - Section A','2026-01-11 17:34:12','default'),(3,'ph',7.20,'pH','Fish Pond 1','2026-01-11 17:34:12','default'),(4,'water_level',85.00,'%','Feed Storage Area','2026-01-11 17:34:12','default'),(5,'ammonia',12.30,'ppm','Main Barn - Ventilation Area','2026-01-11 17:34:12','default');
/*!40000 ALTER TABLE `sensor_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sensor_data_partitioned`
--

DROP TABLE IF EXISTS `sensor_data_partitioned`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor_data_partitioned` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) NOT NULL DEFAULT 'default',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sensor_type` varchar(50) NOT NULL,
  `value` decimal(10,3) NOT NULL,
  `unit` varchar(50) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `device_id` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'ok',
  `threshold_min` decimal(10,3) DEFAULT NULL,
  `threshold_max` decimal(10,3) DEFAULT NULL,
  `automation_triggered` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sensor_tenant` (`tenant_id`),
  KEY `idx_sensor_device_timestamp` (`device_id`,`timestamp`),
  KEY `idx_sensor_type` (`sensor_type`),
  KEY `idx_sensor_location` (`location`),
  KEY `idx_sensor_data_device_timestamp` (`device_id`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensor_data_partitioned`
--

LOCK TABLES `sensor_data_partitioned` WRITE;
/*!40000 ALTER TABLE `sensor_data_partitioned` DISABLE KEYS */;
/*!40000 ALTER TABLE `sensor_data_partitioned` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_registries`
--

DROP TABLE IF EXISTS `service_registries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_registries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_id` varchar(100) NOT NULL,
  `service_name` varchar(200) NOT NULL,
  `host` varchar(255) NOT NULL,
  `port` int NOT NULL,
  `version` varchar(50) DEFAULT '1.0.0',
  `status` enum('healthy','unhealthy','degraded','maintenance') DEFAULT 'healthy',
  `last_heartbeat` datetime DEFAULT CURRENT_TIMESTAMP,
  `metadata` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_id` (`service_id`),
  KEY `idx_service_id` (`service_id`),
  KEY `idx_service_name` (`service_name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_registries`
--

LOCK TABLES `service_registries` WRITE;
/*!40000 ALTER TABLE `service_registries` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_registries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soil_health_logs`
--

DROP TABLE IF EXISTS `soil_health_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `soil_health_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `field_id` int DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `organic_matter_percent` float DEFAULT NULL,
  `ph` float DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `ix_soil_health_logs_id` (`id`),
  KEY `ix_soil_health_logs_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soil_health_logs`
--

LOCK TABLES `soil_health_logs` WRITE;
/*!40000 ALTER TABLE `soil_health_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `soil_health_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sop_executions`
--

DROP TABLE IF EXISTS `sop_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sop_executions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `sop_id` int DEFAULT NULL,
  `executed_by` int DEFAULT NULL,
  `executed_at` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `sop_id` (`sop_id`),
  KEY `executed_by` (`executed_by`),
  KEY `ix_sop_executions_tenant_id` (`tenant_id`),
  KEY `ix_sop_executions_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sop_executions`
--

LOCK TABLES `sop_executions` WRITE;
/*!40000 ALTER TABLE `sop_executions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sop_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sops`
--

DROP TABLE IF EXISTS `sops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `content` text,
  `role` varchar(50) DEFAULT NULL,
  `created_at` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_sops_tenant_id` (`tenant_id`),
  KEY `ix_sops_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sops`
--

LOCK TABLES `sops` WRITE;
/*!40000 ALTER TABLE `sops` DISABLE KEYS */;
INSERT INTO `sops` VALUES (1,'default','Test SOP','Test Content','Worker','2026-01-12'),(2,'default','Test SOP','Test Content','Worker','2026-01-12');
/*!40000 ALTER TABLE `sops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supply_chain_networks`
--

DROP TABLE IF EXISTS `supply_chain_networks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supply_chain_networks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `network_id` varchar(50) NOT NULL,
  `network_name` varchar(200) NOT NULL,
  `description` text,
  `network_type` varchar(50) DEFAULT 'agricultural',
  `stages` json DEFAULT NULL,
  `locations` json DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `network_id` (`network_id`),
  KEY `idx_network_id` (`network_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supply_chain_networks`
--

LOCK TABLES `supply_chain_networks` WRITE;
/*!40000 ALTER TABLE `supply_chain_networks` DISABLE KEYS */;
/*!40000 ALTER TABLE `supply_chain_networks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supply_chain_nodes`
--

DROP TABLE IF EXISTS `supply_chain_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supply_chain_nodes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `network_id` varchar(50) NOT NULL,
  `node_id` varchar(50) NOT NULL,
  `node_name` varchar(200) NOT NULL,
  `node_type` varchar(100) DEFAULT NULL,
  `location` varchar(200) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `current_stock` int DEFAULT '0',
  `coordinates` json DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_network_id` (`network_id`),
  KEY `idx_node_id` (`node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supply_chain_nodes`
--

LOCK TABLES `supply_chain_nodes` WRITE;
/*!40000 ALTER TABLE `supply_chain_nodes` DISABLE KEYS */;
/*!40000 ALTER TABLE `supply_chain_nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `setting_type` varchar(20) DEFAULT 'string',
  `category` varchar(50) DEFAULT 'general',
  `description` text,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `updated_by` (`updated_by`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'farm_name','Begin Masimba Farm','string','farm','Name of the farm',NULL,'2026-01-11 16:06:29'),(2,'farm_location','Zimbabwe','string','farm','Location of the farm',NULL,'2026-01-11 16:06:29'),(3,'farm_size','100','number','farm','Size of the farm in hectares',NULL,'2026-01-11 16:06:29'),(4,'backup_frequency','daily','string','backup','How often to backup data',NULL,'2026-01-11 16:06:29'),(5,'email_provider','smtp','string','notifications','Email service provider',NULL,'2026-01-11 16:06:29'),(6,'sms_provider','none','string','notifications','SMS service provider',NULL,'2026-01-11 16:06:29');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text,
  `assigned_to` int DEFAULT NULL,
  `status` enum('pending','in_progress','completed','cancelled') DEFAULT 'pending',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `due_date` date DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_recurring` tinyint(1) DEFAULT '0',
  `tenant_id` int DEFAULT NULL,
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `ix_tasks_tenant_id` (`tenant_id`),
  KEY `idx_tasks_assigned_status_due` (`assigned_to`,`status`,`due_date`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'Morning Feeding','Feed cattle in North Pasture',2,'pending','high','2026-01-13',NULL,2,'2026-01-12 13:25:58',0,NULL,NULL),(2,'Fence Repair','Check fence line on South Crops',2,'in_progress','medium','2026-01-14',NULL,2,'2026-01-12 13:25:58',0,NULL,NULL),(3,'Vaccination Round','Vaccinate Goat Group 1',2,'pending','high','2026-01-19',NULL,2,'2026-01-12 13:25:58',0,NULL,NULL),(4,'Maize Planting SOP','Follow SOP: Maize Planting SOP\n\nSOP Checklist:\n- [ ] Check soil moisture depth (>30cm)\n- [ ] Calibrate planter for population (45k-55k/ha)\n- [ ] Fill seed and fertilizer hoppers\n- [ ] Check depth settings (5cm)\n- [ ] Run test strip (10m) and verify spacing\n- [ ] Begin planting at 6-8 km/h\n- [ ] Monitor monitor sensors continuously',5,'pending','high','2026-01-22',NULL,2,'2026-01-12 19:58:30',0,NULL,NULL),(5,'Livestock Vaccination SOP','Follow SOP: Livestock Vaccination SOP\n\nSOP Checklist:\n- [ ] Check refrigerator temperature (2-8┬░C)\n- [ ] Verify vaccine expiration date\n- [ ] Prepare sterile needles (one per animal if possible)\n- [ ] Restrain animal safely in crush\n- [ ] Administer dose according to label (Sub-Q or IM)\n- [ ] Record batch number and expiry in log\n- [ ] Observe animal for 15 mins for reaction',4,'pending','high','2026-01-14',NULL,2,'2026-01-13 16:05:45',0,NULL,NULL),(6,'Test Farm Maintenance','Test task for equipment maintenance',1,'pending','high','2024-02-20',NULL,1,'2026-02-13 09:46:53',0,1,NULL);
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenants`
--

DROP TABLE IF EXISTS `tenants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `subdomain` varchar(100) DEFAULT NULL,
  `domain` varchar(255) DEFAULT NULL,
  `description` text,
  `address` text,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `subscription_plan` varchar(50) DEFAULT 'basic',
  `subscription_expires` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subdomain` (`subdomain`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenants`
--

LOCK TABLES `tenants` WRITE;
/*!40000 ALTER TABLE `tenants` DISABLE KEYS */;
INSERT INTO `tenants` VALUES (1,'Default Tenant','default',NULL,NULL,NULL,NULL,NULL,NULL,1,'basic',NULL,'2026-01-12 11:09:50','2026-01-12 11:09:50');
/*!40000 ALTER TABLE `tenants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timesheets`
--

DROP TABLE IF EXISTS `timesheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timesheets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `work_date` date NOT NULL,
  `hours_worked` decimal(5,2) NOT NULL,
  `task_description` text,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `approved_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `approved_by` (`approved_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timesheets`
--

LOCK TABLES `timesheets` WRITE;
/*!40000 ALTER TABLE `timesheets` DISABLE KEYS */;
/*!40000 ALTER TABLE `timesheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tracking_qr_codes`
--

DROP TABLE IF EXISTS `tracking_qr_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tracking_qr_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tracking_id` varchar(50) NOT NULL,
  `qr_data` longtext NOT NULL,
  `qr_image_base64` longtext,
  `qr_url` varchar(500) DEFAULT NULL,
  `generated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','inactive') DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `idx_tracking_id` (`tracking_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tracking_qr_codes`
--

LOCK TABLES `tracking_qr_codes` WRITE;
/*!40000 ALTER TABLE `tracking_qr_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `tracking_qr_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_code` varchar(50) DEFAULT NULL,
  `transaction_type` enum('income','expense') NOT NULL,
  `category` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text,
  `transaction_date` date NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `reference_id` varchar(50) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_code` (`transaction_code`),
  KEY `created_by` (`created_by`),
  KEY `tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,'TX-1768224358136998','expense','Feed',450.00,'Weekly cattle feed purchase','2026-01-12',NULL,NULL,2,'2026-01-12 13:25:58',NULL),(2,'TX-1768224358165888','income','Sales',1200.00,'Sold 2 calves','2026-01-11',NULL,NULL,2,'2026-01-12 13:25:58',NULL),(3,'TX-1768224358166634','expense','Fuel',150.00,'Diesel for tractor','2026-01-10',NULL,NULL,2,'2026-01-12 13:25:58',NULL),(4,'TRX-1768236317729','expense','Seeds',250.00,'Maize Seeds','2026-01-12',NULL,NULL,4,'2026-01-12 16:45:17',NULL),(5,'TRX-1768245934285','expense','Seeds',250.00,'Maize Seeds','2026-01-12',NULL,NULL,4,'2026-01-12 19:25:34',NULL),(6,'TRX-1768246092017','expense','Seeds',250.00,'Maize Seeds','2026-01-12',NULL,NULL,4,'2026-01-12 19:28:12',NULL);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_activity_log`
--

DROP TABLE IF EXISTS `user_activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activity_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `action` varchar(100) NOT NULL,
  `details` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_activity_log`
--

LOCK TABLES `user_activity_log` WRITE;
/*!40000 ALTER TABLE `user_activity_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_activity_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_invitations`
--

DROP TABLE IF EXISTS `user_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_invitations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `role_id` int DEFAULT NULL,
  `invited_by` int NOT NULL,
  `invitation_token` varchar(190) DEFAULT NULL,
  `status` enum('pending','accepted','expired') DEFAULT 'pending',
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `invitation_token` (`invitation_token`),
  KEY `role_id` (`role_id`),
  KEY `invited_by` (`invited_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_invitations`
--

LOCK TABLES `user_invitations` WRITE;
/*!40000 ALTER TABLE `user_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_invitations` ENABLE KEYS */;
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
  `permission` varchar(120) NOT NULL,
  `effect` varchar(10) NOT NULL DEFAULT 'allow',
  `farm_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_permissions_user` (`user_id`),
  KEY `idx_user_permissions_farm` (`farm_id`),
  KEY `idx_user_permissions_effect` (`effect`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role_id` int DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` int DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'active',
  `hashed_password` varchar(255) DEFAULT NULL,
  `mfa_enabled` tinyint(1) DEFAULT '0',
  `mfa_enabled_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `uuid_identifier` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `unique_tenant_email` (`tenant_id`,`email`),
  KEY `idx_users_role_active` (`role_id`,`is_active`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin','admin@local','$2y$12$AQqt9S5tgZSmelBu86gl4.s7noll0A7F1U8Bgv0SZZbYD6uBOem6y',1,NULL,'2026-01-11 17:28:21','2026-01-11 15:06:45',NULL,'admin','active','$2b$12$KFkTJNiSbL8X.S/jWZ7a9eW03UXaXB6UPD8VP3TppTCYrHwyXNxm2',0,NULL,1,NULL),(2,'Admin User','admin@beginmasimba.com','$2y$12$AQqt9S5tgZSmelBu86gl4.s7noll0A7F1U8Bgv0SZZbYD6uBOem6y',1,'1234567890','2026-04-12 16:39:16','2026-01-11 15:08:36',NULL,'admin','active','$2b$12$EZu3pwbEKWN4Fw5S7LviKOj8GVgnHDRceC8ZEBxNdKVJphcCZUGqa',0,NULL,1,NULL),(3,'Admin User','admin@masimba.farm','$2y$12$AQqt9S5tgZSmelBu86gl4.s7noll0A7F1U8Bgv0SZZbYD6uBOem6y',1,NULL,'2026-02-12 17:49:50','2026-01-12 16:42:06',NULL,'admin','active','$2b$12$xxDLS8zxzBo/zQJEXoJPneNTFGmEiAmcFVTrMatr8wd0lGebSX7sO',0,NULL,1,NULL),(4,'Farm Manager','manager@masimba.farm','$2a$10$JhH5YHZJIzX3Y14uH31k7ehy.6B3/ICRwAGF6iC6UbnqsmVhavQq.',2,NULL,'2026-02-12 17:55:50','2026-01-12 16:42:06',NULL,'manager','active','$2y$10$EmKzbPCyUURGVssAGas/yu3HbcEKIkYfIDVLs2u5BnyoQfl3LzlNe',0,NULL,1,NULL),(5,'Field Worker','worker@masimba.farm','$2a$10$JhH5YHZJIzX3Y14uH31k7ehy.6B3/ICRwAGF6iC6UbnqsmVhavQq.',3,NULL,NULL,'2026-01-12 16:42:06',NULL,'worker','active','$2b$12$gTUx.dNvOl8itgr1Uejcl..PgmOGIt/K1JpH1EoeXxeEy7cY5ZcOq',0,NULL,1,NULL),(6,'Admin User','admin@example.com','$2y$12$AQqt9S5tgZSmelBu86gl4.s7noll0A7F1U8Bgv0SZZbYD6uBOem6y',1,NULL,'2026-04-20 22:05:11','2026-01-12 16:36:21',0,'admin','active','$2b$12$0oY7JdrdR/dVNOUVwb4/EOIlgvPSJaeV6lEGw6Dj.2M1R92h3SABG',0,NULL,1,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weather_data`
--

DROP TABLE IF EXISTS `weather_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weather_data` (
  `id` int NOT NULL AUTO_INCREMENT,
  `location` varchar(100) NOT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `temperature_celsius` float DEFAULT NULL,
  `humidity_percent` float DEFAULT NULL,
  `pressure_hpa` float DEFAULT NULL,
  `wind_speed_kmh` float DEFAULT NULL,
  `wind_direction_degrees` int DEFAULT NULL,
  `precipitation_mm` float DEFAULT NULL,
  `weather_condition` varchar(100) DEFAULT NULL,
  `visibility_km` float DEFAULT NULL,
  `uv_index` float DEFAULT NULL,
  `data_source` varchar(50) DEFAULT 'openweathermap',
  `forecast_hours_ahead` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_location_timestamp` (`location`,`timestamp`),
  KEY `idx_forecast` (`forecast_hours_ahead`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weather_data`
--

LOCK TABLES `weather_data` WRITE;
/*!40000 ALTER TABLE `weather_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `weather_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weather_logs`
--

DROP TABLE IF EXISTS `weather_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weather_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `log_date` date NOT NULL,
  `temperature_c` decimal(5,2) DEFAULT NULL,
  `humidity_percent` decimal(5,2) DEFAULT NULL,
  `rainfall_mm` decimal(6,2) DEFAULT '0.00',
  `wind_speed_kph` decimal(5,2) DEFAULT NULL,
  `conditions` varchar(50) DEFAULT NULL,
  `notes` text,
  `recorded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `recorded_by` (`recorded_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weather_logs`
--

LOCK TABLES `weather_logs` WRITE;
/*!40000 ALTER TABLE `weather_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `weather_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'begin_masimba_farm'
--

--
-- Dumping routines for database 'begin_masimba_farm'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:29:04
