-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: kaycee_db
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
-- Current Database: `kaycee_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `kaycee_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `kaycee_db`;

--
-- Table structure for table `about_content`
--

DROP TABLE IF EXISTS `about_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `about_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section` varchar(100) NOT NULL,
  `content` mediumtext,
  `image_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_about_section` (`section`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `about_content`
--

LOCK TABLES `about_content` WRITE;
/*!40000 ALTER TABLE `about_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `about_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_activity_log`
--

DROP TABLE IF EXISTS `admin_activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_activity_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `action` varchar(100) NOT NULL,
  `details` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_action_created_at` (`action`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_activity_log`
--

LOCK TABLES `admin_activity_log` WRITE;
/*!40000 ALTER TABLE `admin_activity_log` DISABLE KEYS */;
INSERT INTO `admin_activity_log` VALUES (1,1,'inbox_sync','synced=5','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-27 18:39:14'),(2,1,'admin_error','dashboard_data_fetch - SQLSTATE[42S02]: Base table or view not found: 1146 Table \'kaycee_db.cron_run_log\' doesn\'t exist','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-30 09:04:14'),(3,1,'admin_error','dashboard_data_fetch - SQLSTATE[42S02]: Base table or view not found: 1146 Table \'kaycee_db.cron_run_log\' doesn\'t exist','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-30 09:06:58'),(4,0,'eap_order_public','Company: Kaycee & Associates, Tier: enhanced','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-30 13:42:22'),(5,1,'report_generate','type=weekly_revenue start=2026-03-06 end=2026-03-17 format=array','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-31 08:15:36'),(6,1,'report_generate','type=therapist_performance start=2026-03-01 end=2026-03-31 format=array','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-31 08:16:03'),(7,1,'inbox_sync','synced=1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-31 08:25:21'),(8,1,'inbox_sync','synced=0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-03-31 09:48:13'),(9,1,'inbox_sync','synced=2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-04-06 07:25:58'),(10,1,'inbox_sync','synced=2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-04-08 06:38:53'),(11,1,'inbox_sync','synced=0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','2026-04-08 09:02:19'),(12,1,'inbox_sync','synced=3','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36','2026-04-15 07:43:40'),(13,1,'inbox_sync','synced=0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36','2026-04-15 07:44:37');
/*!40000 ALTER TABLE `admin_activity_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_posts`
--

DROP TABLE IF EXISTS `blog_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(191) NOT NULL,
  `excerpt` text,
  `content` text,
  `image_url` varchar(255) DEFAULT NULL,
  `author` varchar(100) DEFAULT 'Kaycee',
  `date` date DEFAULT NULL,
  `category` varchar(50) DEFAULT 'Wellness',
  `read_time` varchar(20) DEFAULT '5 min read',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_date` (`date`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_posts`
--

LOCK TABLES `blog_posts` WRITE;
/*!40000 ALTER TABLE `blog_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `blog_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_audit`
--

DROP TABLE IF EXISTS `booking_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_audit` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `action` varchar(50) NOT NULL DEFAULT 'status',
  `previous_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) DEFAULT NULL,
  `previous_date` date DEFAULT NULL,
  `new_date` date DEFAULT NULL,
  `previous_time` time DEFAULT NULL,
  `new_time` time DEFAULT NULL,
  `reason` text,
  `changed_by` varchar(100) NOT NULL,
  `changed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_changed_at` (`changed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_audit`
--

LOCK TABLES `booking_audit` WRITE;
/*!40000 ALTER TABLE `booking_audit` DISABLE KEYS */;
INSERT INTO `booking_audit` VALUES (1,3,'payment','unpaid','paid',NULL,NULL,NULL,NULL,NULL,'admin','2026-03-23 04:32:40'),(2,21,'status_change','pending','confirmed',NULL,NULL,NULL,NULL,NULL,'trigger','2026-03-27 07:21:56'),(3,21,'status','pending','confirmed',NULL,NULL,NULL,NULL,NULL,'admin','2026-03-27 07:21:56');
/*!40000 ALTER TABLE `booking_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_notes`
--

DROP TABLE IF EXISTS `booking_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `note` text NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_notes`
--

LOCK TABLES `booking_notes` WRITE;
/*!40000 ALTER TABLE `booking_notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `booking_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_status_history`
--

DROP TABLE IF EXISTS `booking_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` varchar(100) DEFAULT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `idx_booking` (`booking_id`),
  KEY `idx_changed_at` (`changed_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_status_history`
--

LOCK TABLES `booking_status_history` WRITE;
/*!40000 ALTER TABLE `booking_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `booking_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `location_name` varchar(500) DEFAULT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `type` enum('in-person','online') DEFAULT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `notes` text,
  `status` enum('pending','confirmed','completed','cancelled','waitlisted') DEFAULT 'pending',
  `paid` tinyint(1) NOT NULL DEFAULT '0',
  `payment_method` varchar(100) DEFAULT NULL,
  `amount_paid` decimal(10,2) NOT NULL DEFAULT '0.00',
  `amount_due` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_status` enum('pending','completed','failed','settled') NOT NULL DEFAULT 'pending',
  `transaction_id` varchar(191) DEFAULT NULL,
  `receipt_number` varchar(191) DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reminder_sent` tinyint DEFAULT '0',
  `follow_up_sent` tinyint DEFAULT '0',
  `reviewed` tinyint(1) NOT NULL DEFAULT '0',
  `reviewed_by` varchar(100) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  KEY `idx_status` (`status`),
  KEY `idx_date_time` (`date`,`time`),
  KEY `idx_user_email` (`email`),
  KEY `idx_date_status` (`date`,`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_location_date` (`location_id`,`date`),
  KEY `idx_email_created_at` (`email`,`created_at`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_reviewed` (`reviewed`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-30','10:00:00','Cynthia Rasiile','rcynthiantebatse@gmail.com','0767780804','Please contact me on WhatsApp ','cancelled',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-10 14:18:35',0,0,0,NULL,NULL,NULL),(2,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-30','10:00:00','Kgomotso','carolinesebeela','0782003457','Hey','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-10 14:31:44',0,0,0,NULL,NULL,NULL),(3,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-26','15:00:00','Turn Fox','turnfox5@gmail.com','0649186091','I want to see if this works ','confirmed',1,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-23 06:32:40','2026-03-11 03:41:11',0,0,0,NULL,NULL,NULL),(4,7,NULL,NULL,'Elizabeth Mathibe','online','2026-03-20','15:00:00','Turn Fox','turnfox5@gmail.com','0649186091','Addiction counselling supports individuals who are struggling with substance use or addictive behaviours.','completed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-11 03:59:37',0,0,0,NULL,NULL,NULL),(5,3,NULL,NULL,'Kgomotso Caroline Sebeela','online','2026-04-16','13:00:00','Stephen Masimba','masimbastephen92@gmail.com','0697316145','It has to work now ','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-11 04:12:28',0,0,0,NULL,NULL,NULL),(6,5,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-19','10:00:00','Stephen Masimba','masimbastephen92@gmail.com','0697316145','What if I am it this time ','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-11 04:21:10',0,0,0,NULL,NULL,NULL),(7,1,NULL,NULL,'Kgomotso Caroline Sebeela','online','2026-03-11','14:00:00','Angela D Too','masimbastephen@gmail.com','0649186091','This year I believe that The King has opened the doors','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-11 04:30:24',0,0,0,NULL,NULL,NULL),(8,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-12','09:00:00','Kgomotso Sebeela','kcsebeela@gmail.com','0782003457','Hi','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-11 05:40:27',0,0,0,NULL,NULL,NULL),(9,2,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-11','14:00:00','Kau','Kcsebeela@gmail.com','0782003457','','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-11 06:15:02',0,0,0,NULL,NULL,NULL),(10,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-17','15:00:00','Vuyisa','hlakanyanavee@gmail.com','0813813915','','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-14 14:09:40',0,0,0,NULL,NULL,NULL),(11,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-17','15:00:00','Vuyisa','hlakanyanavee@gmail.com','0813813915','','pending',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-14 14:09:40',0,0,0,NULL,NULL,NULL),(12,4,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-21','11:00:00','Jabulane Tshekeli ','jtshekelip@gmail.com','0714840599','','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-15 07:15:09',0,0,0,NULL,NULL,NULL),(13,1,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-16','10:00:00','Kgom','kcsebeela@gmail.com','0782003457','','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-15 19:09:20',0,0,0,NULL,NULL,NULL),(14,1,NULL,NULL,'Kgomotso Caroline Sebeela','online','2026-03-31','13:00:00','Tlou Monama','tloumonama@gmail.com','0798437218','','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-16 05:50:32',0,0,0,NULL,NULL,NULL),(15,2,NULL,NULL,'Kgomotso Caroline Sebeela','in-person','2026-03-17','10:00:00','Kay','Kcsebeela@gmail.com','0782003457','','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-16 17:13:56',0,0,0,NULL,NULL,NULL),(16,7,NULL,NULL,'Elizabeth Mathibe','online','2026-03-19','09:00:00','Stephen Masimba','masimbastephen92@gmail.com','0697316145','This is what I want, right ke Kgomotso?','confirmed',0,NULL,0.00,0.00,'pending',NULL,NULL,'2026-03-22 02:15:35','2026-03-17 03:07:09',0,0,0,NULL,NULL,NULL),(17,1,2,'In-Person | Rivonia Therapy Centre','Kgomotso Caroline Sebeela','','2026-03-27','14:00:00','Angela D Too','stephentmasimba@gmail.com','0697316145','check now ','pending',0,'Offline',0.00,650.00,'pending',NULL,'RCPT-20260327-2416','2026-03-27 09:03:34','2026-03-27 07:03:34',0,0,0,NULL,NULL,NULL),(18,1,2,'In-Person | Rivonia Therapy Centre','Kgomotso Caroline Sebeela','','2026-03-27','14:00:00','Angela D Too','stephentmasimba@gmail.com','0697316145','check now ','pending',0,'Offline',0.00,650.00,'pending',NULL,'RCPT-20260327-2365','2026-03-27 09:03:39','2026-03-27 07:03:39',0,0,0,NULL,NULL,NULL),(20,1,NULL,'Online Session','Kgomotso Caroline Sebeela','online','2026-03-30','10:00:00','Test Client','test@example.com','0123456789','test','pending',0,'Offline',0.00,500.00,'pending',NULL,'RCPT-20260327-9362','2026-03-27 09:12:43','2026-03-27 07:12:43',0,0,0,NULL,NULL,NULL),(21,1,2,'In-Person | Rivonia Therapy Centre','Kgomotso Caroline Sebeela','','2026-03-27','13:30:00','Angela D Too','stephentmasimba@gmail.com','0697316145','check again','confirmed',0,'Offline',0.00,650.00,'pending',NULL,'RCPT-20260327-9777','2026-03-27 09:21:56','2026-03-27 07:14:36',0,0,0,NULL,NULL,NULL),(22,1,3,'Wellness Center','Kgomotso Caroline Sebeela','','2026-03-31','08:30:00','Stephen Masimba','stephentmasimba@gmail.com','0697316145','akoi','pending',0,'Offline',0.00,500.00,'pending',NULL,'RCPT-20260327-3234','2026-03-27 10:38:03','2026-03-27 08:38:03',0,0,0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_bookings_after_update` AFTER UPDATE ON `bookings` FOR EACH ROW BEGIN
  IF NEW.status <> OLD.status THEN
    INSERT INTO booking_audit (booking_id, action, previous_status, new_status, changed_by, changed_at)
    VALUES (NEW.id, 'status_change', OLD.status, NEW.status, 'trigger', NOW());
  END IF;
  IF NEW.amount_paid <> OLD.amount_paid THEN
    INSERT INTO payment_history (booking_id, action, status, amount, created_by)
    VALUES (NEW.id, 'amount_paid_change', NEW.payment_status, NEW.amount_paid - OLD.amount_paid, 'trigger');
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cron_run_log`
--

DROP TABLE IF EXISTS `cron_run_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cron_run_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `task` varchar(191) NOT NULL,
  `status` enum('success','failure') NOT NULL DEFAULT 'success',
  `details` text,
  `duration_ms` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_task` (`task`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cron_run_log`
--

LOCK TABLES `cron_run_log` WRITE;
/*!40000 ALTER TABLE `cron_run_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `cron_run_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_assessments`
--

DROP TABLE IF EXISTS `eap_assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_assessments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `assessment_type` enum('phq9','gad7','stress','burnout','audit','trauma') NOT NULL,
  `total_score` int unsigned NOT NULL,
  `severity` varchar(50) NOT NULL,
  `answers_json` text NOT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `consent_given` tinyint(1) NOT NULL DEFAULT '0',
  `consent_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_type` (`assessment_type`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_assessments`
--

LOCK TABLES `eap_assessments` WRITE;
/*!40000 ALTER TABLE `eap_assessments` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_challenge_progress`
--

DROP TABLE IF EXISTS `eap_challenge_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_challenge_progress` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `challenge_id` int unsigned NOT NULL,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  `points` int unsigned NOT NULL DEFAULT '0',
  `streak` int unsigned NOT NULL DEFAULT '0',
  `last_checkin_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_challenge_member` (`challenge_id`,`member_id`),
  KEY `idx_challenge_id` (`challenge_id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_challenge_progress`
--

LOCK TABLES `eap_challenge_progress` WRITE;
/*!40000 ALTER TABLE `eap_challenge_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_challenge_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_challenges`
--

DROP TABLE IF EXISTS `eap_challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_challenges` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `points_per_checkin` int unsigned NOT NULL DEFAULT '10',
  `audience` enum('public','individual','corporate','eap') NOT NULL DEFAULT 'eap',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`),
  KEY `idx_dates` (`start_date`,`end_date`),
  KEY `idx_audience` (`audience`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_challenges`
--

LOCK TABLES `eap_challenges` WRITE;
/*!40000 ALTER TABLE `eap_challenges` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_challenges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_community_posts`
--

DROP TABLE IF EXISTS `eap_community_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_community_posts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `member_id` int unsigned NOT NULL,
  `post_type` enum('post','event') NOT NULL DEFAULT 'post',
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `event_at` datetime DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `moderated_by` int unsigned DEFAULT NULL,
  `moderated_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_event_at` (`event_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_community_posts`
--

LOCK TABLES `eap_community_posts` WRITE;
/*!40000 ALTER TABLE `eap_community_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_community_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_conversation_files`
--

DROP TABLE IF EXISTS `eap_conversation_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_conversation_files` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` int unsigned NOT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `uploaded_by` enum('member','admin') NOT NULL DEFAULT 'member',
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_conversation_files`
--

LOCK TABLES `eap_conversation_files` WRITE;
/*!40000 ALTER TABLE `eap_conversation_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_conversation_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_conversation_messages`
--

DROP TABLE IF EXISTS `eap_conversation_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_conversation_messages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` int unsigned NOT NULL,
  `sender_role` enum('member','admin') NOT NULL,
  `sender_member_id` int unsigned DEFAULT NULL,
  `sender_user_id` int unsigned DEFAULT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `visibility` enum('member','internal') NOT NULL DEFAULT 'member',
  `message_type` enum('message','note','system') NOT NULL DEFAULT 'message',
  `meta_json` text,
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_conversation_created` (`conversation_id`,`created_at`),
  KEY `idx_visibility` (`visibility`),
  KEY `idx_message_type` (`message_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_conversation_messages`
--

LOCK TABLES `eap_conversation_messages` WRITE;
/*!40000 ALTER TABLE `eap_conversation_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_conversation_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_conversations`
--

DROP TABLE IF EXISTS `eap_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_conversations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `assigned_to` int unsigned DEFAULT NULL,
  `first_response_at` datetime DEFAULT NULL,
  `first_response_due_at` datetime DEFAULT NULL,
  `last_message_at` datetime DEFAULT NULL,
  `resolution_due_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `escalated_at` datetime DEFAULT NULL,
  `escalated_reason` varchar(255) DEFAULT NULL,
  `channel` enum('web','email','phone','sms','whatsapp') NOT NULL DEFAULT 'web',
  `priority` enum('normal','urgent','crisis') NOT NULL DEFAULT 'normal',
  `contact_phone` varchar(50) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_first_response_due_at` (`first_response_due_at`),
  KEY `idx_resolution_due_at` (`resolution_due_at`),
  KEY `idx_resolved_at` (`resolved_at`),
  KEY `idx_escalated_at` (`escalated_at`),
  KEY `idx_channel` (`channel`),
  KEY `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_conversations`
--

LOCK TABLES `eap_conversations` WRITE;
/*!40000 ALTER TABLE `eap_conversations` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_crisis_contacts`
--

DROP TABLE IF EXISTS `eap_crisis_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_crisis_contacts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `country_code` varchar(10) NOT NULL DEFAULT 'ZA',
  `label` varchar(255) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `whatsapp` varchar(50) DEFAULT NULL,
  `url` varchar(800) DEFAULT NULL,
  `notes` varchar(500) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_active` (`active`),
  KEY `idx_country_code` (`country_code`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_crisis_contacts`
--

LOCK TABLES `eap_crisis_contacts` WRITE;
/*!40000 ALTER TABLE `eap_crisis_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_crisis_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_demo_request_attachments`
--

DROP TABLE IF EXISTS `eap_demo_request_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_demo_request_attachments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int unsigned NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `stored_name` varchar(255) NOT NULL,
  `mime_type` varchar(120) DEFAULT NULL,
  `file_size_bytes` int unsigned NOT NULL DEFAULT '0',
  `sha256` char(64) DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_request_stored` (`request_id`,`stored_name`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_demo_request_attachments`
--

LOCK TABLES `eap_demo_request_attachments` WRITE;
/*!40000 ALTER TABLE `eap_demo_request_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_demo_request_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_demo_request_followups`
--

DROP TABLE IF EXISTS `eap_demo_request_followups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_demo_request_followups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int unsigned NOT NULL,
  `due_at` datetime NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_due_at` (`due_at`),
  KEY `idx_completed` (`completed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_demo_request_followups`
--

LOCK TABLES `eap_demo_request_followups` WRITE;
/*!40000 ALTER TABLE `eap_demo_request_followups` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_demo_request_followups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_demo_request_notes`
--

DROP TABLE IF EXISTS `eap_demo_request_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_demo_request_notes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int unsigned NOT NULL,
  `note` text NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_demo_request_notes`
--

LOCK TABLES `eap_demo_request_notes` WRITE;
/*!40000 ALTER TABLE `eap_demo_request_notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_demo_request_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_demo_requests`
--

DROP TABLE IF EXISTS `eap_demo_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_demo_requests` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `contact_email` varchar(255) NOT NULL,
  `contact_phone` varchar(50) NOT NULL,
  `employee_count` int unsigned DEFAULT '0',
  `note` text,
  `status` enum('new','contacted','converted','closed') NOT NULL DEFAULT 'new',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `company_size` varchar(50) DEFAULT NULL,
  `industry` varchar(150) DEFAULT NULL,
  `preferred_contact_method` enum('email','phone','any') NOT NULL DEFAULT 'any',
  `source` varchar(100) NOT NULL DEFAULT 'eap_page',
  `assigned_to` int unsigned DEFAULT NULL,
  `follow_up_by` date DEFAULT NULL,
  `consent_given` tinyint(1) NOT NULL DEFAULT '0',
  `consent_at` datetime DEFAULT NULL,
  `status_updated_at` datetime DEFAULT NULL,
  `contacted_at` datetime DEFAULT NULL,
  `converted_at` datetime DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `utm_source` varchar(120) DEFAULT NULL,
  `utm_medium` varchar(120) DEFAULT NULL,
  `utm_campaign` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_status_updated_at` (`status_updated_at`),
  KEY `idx_contacted_at` (`contacted_at`),
  KEY `idx_converted_at` (`converted_at`),
  KEY `idx_closed_at` (`closed_at`),
  KEY `idx_contact_email_created` (`contact_email`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_demo_requests`
--

LOCK TABLES `eap_demo_requests` WRITE;
/*!40000 ALTER TABLE `eap_demo_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_demo_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_incidents`
--

DROP TABLE IF EXISTS `eap_incidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_incidents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `incident_type` enum('critical_incident','workplace_violence','mental_health_crisis','system_issue','other') NOT NULL DEFAULT 'other',
  `description` text NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `urgency` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `status` enum('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
  `dispatched_to` int unsigned DEFAULT NULL,
  `dispatched_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_status` (`status`),
  KEY `idx_incident_type` (`incident_type`),
  KEY `idx_urgency` (`urgency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_incidents`
--

LOCK TABLES `eap_incidents` WRITE;
/*!40000 ALTER TABLE `eap_incidents` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_incidents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_members`
--

DROP TABLE IF EXISTS `eap_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_members` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(120) DEFAULT NULL,
  `last_name` varchar(120) DEFAULT NULL,
  `member_type` enum('employee','dependent','hr') NOT NULL DEFAULT 'employee',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `first_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `login_count` int unsigned NOT NULL DEFAULT '0',
  `preferred_language` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_org_email` (`organization_id`,`email`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_active` (`active`),
  KEY `idx_last_login_at` (`last_login_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_members`
--

LOCK TABLES `eap_members` WRITE;
/*!40000 ALTER TABLE `eap_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_message_templates`
--

DROP TABLE IF EXISTS `eap_message_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_message_templates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` varchar(120) DEFAULT NULL,
  `body` text NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_message_templates`
--

LOCK TABLES `eap_message_templates` WRITE;
/*!40000 ALTER TABLE `eap_message_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_message_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_notification_queue`
--

DROP TABLE IF EXISTS `eap_notification_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_notification_queue` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `platform` enum('expo') NOT NULL DEFAULT 'expo',
  `token` varchar(255) NOT NULL,
  `title` varchar(120) NOT NULL,
  `body` varchar(350) NOT NULL,
  `data_json` text,
  `status` enum('queued','sent','failed') NOT NULL DEFAULT 'queued',
  `last_error` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_notification_queue`
--

LOCK TABLES `eap_notification_queue` WRITE;
/*!40000 ALTER TABLE `eap_notification_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_notification_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_orders`
--

DROP TABLE IF EXISTS `eap_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `contact_email` varchar(255) NOT NULL,
  `contact_phone` varchar(50) NOT NULL,
  `tier` enum('essential','enhanced','enterprise') NOT NULL,
  `employee_count` int unsigned NOT NULL DEFAULT '0',
  `status` enum('new','invoiced','paid','cancelled') NOT NULL DEFAULT 'new',
  `note` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `invoice_number` varchar(191) DEFAULT NULL,
  `amount_due` decimal(10,2) DEFAULT NULL,
  `payment_reference` varchar(191) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_orders`
--

LOCK TABLES `eap_orders` WRITE;
/*!40000 ALTER TABLE `eap_orders` DISABLE KEYS */;
INSERT INTO `eap_orders` VALUES (1,'Kaycee & Associates','Stephen Masimba','masimbastephen92@gmail.com','0697316145','enhanced',120,'new','jj','2026-03-30 13:42:22',NULL,NULL,17400.00,NULL,NULL);
/*!40000 ALTER TABLE `eap_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_organizations`
--

DROP TABLE IF EXISTS `eap_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_organizations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `org_code` varchar(40) NOT NULL,
  `tier` enum('essential','enhanced','enterprise') NOT NULL DEFAULT 'essential',
  `employee_count` int unsigned NOT NULL DEFAULT '0',
  `include_dependents` tinyint(1) NOT NULL DEFAULT '0',
  `monthly_session_limit` int unsigned NOT NULL DEFAULT '0',
  `access_pin_hash` varchar(255) DEFAULT NULL,
  `sla_first_response_hours` int unsigned DEFAULT NULL,
  `sla_resolution_days` int unsigned DEFAULT NULL,
  `retention_days` int unsigned DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `enable_programs` tinyint(1) DEFAULT NULL,
  `enable_webinars` tinyint(1) DEFAULT NULL,
  `enable_challenges` tinyint(1) DEFAULT NULL,
  `enable_community` tinyint(1) DEFAULT NULL,
  `enable_ai_helper` tinyint(1) DEFAULT NULL,
  `support_email` varchar(255) DEFAULT NULL,
  `support_phone` varchar(50) DEFAULT NULL,
  `support_hours_label` varchar(120) DEFAULT NULL,
  `support_24_7` tinyint(1) DEFAULT NULL,
  `default_language` varchar(10) DEFAULT 'en',
  `sso_provider` enum('none','microsoft') NOT NULL DEFAULT 'none',
  `sso_tenant` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_org_code` (`org_code`),
  KEY `idx_active` (`active`),
  KEY `idx_sso_provider` (`sso_provider`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_organizations`
--

LOCK TABLES `eap_organizations` WRITE;
/*!40000 ALTER TABLE `eap_organizations` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_outcome_surveys`
--

DROP TABLE IF EXISTS `eap_outcome_surveys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_outcome_surveys` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  `related_type` enum('conversation','session','program') NOT NULL,
  `related_id` int unsigned NOT NULL,
  `satisfaction_rating` int unsigned DEFAULT NULL,
  `impact_rating` int unsigned DEFAULT NULL,
  `comments` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_related_member` (`related_type`,`related_id`,`member_id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_related` (`related_type`,`related_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_outcome_surveys`
--

LOCK TABLES `eap_outcome_surveys` WRITE;
/*!40000 ALTER TABLE `eap_outcome_surveys` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_outcome_surveys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_program_enrollments`
--

DROP TABLE IF EXISTS `eap_program_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_program_enrollments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `program_id` int unsigned NOT NULL,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  `status` enum('enrolled','completed','cancelled') NOT NULL DEFAULT 'enrolled',
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `progress_percent` int unsigned NOT NULL DEFAULT '0',
  `milestones_completed_json` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_program_member` (`program_id`,`member_id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_program_enrollments`
--

LOCK TABLES `eap_program_enrollments` WRITE;
/*!40000 ALTER TABLE `eap_program_enrollments` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_program_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_programs`
--

DROP TABLE IF EXISTS `eap_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_programs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `program_type` enum('wellbeing','manager_enablement') NOT NULL DEFAULT 'wellbeing',
  `description` text,
  `duration_weeks` int unsigned NOT NULL DEFAULT '4',
  `milestones_json` text,
  `audience` enum('public','individual','corporate','eap') NOT NULL DEFAULT 'eap',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `tier` enum('all','essential','enhanced','enterprise') DEFAULT 'all',
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`),
  KEY `idx_type` (`program_type`),
  KEY `idx_audience` (`audience`),
  KEY `idx_tier` (`tier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_programs`
--

LOCK TABLES `eap_programs` WRITE;
/*!40000 ALTER TABLE `eap_programs` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_provider_assignments`
--

DROP TABLE IF EXISTS `eap_provider_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_provider_assignments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `session_id` int unsigned NOT NULL,
  `provider_id` int unsigned NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','assigned','confirmed','cancelled','completed') NOT NULL DEFAULT 'pending',
  `note` text,
  PRIMARY KEY (`id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_provider_id` (`provider_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_provider_assignments`
--

LOCK TABLES `eap_provider_assignments` WRITE;
/*!40000 ALTER TABLE `eap_provider_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_provider_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_provider_network`
--

DROP TABLE IF EXISTS `eap_provider_network`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_provider_network` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `role` enum('coach','therapist','medical','legal','financial','other') NOT NULL DEFAULT 'other',
  `license_number` varchar(128) DEFAULT NULL,
  `specialties` text,
  `capacity` int unsigned NOT NULL DEFAULT '10',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `last_availability_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `quality_score` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_assignments` int unsigned NOT NULL DEFAULT '0',
  `last_assigned_at` datetime DEFAULT NULL,
  `languages` varchar(255) DEFAULT NULL,
  `modalities` varchar(255) DEFAULT NULL,
  `locations` varchar(255) DEFAULT NULL,
  `time_zone` varchar(60) NOT NULL DEFAULT 'Africa/Johannesburg',
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_active` (`active`),
  KEY `idx_role` (`role`),
  KEY `idx_last_assigned_at` (`last_assigned_at`),
  KEY `idx_verified` (`verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_provider_network`
--

LOCK TABLES `eap_provider_network` WRITE;
/*!40000 ALTER TABLE `eap_provider_network` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_provider_network` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_provider_slots`
--

DROP TABLE IF EXISTS `eap_provider_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_provider_slots` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `provider_id` int unsigned NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `status` enum('open','booked','blocked') NOT NULL DEFAULT 'open',
  `session_id` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_id` (`provider_id`),
  KEY `idx_starts_at` (`starts_at`),
  KEY `idx_status` (`status`),
  KEY `idx_provider_starts` (`provider_id`,`starts_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_provider_slots`
--

LOCK TABLES `eap_provider_slots` WRITE;
/*!40000 ALTER TABLE `eap_provider_slots` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_provider_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_push_tokens`
--

DROP TABLE IF EXISTS `eap_push_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_push_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned DEFAULT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `platform` enum('expo','apns','fcm') NOT NULL DEFAULT 'expo',
  `token` varchar(255) NOT NULL,
  `device_id` varchar(191) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `last_seen_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_platform_token` (`platform`,`token`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_push_tokens`
--

LOCK TABLES `eap_push_tokens` WRITE;
/*!40000 ALTER TABLE `eap_push_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_push_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_reminder_logs`
--

DROP TABLE IF EXISTS `eap_reminder_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_reminder_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `reminder_type` enum('program_inactivity','conversation_unread','sla_breach','triage_pending') NOT NULL,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  `related_type` enum('program_enrollment','conversation','triage_request') NOT NULL,
  `related_id` int unsigned NOT NULL,
  `sent_to_email` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_related` (`related_type`,`related_id`),
  KEY `idx_type_created` (`reminder_type`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_reminder_logs`
--

LOCK TABLES `eap_reminder_logs` WRITE;
/*!40000 ALTER TABLE `eap_reminder_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_reminder_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_resource_favorites`
--

DROP TABLE IF EXISTS `eap_resource_favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_resource_favorites` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `member_id` int unsigned NOT NULL,
  `resource_id` int unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_member_resource` (`member_id`,`resource_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_resource_favorites`
--

LOCK TABLES `eap_resource_favorites` WRITE;
/*!40000 ALTER TABLE `eap_resource_favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_resource_favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_resource_views`
--

DROP TABLE IF EXISTS `eap_resource_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_resource_views` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `resource_id` int unsigned NOT NULL,
  `audience` varchar(50) DEFAULT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_resource_id` (`resource_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_resource_views`
--

LOCK TABLES `eap_resource_views` WRITE;
/*!40000 ALTER TABLE `eap_resource_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_resource_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_resources`
--

DROP TABLE IF EXISTS `eap_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_resources` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `resource_type` enum('article','video','worksheet','guide','assessment','link','download') NOT NULL DEFAULT 'article',
  `audience` enum('public','individual','corporate','eap') NOT NULL DEFAULT 'public',
  `url` varchar(800) DEFAULT NULL,
  `file_path` varchar(800) DEFAULT NULL,
  `tags` varchar(500) DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `sensitivity` enum('standard','sensitive') NOT NULL DEFAULT 'standard',
  `clinical_review_status` enum('draft','in_review','approved','rejected') NOT NULL DEFAULT 'approved',
  `reviewed_by` int unsigned DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `clinical_notes` text,
  `tier` enum('all','essential','enhanced','enterprise') DEFAULT 'all',
  `language` varchar(10) DEFAULT 'en',
  `readability_level` enum('easy','standard','advanced') NOT NULL DEFAULT 'standard',
  `published_at` datetime DEFAULT NULL,
  `archived_at` datetime DEFAULT NULL,
  `review_due_at` datetime DEFAULT NULL,
  `version` int unsigned NOT NULL DEFAULT '1',
  `category` varchar(120) NOT NULL DEFAULT 'General',
  `content` mediumtext,
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`),
  KEY `idx_audience` (`audience`),
  KEY `idx_type` (`resource_type`),
  KEY `idx_review_status` (`clinical_review_status`),
  KEY `idx_sensitivity` (`sensitivity`),
  KEY `idx_tier` (`tier`),
  KEY `idx_language` (`language`),
  KEY `idx_archived_at` (`archived_at`),
  KEY `idx_review_due_at` (`review_due_at`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_resources`
--

LOCK TABLES `eap_resources` WRITE;
/*!40000 ALTER TABLE `eap_resources` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_security_events`
--

DROP TABLE IF EXISTS `eap_security_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_security_events` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `event_type` varchar(80) NOT NULL,
  `organization_id` int unsigned DEFAULT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `details_json` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_type` (`event_type`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_security_events`
--

LOCK TABLES `eap_security_events` WRITE;
/*!40000 ALTER TABLE `eap_security_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_security_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_session_bookings`
--

DROP TABLE IF EXISTS `eap_session_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_session_bookings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int unsigned NOT NULL,
  `team_member_id` int unsigned DEFAULT NULL,
  `session_date` date NOT NULL,
  `session_time` time DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled') NOT NULL DEFAULT 'scheduled',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_team_member_id` (`team_member_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_session_bookings`
--

LOCK TABLES `eap_session_bookings` WRITE;
/*!40000 ALTER TABLE `eap_session_bookings` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_session_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_sessions`
--

DROP TABLE IF EXISTS `eap_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_sessions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int unsigned DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `organization_id` int unsigned DEFAULT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `team_member_id` int unsigned DEFAULT NULL,
  `recommended_team_member_id` int unsigned DEFAULT NULL,
  `session_type` enum('consultation','counselling','workshop','manager_support','crisis_support','other') NOT NULL DEFAULT 'consultation',
  `modality` enum('in_person','online','phone') NOT NULL DEFAULT 'online',
  `requested_category` varchar(120) DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `duration_minutes` int unsigned NOT NULL DEFAULT '60',
  `status` enum('planned','scheduled','completed','cancelled') NOT NULL DEFAULT 'planned',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `channel` enum('web','email','phone','sms','whatsapp') NOT NULL DEFAULT 'web',
  `requires_approval` tinyint(1) NOT NULL DEFAULT '0',
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_reason` varchar(255) DEFAULT NULL,
  `reminder_sent_at` datetime DEFAULT NULL,
  `external_calendar_event_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_team_member_id` (`team_member_id`),
  KEY `idx_recommended_team_member_id` (`recommended_team_member_id`),
  KEY `idx_status` (`status`),
  KEY `idx_scheduled_at` (`scheduled_at`),
  KEY `idx_requires_approval` (`requires_approval`),
  KEY `idx_cancelled_at` (`cancelled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_sessions`
--

LOCK TABLES `eap_sessions` WRITE;
/*!40000 ALTER TABLE `eap_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_team_members`
--

DROP TABLE IF EXISTS `eap_team_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_team_members` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `specialty` varchar(255) NOT NULL,
  `bio` text NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_team_members`
--

LOCK TABLES `eap_team_members` WRITE;
/*!40000 ALTER TABLE `eap_team_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_team_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_triage_requests`
--

DROP TABLE IF EXISTS `eap_triage_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_triage_requests` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  `concern` varchar(255) NOT NULL,
  `urgency` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `preferred_channel` enum('email','phone','chat','video','sms','whatsapp') NOT NULL DEFAULT 'chat',
  `notes` text,
  `recommended_path` varchar(255) DEFAULT NULL,
  `status` enum('pending','reviewed','escalated','closed') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_status` (`status`),
  KEY `idx_urgency` (`urgency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_triage_requests`
--

LOCK TABLES `eap_triage_requests` WRITE;
/*!40000 ALTER TABLE `eap_triage_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_triage_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_webinar_registrations`
--

DROP TABLE IF EXISTS `eap_webinar_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_webinar_registrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `webinar_id` int unsigned NOT NULL,
  `organization_id` int unsigned NOT NULL,
  `member_id` int unsigned NOT NULL,
  `registered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attended_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_webinar_member` (`webinar_id`,`member_id`),
  KEY `idx_webinar_id` (`webinar_id`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_attended_at` (`attended_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_webinar_registrations`
--

LOCK TABLES `eap_webinar_registrations` WRITE;
/*!40000 ALTER TABLE `eap_webinar_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_webinar_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eap_webinars`
--

DROP TABLE IF EXISTS `eap_webinars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eap_webinars` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `starts_at` datetime NOT NULL,
  `duration_minutes` int unsigned NOT NULL DEFAULT '60',
  `meeting_url` varchar(800) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `audience` enum('public','individual','corporate','eap') NOT NULL DEFAULT 'eap',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`),
  KEY `idx_starts_at` (`starts_at`),
  KEY `idx_audience` (`audience`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eap_webinars`
--

LOCK TABLES `eap_webinars` WRITE;
/*!40000 ALTER TABLE `eap_webinars` DISABLE KEYS */;
/*!40000 ALTER TABLE `eap_webinars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `to_email` varchar(255) NOT NULL,
  `to_name` varchar(255) DEFAULT NULL,
  `subject` varchar(500) NOT NULL,
  `template_type` varchar(100) DEFAULT NULL,
  `status` enum('sent','failed','pending') DEFAULT 'pending',
  `error_message` text,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `read_status` enum('unread','read') DEFAULT 'unread',
  `body` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`to_email`),
  KEY `idx_status` (`status`),
  KEY `idx_date` (`created_at`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES (1,'booking@kayceea.co.za','Test User','Email Configuration Test - Kaycee & Associates','test_email','sent',NULL,'2026-03-24 11:04:20','2026-03-24 11:04:18','unread',NULL),(2,'stephentmasimba@gmail.com','Angela D Too','We\'ve received your booking request - Kaycee & Associates','booking_received','sent',NULL,'2026-03-27 07:03:36','2026-03-27 07:03:34','unread','\n<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\'UTF-8\'>\n    <meta name=\'viewport\' content=\'width=device-width, initial-scale=1.0\'>\n    <title>Booking Received - Kaycee & Associates</title>\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap\');\n        \n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        \n        body {\n            font-family: \'Lato\', sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            color: #333;\n            padding: 20px;\n            min-height: 100vh;\n        }\n        \n        .email-container {\n            max-width: 650px;\n            margin: 0 auto;\n            background: white;\n            border-radius: 20px;\n            box-shadow: 0 20px 40px rgba(0,0,0,0.1);\n            overflow: hidden;\n        }\n        \n        .header {\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            color: white;\n            padding: 40px 30px;\n            text-align: center;\n            position: relative;\n            overflow: hidden;\n        }\n        \n        .header::before {\n            content: \'\';\n            position: absolute;\n            top: -50%;\n            left: -50%;\n            width: 200%;\n            height: 200%;\n            background: url(\'data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"none\" stroke=\"rgba(255,255,255,0.1)\" stroke-width=\"0.5\"/></svg>\');\n            animation: float 20s infinite linear;\n        }\n        \n        .header h1 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 32px;\n            font-weight: 700;\n            margin: 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .header p {\n            font-size: 16px;\n            opacity: 0.9;\n            margin: 8px 0 0 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .content {\n            padding: 40px 30px;\n        }\n        \n        .received-badge {\n            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);\n            color: white;\n            padding: 15px 25px;\n            border-radius: 50px;\n            font-weight: 700;\n            display: inline-flex;\n            align-items: center;\n            gap: 10px;\n            margin-bottom: 30px;\n            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);\n        }\n        \n        .received-icon {\n            width: 24px;\n            height: 24px;\n            background: white;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n        }\n        \n        .greeting {\n            font-size: 18px;\n            line-height: 1.6;\n            margin-bottom: 25px;\n            color: #4b5563;\n        }\n        \n        .greeting strong {\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .booking-summary {\n            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);\n            border: 1px solid #e2e8f0;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 25px 0;\n            position: relative;\n        }\n        \n        .booking-summary::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #6b46c1, #8e44ad, #ec4899);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .booking-summary h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e293b;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .details-grid {\n            display: grid;\n            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));\n            gap: 20px;\n            margin-top: 20px;\n        }\n        \n        .detail-item {\n            display: flex;\n            align-items: center;\n            gap: 12px;\n            padding: 15px;\n            background: white;\n            border-radius: 12px;\n            border: 1px solid #e5e7eb;\n        }\n        \n        .detail-icon {\n            width: 32px;\n            height: 32px;\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            border-radius: 8px;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n            color: white;\n            flex-shrink: 0;\n        }\n        \n        .detail-content {\n            flex: 1;\n        }\n        \n        .detail-label {\n            font-size: 12px;\n            color: #6b7280;\n            text-transform: uppercase;\n            letter-spacing: 0.5px;\n            margin-bottom: 4px;\n        }\n        \n        .detail-value {\n            font-size: 16px;\n            color: #1f2937;\n            font-weight: 600;\n        }\n        \n        .next-steps {\n            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);\n            border: 1px solid #93c5fd;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n        }\n        \n        .next-steps h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e40af;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .steps-list {\n            list-style: none;\n            padding: 0;\n        }\n        \n        .steps-list li {\n            padding: 12px 0;\n            border-bottom: 1px solid rgba(59, 130, 246, 0.2);\n            display: flex;\n            align-items: flex-start;\n            gap: 12px;\n            line-height: 1.6;\n        }\n        \n        .steps-list li:last-child {\n            border-bottom: none;\n        }\n        \n        .step-number {\n            width: 24px;\n            height: 24px;\n            background: #3b82f6;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            color: white;\n            font-size: 12px;\n            font-weight: bold;\n            flex-shrink: 0;\n            margin-top: 2px;\n        }\n        \n        .footer {\n            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);\n            padding: 30px;\n            text-align: center;\n            border-top: 1px solid #e5e7eb;\n        }\n        \n        .footer p {\n            margin: 5px 0;\n            font-size: 14px;\n            color: #6b7280;\n        }\n        \n        .footer .company-name {\n            font-family: \'Playfair Display\', serif;\n            font-size: 18px;\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .contact-info {\n            margin-top: 20px;\n            padding-top: 20px;\n            border-top: 1px solid #e5e7eb;\n            font-size: 13px;\n            color: #9ca3af;\n            line-height: 1.6;\n        }\n        \n        @keyframes float {\n            0%, 100% { transform: rotate(0deg); }\n            50% { transform: rotate(180deg); }\n        }\n        \n        @media (max-width: 600px) {\n            body {\n                padding: 10px;\n            }\n            \n            .email-container {\n                border-radius: 15px;\n            }\n            \n            .header, .content {\n                padding: 25px 20px;\n            }\n            \n            .details-grid {\n                grid-template-columns: 1fr;\n                gap: 15px;\n            }\n            \n            .detail-item {\n                padding: 12px;\n            }\n            \n            .booking-summary, .next-steps {\n                padding: 20px;\n            }\n        }\n    </style>\n</head>\n<body>\n    <div class=\'email-container\'>\n        <!-- Header -->\n        <div class=\'header\'>\n            <div style=\'text-align: center; margin-bottom: 20px;\'>\n                <img src=\'https://kayceea.co.za/assets/images/logo.png\' alt=\'Kaycee & Associates Logo\' style=\'width: 80px; height: auto; margin-bottom: 15px;\'>\n            </div>\n            <h1>Kaycee & Associates</h1>\n            <p>Professional Counseling & Psychological Services</p>\n        </div>\n        \n        <!-- Main Content -->\n        <div class=\'content\'>\n            <div class=\'received-badge\'>\n                <div class=\'received-icon\'>≡ƒôï</div>\n                Booking Request Received\n            </div>\n            \n            <p class=\'greeting\'>\n                Hi <strong>Angela D Too</strong>,<br><br>\n                Thank you for choosing <strong>Kaycee & Associates</strong>. We\'ve successfully received your booking request and our team is reviewing it.\n            </p>\n            \n            <!-- Booking Summary -->\n            <div class=\'booking-summary\'>\n                <h3>≡ƒôà Your Booking Request</h3>\n                \n                <div class=\'details-grid\'>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒùô</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Date</div>\n                            <div class=\'detail-value\'>2026-03-27</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒòÉ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Time</div>\n                            <div class=\'detail-value\'>14:00</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒæñ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Therapist</div>\n                            <div class=\'detail-value\'>Kgomotso Caroline Sebeela</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÄ»</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Service</div>\n                            <div class=\'detail-value\'>Individual Counselling</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒôì</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Location</div>\n                            <div class=\'detail-value\'></div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÆ░</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Price</div>\n                            <div class=\'detail-value\'>R 650.00</div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Next Steps -->\n            <div class=\'next-steps\'>\n                <h3>≡ƒöä What Happens Next?</h3>\n                \n                <ul class=\'steps-list\'>\n                    <li>\n                        <div class=\'step-number\'>1</div>\n                        <div>Our team reviews your booking request and availability</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>2</div>\n                        <div>You\'ll receive a confirmation email with payment details</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>3</div>\n                        <div>Complete payment to secure your appointment</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>4</div>\n                        <div>Receive final confirmation with calendar links</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>!</div>\n                        <div>Please ensure your selected time is within the chosen location\'s operating hours and arrive 10 minutes early.</div>\n                    </li>\n                </ul>\n            </div>\n        </div>\n        \n        <!-- Footer -->\n        <div class=\'footer\'>\n            <p style=\'margin: 0; color: #6b7280; font-size: 14px;\'>We\'ll be in touch soon!</p>\n            <p class=\'company-name\'>The Kaycee & Associates Team</p>\n            \n            <div class=\'contact-info\'>\n                <strong>Need to reach us urgently?</strong><br>\n                ≡ƒô₧ +27 663566897<br>\n                ≡ƒôº Info@kayceea.co.za<br>\n                ≡ƒôì 69 Amanda Avenue, Glenanda, Johannesburg, 2190\n            </div>\n        </div>\n    </div>\n</body>\n</html>'),(3,'stephentmasimba@gmail.com','Angela D Too','We\'ve received your booking request - Kaycee & Associates','booking_received','sent',NULL,'2026-03-27 07:03:42','2026-03-27 07:03:39','unread','\n<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\'UTF-8\'>\n    <meta name=\'viewport\' content=\'width=device-width, initial-scale=1.0\'>\n    <title>Booking Received - Kaycee & Associates</title>\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap\');\n        \n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        \n        body {\n            font-family: \'Lato\', sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            color: #333;\n            padding: 20px;\n            min-height: 100vh;\n        }\n        \n        .email-container {\n            max-width: 650px;\n            margin: 0 auto;\n            background: white;\n            border-radius: 20px;\n            box-shadow: 0 20px 40px rgba(0,0,0,0.1);\n            overflow: hidden;\n        }\n        \n        .header {\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            color: white;\n            padding: 40px 30px;\n            text-align: center;\n            position: relative;\n            overflow: hidden;\n        }\n        \n        .header::before {\n            content: \'\';\n            position: absolute;\n            top: -50%;\n            left: -50%;\n            width: 200%;\n            height: 200%;\n            background: url(\'data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"none\" stroke=\"rgba(255,255,255,0.1)\" stroke-width=\"0.5\"/></svg>\');\n            animation: float 20s infinite linear;\n        }\n        \n        .header h1 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 32px;\n            font-weight: 700;\n            margin: 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .header p {\n            font-size: 16px;\n            opacity: 0.9;\n            margin: 8px 0 0 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .content {\n            padding: 40px 30px;\n        }\n        \n        .received-badge {\n            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);\n            color: white;\n            padding: 15px 25px;\n            border-radius: 50px;\n            font-weight: 700;\n            display: inline-flex;\n            align-items: center;\n            gap: 10px;\n            margin-bottom: 30px;\n            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);\n        }\n        \n        .received-icon {\n            width: 24px;\n            height: 24px;\n            background: white;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n        }\n        \n        .greeting {\n            font-size: 18px;\n            line-height: 1.6;\n            margin-bottom: 25px;\n            color: #4b5563;\n        }\n        \n        .greeting strong {\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .booking-summary {\n            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);\n            border: 1px solid #e2e8f0;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 25px 0;\n            position: relative;\n        }\n        \n        .booking-summary::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #6b46c1, #8e44ad, #ec4899);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .booking-summary h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e293b;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .details-grid {\n            display: grid;\n            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));\n            gap: 20px;\n            margin-top: 20px;\n        }\n        \n        .detail-item {\n            display: flex;\n            align-items: center;\n            gap: 12px;\n            padding: 15px;\n            background: white;\n            border-radius: 12px;\n            border: 1px solid #e5e7eb;\n        }\n        \n        .detail-icon {\n            width: 32px;\n            height: 32px;\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            border-radius: 8px;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n            color: white;\n            flex-shrink: 0;\n        }\n        \n        .detail-content {\n            flex: 1;\n        }\n        \n        .detail-label {\n            font-size: 12px;\n            color: #6b7280;\n            text-transform: uppercase;\n            letter-spacing: 0.5px;\n            margin-bottom: 4px;\n        }\n        \n        .detail-value {\n            font-size: 16px;\n            color: #1f2937;\n            font-weight: 600;\n        }\n        \n        .next-steps {\n            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);\n            border: 1px solid #93c5fd;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n        }\n        \n        .next-steps h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e40af;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .steps-list {\n            list-style: none;\n            padding: 0;\n        }\n        \n        .steps-list li {\n            padding: 12px 0;\n            border-bottom: 1px solid rgba(59, 130, 246, 0.2);\n            display: flex;\n            align-items: flex-start;\n            gap: 12px;\n            line-height: 1.6;\n        }\n        \n        .steps-list li:last-child {\n            border-bottom: none;\n        }\n        \n        .step-number {\n            width: 24px;\n            height: 24px;\n            background: #3b82f6;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            color: white;\n            font-size: 12px;\n            font-weight: bold;\n            flex-shrink: 0;\n            margin-top: 2px;\n        }\n        \n        .footer {\n            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);\n            padding: 30px;\n            text-align: center;\n            border-top: 1px solid #e5e7eb;\n        }\n        \n        .footer p {\n            margin: 5px 0;\n            font-size: 14px;\n            color: #6b7280;\n        }\n        \n        .footer .company-name {\n            font-family: \'Playfair Display\', serif;\n            font-size: 18px;\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .contact-info {\n            margin-top: 20px;\n            padding-top: 20px;\n            border-top: 1px solid #e5e7eb;\n            font-size: 13px;\n            color: #9ca3af;\n            line-height: 1.6;\n        }\n        \n        @keyframes float {\n            0%, 100% { transform: rotate(0deg); }\n            50% { transform: rotate(180deg); }\n        }\n        \n        @media (max-width: 600px) {\n            body {\n                padding: 10px;\n            }\n            \n            .email-container {\n                border-radius: 15px;\n            }\n            \n            .header, .content {\n                padding: 25px 20px;\n            }\n            \n            .details-grid {\n                grid-template-columns: 1fr;\n                gap: 15px;\n            }\n            \n            .detail-item {\n                padding: 12px;\n            }\n            \n            .booking-summary, .next-steps {\n                padding: 20px;\n            }\n        }\n    </style>\n</head>\n<body>\n    <div class=\'email-container\'>\n        <!-- Header -->\n        <div class=\'header\'>\n            <div style=\'text-align: center; margin-bottom: 20px;\'>\n                <img src=\'https://kayceea.co.za/assets/images/logo.png\' alt=\'Kaycee & Associates Logo\' style=\'width: 80px; height: auto; margin-bottom: 15px;\'>\n            </div>\n            <h1>Kaycee & Associates</h1>\n            <p>Professional Counseling & Psychological Services</p>\n        </div>\n        \n        <!-- Main Content -->\n        <div class=\'content\'>\n            <div class=\'received-badge\'>\n                <div class=\'received-icon\'>≡ƒôï</div>\n                Booking Request Received\n            </div>\n            \n            <p class=\'greeting\'>\n                Hi <strong>Angela D Too</strong>,<br><br>\n                Thank you for choosing <strong>Kaycee & Associates</strong>. We\'ve successfully received your booking request and our team is reviewing it.\n            </p>\n            \n            <!-- Booking Summary -->\n            <div class=\'booking-summary\'>\n                <h3>≡ƒôà Your Booking Request</h3>\n                \n                <div class=\'details-grid\'>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒùô</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Date</div>\n                            <div class=\'detail-value\'>2026-03-27</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒòÉ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Time</div>\n                            <div class=\'detail-value\'>14:00</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒæñ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Therapist</div>\n                            <div class=\'detail-value\'>Kgomotso Caroline Sebeela</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÄ»</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Service</div>\n                            <div class=\'detail-value\'>Individual Counselling</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒôì</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Location</div>\n                            <div class=\'detail-value\'></div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÆ░</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Price</div>\n                            <div class=\'detail-value\'>R 650.00</div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Next Steps -->\n            <div class=\'next-steps\'>\n                <h3>≡ƒöä What Happens Next?</h3>\n                \n                <ul class=\'steps-list\'>\n                    <li>\n                        <div class=\'step-number\'>1</div>\n                        <div>Our team reviews your booking request and availability</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>2</div>\n                        <div>You\'ll receive a confirmation email with payment details</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>3</div>\n                        <div>Complete payment to secure your appointment</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>4</div>\n                        <div>Receive final confirmation with calendar links</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>!</div>\n                        <div>Please ensure your selected time is within the chosen location\'s operating hours and arrive 10 minutes early.</div>\n                    </li>\n                </ul>\n            </div>\n        </div>\n        \n        <!-- Footer -->\n        <div class=\'footer\'>\n            <p style=\'margin: 0; color: #6b7280; font-size: 14px;\'>We\'ll be in touch soon!</p>\n            <p class=\'company-name\'>The Kaycee & Associates Team</p>\n            \n            <div class=\'contact-info\'>\n                <strong>Need to reach us urgently?</strong><br>\n                ≡ƒô₧ +27 663566897<br>\n                ≡ƒôº Info@kayceea.co.za<br>\n                ≡ƒôì 69 Amanda Avenue, Glenanda, Johannesburg, 2190\n            </div>\n        </div>\n    </div>\n</body>\n</html>'),(4,'test@example.com','Test Client','We\'ve received your booking request - Kaycee & Associates','booking_received','sent',NULL,'2026-03-27 07:12:45','2026-03-27 07:12:43','unread','\n<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\'UTF-8\'>\n    <meta name=\'viewport\' content=\'width=device-width, initial-scale=1.0\'>\n    <title>Booking Received - Kaycee & Associates</title>\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap\');\n        \n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        \n        body {\n            font-family: \'Lato\', sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            color: #333;\n            padding: 20px;\n            min-height: 100vh;\n        }\n        \n        .email-container {\n            max-width: 650px;\n            margin: 0 auto;\n            background: white;\n            border-radius: 20px;\n            box-shadow: 0 20px 40px rgba(0,0,0,0.1);\n            overflow: hidden;\n        }\n        \n        .header {\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            color: white;\n            padding: 40px 30px;\n            text-align: center;\n            position: relative;\n            overflow: hidden;\n        }\n        \n        .header::before {\n            content: \'\';\n            position: absolute;\n            top: -50%;\n            left: -50%;\n            width: 200%;\n            height: 200%;\n            background: url(\'data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"none\" stroke=\"rgba(255,255,255,0.1)\" stroke-width=\"0.5\"/></svg>\');\n            animation: float 20s infinite linear;\n        }\n        \n        .header h1 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 32px;\n            font-weight: 700;\n            margin: 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .header p {\n            font-size: 16px;\n            opacity: 0.9;\n            margin: 8px 0 0 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .content {\n            padding: 40px 30px;\n        }\n        \n        .received-badge {\n            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);\n            color: white;\n            padding: 15px 25px;\n            border-radius: 50px;\n            font-weight: 700;\n            display: inline-flex;\n            align-items: center;\n            gap: 10px;\n            margin-bottom: 30px;\n            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);\n        }\n        \n        .received-icon {\n            width: 24px;\n            height: 24px;\n            background: white;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n        }\n        \n        .greeting {\n            font-size: 18px;\n            line-height: 1.6;\n            margin-bottom: 25px;\n            color: #4b5563;\n        }\n        \n        .greeting strong {\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .booking-summary {\n            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);\n            border: 1px solid #e2e8f0;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 25px 0;\n            position: relative;\n        }\n        \n        .booking-summary::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #6b46c1, #8e44ad, #ec4899);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .booking-summary h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e293b;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .details-grid {\n            display: grid;\n            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));\n            gap: 20px;\n            margin-top: 20px;\n        }\n        \n        .detail-item {\n            display: flex;\n            align-items: center;\n            gap: 12px;\n            padding: 15px;\n            background: white;\n            border-radius: 12px;\n            border: 1px solid #e5e7eb;\n        }\n        \n        .detail-icon {\n            width: 32px;\n            height: 32px;\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            border-radius: 8px;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n            color: white;\n            flex-shrink: 0;\n        }\n        \n        .detail-content {\n            flex: 1;\n        }\n        \n        .detail-label {\n            font-size: 12px;\n            color: #6b7280;\n            text-transform: uppercase;\n            letter-spacing: 0.5px;\n            margin-bottom: 4px;\n        }\n        \n        .detail-value {\n            font-size: 16px;\n            color: #1f2937;\n            font-weight: 600;\n        }\n        \n        .next-steps {\n            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);\n            border: 1px solid #93c5fd;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n        }\n        \n        .next-steps h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e40af;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .steps-list {\n            list-style: none;\n            padding: 0;\n        }\n        \n        .steps-list li {\n            padding: 12px 0;\n            border-bottom: 1px solid rgba(59, 130, 246, 0.2);\n            display: flex;\n            align-items: flex-start;\n            gap: 12px;\n            line-height: 1.6;\n        }\n        \n        .steps-list li:last-child {\n            border-bottom: none;\n        }\n        \n        .step-number {\n            width: 24px;\n            height: 24px;\n            background: #3b82f6;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            color: white;\n            font-size: 12px;\n            font-weight: bold;\n            flex-shrink: 0;\n            margin-top: 2px;\n        }\n        \n        .footer {\n            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);\n            padding: 30px;\n            text-align: center;\n            border-top: 1px solid #e5e7eb;\n        }\n        \n        .footer p {\n            margin: 5px 0;\n            font-size: 14px;\n            color: #6b7280;\n        }\n        \n        .footer .company-name {\n            font-family: \'Playfair Display\', serif;\n            font-size: 18px;\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .contact-info {\n            margin-top: 20px;\n            padding-top: 20px;\n            border-top: 1px solid #e5e7eb;\n            font-size: 13px;\n            color: #9ca3af;\n            line-height: 1.6;\n        }\n        \n        @keyframes float {\n            0%, 100% { transform: rotate(0deg); }\n            50% { transform: rotate(180deg); }\n        }\n        \n        @media (max-width: 600px) {\n            body {\n                padding: 10px;\n            }\n            \n            .email-container {\n                border-radius: 15px;\n            }\n            \n            .header, .content {\n                padding: 25px 20px;\n            }\n            \n            .details-grid {\n                grid-template-columns: 1fr;\n                gap: 15px;\n            }\n            \n            .detail-item {\n                padding: 12px;\n            }\n            \n            .booking-summary, .next-steps {\n                padding: 20px;\n            }\n        }\n    </style>\n</head>\n<body>\n    <div class=\'email-container\'>\n        <!-- Header -->\n        <div class=\'header\'>\n            <div style=\'text-align: center; margin-bottom: 20px;\'>\n                <img src=\'https://kayceea.co.za/assets/images/logo.png\' alt=\'Kaycee & Associates Logo\' style=\'width: 80px; height: auto; margin-bottom: 15px;\'>\n            </div>\n            <h1>Kaycee & Associates</h1>\n            <p>Professional Counseling & Psychological Services</p>\n        </div>\n        \n        <!-- Main Content -->\n        <div class=\'content\'>\n            <div class=\'received-badge\'>\n                <div class=\'received-icon\'>≡ƒôï</div>\n                Booking Request Received\n            </div>\n            \n            <p class=\'greeting\'>\n                Hi <strong>Test Client</strong>,<br><br>\n                Thank you for choosing <strong>Kaycee & Associates</strong>. We\'ve successfully received your booking request and our team is reviewing it.\n            </p>\n            \n            <!-- Booking Summary -->\n            <div class=\'booking-summary\'>\n                <h3>≡ƒôà Your Booking Request</h3>\n                \n                <div class=\'details-grid\'>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒùô</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Date</div>\n                            <div class=\'detail-value\'>2026-03-30</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒòÉ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Time</div>\n                            <div class=\'detail-value\'>10:00</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒæñ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Therapist</div>\n                            <div class=\'detail-value\'>Kgomotso Caroline Sebeela</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÄ»</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Service</div>\n                            <div class=\'detail-value\'>Individual Counselling</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒôì</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Location</div>\n                            <div class=\'detail-value\'>Online Session</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÆ░</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Price</div>\n                            <div class=\'detail-value\'>R 500.00</div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Next Steps -->\n            <div class=\'next-steps\'>\n                <h3>≡ƒöä What Happens Next?</h3>\n                \n                <ul class=\'steps-list\'>\n                    <li>\n                        <div class=\'step-number\'>1</div>\n                        <div>Our team reviews your booking request and availability</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>2</div>\n                        <div>You\'ll receive a confirmation email with payment details</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>3</div>\n                        <div>Complete payment to secure your appointment</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>4</div>\n                        <div>Receive final confirmation with calendar links</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>!</div>\n                        <div>Please ensure your selected time is within the chosen location\'s operating hours and arrive 10 minutes early.</div>\n                    </li>\n                </ul>\n            </div>\n        </div>\n        \n        <!-- Footer -->\n        <div class=\'footer\'>\n            <p style=\'margin: 0; color: #6b7280; font-size: 14px;\'>We\'ll be in touch soon!</p>\n            <p class=\'company-name\'>The Kaycee & Associates Team</p>\n            \n            <div class=\'contact-info\'>\n                <strong>Need to reach us urgently?</strong><br>\n                ≡ƒô₧ +27 663566897<br>\n                ≡ƒôº Info@kayceea.co.za<br>\n                ≡ƒôì 69 Amanda Avenue, Glenanda, Johannesburg, 2190\n            </div>\n        </div>\n    </div>\n</body>\n</html>'),(5,'stephentmasimba@gmail.com','Angela D Too','We\'ve received your booking request - Kaycee & Associates','booking_received','sent',NULL,'2026-03-27 07:14:37','2026-03-27 07:14:36','unread','\n<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\'UTF-8\'>\n    <meta name=\'viewport\' content=\'width=device-width, initial-scale=1.0\'>\n    <title>Booking Received - Kaycee & Associates</title>\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap\');\n        \n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        \n        body {\n            font-family: \'Lato\', sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            color: #333;\n            padding: 20px;\n            min-height: 100vh;\n        }\n        \n        .email-container {\n            max-width: 650px;\n            margin: 0 auto;\n            background: white;\n            border-radius: 20px;\n            box-shadow: 0 20px 40px rgba(0,0,0,0.1);\n            overflow: hidden;\n        }\n        \n        .header {\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            color: white;\n            padding: 40px 30px;\n            text-align: center;\n            position: relative;\n            overflow: hidden;\n        }\n        \n        .header::before {\n            content: \'\';\n            position: absolute;\n            top: -50%;\n            left: -50%;\n            width: 200%;\n            height: 200%;\n            background: url(\'data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"none\" stroke=\"rgba(255,255,255,0.1)\" stroke-width=\"0.5\"/></svg>\');\n            animation: float 20s infinite linear;\n        }\n        \n        .header h1 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 32px;\n            font-weight: 700;\n            margin: 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .header p {\n            font-size: 16px;\n            opacity: 0.9;\n            margin: 8px 0 0 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .content {\n            padding: 40px 30px;\n        }\n        \n        .received-badge {\n            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);\n            color: white;\n            padding: 15px 25px;\n            border-radius: 50px;\n            font-weight: 700;\n            display: inline-flex;\n            align-items: center;\n            gap: 10px;\n            margin-bottom: 30px;\n            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);\n        }\n        \n        .received-icon {\n            width: 24px;\n            height: 24px;\n            background: white;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n        }\n        \n        .greeting {\n            font-size: 18px;\n            line-height: 1.6;\n            margin-bottom: 25px;\n            color: #4b5563;\n        }\n        \n        .greeting strong {\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .booking-summary {\n            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);\n            border: 1px solid #e2e8f0;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 25px 0;\n            position: relative;\n        }\n        \n        .booking-summary::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #6b46c1, #8e44ad, #ec4899);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .booking-summary h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e293b;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .details-grid {\n            display: grid;\n            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));\n            gap: 20px;\n            margin-top: 20px;\n        }\n        \n        .detail-item {\n            display: flex;\n            align-items: center;\n            gap: 12px;\n            padding: 15px;\n            background: white;\n            border-radius: 12px;\n            border: 1px solid #e5e7eb;\n        }\n        \n        .detail-icon {\n            width: 32px;\n            height: 32px;\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            border-radius: 8px;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n            color: white;\n            flex-shrink: 0;\n        }\n        \n        .detail-content {\n            flex: 1;\n        }\n        \n        .detail-label {\n            font-size: 12px;\n            color: #6b7280;\n            text-transform: uppercase;\n            letter-spacing: 0.5px;\n            margin-bottom: 4px;\n        }\n        \n        .detail-value {\n            font-size: 16px;\n            color: #1f2937;\n            font-weight: 600;\n        }\n        \n        .next-steps {\n            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);\n            border: 1px solid #93c5fd;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n        }\n        \n        .next-steps h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e40af;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .steps-list {\n            list-style: none;\n            padding: 0;\n        }\n        \n        .steps-list li {\n            padding: 12px 0;\n            border-bottom: 1px solid rgba(59, 130, 246, 0.2);\n            display: flex;\n            align-items: flex-start;\n            gap: 12px;\n            line-height: 1.6;\n        }\n        \n        .steps-list li:last-child {\n            border-bottom: none;\n        }\n        \n        .step-number {\n            width: 24px;\n            height: 24px;\n            background: #3b82f6;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            color: white;\n            font-size: 12px;\n            font-weight: bold;\n            flex-shrink: 0;\n            margin-top: 2px;\n        }\n        \n        .footer {\n            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);\n            padding: 30px;\n            text-align: center;\n            border-top: 1px solid #e5e7eb;\n        }\n        \n        .footer p {\n            margin: 5px 0;\n            font-size: 14px;\n            color: #6b7280;\n        }\n        \n        .footer .company-name {\n            font-family: \'Playfair Display\', serif;\n            font-size: 18px;\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .contact-info {\n            margin-top: 20px;\n            padding-top: 20px;\n            border-top: 1px solid #e5e7eb;\n            font-size: 13px;\n            color: #9ca3af;\n            line-height: 1.6;\n        }\n        \n        @keyframes float {\n            0%, 100% { transform: rotate(0deg); }\n            50% { transform: rotate(180deg); }\n        }\n        \n        @media (max-width: 600px) {\n            body {\n                padding: 10px;\n            }\n            \n            .email-container {\n                border-radius: 15px;\n            }\n            \n            .header, .content {\n                padding: 25px 20px;\n            }\n            \n            .details-grid {\n                grid-template-columns: 1fr;\n                gap: 15px;\n            }\n            \n            .detail-item {\n                padding: 12px;\n            }\n            \n            .booking-summary, .next-steps {\n                padding: 20px;\n            }\n        }\n    </style>\n</head>\n<body>\n    <div class=\'email-container\'>\n        <!-- Header -->\n        <div class=\'header\'>\n            <div style=\'text-align: center; margin-bottom: 20px;\'>\n                <img src=\'https://kayceea.co.za/assets/images/logo.png\' alt=\'Kaycee & Associates Logo\' style=\'width: 80px; height: auto; margin-bottom: 15px;\'>\n            </div>\n            <h1>Kaycee & Associates</h1>\n            <p>Professional Counseling & Psychological Services</p>\n        </div>\n        \n        <!-- Main Content -->\n        <div class=\'content\'>\n            <div class=\'received-badge\'>\n                <div class=\'received-icon\'>≡ƒôï</div>\n                Booking Request Received\n            </div>\n            \n            <p class=\'greeting\'>\n                Hi <strong>Angela D Too</strong>,<br><br>\n                Thank you for choosing <strong>Kaycee & Associates</strong>. We\'ve successfully received your booking request and our team is reviewing it.\n            </p>\n            \n            <!-- Booking Summary -->\n            <div class=\'booking-summary\'>\n                <h3>≡ƒôà Your Booking Request</h3>\n                \n                <div class=\'details-grid\'>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒùô</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Date</div>\n                            <div class=\'detail-value\'>2026-03-27</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒòÉ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Time</div>\n                            <div class=\'detail-value\'>13:30</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒæñ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Therapist</div>\n                            <div class=\'detail-value\'>Kgomotso Caroline Sebeela</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÄ»</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Service</div>\n                            <div class=\'detail-value\'>Individual Counselling</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒôì</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Location</div>\n                            <div class=\'detail-value\'>In-Person | Rivonia Therapy Centre</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÆ░</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Price</div>\n                            <div class=\'detail-value\'>R 650.00</div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Next Steps -->\n            <div class=\'next-steps\'>\n                <h3>≡ƒöä What Happens Next?</h3>\n                \n                <ul class=\'steps-list\'>\n                    <li>\n                        <div class=\'step-number\'>1</div>\n                        <div>Our team reviews your booking request and availability</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>2</div>\n                        <div>You\'ll receive a confirmation email with payment details</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>3</div>\n                        <div>Complete payment to secure your appointment</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>4</div>\n                        <div>Receive final confirmation with calendar links</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>!</div>\n                        <div>Please ensure your selected time is within the chosen location\'s operating hours and arrive 10 minutes early.</div>\n                    </li>\n                </ul>\n            </div>\n        </div>\n        \n        <!-- Footer -->\n        <div class=\'footer\'>\n            <p style=\'margin: 0; color: #6b7280; font-size: 14px;\'>We\'ll be in touch soon!</p>\n            <p class=\'company-name\'>The Kaycee & Associates Team</p>\n            \n            <div class=\'contact-info\'>\n                <strong>Need to reach us urgently?</strong><br>\n                ≡ƒô₧ +27 663566897<br>\n                ≡ƒôº Info@kayceea.co.za<br>\n                ≡ƒôì 69 Amanda Avenue, Glenanda, Johannesburg, 2190\n            </div>\n        </div>\n    </div>\n</body>\n</html>'),(6,'stephentmasimba@gmail.com','Angela D Too','Booking Confirmed: You\'re booked! Next steps for your session with Kgomotso Caroline Sebeela','booking_related','sent',NULL,'2026-03-27 07:21:58','2026-03-27 07:21:56','unread','\n<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\'UTF-8\'>\n    <meta name=\'viewport\' content=\'width=device-width, initial-scale=1.0\'>\n    <title>Booking Confirmation - Kaycee & Associates</title>\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap\');\n        \n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        \n        body {\n            font-family: \'Lato\', sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            color: #333;\n            padding: 20px;\n            min-height: 100vh;\n        }\n        \n        .email-container {\n            max-width: 650px;\n            margin: 0 auto;\n            background: white;\n            border-radius: 20px;\n            box-shadow: 0 20px 40px rgba(0,0,0,0.1);\n            overflow: hidden;\n        }\n        \n        .header {\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            color: white;\n            padding: 40px 30px;\n            text-align: center;\n            position: relative;\n            overflow: hidden;\n        }\n        \n        .header::before {\n            content: \'\';\n            position: absolute;\n            top: -50%;\n            left: -50%;\n            width: 200%;\n            height: 200%;\n            background: url(\'data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"none\" stroke=\"rgba(255,255,255,0.1)\" stroke-width=\"0.5\"/></svg>\');\n            animation: float 20s infinite linear;\n        }\n        \n        .header h1 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 32px;\n            font-weight: 700;\n            margin: 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .header p {\n            font-size: 16px;\n            opacity: 0.9;\n            margin: 8px 0 0 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .content {\n            padding: 40px 30px;\n        }\n        \n        .success-badge {\n            background: linear-gradient(135deg, #10b981 0%, #059669 100%);\n            color: white;\n            padding: 15px 25px;\n            border-radius: 50px;\n            font-weight: 700;\n            display: inline-flex;\n            align-items: center;\n            gap: 10px;\n            margin-bottom: 30px;\n            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);\n        }\n        \n        .success-icon {\n            width: 24px;\n            height: 24px;\n            background: white;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n        }\n        \n        .greeting {\n            font-size: 18px;\n            line-height: 1.6;\n            margin-bottom: 25px;\n            color: #4b5563;\n        }\n        \n        .greeting strong {\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .session-details {\n            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);\n            border: 1px solid #e2e8f0;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 25px 0;\n            position: relative;\n        }\n        \n        .session-details::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #6b46c1, #8e44ad, #ec4899);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .session-details h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e293b;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .details-grid {\n            display: grid;\n            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));\n            gap: 20px;\n            margin-top: 20px;\n        }\n        \n        .detail-item {\n            display: flex;\n            align-items: center;\n            gap: 12px;\n            padding: 15px;\n            background: white;\n            border-radius: 12px;\n            border: 1px solid #e5e7eb;\n            transition: all 0.3s ease;\n        }\n        \n        .detail-item:hover {\n            transform: translateY(-2px);\n            box-shadow: 0 4px 12px rgba(0,0,0,0.1);\n        }\n        \n        .detail-icon {\n            width: 32px;\n            height: 32px;\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            border-radius: 8px;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n            color: white;\n            flex-shrink: 0;\n        }\n        \n        .detail-content {\n            flex: 1;\n        }\n        \n        .detail-label {\n            font-size: 12px;\n            color: #6b7280;\n            text-transform: uppercase;\n            letter-spacing: 0.5px;\n            margin-bottom: 4px;\n        }\n        \n        .detail-value {\n            font-size: 16px;\n            color: #1f2937;\n            font-weight: 600;\n        }\n        \n        .calendar-section {\n            margin: 30px 0;\n            text-align: center;\n        }\n        \n        .payment-section {\n            background: linear-gradient(135deg, #fef3c7 0%, #fed7aa 100%);\n            border: 1px solid #fbbf24;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n            position: relative;\n        }\n        \n        .payment-section::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #f59e0b, #f97316, #dc2626);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .payment-section h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #92400e;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .payment-info {\n            background: white;\n            border-radius: 12px;\n            padding: 25px;\n            margin-top: 20px;\n            border: 1px solid #fde68a;\n        }\n        \n        .bank-details {\n            display: grid;\n            gap: 15px;\n        }\n        \n        .bank-row {\n            display: flex;\n            justify-content: space-between;\n            align-items: center;\n            padding: 12px 0;\n            border-bottom: 1px solid #f3f4f6;\n        }\n        \n        .bank-row:last-child {\n            border-bottom: none;\n        }\n        \n        .bank-label {\n            font-weight: 600;\n            color: #374151;\n            font-size: 14px;\n        }\n        \n        .bank-value {\n            font-weight: 700;\n            color: #1f2937;\n            font-size: 15px;\n        }\n        \n        .notes-section {\n            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);\n            border: 1px solid #93c5fd;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n        }\n        \n        .notes-section h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e40af;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .notes-list {\n            list-style: none;\n            padding: 0;\n        }\n        \n        .notes-list li {\n            padding: 12px 0;\n            border-bottom: 1px solid rgba(59, 130, 246, 0.2);\n            display: flex;\n            align-items: flex-start;\n            gap: 12px;\n            line-height: 1.6;\n        }\n        \n        .notes-list li:last-child {\n            border-bottom: none;\n        }\n        \n        .notes-icon {\n            width: 24px;\n            height: 24px;\n            background: #3b82f6;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            color: white;\n            font-size: 12px;\n            flex-shrink: 0;\n            margin-top: 2px;\n        }\n        \n        .footer {\n            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);\n            padding: 30px;\n            text-align: center;\n            border-top: 1px solid #e5e7eb;\n        }\n        \n        .footer p {\n            margin: 5px 0;\n            font-size: 14px;\n            color: #6b7280;\n        }\n        \n        .footer .company-name {\n            font-family: \'Playfair Display\', serif;\n            font-size: 18px;\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .contact-info {\n            margin-top: 20px;\n            padding-top: 20px;\n            border-top: 1px solid #e5e7eb;\n            font-size: 13px;\n            color: #9ca3af;\n            line-height: 1.6;\n        }\n        \n        @keyframes float {\n            0%, 100% { transform: rotate(0deg); }\n            50% { transform: rotate(180deg); }\n        }\n        \n        @media (max-width: 600px) {\n            body {\n                padding: 10px;\n            }\n            \n            .email-container {\n                border-radius: 15px;\n            }\n            \n            .header, .content {\n                padding: 25px 20px;\n            }\n            \n            .details-grid {\n                grid-template-columns: 1fr;\n                gap: 15px;\n            }\n            \n            .detail-item {\n                padding: 12px;\n            }\n            \n            .payment-section, .notes-section, .session-details {\n                padding: 20px;\n            }\n        }\n    </style>\n</head>\n<body>\n    <div class=\'email-container\'>\n        <!-- Header -->\n        <div class=\'header\'>\n            <div style=\'text-align: center; margin-bottom: 20px;\'>\n                <img src=\'https://kayceea.co.za/assets/images/logo.png\' alt=\'Kaycee & Associates Logo\' style=\'width: 80px; height: auto; margin-bottom: 15px;\'>\n            </div>\n            <h1>Kaycee & Associates</h1>\n            <p>Professional Counseling & Psychological Services</p>\n        </div>\n        \n        <!-- Main Content -->\n        <div class=\'content\'>\n            <div class=\'success-badge\'>\n                <div class=\'success-icon\'>Γ£ô</div>\n                You\'re Booked!\n            </div>\n            \n            <p class=\'greeting\'>\n                Hi <strong>Angela D Too</strong>,<br><br>\n                Thank you for booking with <strong>Kaycee & Associates</strong>. We\'re looking forward to supporting you on your wellness journey.\n            </p>\n            \n            <!-- Session Details -->\n            <div class=\'session-details\'>\n                <h3>≡ƒôà Your Session Details</h3>\n                \n                <div class=\'details-grid\'>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒùô</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Date</div>\n                            <div class=\'detail-value\'>2026-03-27</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒòÉ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Time</div>\n                            <div class=\'detail-value\'>13:30:00</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒæñ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Therapist</div>\n                            <div class=\'detail-value\'>Kgomotso Caroline Sebeela</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÆ░</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Price</div>\n                            <div class=\'detail-value\'>R500.00</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÄ»</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Service</div>\n                            <div class=\'detail-value\'>Individual Counselling</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒôì</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Location</div>\n                            <div class=\'detail-value\'>69 Amanda Avenue, Glenanda, Johannesburg, 2190</div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Calendar Integration -->\n            <div class=\'calendar-section\'>\n                <div style=\"margin-top: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 8px;\"><h4 style=\"margin: 0 0 10px 0; color: #333;\">Add to Your Calendar:</h4><div style=\"display: flex; gap: 10px; flex-wrap: wrap;\"><a href=\"https://calendar.google.com/calendar/render?action=TEMPLATE&text=Individual+Counselling+-+Kgomotso+Caroline+Sebeela&dates=20260327T133000/20260327T143000&details=Individual+Counselling+session+with+Kgomotso+Caroline+Sebeela%0A%0AClient%3A+Angela+D+Too%0AEmail%3A+%0APhone%3A+%0A%0ANotes%3A+&location=69+Amanda+Avenue%2C+Glenanda%2C+Johannesburg%2C+2190\" target=\"_blank\" style=\"display: inline-flex; align-items: center; gap: 5px; padding: 8px 16px; background-color: #4285f4; color: white; text-decoration: none; border-radius: 4px; font-size: 14px;\">≡ƒôà Google Calendar</a><a href=\"https://outlook.live.com/calendar/0/dee/?subject=Individual+Counselling+-+Kgomotso+Caroline+Sebeela&startdt=2026-03-27T13:30:00&enddt=2026-03-27T14:30:00&body=Individual+Counselling+session+with+Kgomotso+Caroline+Sebeela%0A%0AClient%3A+Angela+D+Too%0AEmail%3A+%0APhone%3A+%0A%0ANotes%3A+&location=69+Amanda+Avenue%2C+Glenanda%2C+Johannesburg%2C+2190\" target=\"_blank\" style=\"display: inline-flex; align-items: center; gap: 5px; padding: 8px 16px; background-color: #0078d4; color: white; text-decoration: none; border-radius: 4px; font-size: 14px;\">≡ƒôà Outlook Calendar</a></div></div>\n            </div>\n            \n            <!-- Payment Section -->\n            <div class=\'payment-section\'>\n                <h3>≡ƒöÆ Confirm Your Booking</h3>\n                \n                <p style=\'margin-bottom: 20px; line-height: 1.6; color: #92400e;\'>\n                    Your spot is temporarily reserved. To secure your appointment, please complete payment using the details below and reply with your Proof of Payment.\n                </p>\n                \n                <div class=\'payment-info\'>\n                    <h4 style=\'margin: 0 0 15px 0; color: #1f2937; font-size: 18px; font-family: \"Playfair Display\", serif;\'>First National Bank</h4>\n                    \n                    <div class=\'bank-details\'>\n                        <div class=\'bank-row\'>\n                            <span class=\'bank-label\'>Account Name:</span>\n                            <span class=\'bank-value\'>Kaycee & Associates</span>\n                        </div>\n                        <div class=\'bank-row\'>\n                            <span class=\'bank-label\'>Account Number:</span>\n                            <span class=\'bank-value\'>6277 5377 221</span>\n                        </div>\n                        <div class=\'bank-row\'>\n                            <span class=\'bank-label\'>Branch Code:</span>\n                            <span class=\'bank-value\'>250655</span>\n                        </div>\n                        <div class=\'bank-row\'>\n                            <span class=\'bank-label\'>Reference:</span>\n                            <span class=\'bank-value\'>Angela D Too</span>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Important Notes -->\n            <div class=\'notes-section\'>\n                <h3>≡ƒôï Important Information</h3>\n                \n                <ul class=\'notes-list\'>\n                    <li>\n                        <div class=\'notes-icon\'>≡ƒòÉ</div>\n                        <div>We operate MondayΓÇôSaturday by appointment only</div>\n                    </li>\n                    <li>\n                        <div class=\'notes-icon\'>ΓÅ░</div>\n                        <div>Please cancel at least 24 hours in advance to avoid fees</div>\n                    </li>\n                    <li>\n                        <div class=\'notes-icon\'>≡ƒÆ╕</div>\n                        <div>Late cancellations incur a 40% fee</div>\n                    </li>\n                    <li>\n                        <div class=\'notes-icon\'>Γ¥î</div>\n                        <div>Missed appointments are charged in full</div>\n                    </li>\n                </ul>\n            </div>\n        </div>\n        \n        <!-- Footer -->\n        <div class=\'footer\'>\n            <p style=\'margin: 0; color: #6b7280; font-size: 14px;\'>We look forward to seeing you,</p>\n            <p class=\'company-name\'>The Kaycee & Associates Team</p>\n            \n            <div class=\'contact-info\'>\n                <strong>Contact Information:</strong><br>\n                ≡ƒô₧ +27 663566897<br>\n                ≡ƒôº Info@kayceea.co.za<br>\n                ≡ƒôì 69 Amanda Avenue, Glenanda, Johannesburg, 2190\n            </div>\n        </div>\n    </div>\n</body>\n</html>'),(7,'stephentmasimba@gmail.com','Stephen Masimba','We\'ve received your booking request - Kaycee & Associates','booking_received','sent',NULL,'2026-03-27 08:38:05','2026-03-27 08:38:03','unread','\n<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\'UTF-8\'>\n    <meta name=\'viewport\' content=\'width=device-width, initial-scale=1.0\'>\n    <title>Booking Received - Kaycee & Associates</title>\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap\');\n        \n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        \n        body {\n            font-family: \'Lato\', sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            color: #333;\n            padding: 20px;\n            min-height: 100vh;\n        }\n        \n        .email-container {\n            max-width: 650px;\n            margin: 0 auto;\n            background: white;\n            border-radius: 20px;\n            box-shadow: 0 20px 40px rgba(0,0,0,0.1);\n            overflow: hidden;\n        }\n        \n        .header {\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            color: white;\n            padding: 40px 30px;\n            text-align: center;\n            position: relative;\n            overflow: hidden;\n        }\n        \n        .header::before {\n            content: \'\';\n            position: absolute;\n            top: -50%;\n            left: -50%;\n            width: 200%;\n            height: 200%;\n            background: url(\'data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"none\" stroke=\"rgba(255,255,255,0.1)\" stroke-width=\"0.5\"/></svg>\');\n            animation: float 20s infinite linear;\n        }\n        \n        .header h1 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 32px;\n            font-weight: 700;\n            margin: 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .header p {\n            font-size: 16px;\n            opacity: 0.9;\n            margin: 8px 0 0 0;\n            position: relative;\n            z-index: 1;\n        }\n        \n        .content {\n            padding: 40px 30px;\n        }\n        \n        .received-badge {\n            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);\n            color: white;\n            padding: 15px 25px;\n            border-radius: 50px;\n            font-weight: 700;\n            display: inline-flex;\n            align-items: center;\n            gap: 10px;\n            margin-bottom: 30px;\n            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);\n        }\n        \n        .received-icon {\n            width: 24px;\n            height: 24px;\n            background: white;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n        }\n        \n        .greeting {\n            font-size: 18px;\n            line-height: 1.6;\n            margin-bottom: 25px;\n            color: #4b5563;\n        }\n        \n        .greeting strong {\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .booking-summary {\n            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);\n            border: 1px solid #e2e8f0;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 25px 0;\n            position: relative;\n        }\n        \n        .booking-summary::before {\n            content: \'\';\n            position: absolute;\n            top: 0;\n            left: 0;\n            right: 0;\n            height: 4px;\n            background: linear-gradient(90deg, #6b46c1, #8e44ad, #ec4899);\n            border-radius: 16px 16px 0 0;\n        }\n        \n        .booking-summary h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e293b;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .details-grid {\n            display: grid;\n            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));\n            gap: 20px;\n            margin-top: 20px;\n        }\n        \n        .detail-item {\n            display: flex;\n            align-items: center;\n            gap: 12px;\n            padding: 15px;\n            background: white;\n            border-radius: 12px;\n            border: 1px solid #e5e7eb;\n        }\n        \n        .detail-icon {\n            width: 32px;\n            height: 32px;\n            background: linear-gradient(135deg, #6b46c1 0%, #8e44ad 100%);\n            border-radius: 8px;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-size: 14px;\n            color: white;\n            flex-shrink: 0;\n        }\n        \n        .detail-content {\n            flex: 1;\n        }\n        \n        .detail-label {\n            font-size: 12px;\n            color: #6b7280;\n            text-transform: uppercase;\n            letter-spacing: 0.5px;\n            margin-bottom: 4px;\n        }\n        \n        .detail-value {\n            font-size: 16px;\n            color: #1f2937;\n            font-weight: 600;\n        }\n        \n        .next-steps {\n            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);\n            border: 1px solid #93c5fd;\n            border-radius: 16px;\n            padding: 30px;\n            margin: 30px 0;\n        }\n        \n        .next-steps h3 {\n            font-family: \'Playfair Display\', serif;\n            font-size: 22px;\n            color: #1e40af;\n            margin: 0 0 20px 0;\n            display: flex;\n            align-items: center;\n            gap: 10px;\n        }\n        \n        .steps-list {\n            list-style: none;\n            padding: 0;\n        }\n        \n        .steps-list li {\n            padding: 12px 0;\n            border-bottom: 1px solid rgba(59, 130, 246, 0.2);\n            display: flex;\n            align-items: flex-start;\n            gap: 12px;\n            line-height: 1.6;\n        }\n        \n        .steps-list li:last-child {\n            border-bottom: none;\n        }\n        \n        .step-number {\n            width: 24px;\n            height: 24px;\n            background: #3b82f6;\n            border-radius: 50%;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            color: white;\n            font-size: 12px;\n            font-weight: bold;\n            flex-shrink: 0;\n            margin-top: 2px;\n        }\n        \n        .footer {\n            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);\n            padding: 30px;\n            text-align: center;\n            border-top: 1px solid #e5e7eb;\n        }\n        \n        .footer p {\n            margin: 5px 0;\n            font-size: 14px;\n            color: #6b7280;\n        }\n        \n        .footer .company-name {\n            font-family: \'Playfair Display\', serif;\n            font-size: 18px;\n            color: #6b46c1;\n            font-weight: 700;\n        }\n        \n        .contact-info {\n            margin-top: 20px;\n            padding-top: 20px;\n            border-top: 1px solid #e5e7eb;\n            font-size: 13px;\n            color: #9ca3af;\n            line-height: 1.6;\n        }\n        \n        @keyframes float {\n            0%, 100% { transform: rotate(0deg); }\n            50% { transform: rotate(180deg); }\n        }\n        \n        @media (max-width: 600px) {\n            body {\n                padding: 10px;\n            }\n            \n            .email-container {\n                border-radius: 15px;\n            }\n            \n            .header, .content {\n                padding: 25px 20px;\n            }\n            \n            .details-grid {\n                grid-template-columns: 1fr;\n                gap: 15px;\n            }\n            \n            .detail-item {\n                padding: 12px;\n            }\n            \n            .booking-summary, .next-steps {\n                padding: 20px;\n            }\n        }\n    </style>\n</head>\n<body>\n    <div class=\'email-container\'>\n        <!-- Header -->\n        <div class=\'header\'>\n            <div style=\'text-align: center; margin-bottom: 20px;\'>\n                <img src=\'https://kayceea.co.za/assets/images/logo.png\' alt=\'Kaycee & Associates Logo\' style=\'width: 80px; height: auto; margin-bottom: 15px;\'>\n            </div>\n            <h1>Kaycee & Associates</h1>\n            <p>Professional Counseling & Psychological Services</p>\n        </div>\n        \n        <!-- Main Content -->\n        <div class=\'content\'>\n            <div class=\'received-badge\'>\n                <div class=\'received-icon\'>≡ƒôï</div>\n                Booking Request Received\n            </div>\n            \n            <p class=\'greeting\'>\n                Hi <strong>Stephen Masimba</strong>,<br><br>\n                Thank you for choosing <strong>Kaycee & Associates</strong>. We\'ve successfully received your booking request and our team is reviewing it.\n            </p>\n            \n            <!-- Booking Summary -->\n            <div class=\'booking-summary\'>\n                <h3>≡ƒôà Your Booking Request</h3>\n                \n                <div class=\'details-grid\'>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒùô</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Date</div>\n                            <div class=\'detail-value\'>2026-03-31</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒòÉ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Requested Time</div>\n                            <div class=\'detail-value\'>08:30</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒæñ</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Therapist</div>\n                            <div class=\'detail-value\'>Kgomotso Caroline Sebeela</div>\n                        </div>\n                    </div>\n                    \n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÄ»</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Service</div>\n                            <div class=\'detail-value\'>Individual Counselling</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒôì</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Location</div>\n                            <div class=\'detail-value\'>Wellness Center</div>\n                        </div>\n                    </div>\n                    <div class=\'detail-item\'>\n                        <div class=\'detail-icon\'>≡ƒÆ░</div>\n                        <div class=\'detail-content\'>\n                            <div class=\'detail-label\'>Price</div>\n                            <div class=\'detail-value\'>R 500.00</div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n            \n            <!-- Next Steps -->\n            <div class=\'next-steps\'>\n                <h3>≡ƒöä What Happens Next?</h3>\n                \n                <ul class=\'steps-list\'>\n                    <li>\n                        <div class=\'step-number\'>1</div>\n                        <div>Our team reviews your booking request and availability</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>2</div>\n                        <div>You\'ll receive a confirmation email with payment details</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>3</div>\n                        <div>Complete payment to secure your appointment</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>4</div>\n                        <div>Receive final confirmation with calendar links</div>\n                    </li>\n                    <li>\n                        <div class=\'step-number\'>!</div>\n                        <div>Please ensure your selected time is within the chosen location\'s operating hours and arrive 10 minutes early.</div>\n                    </li>\n                </ul>\n            </div>\n        </div>\n        \n        <!-- Footer -->\n        <div class=\'footer\'>\n            <p style=\'margin: 0; color: #6b7280; font-size: 14px;\'>We\'ll be in touch soon!</p>\n            <p class=\'company-name\'>The Kaycee & Associates Team</p>\n            \n            <div class=\'contact-info\'>\n                <strong>Need to reach us urgently?</strong><br>\n                ≡ƒô₧ +27 663566897<br>\n                ≡ƒôº Info@kayceea.co.za<br>\n                ≡ƒôì 69 Amanda Avenue, Glenanda, Johannesburg, 2190\n            </div>\n        </div>\n    </div>\n</body>\n</html>');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_settings`
--

DROP TABLE IF EXISTS `email_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(191) NOT NULL,
  `setting_value` text,
  `setting_type` varchar(50) DEFAULT 'text',
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_settings`
--

LOCK TABLES `email_settings` WRITE;
/*!40000 ALTER TABLE `email_settings` DISABLE KEYS */;
INSERT INTO `email_settings` VALUES (1,'smtp_host','mail.kayceea.co.za','text','SMTP server hostname (e.g., smtp.gmail.com)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(2,'smtp_port','465','number','SMTP server port (usually 587 for TLS, 465 for SSL)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(3,'smtp_username','booking@kayceea.co.za','text','SMTP username (usually your email address)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(4,'smtp_password','[0d5YGGZ@z+r=&}q','password','SMTP password or app password','2026-03-24 11:55:40','2026-03-24 11:55:40'),(5,'from_email','booking@kayceea.co.za','text','Default sender email address','2026-03-24 11:55:40','2026-03-24 11:55:40'),(6,'from_name','Kaycee & Associates','text','Default sender name','2026-03-24 11:55:40','2026-03-24 11:55:40'),(7,'imap_host','mail.kayceea.co.za','text','IMAP server hostname (e.g., imap.gmail.com)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(8,'imap_port','993','number','IMAP server port (usually 993)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(9,'imap_username','booking@kayceea.co.za','text','IMAP username (usually your email address)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(10,'imap_password','[0d5YGGZ@z+r=&}q','password','IMAP password or app password','2026-03-24 11:55:40','2026-03-24 11:55:40'),(11,'imap_flags','/imap/ssl/novalidate-cert','text','IMAP connection flags (e.g., /imap/ssl/novalidate-cert)','2026-03-24 11:55:40','2026-03-24 11:55:40'),(12,'company_name','Kaycee & Associates','text','Your company name for email templates','2026-03-24 11:55:40','2026-03-24 11:55:40'),(13,'bank_name','First National Bank','text','Bank name for payment details','2026-03-24 11:55:40','2026-03-24 11:55:40'),(14,'bank_account_name','Kaycee & Associates','text','Account holder name','2026-03-24 11:55:40','2026-03-24 11:55:40'),(15,'bank_account_number','6277 5377 221','text','Bank account number','2026-03-24 11:55:40','2026-03-24 11:55:40'),(16,'bank_branch','250655','text','Bank branch code','2026-03-24 11:55:40','2026-03-24 11:55:40'),(17,'company_phone','+27 663566897','text','Company phone number','2026-03-24 11:55:40','2026-03-24 11:55:40'),(18,'company_email','Info@kayceea.co.za','text','Company contact email','2026-03-24 11:55:40','2026-03-24 11:55:40'),(19,'company_address','69 Amanda Avenue, Glenanda, Johannesburg, 2190','text','Company physical address','2026-03-24 11:55:40','2026-03-24 11:55:40');
/*!40000 ALTER TABLE `email_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_logs`
--

DROP TABLE IF EXISTS `event_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(191) NOT NULL,
  `url` varchar(800) DEFAULT NULL,
  `client_ts` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `organization_id` int unsigned DEFAULT NULL,
  `member_id` int unsigned DEFAULT NULL,
  `meta_json` text,
  PRIMARY KEY (`id`),
  KEY `idx_label` (`label`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_org_id` (`organization_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_label_created_at` (`label`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_logs`
--

LOCK TABLES `event_logs` WRITE;
/*!40000 ALTER TABLE `event_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `invoice_number` varchar(191) NOT NULL,
  `issue_date` date NOT NULL,
  `due_date` date NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `vat_amount` decimal(10,2) NOT NULL,
  `status` enum('unpaid','paid','overdue') NOT NULL DEFAULT 'unpaid',
  `items` json DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_status` (`status`),
  KEY `idx_status_issue` (`status`,`issue_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_invoices_after_insert` AFTER INSERT ON `invoices` FOR EACH ROW BEGIN
  IF NEW.status = 'unpaid' THEN
    UPDATE bookings SET payment_status='pending' WHERE id = NEW.booking_id;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` varchar(500) NOT NULL,
  `working_days` text,
  `working_hours` text,
  `closed_dates` mediumtext,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `daily_capacity` int DEFAULT '10',
  PRIMARY KEY (`id`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=' `closed_dates` TEXT,';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES (1,'Online Session','Remote / Virtual','Monday, Tuesday, Wednesday, Thursday, Friday, Saturday','Monday 08:00-18:00; Tuesday 08:00-18:00; Wednesday 08:00-18:00; Thursday 08:00-18:00; Friday 08:00-18:00; Saturday 09:00-13:00',NULL,1,'2026-03-22 00:15:50','2026-03-22 01:07:57',10),(2,'In-Person | Rivonia Therapy Centre','19 9th Avenue Edenburg, Rivonia 2129','Monday, Friday, Saturday','Monday 21:00-12:00; Friday 13:00-16:00; Saturday 09:00-12:00',NULL,1,'2026-03-22 01:04:30','2026-03-25 14:54:33',10),(3,'Wellness Center','69 Amanda Avenue, Glenanda, Johannesburg, 2190','Monday, Tuesday, Wednesday, Thursday, Friday','Monday 13:00-18:00; Tuesday 08:00-18:00; Wednesday 08:00-18:00; Thursday 08:00-18:00; Friday 08:00-12:00',NULL,1,'2026-03-25 14:51:25','2026-03-25 14:55:18',10);
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,'Kaycee & Associates ','booking@kayceea.co.za','Email Configuration Test - Kaycee & Associates','Email Configuration Test This is a test email to verify that the email system is working correctly. Test Date: 2026-03-24 12:04:18 Server: localhost If you receive this email, the configuration is working properly!','2026-03-24 10:04:20'),(2,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Lwandile Dlamini (2026-03-22 14:00)','New booking request\r\n\r\nName: Lwandile Dlamini\r\nEmail: lwandile.dlams7@gmail.com\r\nPhone: 0672456753\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-22\r\nTime: 14:00\r\nService ID: 3','2026-03-21 08:46:03'),(3,'Customer service ','donotreply@regus.com','Verify your identity','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.=\r\nw3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n    <html xmlns=3D\"http://www.w3.org/1999/xhtml\" xmlns:v=3D\"urn:schemas-mic=\r\nrosoft-com:vml\" xmlns:o=3D\"urn:schemas-microsoft-com:office:office\"><head>\r\n        <!--[if gte mso 9]>\r\n        <xml>\r\n        <o:OfficeDocumentSettings>\r\n        <o:AllowPNG/>\r\n        <o:PixelsPerInch>96</o:PixelsPerInch>\r\n        </o:OfficeDocumentSettings>\r\n        </xml>\r\n        <![endif]-->\r\n        <title></title>\r\n        <meta name=3D\"viewport\" content=3D\"width=3Ddevice-width, initial-sc=\r\nale=3D1.0\">\r\n        <meta name=3D\"format-detection\" content=3D\"telephone=3Dno\">\r\n        <meta http-equiv=3D\"Content-Type\" content=3D\"text/html; charset=3DU=\r\nTF-8\">\r\n        <style type=3D\"text/css\">\r\n            /* th stacking*/\r\n            th {\r\n                margin: 0;\r\n                padding: 0;\r\n            }\r\n            /* standard classes */\r\n            span.MsoHyperlink, span.MsoHyperlinkFollowed {\r\n                mso-style-priority: 99;\r\n                color: inherit;\r\n            }\r\n\r\n            a {\r\n                color: inherit;\r\n                text-decoration: none;\r\n            }\r\n\r\n            .ReadMsgBody, .ExternalClass {\r\n                width: 100%;\r\n            }\r\n\r\n                .ExternalClass * {\r\n                    line-height: 110%;\r\n                }\r\n\r\n            body {\r\n                width: 100% !important;\r\n                -webkit-text-size-adjust: 100%;\r\n                -ms-text-size-adjust: 100%;\r\n                margin: 0;\r\n                padding: 0;\r\n            }\r\n\r\n            table {\r\n                border-collapse: collapse !important;\r\n                mso-table-lspace: 0pt;\r\n                mso-table-rspace: 0pt;\r\n            }\r\n\r\n            .gmailfix {\r\n                display: none;\r\n                display: none !important;\r\n            }\r\n\r\n            span > a, sup > a, span > a > sup {\r\n                color: inherit !important;\r\n                text-decoration: none;\r\n            }\r\n\r\n            .footer span > a {\r\n                color: #333333 !important;\r\n            }\r\n\r\n            [office365] button {\r\n                display: block !important;\r\n                margin: 0 !important;\r\n                padding: 0 !important;\r\n            }\r\n\r\n            [office365] div {\r\n                display: block !important\r\n            }\r\n\r\n            [owa] .m-show img {\r\n                display: none !important;\r\n            }\r\n        </style>\r\n        <style type=3D\"text/css\">\r\n            @media only screen and (max-width: 480px) {\r\n                .wrapper {\r\n                    width: 100vh !important;\r\n                }\r\n                /* th stacking */\r\n                .force-100 tr {\r\n                    width: 100% !important;\r\n                    display: table !important;\r\n                }\r\n\r\n                .top {\r\n                    display: table-header-group !important;\r\n                    width: 100% !important;\r\n                }\r\n\r\n                .bottom {\r\n                    display: table-footer-group !important;\r\n                    width: 100% !important;\r\n                }\r\n                /* standard mobile classes */\r\n                .MainTable {\r\n                    width: 100% !important;\r\n                    min-width: 320px !important;\r\n                }\r\n\r\n                .main-padding {\r\n                    padding: 0px !important;\r\n                }\r\n\r\n                html, body {\r\n                    width: 100% !important;\r\n                    min-width: 100% !important;\r\n                }\r\n\r\n                [owa] .m-show img {\r\n                    display: block !important;\r\n                }\r\n\r\n                .m-hide, .m-hide * {\r\n                    display: none !important;\r\n                    height: 0 !important;\r\n                    width: 0px !important;\r\n                    visibility: hidden !important;\r\n                    line-height: 0px !important;\r\n                    font-size: 0px !important;\r\n                }\r\n\r\n                .m-show {\r\n                    display: block !important;\r\n                    max-height: inherit !important;\r\n                    max-width: inherit !important;\r\n                    visibility: visible !important;\r\n                    overflow: visible !important;\r\n                }\r\n\r\n                .float-left {\r\n                    float: left !important;\r\n                    clear: none !important;\r\n                }\r\n\r\n                .float-right {\r\n                    float: right !important;\r\n                    clear: none !important;\r\n                }\r\n\r\n                .half-width {\r\n                    width: 48% !important;\r\n                    display: inline-block !important;\r\n                }\r\n\r\n                .block, .drop, .drop tbody, .drop table, .drop tr {\r\n                    float: none !important;\r\n                    width: 100% !important;\r\n                    padding: 0 !important;\r\n                    display: block !important;\r\n                }\r\n\r\n                .center {\r\n                    text-align: center !important;\r\n                }\r\n\r\n                .align-left {\r\n                    text-align: left !important;\r\n                }\r\n\r\n                .align-right {\r\n                    text-align: right !important;\r\n                }\r\n\r\n                .absolute {\r\n                    position: absolute !important;\r\n                }\r\n\r\n                table.block, table.drop, .drop table, .drop tbody {\r\n                    display: table !important;\r\n                }\r\n\r\n                tr.block, tr.drop, .drop tr {\r\n                    display: table-row !important;\r\n                }\r\n\r\n                td.block, td.drop, .drop td {\r\n                    display: table-cell !important;\r\n                }\r\n\r\n                .center > img, img.center, .align-left > img, img.align-lef=\r\nt, .align-right > img, img.align-right {\r\n                    display: inline-block !important;\r\n                }\r\n\r\n                .center table.center, .align-right > table, .align-left > t=\r\nable {\r\n                    display: inline-table !important;\r\n                }\r\n\r\n                .background-none {\r\n                    background: transparent !important;\r\n                }\r\n\r\n                .background-image-none {\r\n                    background-image: none !important;\r\n                }\r\n\r\n                .text-size {\r\n                    line-height: 120% !important;\r\n                }\r\n\r\n                .text-size-10px {\r\n                    font-size: 10px !important;\r\n                }\r\n\r\n                .text-size-11px {\r\n                    font-size: 11px !important;\r\n                }\r\n\r\n                .text-size-12px {\r\n                    font-size: 12px !important;\r\n                }\r\n\r\n                .text-size-13px {\r\n                    font-size: 13px !important;\r\n                }\r\n\r\n                .text-size-14px {\r\n                    font-size: 14px !important;\r\n                }\r\n\r\n                .text-size-15px {\r\n                    font-size: 15px !important;\r\n                }\r\n\r\n                .text-size-16px {\r\n                    font-size: 16px !important;\r\n                }\r\n\r\n                .text-size-17px {\r\n                    font-size: 17px !important;\r\n                }\r\n\r\n                .text-size-18px {\r\n                    font-size: 18px !important;\r\n                }\r\n\r\n                .text-size-19px {\r\n                    font-size: 19px !important;\r\n                }\r\n\r\n                .text-size-20px {\r\n                    font-size: 20px !important;\r\n                }\r\n\r\n                .text-size-21px {\r\n                    font-size: 21px !important;\r\n                }\r\n\r\n                .text-size-22px {\r\n                    font-size: 22px !important;\r\n                }\r\n\r\n                .text-size-23px {\r\n                    font-size: 23px !important;\r\n                }\r\n\r\n                .text-size-24px {\r\n                    font-size: 24px !important;\r\n                }\r\n\r\n                .text-size-25px {\r\n                    font-size: 25px !important;\r\n                }\r\n\r\n                .text-size-26px {\r\n                    font-size: 26px !important;\r\n                }\r\n\r\n                .text-size-27px {\r\n                    font-size: 27px !important;\r\n                }\r\n\r\n                .text-size-28px {\r\n                    font-size: 28px !important;\r\n                }\r\n\r\n                .text-size-29px {\r\n                    font-size: 29px !important;\r\n                }\r\n\r\n                .text-size-30px {\r\n                    font-size: 30px !important;\r\n                }\r\n\r\n                .width-100 {\r\n                    width: 100% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-90 {\r\n                    width: 90% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-80 {\r\n                    width: 80% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-70 {\r\n                    width: 70% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-60 {\r\n                    width: 60% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-50 {\r\n                    width: 50% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-40 {\r\n                    width: 40% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-30 {\r\n                    width: 30% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-20 {\r\n                    width: 20% !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-0 {\r\n                    width: 0px !important;\r\n                    height: auto !important;\r\n                }\r\n\r\n                .width-auto {\r\n                    width: auto !important;\r\n                }\r\n\r\n                .height-auto {\r\n                    height: auto !important;\r\n                }\r\n\r\n                .padding-0 {\r\n                    padding: 0 !important;\r\n                }\r\n\r\n                .padding-5 {\r\n                    padding: 5px !important;\r\n                }\r\n\r\n                .padding-10 {\r\n                    padding: 10px !important;\r\n                }\r\n\r\n                .padding-15 {\r\n                    padding: 15px !important;\r\n                }\r\n\r\n                .padding-20 {\r\n                    padding: 20px !important;\r\n                }\r\n\r\n                .padding-25 {\r\n                    padding: 25px !important;\r\n                }\r\n\r\n                .padding-30 {\r\n                    padding: 30px !important;\r\n                }\r\n\r\n                .padding-horz-0 {\r\n                    padding-left: 0px !important;\r\n                    padding-right: 0px !important;\r\n                }\r\n\r\n                .padding-horz-5 {\r\n                    padding-left: 5px !important;\r\n                    padding-right: 5px !important;\r\n                }\r\n\r\n                .padding-horz-10 {\r\n                    padding-left: 10px !important;\r\n                    padding-right: 10px !important;\r\n                }\r\n\r\n                .padding-horz-15 {\r\n                    padding-left: 15px !important;\r\n                    padding-right: 15px !important;\r\n                }\r\n\r\n                .padding-horz-20 {\r\n                    padding-left: 20px !important;\r\n                    padding-right: 20px !important;\r\n                }\r\n\r\n                .padding-horz-25 {\r\n                    padding-left: 25px !important;\r\n                    padding-right: 25px !important;\r\n                }\r\n\r\n                .padding-horz-30 {\r\n                    padding-left: 30px !important;\r\n                    padding-right: 30px !important;\r\n                }\r\n\r\n                .padding-vert-0 {\r\n                    padding-top: 0px !important;\r\n                    padding-bottom: 0px !important;\r\n                }\r\n\r\n                .padding-vert-5 {\r\n                    padding-top: 5px !important;\r\n                    padding-bottom: 5px !important;\r\n                }\r\n\r\n                .padding-vert-10 {\r\n                    padding-top: 10px !important;\r\n                    padding-bottom: 10px !important;\r\n                }\r\n\r\n                .padding-vert-15 {\r\n                    padding-top: 15px !important;\r\n                    padding-bottom: 15px !important;\r\n                }\r\n\r\n                .padding-vert-20 {\r\n                    padding-top: 20px !important;\r\n                    padding-bottom: 20px !important;\r\n                }\r\n\r\n                .padding-vert-25 {\r\n                    padding-top: 25px !important;\r\n                    padding-bottom: 25px !important;\r\n                }\r\n\r\n                .padding-vert-30 {\r\n                    padding-top: 30px !important;\r\n                    padding-bottom: 30px !important;\r\n                }\r\n\r\n                .padding-right-0 {\r\n                    padding-right: 0px !important;\r\n                }\r\n\r\n                .padding-right-5 {\r\n                    padding-right: 5px !important;\r\n                }\r\n\r\n                .padding-right-10 {\r\n                    padding-right: 10px !important;\r\n                }\r\n\r\n                .padding-right-15 {\r\n                    padding-right: 15px !important;\r\n                }\r\n\r\n                .padding-right-20 {\r\n                    padding-right: 20px !important;\r\n                }\r\n\r\n                .padding-right-25 {\r\n                    padding-right: 25px !important;\r\n                }\r\n\r\n                .padding-right-30 {\r\n                    padding-right: 30px !important;\r\n                }\r\n\r\n                .padding-left-0 {\r\n                    padding-left: 0px !important;\r\n                }\r\n\r\n                .padding-left-5 {\r\n                    padding-left: 5px !important;\r\n                }\r\n\r\n                .padding-left-10 {\r\n                    padding-left: 10px !important;\r\n                }\r\n\r\n                .padding-left-15 {\r\n                    padding-left: 15px !important;\r\n                }\r\n\r\n                .padding-left-20 {\r\n                    padding-left: 20px !important;\r\n                }\r\n\r\n                .padding-left-25 {\r\n                    padding-left: 25px !important;\r\n                }\r\n\r\n                .padding-left-30 {\r\n                    padding-left: 30px !important;\r\n                }\r\n\r\n                .padding-top-0 {\r\n                    padding-top: 0px !important;\r\n                }\r\n\r\n                .padding-top-5 {\r\n                    padding-top: 5px !important;\r\n                }\r\n\r\n                .padding-top-10 {\r\n                    padding-top: 10px !important;\r\n                }\r\n\r\n                .padding-top-15 {\r\n                    padding-top: 15px !important;\r\n                }\r\n\r\n                .padding-top-20 {\r\n                    padding-top: 20px !important;\r\n                }\r\n\r\n                .padding-top-25 {\r\n                    padding-top: 25px !important;\r\n                }\r\n\r\n                .padding-top-30 {\r\n                    padding-top: 30px !important;\r\n                }\r\n\r\n                .padding-bottom-0 {\r\n                    padding-bottom: 0px !important;\r\n                }\r\n\r\n                .padding-bottom-5 {\r\n                    padding-bottom: 5px !important;\r\n                }\r\n\r\n                .padding-bottom-10 {\r\n                    padding-bottom: 10px !important;\r\n                }\r\n\r\n                .padding-bottom-15 {\r\n                    padding-bottom: 15px !important;\r\n                }\r\n\r\n                .padding-bottom-20 {\r\n                    padding-bottom: 20px !important;\r\n                }\r\n\r\n                .padding-bottom-25 {\r\n                    padding-bottom: 25px !important;\r\n                }\r\n\r\n                .padding-bottom-30 {\r\n                    padding-bottom: 30px !important;\r\n                }\r\n                /*Styles specific to this email*/\r\n                .border-none {\r\n                    border: none !important;\r\n                }\r\n\r\n                .text-size-42px {\r\n                    font-size: 42px !important;\r\n                }\r\n            }\r\n        </style>\r\n        <!--[if gte mso 9]>\r\n        <style type=3D\"text/css\">\r\n        sup {vertical-align: baseline; position: relative; top: -0.4em; fon=\r\nt-size:85%;}\r\n        </style>\r\n        <![endif]-->\r\n        <!--[if !mso]><!-->\r\n        <style type=3D\"text/css\">\r\n            sup {\r\n                vertical-align: top;\r\n                font-size: 50%;\r\n            }\r\n        </style>\r\n        <!--<![endif]-->\r\n        <style type=3D\"text/css\">\r\n            .footer-link-wrapper a {\r\n                text-decoration: underline;\r\n                color: #000001;\r\n            }\r\n\r\n			.default-top-label {\r\n				font-family: Arial, Helvetica, sans-serif;\r\n				font-size: 12px;\r\n				line-height: 18px;\r\n				mso-line-height-rule: exactly;\r\n				color: #000000;\r\n                text-align: start;\r\n			}\r\n\r\n            .default-top-label a {\r\n                color: #000000;\r\n                text-decoration: underline;\r\n            }\r\n\r\n            .default-title {\r\n                  font-family: Arial, Helvetica, sans-serif;\r\n                  font-size: 48px;\r\n                  line-height: 60px;\r\n                  mso-line-height-rule: exactly;\r\n                  color: #000000;\r\n                  font-weight: normal;\r\n            }\r\n\r\n            .default-body {\r\n              padding: 20px 0 0;\r\n              font-family: Arial, Helvetica, sans-serif;\r\n              font-size: 16px;\r\n              line-height: 24px;\r\n              mso-line-height-rule: exactly;\r\n              color: #000000;\r\n            }\r\n\r\n		=09\r\n        </style>\r\n    </head>\r\n    <body marginheight=3D\"0\" marginwidth=3D\"0\" topmargin=3D\"0\" leftmargin=\r\n=3D\"0\" rightmargin=3D\"0\" style=3D\"width: 100% !important;-webkit-text-size-=\r\nadjust: 100%;-ms-text-size-adjust: 100%;margin: 0;padding: 0;background-col=\r\nor: #FFFFFF\" bgcolor=3D\"#FFFFFF\" dir=3D\"ltr\">\r\n        <table class=3D\"MainTable\" cellspacing=3D\"0\" cellpadding=3D\"0\" widt=\r\nh=3D\"100%\" border=3D\"0\" role=3D\"presentation\" bgcolor=3D\"#FFFFFF\" style=3D\"=\r\nborder-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-rspace=\r\n: 0pt\">\r\n            <tbody><tr>\r\n                <td align=3D\"center\">\r\n\r\n                    <!-- SSL / View online -->\r\n                    <table width=3D\"100%\" border=3D\"0\" cellspacing=3D\"0\" ce=\r\nllpadding=3D\"0\" role=3D\"presentation\" style=3D\"border-collapse: collapse !i=\r\nmportant;mso-table-lspace: 0pt;mso-table-rspace: 0pt\">\r\n                        <tbody><tr>\r\n                            <td align=3D\"center\">\r\n                                <table align=3D\"center\" class=3D\"MainTable\"=\r\n width=3D\"648px\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"p=\r\nresentation\" style=3D\"border-collapse: collapse !important;mso-table-lspace=\r\n: 0pt;mso-table-rspace: 0pt;width: 648px;margin: 0 auto\">\r\n                                    <tbody><tr>\r\n                                        <td class=3D\"padding-horz-15\" style=\r\n=3D\"padding: 0 30px;\">\r\n                                            <table width=3D\"100%\" border=3D=\r\n\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" style=3D\"bord=\r\ner-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-rspace: 0p=\r\nt\">\r\n                                                <tbody><tr>\r\n                                                    <td dir=3D\"ltr\" width=\r\n=3D\"50%\" valign=3D\"top\" class=3D\"default-top-label\" style=3D\"font-family: A=\r\nrial, Helvetica, sans-serif;font-size: 12px;line-height: 18px;mso-line-heig=\r\nht-rule: exactly;color: #000000;text-align: start\">\r\n                                                       =20\r\n                                                            &nbsp;\r\n                                                        <table width=3D\"100=\r\n%\" border=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" cellspacing=3D\"0\" s=\r\ntyle=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-tabl=\r\ne-rspace: 0pt\"></table>\r\n                                                        <!--[if !mso]><!-->\r\n                                                        <div style=3D\"displ=\r\nay: none; max-height: 0px; overflow: hidden; font-size:0; line-height:0; ms=\r\no-hide: all\">\r\n                                                            &nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C=\r\n&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C&nbsp;=E2=80=8C\r\n                                                        </div>\r\n                                                        <!--<![endif]-->\r\n                                                    </td>\r\n                                               =20\r\n                                                    <td dir=3D\"ltr\" width=\r\n=3D\"50%\" valign=3D\"top\" class=3D\"default-top-label\" style=3D\"font-family: A=\r\nrial, Helvetica, sans-serif;font-size: 12px;line-height: 18px;mso-line-heig=\r\nht-rule: exactly;color: #000000;text-align: right\">\r\n                                                        Not viewing properl=\r\ny? <a href=3D\"http://url8979.regus.com/ls/click?upn=3Du001.FE8SSZd39sEWDgGf=\r\nkh3vuOFYgPtqXNG-2FTgktAm39plEOoImvMk7jWjofn4yp4IixOHIesTH94wJRC-2BqnGP-2Bec=\r\nfzD33behvblAWCMWRyybAvFp-2BkJxYIm-2B959XEjRpcMf5H4ZGjkpKZsK-2BgKStQiO3A-3D-=\r\n3DtA2-_hjjqKjo3BqZwPJQ1Rjxmck-2BtoVk8XI0M7Ws4th2zWIvFHh95n0hKq1F-2BQs4OhEeV=\r\nRVNTocVwz4zyJGCWbMCaGdyluNaw6dE9cMMh3KfHsGb8ksgCKsXQ2ej-2BVeOAOXNOHU5dZMFhz=\r\nmkpkMvXGRWuxI2oGZnX6Pn4iuHO-2BF-2Fy3YHGFiGA-2BsXzDCYZK4vJgm3ixvzjQUdUb7pzKY=\r\nMWD-2F32UgE7DAXI3qB0OyqhD-2BD4gDstJ1KcgVcjKvParVN0YGwJBFJjAT9-2BcbK72FLdC8h=\r\nTfe0AnRWzaKzV-2FLysJORsWcpZUMYydAKcZnZpyhG95jsYwhQrZfaZnOJoJGd76ggvDzOvkJPg=\r\nJ5c04gBSqWQKOio-3D\" target=3D\"_blank\" style=3D\"color: #000000;text-decorati=\r\non: underline\">View&nbsp;online</a>.                                       =\r\n             </td>\r\n                                                </tr>\r\n                                            </tbody></table>\r\n                                        </td>\r\n                                    </tr>\r\n                                </tbody></table>\r\n                            </td>\r\n                        </tr>\r\n                        <tr>\r\n                            <td align=3D\"center\" valign=3D\"top\">\r\n                                <table class=3D\"MainTable\" width=3D\"648px\" =\r\nborder=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" styl=\r\ne=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-r=\r\nspace: 0pt;width: 648px;margin: 0 auto\">\r\n                                    <!--INBOX MIN-WIDTH FIX - DO NOT REMOVE=\r\n - MAKE SURE THESE SPACERS ADD UP TO THE WIDTH OF YOUR EMAIL-->\r\n                                    <tbody><tr class=3D\"m-hide\">\r\n                                        <td align=3D\"left\" style=3D\"min-wid=\r\nth:648px;\">\r\n                                            <table width=3D\"100%\" border=3D=\r\n\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" style=3D\"bord=\r\ner-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-rspace: 0p=\r\nt\">\r\n                                                <tbody><tr>\r\n                                                    <td width=3D\"324\" align=\r\n=3D\"left\" style=3D\"font-size:0px; line-height:0px; width:324px;\">\r\n                                                        <img src=3D\"https:/=\r\n/assets.iwgplc.com/image/upload/CNS/images/blocks/largespacer_300_263.png\" =\r\nalt=3D\"\" width=3D\"324\" height=3D\"1\" style=3D\"display:block\" border=3D\"0\">\r\n                                                    </td>\r\n                                                    <td width=3D\"324\" align=\r\n=3D\"left\" style=3D\"font-size:0px; line-height:0px; width:324px;\">\r\n                                                        <img src=3D\"https:/=\r\n/assets.iwgplc.com/image/upload/CNS/images/blocks/largespacer_300_263.png\" =\r\nalt=3D\"\" width=3D\"324\" height=3D\"1\" style=3D\"display:block\" border=3D\"0\">\r\n                                                    </td>\r\n                                                </tr>\r\n                                            </tbody></table>\r\n                                        </td>\r\n                                    </tr>\r\n                                    <!--/INBOX MIN-WIDTH FIX - DO NOT REMOV=\r\nE - MAKE SURE THESE SPACERS ADD UP TO THE WIDTH OF YOUR EMAIL-->\r\n                                </tbody></table>\r\n                            </td>\r\n                        </tr>\r\n                    </tbody></table>\r\n                    <!-- SSL / View online -->\r\n                    <!-- Logo / Nav -->\r\n                    <table align=3D\"center\" cellspacing=3D\"0\" cellpadding=\r\n=3D\"0\" width=3D\"648px\" style=3D\"border-collapse: collapse !important;mso-ta=\r\nble-lspace: 0pt;mso-table-rspace: 0pt;width: 648px\" border=3D\"0\" class=3D\"w=\r\nidth-100\" role=3D\"presentation\" bgcolor=3D\"#FFFFFF\">\r\n                        <tbody><tr>\r\n                            <td align=3D\"center\">\r\n                                <table width=3D\"100%\" border=3D\"0\" cellspac=\r\ning=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" style=3D\"border-collapse:=\r\n collapse !important;mso-table-lspace: 0pt;mso-table-rspace: 0pt\">\r\n                                    <tbody><tr>\r\n                                        <td align=3D\"center\" style=3D\"paddi=\r\nng:15px;\">\r\n                                            <img src=3D\"https://assets.iwgp=\r\nlc.com/image/upload/CNS/images/logos/regus_logo_nonwhite_tm_320_174.png\" wi=\r\ndth=3D\"150\" alt=3D\"Regus\" style=3D\"display:block; border:none;\" border=3D\"0=\r\n\">\r\n                                        </td>\r\n                                    </tr>\r\n                                </tbody></table>\r\n                            </td>\r\n                        </tr>\r\n                    </tbody></table>\r\n\r\n                    <!-- Primary Article -->\r\n                    <table cellspacing=3D\"0\" cellpadding=3D\"0\" width=3D\"648=\r\npx\" style=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso=\r\n-table-rspace: 0pt;width: 648px\" border=3D\"0\" class=3D\"width-100\" role=3D\"p=\r\nresentation\" bgcolor=3D\"#FFFFFF\">\r\n                        <tbody><tr>\r\n                            <td align=3D\"center\" style=3D\"padding:15px 30px=\r\n 50px;\" class=3D\"padding-bottom-30 padding-horz-20\">\r\n                                <table cellspacing=3D\"0\" cellpadding=3D\"0\" =\r\nwidth=3D\"100%\" style=3D\"border-collapse: collapse !important;mso-table-lspa=\r\nce: 0pt;mso-table-rspace: 0pt;width: 100%\" border=3D\"0\" role=3D\"presentatio=\r\nn\">\r\n                                    <tbody><tr>\r\n                                        <!-- PSD is 62px but way too large =\r\nfor the text that actually gets used here -->\r\n                                        <td align=3D\"left\" class=3D\"text-si=\r\nze text-size-42px\" style=3D\"font-family: Arial, Helvetica, sans-serif; font=\r\n-size:48px; line-height:60px; mso-line-height-rule:exactly; color:#000000; =\r\nfont-weight: normal;\">\r\n                                            <table width=3D\"100%\" border=3D=\r\n\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" style=3D\"bord=\r\ner-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-rspace: 0p=\r\nt\"><tbody><tr><td>\r\n                                            <table dir=3D\"ltr\" width=3D\"100=\r\n%\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" s=\r\ntyle=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-tabl=\r\ne-rspace: 0pt\">\r\n				                               =20\r\n                                            </table>\r\n                                            </td></tr></tbody></table>\r\n                                        </td>\r\n                                    </tr>\r\n                                    <tr>\r\n            <td dir=3D\"ltr\" align=3D\"left\" class=3D\"default-body\" valign=3D=\r\n\"top\" style=3D\"padding: 20px 0 0;font-family: Arial, Helvetica, sans-serif;=\r\nfont-size: 16px;line-height: 24px;mso-line-height-rule: exactly;color: #000=\r\n000\">\r\n                <div align=3D\"center\">\r\n                    <p>Please use the verification code below to confirm yo=\r\nur identity.</p>\r\n                    <br>\r\n                    <p>\r\n                        <b>\r\n                            Verification code:\r\n                        </b>\r\n                        <br>\r\n                        <br>\r\n                        <b style=3D\"font-size:120%\">\r\n                            010243\r\n                        </b>\r\n                    </p>\r\n                    <p>\r\n                        (This code will expire in 10 minutes)\r\n                    </p>\r\n                </div> =20\r\n            </td>\r\n        </tr>\r\n                                </tbody></table>\r\n                            </td>\r\n                        </tr>\r\n                    </tbody></table>\r\n\r\n                    <!-- Footer -->\r\n                    <table dir=3D\"ltr\" cellspacing=3D\"0\" cellpadding=3D\"0\" =\r\nwidth=3D\"648px\" style=3D\"border-collapse: collapse !important;mso-table-lsp=\r\nace: 0pt;mso-table-rspace: 0pt;width: 648px\" border=3D\"0\" class=3D\"width-10=\r\n0\" role=3D\"presentation\" bgcolor=3D\"#f1f1f1\">\r\n                        <tbody><tr>\r\n                            <td class=3D\"padding-horz-15 padding-vert-30\" a=\r\nlign=3D\"left\" style=3D\"padding:50px 30px;\">\r\n                                <table width=3D\"100%\" cellspacing=3D\"0\" cel=\r\nlpadding=3D\"0\" border=3D\"0\" role=3D\"presentation\" style=3D\"border-collapse:=\r\n collapse !important;mso-table-lspace: 0pt;mso-table-rspace: 0pt\">\r\n                                    <tbody><tr>\r\n                                        <td>\r\n                                            <table dir=3D\"ltr\" width=3D\"100=\r\n%\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" s=\r\ntyle=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-tabl=\r\ne-rspace: 0pt\">\r\n                                                <tbody><tr>\r\n                                                    <th width=3D\"138\" align=\r\n=3D\"left\" class=3D\"block border-none\" valign=3D\"top\" style=3D\"margin: 0;pad=\r\nding: 0;font-weight: normal\">\r\n                                                        <table width=3D\"100=\r\n%\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" s=\r\ntyle=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-tabl=\r\ne-rspace: 0pt\">\r\n                                                            <tbody><tr>\r\n                                                                <td class=\r\n=3D\"padding-bottom-15\" style=3D\"padding:0 10px 28px 0;\"><img src=3D\"https:/=\r\n/assets.iwgplc.com/image/upload/CNS/images/logos/regus_logo_nonwhite_228_12=\r\n6.png\" width=3D\"114\" alt=3D\"Regus\" style=3D\"display:block; border:none;\" bo=\r\nrder=3D\"0\"></td>\r\n                                                            </tr>\r\n                                                            <tr>\r\n                                                                <td align=\r\n=3D\"left\" style=3D\"font-family: Arial, Helvetica, sans-serif; font-size:12p=\r\nx; line-height:18px; mso-line-height-rule:exactly; color:#000000;font-weigh=\r\nt:normal; padding: 0 0 10px;\">Part Of The IWG Network</td>\r\n                                                            </tr>\r\n                                                        </tbody></table>\r\n                                                    </th>\r\n                                                    <th width=3D\"112\" class=\r\n=3D\"block border-none padding-top-10\" align=3D\"left\" valign=3D\"top\" style=\r\n=3D\"margin: 0;padding: 0;font-weight: normal;border-right: 1px solid #00000=\r\n0;border-left: 1px solid #000000\">\r\n                                                        <table width=3D\"100=\r\n%\" cellspacing=3D\"0\" cellpadding=3D\"0\" border=3D\"0\" role=3D\"presentation\" s=\r\ntyle=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-tabl=\r\ne-rspace: 0pt\">\r\n                                                            <tbody><tr>\r\n                                                                <td class=\r\n=3D\"padding-0\" align=3D\"left\" style=3D\"font-family:arial, sans-serif; font-=\r\nsize:12px; line-height:22px; mso-line-height-rule:exactly; color:#000000;pa=\r\ndding:0 10px;\">\r\n                                                                    <span s=\r\ntyle=3D\"color:#000001; text-decoration:none\">Offices</span><br>\r\n                                                                    <span s=\r\ntyle=3D\"color:#000001; text-decoration:none\">Coworking</span><br>\r\n                                                                    <span s=\r\ntyle=3D\"color:#000001; text-decoration:none\">Virtual Offices</span><br>\r\n                                                                    <span s=\r\ntyle=3D\"color:#000001; text-decoration:none\">Meeting Rooms</span><br>\r\n                                                                    <span s=\r\ntyle=3D\"color:#000001; text-decoration:none\">Memberships</span>\r\n                                                                </td>\r\n                                                            </tr>\r\n                                                        </tbody></table>\r\n                                                    </th>\r\n                                                    <th dir=3D\"ltr\" class=\r\n=3D\"block border-none padding-top-20\" align=3D\"left\" valign=3D\"top\" style=\r\n=3D\"margin: 0;font-weight: normal;border-right: 1px solid #000000;border-le=\r\nft: 1px solid #000000;padding: 0 10px\">\r\n                                                        <table dir=3D\"ltr\" =\r\ncellspacing=3D\"0\" cellpadding=3D\"0\" width=3D\"100%\" border=3D\"0\" role=3D\"pre=\r\nsentation\" style=3D\"border-collapse: collapse !important;mso-table-lspace: =\r\n0pt;mso-table-rspace: 0pt\">\r\n                                                            <tbody><tr>\r\n                                                                <td dir=3D\"=\r\nltr\" align=3D\"left\" style=3D\"padding:0 0 10px; font-family:arial, sans-seri=\r\nf; font-size:12px; line-height:18px; mso-line-height-rule:exactly; color:#0=\r\n00000;\">Book now:</td>\r\n                                                            </tr>\r\n                                                            <tr>\r\n                                                                <td>\r\n                                                                    <table =\r\ndir=3D\"ltr\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presen=\r\ntation\" style=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt=\r\n;mso-table-rspace: 0pt\">\r\n                                                                        <tb=\r\nody><tr>\r\n                                                                           =\r\n <td align=3D\"left\" style=3D\"padding: 0 4px 0 4px;\"><img src=3D\"https://ass=\r\nets.iwgplc.com/image/upload/CNS/images/application_stores/googleplay_203_61=\r\n.png\" width=3D\"92\" alt=3D\"Get it on Google Play\" style=3D\"display:block; bo=\r\nrder:none;\" border=3D\"0\"></td>\r\n                                                                           =\r\n <td align=3D\"left\"><img src=3D\"https://assets.iwgplc.com/image/upload/w_18=\r\n0,h_61/CNS/images/application_stores/appstore_290_96.png\" width=3D\"84\" alt=\r\n=3D\"Download on the App Store\" style=3D\"display:block; border:none;\" border=\r\n=3D\"0\"></td>\r\n                                                                        </t=\r\nr>\r\n                                                                  </tbody><=\r\n/table>\r\n                                                                </td>\r\n                                                            </tr>\r\n                                                            <tr>\r\n                                                                <td dir=3D\"=\r\nltr\" align=3D\"left\" style=3D\"padding:15px 0 0;\">\r\n                                                                    <table =\r\nborder=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" styl=\r\ne=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-r=\r\nspace: 0pt\">\r\n                                                                        <tb=\r\nody><tr>\r\n                                                                           =\r\n <th class=3D\"block padding-top-10\" valign=3D\"top\" style=3D\"margin: 0;paddi=\r\nng: 0\">\r\n                                                                           =\r\n     <table width=3D\"100%\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\"=\r\n role=3D\"presentation\" style=3D\"border-collapse: collapse !important;mso-ta=\r\nble-lspace: 0pt;mso-table-rspace: 0pt\">\r\n                                                                           =\r\n         <tbody><tr>\r\n                                                                           =\r\n             <td dir=3D\"ltr\" align=3D\"left\" style=3D\"font-family: Arial, He=\r\nlvetica, sans-serif; font-size:12px; line-height:18px;mso-line-height-rule:=\r\nexactly; color:#000000;font-weight:normal;\">Visit us:</td>\r\n                                                                           =\r\n         </tr>\r\n                                                                           =\r\n         <tr>\r\n                                                                           =\r\n             <td align=3D\"left\" style=3D\"font-family: Arial, Helvetica, san=\r\ns-serif; font-size:15px; line-height:23px;mso-line-height-rule:exactly; col=\r\nor:#e30613;font-weight:normal;\"><span style=3D\"color:#e30613; text-decorati=\r\non: none;\">regus.com</span></td>\r\n                                                                           =\r\n         </tr>\r\n                                                                           =\r\n     </tbody></table>\r\n                                                                           =\r\n </th>\r\n                                                                        </t=\r\nr>\r\n                                                                    </tbody=\r\n></table>\r\n                                                                </td>\r\n                                                            </tr>\r\n                                                        </tbody></table>\r\n                                                    </th>\r\n                                                    <th dir=3D\"ltr\" class=\r\n=3D\"block padding-top-20\" align=3D\"left\" valign=3D\"top\" style=3D\"margin: 0;=\r\nfont-weight: normal;padding: 0 5px 0 5px\">\r\n                                                        <table dir=3D\"ltr\" =\r\nwidth=3D\"100%\" cellspacing=3D\"0\" cellpadding=3D\"0\" border=3D\"0\" role=3D\"pre=\r\nsentation\" style=3D\"border-collapse: collapse !important;mso-table-lspace: =\r\n0pt;mso-table-rspace: 0pt\">\r\n                                                            <tbody><tr>\r\n                                                                <td dir=3D\"=\r\nltr\" align=3D\"left\">\r\n                                                                    <table =\r\ndir=3D\"ltr\" width=3D\"100%\" cellspacing=3D\"0\" cellpadding=3D\"0\" border=3D\"0\"=\r\n role=3D\"presentation\" style=3D\"border-collapse: collapse !important;mso-ta=\r\nble-lspace: 0pt;mso-table-rspace: 0pt\">\r\n                                                                        <tb=\r\nody><tr>\r\n                                                                           =\r\n <td dir=3D\"ltr\" align=3D\"left\" style=3D\"padding:0 0 10px 0; font-family:ar=\r\nial, sans-serif; font-size:12px; line-height:18px; mso-line-height-rule:exa=\r\nctly; color:#000000;\">\r\n                                                                           =\r\n     Connect with us:\r\n                                                                           =\r\n </td>\r\n                                                                        </t=\r\nr>\r\n                                                                    </tbody=\r\n></table>\r\n                                                                    <table =\r\ndir=3D\"ltr\" width=3D\"100%\" align=3D\"right\" cellspacing=3D\"0\" cellpadding=3D=\r\n\"0\" border=3D\"0\" role=3D\"presentation\" style=3D\"border-collapse: collapse !=\r\nimportant;mso-table-lspace: 0pt;mso-table-rspace: 0pt\"><tbody><tr><td>\r\n                                                                    <table =\r\ndir=3D\"ltr\" align=3D\"left\" widht=3D\"100%\" cellspacing=3D\"0\" cellpadding=3D\"=\r\n0\" border=3D\"0\" role=3D\"presentation\" style=3D\"border-collapse: collapse !i=\r\nmportant;mso-table-lspace: 0pt;mso-table-rspace: 0pt\">\r\n                                                                        <tb=\r\nody><tr>\r\n                                                                           =\r\n <td dir=3D\"ltr\" align=3D\"left\" style=3D\"padding: 0 4px 0 4px;\"><img src=3D=\r\n\"https://assets.iwgplc.com/image/upload/CNS/images/social_medias/regus_face=\r\nbook_66.png\" width=3D\"33\" alt=3D\"Facebook\" style=3D\"display:block; border:n=\r\none;\" border=3D\"0\"></td>\r\n                                                                           =\r\n <td dir=3D\"ltr\" align=3D\"left\" style=3D\"padding: 0 4px 0 4px;\"><img src=3D=\r\n\"https://assets.iwgplc.com/image/upload/CNS/images/social_medias/regus_inst=\r\nagram_66_66.png\" width=3D\"33\" alt=3D\"Instagram\" style=3D\"display:block; bor=\r\nder:none;\" border=3D\"0\"></td>\r\n                                                                           =\r\n <td dir=3D\"ltr\" align=3D\"left\" style=3D\"padding: 0 4px 0 4px;\"><img src=3D=\r\n\"https://assets.iwgplc.com/image/upload/v1734013700/CNS/images/social_media=\r\ns/regus_tiktok_66_66.png\" width=3D\"33\" alt=3D\"TikTok\" style=3D\"display:bloc=\r\nk; border:none;\" border=3D\"0\"></td>\r\n                                                                        </t=\r\nr>\r\n                                                                        <tr=\r\n>\r\n                                                                           =\r\n <td dir=3D\"ltr\" align=3D\"left\" style=3D\"padding: 5px 4px 0 4px;\"><img src=\r\n=3D\"https://assets.iwgplc.com/image/upload/CNS/images/social_medias/regus_l=\r\ninkedin_66_66.png\" width=3D\"33\" alt=3D\"LinkedIn\" style=3D\"display:block; bo=\r\nrder:none;\" border=3D\"0\"></td>\r\n                                                                           =\r\n <td dir=3D\"ltr\" align=3D\"left\" style=3D\"padding: 5px 4px 0 4px;\"><img src=\r\n=3D\"https://assets.iwgplc.com/image/upload/CNS/images/social_medias/regus_p=\r\ninterest_33_33.png\" width=3D\"33\" alt=3D\"Pinterest\" style=3D\"display:block; =\r\nborder:none;\" border=3D\"0\"></td>\r\n                                                                        </t=\r\nr>\r\n                                                                    </tbody=\r\n></table>\r\n                                                                    </td></=\r\ntr></tbody></table>\r\n                                                                </td>\r\n                                                            </tr>\r\n                                                        </tbody></table>\r\n                                                    </th>\r\n                                                </tr>\r\n                                            </tbody></table>\r\n                                        </td>\r\n                                    </tr>\r\n                                    <tr>\r\n                                        <td align=3D\"left\" style=3D\"padding=\r\n:50px 0 0;\" class=3D\"padding-top-20\">\r\n                                            <table width=3D\"100%\" border=3D=\r\n\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" style=3D\"bord=\r\ner-collapse: collapse !important;mso-table-lspace: 0pt;mso-table-rspace: 0p=\r\nt\">\r\n                                                <tbody><tr>\r\n                                                    <td align=3D\"left\" vali=\r\ngn=3D\"top\">\r\n                                                        <table width=3D\"100=\r\n%\" border=3D\"0\" cellspacing=3D\"0\" cellpadding=3D\"0\" role=3D\"presentation\" s=\r\ntyle=3D\"border-collapse: collapse !important;mso-table-lspace: 0pt;mso-tabl=\r\ne-rspace: 0pt\">\r\n                                                            <tbody><tr>\r\n                                                                <td dir=3D\"=\r\nltr\" align=3D\"left\" style=3D\"font-family: Arial, Helvetica, sans-serif; fon=\r\nt-size:12px; line-height:18px;mso-line-height-rule:exactly; color:#000000;f=\r\nont-weight:normal;padding:0 0 20px;\">\r\n                                                                    =C2=A9 =\r\nRegus 2026&nbsp;&nbsp;|&nbsp;&nbsp;\r\n                                                                    <span c=\r\nlass=3D\"footer-link-wrapper\">   =20\r\n                                                                        <a =\r\nhref=3D\"http://url8979.regus.com/ls/click?upn=3Du001.FE8SSZd39sEWDgGfkh3vuE=\r\nbjYN0isq45KyGocJskD97tIxv-2BM7K9vVitgNXcN9ag26O2m5re-2Fb1YFd-2FOypou3w-3D-3=\r\nDBPsE_hjjqKjo3BqZwPJQ1Rjxmck-2BtoVk8XI0M7Ws4th2zWIvFHh95n0hKq1F-2BQs4OhEeVR=\r\nVNTocVwz4zyJGCWbMCaGdyluNaw6dE9cMMh3KfHsGb8ksgCKsXQ2ej-2BVeOAOXNOHU5dZMFhzm=\r\nkpkMvXGRWuxI2oGZnX6Pn4iuHO-2BF-2Fy3YGuqrQzemxHMc6qncp1HL7WzjcDuqs7BNJCHI-2F=\r\n7lLyVCiKZFhl0O3KvmhfbQgRL1LnHJdYuYEKeXGADvpcEPsPJsaJDRIe7qCSx-2Bglb8v-2BodW=\r\nr-2Bl9-2BVCtJNrOTibkKDWnwHSqGrCMj7icqXh6oijuQq4xTG6fTKM4ixp7d-2FYo3y7fYjmqK=\r\nsfrIjT1NfuiGmsZo-3D\" target=3D\"_blank\" style=3D\"color: inherit !important;t=\r\next-decoration: underline\">Privacy Policy</a>\r\n                                                                    </span>\r\n                                                                    <span c=\r\nlass=3D\"footer-link-wrapper\">\r\n                                                                    </span>\r\n                                                                </td>\r\n                                                            </tr>\r\n                                                            <tr>\r\n                                                                <td dir=3D\"=\r\nltr\" align=3D\"left\" style=3D\"font-family: Arial, Helvetica, sans-serif; fon=\r\nt-size:12px; line-height:18px;mso-line-height-rule:exactly; color:#000000;f=\r\nont-weight:normal; \">\r\n                                                                    Interna=\r\ntional Workplace Group, Head office Baarerstrasse 52, CH-6300, Zug, Switzer=\r\nland\r\n                                                                    <br>\r\n                                                                    Registe=\r\nred Office: 22 Grenville Street, St Helier, Jersey, JE4 8PX, Channel Island=\r\ns Jersey\r\n                                                                    <br>\r\n                                                                    Registe=\r\nred Number: 122154\r\n                                                                </td>\r\n                                                            </tr>\r\n                                                        </tbody></table>\r\n                                                    </td>\r\n                                                </tr>\r\n                                            </tbody></table>\r\n                                        </td>\r\n                                    </tr>\r\n                                </tbody></table>\r\n                            </td>\r\n                        </tr>\r\n                    </tbody></table>\r\n                </td>\r\n            </tr>\r\n        </tbody></table>\r\n        <div class=3D\"gmailfix\" style=3D\"display: none !important;white-spa=\r\nce: nowrap;font: 15px courier;line-height: 0;color: #ffffff;background-colo=\r\nr: #ffffff\">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =\r\n&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=\r\n; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</di=\r\nv>\r\n   =20\r\n<img src=3D\"http://url8979.regus.com/wf/open?upn=3Du001.kmBIT11aNp6HTej1nX6=\r\nEI6w5tDlDeU42owJmo1Vw2oYdBD-2BL3NJoD7WSEdNB4qXAo1hw2JhyoNnfUEQWMIFqYCS78K9J=\r\nAnj1RTxlWo5rs5hFn240EedOgt-2FTQXNBEsPBM1ZcOTdUcAlZ0AZEwFov13-2FCdwaao9KRa2e=\r\nZszYto835zboUI9-2BmIazu7CeCRzerS2jcKH-2FQ2-2BjtvLfHOrFNbQTKiy2ZI0SkOrvufGYA=\r\nYmhZ6J0vGYskXPTLqCIYMCSSSre3LumF-2F-2BtUYxV4IkQm1QyXUsNfViTd-2FYu3UpNgDpRV-=\r\n2BR8Zpw41jZiFBM8qNU-2BuXyo96rrfHV9yMDy7K2fhb00xKxPlWPqL-2Faw5HSq0yUI-3D\" al=\r\nt=3D\"\" width=3D\"1\" height=3D\"1\" border=3D\"0\" style=3D\"height:1px !important=\r\n;width:1px !important;border-width:0 !important;margin-top:0 !important;mar=\r\ngin-bottom:0 !important;margin-right:0 !important;margin-left:0 !important;=\r\npadding-top:0 !important;padding-bottom:0 !important;padding-right:0 !impor=\r\ntant;padding-left:0 !important;\"/></body></html>','2026-03-17 06:12:18'),(4,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Stephen Masimba (2026-03-19 09:00)','New booking request\r\n\r\nName: Stephen Masimba\r\nEmail: masimbastephen92@gmail.com\r\nPhone: 0697316145\r\nProvider: Elizabeth Mathibe\r\nType: online\r\nDate: 2026-03-19\r\nTime: 09:00\r\nService ID: 7\r\n\r\nNotes:\r\nThis is what I want, right ke Kgomotso?','2026-03-17 04:07:09'),(5,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Kay (2026-03-17 10:00)','New booking request\r\n\r\nName: Kay\r\nEmail: Kcsebeela@gmail.com\r\nPhone: 0782003457\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-17\r\nTime: 10:00\r\nService ID: 2','2026-03-16 18:13:57'),(6,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Tlou Monama (2026-03-31 13:00)','New booking request\r\n\r\nName: Tlou Monama\r\nEmail: tloumonama@gmail.com\r\nPhone: 0798437218\r\nProvider: Kgomotso Caroline Sebeela\r\nType: online\r\nDate: 2026-03-31\r\nTime: 13:00\r\nService ID: 1','2026-03-16 06:50:32'),(7,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Kgom (2026-03-16 10:00)','New booking request\r\n\r\nName: Kgom\r\nEmail: kcsebeela@gmail.com\r\nPhone: 0782003457\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-16\r\nTime: 10:00\r\nService ID: 1','2026-03-15 20:09:20'),(8,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Jabulane Tshekeli (2026-03-21 11:00)','New booking request\r\n\r\nName: Jabulane Tshekeli \r\nEmail: jtshekelip@gmail.com\r\nPhone: 0714840599\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-21\r\nTime: 11:00\r\nService ID: 4','2026-03-15 08:15:10'),(9,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Vuyisa (2026-03-17 15:00)','New booking request\r\n\r\nName: Vuyisa\r\nEmail: hlakanyanavee@gmail.com\r\nPhone: 0813813915\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-17\r\nTime: 15:00\r\nService ID: 1','2026-03-14 15:09:40'),(10,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Kau (2026-03-11 14:00)','New booking request\r\n\r\nName: Kau\r\nEmail: Kcsebeela@gmail.com\r\nPhone: 0782003457\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-11\r\nTime: 14:00\r\nService ID: 2','2026-03-11 07:15:02'),(11,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Kgomotso Sebeela (2026-03-12 09:00)','New booking request\r\n\r\nName: Kgomotso Sebeela\r\nEmail: kcsebeela@gmail.com\r\nPhone: 0782003457\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-12\r\nTime: 09:00\r\nService ID: 1\r\n\r\nNotes:\r\nHi','2026-03-11 06:40:27'),(12,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Angela D Too (2026-03-11 14:00)','New booking request\r\n\r\nName: Angela D Too\r\nEmail: masimbastephen@gmail.com\r\nPhone: 0649186091\r\nProvider: Kgomotso Caroline Sebeela\r\nType: online\r\nDate: 2026-03-11\r\nTime: 14:00\r\nService ID: 1\r\n\r\nNotes:\r\nThis year I believe that The King has opened the doors','2026-03-11 05:30:24'),(13,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Stephen Masimba (2026-03-19 10:00)','New booking request\r\n\r\nName: Stephen Masimba\r\nEmail: masimbastephen92@gmail.com\r\nPhone: 0697316145\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-19\r\nTime: 10:00\r\nService ID: 5\r\n\r\nNotes:\r\nWhat if I am it this time','2026-03-11 05:21:10'),(14,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Stephen Masimba (2026-04-16 13:00)','New booking request\r\n\r\nName: Stephen Masimba\r\nEmail: masimbastephen92@gmail.com\r\nPhone: 0697316145\r\nProvider: Kgomotso Caroline Sebeela\r\nType: online\r\nDate: 2026-04-16\r\nTime: 13:00\r\nService ID: 3\r\n\r\nNotes:\r\nIt has to work now','2026-03-11 05:12:28'),(15,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Turn Fox (2026-03-20 15:00)','New booking request\r\n\r\nName: Turn Fox\r\nEmail: turnfox5@gmail.com\r\nPhone: 0649186091\r\nProvider: Elizabeth Mathibe\r\nType: online\r\nDate: 2026-03-20\r\nTime: 15:00\r\nService ID: 7\r\n\r\nNotes:\r\nAddiction counselling supports individuals who are struggling with substance use or addictive behaviours.','2026-03-11 04:59:37'),(16,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Turn Fox (2026-03-26 15:00)','New booking request\r\n\r\nName: Turn Fox\r\nEmail: turnfox5@gmail.com\r\nPhone: 0649186091\r\nProvider: Kgomotso Caroline Sebeela\r\nType: in-person\r\nDate: 2026-03-26\r\nTime: 15:00\r\nService ID: 1\r\n\r\nNotes:\r\nI want to see if this works','2026-03-11 04:41:11'),(17,'Stephen Masimba ','stephentmasimba@gmail.com','Re: You\'re booked! Next steps for your session with Kgomotso Caroline Sebeela','I am confirming my appointment.\r\n\r\nOn Tue, Mar 10, 2026 at 10:29=E2=80=AFPM Kaycee & Associates <booking@kayce=\r\nea.co.za>\r\nwrote:\r\n\r\n> Kaycee & Associates\r\n>\r\n> Professional Counseling & Psychological Services\r\n> You\'re Booked!\r\n>\r\n> Hi *Test User*,\r\n>\r\n> Thanks for booking with *Kaycee & Associates*. We\'re looking forward to\r\n> working with you.\r\n> Your Session Details:\r\n> =F0=9F=97=93 *Date:*\r\n> 2026-03-12\r\n> =F0=9F=95=90 *Time:*\r\n> 10:00 AM\r\n> =F0=9F=91=A4 *Therapist:*\r\n> Kgomotso Caroline Sebeela\r\n> =F0=9F=92=B0 *Price:*\r\n> R650\r\n> =F0=9F=94=8D *Service:*\r\n> Individual Counseling Session\r\n> =F0=9F=94=92 Confirm Your Booking\r\n>\r\n> Your spot is held temporarily. To lock it in, please make payment to the\r\n> account below and reply with your Proof of Payment.\r\n> *First National Bank*\r\n> Acc: Kaycee & Associates\r\n> No: *6277 5377 221*\r\n> Branch: 250655\r\n> Ref: *Test User*\r\n> =E2=9A=A0=EF=B8=8F Please Note:\r\n>\r\n>    - We operate Monday=E2=80=93Saturday by appointment\r\n>    - To avoid fees, please cancel at least 24 hours in advance\r\n>    - Late cancellations incur a 40% fee\r\n>    - Missed appointments are charged in full\r\n>\r\n> See you soon,\r\n>\r\n> The Kaycee & Associates Team\r\n>\r\n> *Contact Information:*\r\n> =F0=9F=93=9E +27 663566897\r\n> =F0=9F=93=A7 booking@kayceea.co.za\r\n> =F0=9F=93=8D 69 Amanda Avenue, Glenanda, Johannesburg, 2190\r\n>','2026-03-10 19:48:28'),(18,'cPanel on kayceea.co.za','cpanel@kayceea.co.za','=?UTF-8?B?W2theWNlZWEuY28uemFdIENsaWVudCBjb25maWd1cmF0aW9uIHNl?= =?UTF-8?B?dHRpbmdzIGZvciDigJxib29raW5nQGtheWNlZWEuY28uemHigJ0u?=','--related-Cpanel::Email::Object-661074-1773140377-0.837476258626111\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\n<body style=3D\"background:#F4F4F4\">\r\n    <div style=3D\"margin:0;padding:0;background:#F4F4F4\">\r\n        <table cellpadding=3D\"10\" cellspacing=3D\"0\" border=3D\"0\" width=3D\"1=\r\n00%\" style=3D\"width:0 auto;\">\r\n            <tbody>\r\n                <tr>\r\n                    <td align=3D\"center\">\r\n                        <table cellpadding=3D\"0\" cellspacing=3D\"0\" border=\r\n=3D\"0\" width=3D\"680\" style=3D\"border:0;width:0 auto;max-width:680px;\">\r\n                            <tbody>\r\n                                <tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20\r\n                                    <td width=3D\"680\" height=3D\"25\" style=\r\n=3D\"font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:16px;=\r\ncolor:#333333\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                                            Client Configuration settings f=\r\nor =E2=80=9Cbooking@kayceea.co.za=E2=80=9D.\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                                    </td>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20\r\n                                </tr>\r\n                                <tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20\r\n                                    <td style=3D\"padding: 15px 0 20px 0; ba=\r\nckground-color: #FFFFFF; border: 2px solid #E8E8E8; border-bottom: 2px soli=\r\nd #FF6C2C;\">\r\n                                        <table width=3D\"680\" border=3D\"0\" c=\r\nellpadding=3D\"0\" cellspacing=3D\"0\" style=3D\"background:#FFFFFF;font-family:=\r\n\'Helvetica Neue\',Helvetica,Arial,sans-serif;\">\r\n                                            <tbody>\r\n                                                <tr>\r\n                                                    <td width=3D\"15\">\r\n                                                    </td>\r\n                                                    <td width=3D\"650\">\r\n                                                        <table cellpadding=\r\n=3D\"0\" cellspacing=3D\"0\" border=3D\"0\" width=3D\"100%\">\r\n                                                            <tbody>\r\n                                                                <tr>\r\n                                                                    <td>\r\n                                                                        <di=\r\nv id=3D\"manual_settings_area\" class=3D\"section\">\r\n        <h2 id=3D\"hdrManualSettings\">Mail Client Manual Settings</h2>\r\n=20=20=20=20=20=20=20=20\r\n        <div class=3D\"row\">\r\n         <div class=3D\"col-md-6\">\r\n          <div id=3D\"ssl_settings_area\"\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n            style=3D\"background-color: #fff;  border: 1px solid transparent=\r\n; border-radius: 4px; box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05); margin-bot=\r\ntom: 20px; border-color: #428bca;\"\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n            class=3D\"preferred-selection panel panel-primary\">\r\n               <div\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                style=3D\"border-top-left-radius: 3px; border-top-right-radi=\r\nus: 3px; padding: 10px 15px; background-color: #428bca; border-color: #428b=\r\nca; color: #fff;\"\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                class=3D\"panel-heading\">\r\n                Secure <abbr title=3D\"Secure Sockets Layer\">SSL</abbr>/<abb=\r\nr title=3D\"Transport Layer Security\">TLS</abbr> Settings\r\n                (Recommended)\r\n              </div>\r\n              <table class=3D\"table manual_settings_table\" style=3D\"border-=\r\ncollapse: collapse; border-spacing: 0; margin-bottom: 0; width: 100%; backg=\r\nround-color: transparent; max-width: 100%;\">\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblSSLSettingsAreaUsername\">Username:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valSSLSettingsAreaUsername\" class=3D\"data wrap-text\">booking@kayce=\r\nea.co.za</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblSettingsAreaPassword\">Password:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valSettingsAreaPassword\" class=3D\"escape-note\"> Use the email acco=\r\nunt=E2=80=99s password.</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblSettingsAreaIncomingServer\">Incoming Server:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valSettingsAreaIncomingServer\" class=3D\"data\">mail.kayceea.co.za\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><abbr title=3D\"Internet Message Access Proto=\r\ncol\" class=3D\"initialism\">IMAP</abbr> Port: 993</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><abbr title=3D\"Post Office Protocol 3\" class=\r\n=3D\"initialism\">POP3</abbr> Port: 995</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblSettingsAreaOutgoingServer\">Outgoing Server:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valSettingsAreaOutGoingServer\" class=3D\"data\">mail.kayceea.co.za\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><abbr title=3D\"Simple Mail Transfer Protocol=\r\n\">SMTP</abbr> Port: 465</li>\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" colspan=3D\"2\" class=3D\"notes\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20\r\n                                                                           =\r\n     <div id=3D\"lblSettingsAreaSmallNote1\" class=3D\"small_note\">IMAP, POP3,=\r\n and SMTP require authentication.</div>\r\n                      </td>\r\n                  </tr>\r\n              </table>\r\n          </div>\r\n         </div>\r\n=20=20\r\n      </div>\r\n=20=20=20=20=20=20=20=20\r\n\r\n        <div class=3D\"row\" id=3D\"nonSSL\" style=3D\"display: none\">\r\n         <div class=3D\"col-md-6\">\r\n           <div id=3D\"non_ssl_settings_area\"\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n            style=3D\"background-color: #fff;  border: 1px solid transparent=\r\n; border-radius: 4px; box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05); margin-bot=\r\ntom: 20px; border-color: #f6c342;\"\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n           class=3D\"panel panel-default panel-warning\">\r\n               <div\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                style=3D\"border-top-left-radius: 3px; border-top-right-radi=\r\nus: 3px; padding: 10px 15px; background-color: #fcf8e1; border-color: #f6c3=\r\n42; color: #333;\"\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                class=3D\"panel-heading\">\r\n                <span id=3D\"descNonSSLSettings\" class=3D\"caption not-recomm=\r\nended\">Non-SSL Settings (NOT Recommended)</span>\r\n              </div>\r\n              <table id=3D\"tblManualSettingsTable\" class=3D\"table manual_se=\r\nttings_table\" style=3D\"border-collapse: collapse; border-spacing: 0; margin=\r\n-bottom: 0; width: 100%; background-color: transparent; max-width: 100%;\">\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblNonSSLSettingsUsername\">Username:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valNonSSLSettingsUsername\" class=3D\"data wrap-text\">booking@kaycee=\r\na.co.za</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblNonSSLSettingsPassword\">Password:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valNonSSLSettingsPassword\" class=3D\"escape-note\">Use the email acc=\r\nount=E2=80=99s password.</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"lblNonSSLSettingsIncomingServer\">Incoming Server:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"valNonSSLSettingsIncomingServer\" class=3D\"data\">mail.kayceea.co.za=\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><abbr title=3D\"Internet Message Access Proto=\r\ncol\" class=3D\"initialism\">IMAP</abbr> Port: 143</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><abbr title=3D\"Post Office Protocol 3\" class=\r\n=3D\"initialism\">POP3</abbr> Port: 110</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"NonSSLSettingsOutgoingServer\">Outgoing Server:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" id=3D\"NonSSLSettingsOutgoingServerData\" class=3D\"data\">mail.kayceea.co.z=\r\na                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><abbr title=3D\"Simple Mail Transfer Protocol=\r\n\">SMTP</abbr> Port: 587</li>\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" colspan=3D\"2\" class=3D\"notes\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20\r\n                                                                           =\r\n     <div id=3D\"descNonSSLSettingsAuthenticationIsRequiredForIMAPPOP3SMTP1\"=\r\n class=3D\"small_note\">IMAP, POP3, and SMTP require authentication.</div>\r\n                      </td>\r\n                  </tr>\r\n              </table>\r\n          </div>\r\n        </div>\r\n      </div>\r\n\r\n    </div><div class=3D\"section\">\r\n        <h2>Calendar &amp; Contacts Manual Settings</h2>\r\n        <div class=3D\"row\">\r\n=20=20=20=20=20=20=20=20=20\r\n         <div class=3D\"col-md-6\">\r\n          <div style=3D\"background-color: #fff;  border: 1px solid transpar=\r\nent; border-radius: 4px; box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05); margin-=\r\nbottom: 20px; border-color: #428bca;\" class=3D\"preferred-selection panel pa=\r\nnel-primary\">\r\n               <div style=3D\"border-top-left-radius: 3px; border-top-right-=\r\nradius: 3px; padding: 10px 15px; background-color: #428bca; border-color: #=\r\n428bca; color: #fff;\" class=3D\"panel-heading\">\r\n                Secure <abbr title=3D\"Secure Sockets Layer\">SSL</abbr>/<abb=\r\nr title=3D\"Transport Layer Security\">TLS</abbr> Settings (Recommended).\r\n              </div>\r\n              <table class=3D\"table manual_settings_table\" style=3D\"border-=\r\ncollapse: collapse; border-spacing: 0; margin-bottom: 0; width: 100%; backg=\r\nround-color: transparent; max-width: 100%;\">\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Username:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data wrap-text\">booking@kayceea.co.za</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Password:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"escape-note\"> Use the email account=E2=80=99s password.</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Server:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data\">https://mail.kayceea.co.za:2080\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\">Port: 2080</li>\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Full Calendar URL(s):</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data\">\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><b>cPanel CalDAV Calendar</b>:</li>\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\">https://mail.kayceea.co.za:2080/calendars/bo=\r\noking@kayceea.co.za/calendar</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Full Contact List URL(s):</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data\">\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><b>cPanel CardDAV Address Book</b>:</li>\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\">https://mail.kayceea.co.za:2080/addressbooks=\r\n/booking@kayceea.co.za/addressbook</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n              </table>\r\n          </div>\r\n         </div>\r\n=20=20=20=20=20=20=20=20=20\r\n         <div class=3D\"col-md-6\">\r\n          <div style=3D\"background-color: #fff;  border: 1px solid transpar=\r\nent; border-radius: 4px; box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05); margin-=\r\nbottom: 20px; border-color: #f6c342;\" class=3D\"preferred-selection panel pa=\r\nnel-primary\">\r\n               <div style=3D\"border-top-left-radius: 3px; border-top-right-=\r\nradius: 3px; padding: 10px 15px; background-color: #fcf8e1; border-color: #=\r\nf6c342; color: #333;\" class=3D\"panel-heading\">\r\n                Non-SSL Settings (NOT Recommended).\r\n              </div>\r\n              <table class=3D\"table manual_settings_table\" style=3D\"border-=\r\ncollapse: collapse; border-spacing: 0; margin-bottom: 0; width: 100%; backg=\r\nround-color: transparent; max-width: 100%;\">\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Username:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data wrap-text\">booking@kayceea.co.za</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Password:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"escape-note\"> Use the email account=E2=80=99s password.</td>\r\n                  </tr>\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Server:</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data\">http://mail.kayceea.co.za:2079\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\">Port: 2079</li>\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Full Calendar URL(s):</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data\">\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><b>cPanel CalDAV Calendar</b>:</li>\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\">http://mail.kayceea.co.za:2079/calendars/boo=\r\nking@kayceea.co.za/calendar</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                  <tr>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\">Full Contact List URL(s):</td>\r\n                      <td style=3D\"border-top: 1px solid #ddd; padding: 8px=\r\n;\" class=3D\"data\">\r\n                          <ul\r\n                          style=3D\"margin-bottom: 10px; margin-top: 0; list=\r\n-style: outside none none; margin-left: -5px; padding-left: 0;\"\r\n                          class=3D\"port_list list-inline\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\"><b>cPanel CardDAV Address Book</b>:</li>\r\n                              <li style=3D\"display: inline-block; padding-l=\r\neft: 5px; padding-right: 5px;\">http://mail.kayceea.co.za:2079/addressbooks/=\r\nbooking@kayceea.co.za/addressbook</li>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20\r\n                          </ul>\r\n                      </td>\r\n                  </tr>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n              </table>\r\n          </div>\r\n         </div>\r\n=20=20=20=20=20=20=20=20=20\r\n        </div>\r\n      </div>\r\n    </div><p>\r\n A .mobileconfig file for use with iOS for iPhone/iPad/iPod and MacOS=C2=AE=\r\n Mail.app=C2=AE for Mountain Lion (10.8+) is attached to this message.\r\n</p>\r\n                                                                    </td>\r\n                                                                </tr>\r\n                                                                <tr>\r\n                                                                    <td>\r\n                                                                        <di=\r\nv style=3D\"font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;border-t=\r\nop: 2px solid #E8E8E8; padding-top:5px; margin-top: 5px; font-size:12px; co=\r\nlor: #666666;\">\r\n        <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;\">\r\n=20=20=20=20=20=20=20=20\r\n          This notice is the result of a request made by a computer with th=\r\ne <abbr title=3D\"Internet Protocol\">IP</abbr> address of =E2=80=9C197.184.8=\r\n2.54=E2=80=9D through the =E2=80=9Ccpanel=E2=80=9D service on the server.\r\n=20=20=20=20=20=20=20=20\r\n    </p>\r\n\r\n                        <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;\">\r\n                A reverse <abbr title=3D\"Domain Name Service\">DNS</abbr> lo=\r\nokup on the remote <abbr title=3D\"Internet Protocol\">IP</abbr> address retu=\r\nrned the host name =E2=80=9Crain-197-184-82-54.rain.network=E2=80=9D.\r\n            </p>\r\n                <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;\">\r\n                            The remote computer=E2=80=99s location appears =\r\nto be: South Africa (ZA).\r\n                    </p>\r\n=20=20=20=20=20=20=20=20\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n                <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;\">\r\n                  The remote computer=E2=80=99s <abbr title=3D\"Internet Pro=\r\ntocol\">IP</abbr> address is assigned to the provider: =E2=80=9Crain rain=E2=\r\n=80=9D\r\n                </p>\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n=20=20=20=20=20=20=20=20=20=20=20=20\r\n\r\n=20=20=20=20=20=20=20=20=20\r\n                            <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;=\r\n\">\r\n          The remote computer=E2=80=99s network link type appears to be: =\r\n=E2=80=9Cgeneric tunnel or VPN=E2=80=9D.\r\n        </p>\r\n                          <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;\">\r\n=20=20=20=20=20=20=20=20=20=20\r\n            The remote computer=E2=80=99s operating system appears to be: =\r\n=E2=80=9CWindows=E2=80=9D with version =E2=80=9CNT kernel 5.x=E2=80=9D.\r\n=20=20=20=20=20=20=20=20=20=20\r\n        </p>\r\n=20=20=20=20=20=20=20=20=20=20\r\n    <p style=3D\"padding:0 0 0 0; margin: 5px 0 0 0;\">\r\n        The system generated this notice on Tuesday, March 10, 2026 at 10:5=\r\n9:37 AM UTC.\r\n    </p>\r\n</div>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n                                                                           =\r\n<!-- -->\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20\r\n<p>\r\n    Do not reply to this automated message.\r\n</p>\r\n                                                                    </td>\r\n                                                                </tr>\r\n                                                            </tbody>\r\n                                                        </table>\r\n\r\n                                                    </td>\r\n                                                    <td width=3D\"15\">\r\n                                                    </td>\r\n                                                </tr>\r\n                                            </tbody>\r\n                                        </table>\r\n                                    </td>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20\r\n                                </tr>\r\n                                <tr>\r\n                                    <td align=3D\"center\" style=3D\"padding-t=\r\nop: 10px;\">\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20\r\n                                        <img src=3D\"cid:auto_cid_2140506619=\r\n\" height=3D\"25\" width=3D\"25\" style=3D\"border:0;line-height:100%;border:0\" a=\r\nlt=3D\"cP\">\r\n                                        <p style=3D\"font-family:\'Helvetica =\r\nNeue\',Helvetica,Arial,sans-serif;font-size:12px;color:#666666; padding: 0; =\r\nmargin: 0;\">Copyright=C2=A9=C2=A02026 cPanel, L.L.C.<p>\r\n=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=\r\n=20=20=20=20=20=20=20=20=20=20=20\r\n                                    </td>\r\n                                </tr>\r\n                            </tbody>\r\n                        </table>\r\n                    </td>\r\n                </tr>\r\n            </tbody>\r\n        </table>\r\n    </div>\r\n</body>=\r\n\r\n--related-Cpanel::Email::Object-661074-1773140377-0.837476258626111\r\nContent-Type: image/png; x-unix-mode=0600; name=\"cpanel-logo-tiny.png\"\r\nContent-Disposition: attachment; filename=\"cpanel-logo-tiny.png\"\r\nContent-ID: <auto_cid_2140506619>\r\nContent-Transfer-Encoding: base64\r\n\r\niVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAACXBIWXMAAAsTAAALEwEAmpwYAAAK\r\nT2lDQ1BQaG90b3Nob3AgSUNDIHByb2ZpbGUAAHjanVNnVFPpFj333vRCS4iAlEtvUhUIIFJCi4AU\r\nkSYqIQkQSoghodkVUcERRUUEG8igiAOOjoCMFVEsDIoK2AfkIaKOg6OIisr74Xuja9a89+bN/rXX\r\nPues852zzwfACAyWSDNRNYAMqUIeEeCDx8TG4eQuQIEKJHAAEAizZCFz/SMBAPh+PDwrIsAHvgAB\r\neNMLCADATZvAMByH/w/qQplcAYCEAcB0kThLCIAUAEB6jkKmAEBGAYCdmCZTAKAEAGDLY2LjAFAt\r\nAGAnf+bTAICd+Jl7AQBblCEVAaCRACATZYhEAGg7AKzPVopFAFgwABRmS8Q5ANgtADBJV2ZIALC3\r\nAMDOEAuyAAgMADBRiIUpAAR7AGDIIyN4AISZABRG8lc88SuuEOcqAAB4mbI8uSQ5RYFbCC1xB1dX\r\nLh4ozkkXKxQ2YQJhmkAuwnmZGTKBNA/g88wAAKCRFRHgg/P9eM4Ors7ONo62Dl8t6r8G/yJiYuP+\r\n5c+rcEAAAOF0ftH+LC+zGoA7BoBt/qIl7gRoXgugdfeLZrIPQLUAoOnaV/Nw+H48PEWhkLnZ2eXk\r\n5NhKxEJbYcpXff5nwl/AV/1s+X48/Pf14L7iJIEyXYFHBPjgwsz0TKUcz5IJhGLc5o9H/LcL//wd\r\n0yLESWK5WCoU41EScY5EmozzMqUiiUKSKcUl0v9k4t8s+wM+3zUAsGo+AXuRLahdYwP2SycQWHTA\r\n4vcAAPK7b8HUKAgDgGiD4c93/+8//UegJQCAZkmScQAAXkQkLlTKsz/HCAAARKCBKrBBG/TBGCzA\r\nBhzBBdzBC/xgNoRCJMTCQhBCCmSAHHJgKayCQiiGzbAdKmAv1EAdNMBRaIaTcA4uwlW4Dj1wD/ph\r\nCJ7BKLyBCQRByAgTYSHaiAFiilgjjggXmYX4IcFIBBKLJCDJiBRRIkuRNUgxUopUIFVIHfI9cgI5\r\nh1xGupE7yAAygvyGvEcxlIGyUT3UDLVDuag3GoRGogvQZHQxmo8WoJvQcrQaPYw2oefQq2gP2o8+\r\nQ8cwwOgYBzPEbDAuxsNCsTgsCZNjy7EirAyrxhqwVqwDu4n1Y8+xdwQSgUXACTYEd0IgYR5BSFhM\r\nWE7YSKggHCQ0EdoJNwkDhFHCJyKTqEu0JroR+cQYYjIxh1hILCPWEo8TLxB7iEPENyQSiUMyJ7mQ\r\nAkmxpFTSEtJG0m5SI+ksqZs0SBojk8naZGuyBzmULCAryIXkneTD5DPkG+Qh8lsKnWJAcaT4U+Io\r\nUspqShnlEOU05QZlmDJBVaOaUt2ooVQRNY9aQq2htlKvUYeoEzR1mjnNgxZJS6WtopXTGmgXaPdp\r\nr+h0uhHdlR5Ol9BX0svpR+iX6AP0dwwNhhWDx4hnKBmbGAcYZxl3GK+YTKYZ04sZx1QwNzHrmOeZ\r\nD5lvVVgqtip8FZHKCpVKlSaVGyovVKmqpqreqgtV81XLVI+pXlN9rkZVM1PjqQnUlqtVqp1Q61Mb\r\nU2epO6iHqmeob1Q/pH5Z/YkGWcNMw09DpFGgsV/jvMYgC2MZs3gsIWsNq4Z1gTXEJrHN2Xx2KruY\r\n/R27iz2qqaE5QzNKM1ezUvOUZj8H45hx+Jx0TgnnKKeX836K3hTvKeIpG6Y0TLkxZVxrqpaXllir\r\nSKtRq0frvTau7aedpr1Fu1n7gQ5Bx0onXCdHZ4/OBZ3nU9lT3acKpxZNPTr1ri6qa6UbobtEd79u\r\np+6Ynr5egJ5Mb6feeb3n+hx9L/1U/W36p/VHDFgGswwkBtsMzhg8xTVxbzwdL8fb8VFDXcNAQ6Vh\r\nlWGX4YSRudE8o9VGjUYPjGnGXOMk423GbcajJgYmISZLTepN7ppSTbmmKaY7TDtMx83MzaLN1pk1\r\nmz0x1zLnm+eb15vft2BaeFostqi2uGVJsuRaplnutrxuhVo5WaVYVVpds0atna0l1rutu6cRp7lO\r\nk06rntZnw7Dxtsm2qbcZsOXYBtuutm22fWFnYhdnt8Wuw+6TvZN9un2N/T0HDYfZDqsdWh1+c7Ry\r\nFDpWOt6azpzuP33F9JbpL2dYzxDP2DPjthPLKcRpnVOb00dnF2e5c4PziIuJS4LLLpc+Lpsbxt3I\r\nveRKdPVxXeF60vWdm7Obwu2o26/uNu5p7ofcn8w0nymeWTNz0MPIQ+BR5dE/C5+VMGvfrH5PQ0+B\r\nZ7XnIy9jL5FXrdewt6V3qvdh7xc+9j5yn+M+4zw33jLeWV/MN8C3yLfLT8Nvnl+F30N/I/9k/3r/\r\n0QCngCUBZwOJgUGBWwL7+Hp8Ib+OPzrbZfay2e1BjKC5QRVBj4KtguXBrSFoyOyQrSH355jOkc5p\r\nDoVQfujW0Adh5mGLw34MJ4WHhVeGP45wiFga0TGXNXfR3ENz30T6RJZE3ptnMU85ry1KNSo+qi5q\r\nPNo3ujS6P8YuZlnM1VidWElsSxw5LiquNm5svt/87fOH4p3iC+N7F5gvyF1weaHOwvSFpxapLhIs\r\nOpZATIhOOJTwQRAqqBaMJfITdyWOCnnCHcJnIi/RNtGI2ENcKh5O8kgqTXqS7JG8NXkkxTOlLOW5\r\nhCepkLxMDUzdmzqeFpp2IG0yPTq9MYOSkZBxQqohTZO2Z+pn5mZ2y6xlhbL+xW6Lty8elQfJa7OQ\r\nrAVZLQq2QqboVFoo1yoHsmdlV2a/zYnKOZarnivN7cyzytuQN5zvn//tEsIS4ZK2pYZLVy0dWOa9\r\nrGo5sjxxedsK4xUFK4ZWBqw8uIq2Km3VT6vtV5eufr0mek1rgV7ByoLBtQFr6wtVCuWFfevc1+1d\r\nT1gvWd+1YfqGnRs+FYmKrhTbF5cVf9go3HjlG4dvyr+Z3JS0qavEuWTPZtJm6ebeLZ5bDpaql+aX\r\nDm4N2dq0Dd9WtO319kXbL5fNKNu7g7ZDuaO/PLi8ZafJzs07P1SkVPRU+lQ27tLdtWHX+G7R7ht7\r\nvPY07NXbW7z3/T7JvttVAVVN1WbVZftJ+7P3P66Jqun4lvttXa1ObXHtxwPSA/0HIw6217nU1R3S\r\nPVRSj9Yr60cOxx++/p3vdy0NNg1VjZzG4iNwRHnk6fcJ3/ceDTradox7rOEH0x92HWcdL2pCmvKa\r\nRptTmvtbYlu6T8w+0dbq3nr8R9sfD5w0PFl5SvNUyWna6YLTk2fyz4ydlZ19fi753GDborZ752PO\r\n32oPb++6EHTh0kX/i+c7vDvOXPK4dPKy2+UTV7hXmq86X23qdOo8/pPTT8e7nLuarrlca7nuer21\r\ne2b36RueN87d9L158Rb/1tWeOT3dvfN6b/fF9/XfFt1+cif9zsu72Xcn7q28T7xf9EDtQdlD3YfV\r\nP1v+3Njv3H9qwHeg89HcR/cGhYPP/pH1jw9DBY+Zj8uGDYbrnjg+OTniP3L96fynQ89kzyaeF/6i\r\n/suuFxYvfvjV69fO0ZjRoZfyl5O/bXyl/erA6xmv28bCxh6+yXgzMV70VvvtwXfcdx3vo98PT+R8\r\nIH8o/2j5sfVT0Kf7kxmTk/8EA5jz/GMzLdsAADr7aVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8\r\nP3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4\r\nbXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA1\r\nLjYtYzAxNCA3OS4xNTY3OTcsIDIwMTQvMDgvMjAtMDk6NTM6MDIgICAgICAgICI+CiAgIDxyZGY6\r\nUkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5z\r\nIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5z\r\nOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgICAgICAgICAgeG1sbnM6eG1w\r\nTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0\r\nRXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiCiAg\r\nICAgICAgICAgIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3Av\r\nMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8x\r\nLjEvIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4w\r\nLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8i\r\nPgogICAgICAgICA8eG1wOkNyZWF0b3JUb29sPkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE0IChNYWNp\r\nbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDx4bXA6Q3JlYXRlRGF0ZT4yMDE1LTAz\r\nLTIyVDA3OjUwOjI4LTA1OjAwPC94bXA6Q3JlYXRlRGF0ZT4KICAgICAgICAgPHhtcDpNZXRhZGF0\r\nYURhdGU+MjAxNS0wMy0yMlQwNzo1MDoyOC0wNTowMDwveG1wOk1ldGFkYXRhRGF0ZT4KICAgICAg\r\nICAgPHhtcDpNb2RpZnlEYXRlPjIwMTUtMDMtMjJUMDc6NTA6MjgtMDU6MDA8L3htcDpNb2RpZnlE\r\nYXRlPgogICAgICAgICA8eG1wTU06SW5zdGFuY2VJRD54bXAuaWlkOmQxMDU0MzZlLWY5ZTAtNDkx\r\nMS1iZTFiLTcwMzcxNDM4NTA4MjwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcE1NOkRv\r\nY3VtZW50SUQ+YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjVmYTlmM2I1LTExMjAtMTE3OC1iOTIzLWZi\r\nMjdlNDc0YmQzYTwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9j\r\ndW1lbnRJRD54bXAuZGlkOjA4ZTkxZjNlLWU3MjQtNDYzNC04YmJlLTFiNzRlNzMwMTA3NTwveG1w\r\nTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8eG1wTU06SGlzdG9yeT4KICAgICAgICAg\r\nICAgPHJkZjpTZXE+CiAgICAgICAgICAgICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0iUmVzb3Vy\r\nY2UiPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6YWN0aW9uPmNyZWF0ZWQ8L3N0RXZ0OmFjdGlv\r\nbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0Omluc3RhbmNlSUQ+eG1wLmlpZDowOGU5MWYzZS1l\r\nNzI0LTQ2MzQtOGJiZS0xYjc0ZTczMDEwNzU8L3N0RXZ0Omluc3RhbmNlSUQ+CiAgICAgICAgICAg\r\nICAgICAgIDxzdEV2dDp3aGVuPjIwMTUtMDMtMjJUMDc6NTA6MjgtMDU6MDA8L3N0RXZ0OndoZW4+\r\nCiAgICAgICAgICAgICAgICAgIDxzdEV2dDpzb2Z0d2FyZUFnZW50PkFkb2JlIFBob3Rvc2hvcCBD\r\nQyAyMDE0IChNYWNpbnRvc2gpPC9zdEV2dDpzb2Z0d2FyZUFnZW50PgogICAgICAgICAgICAgICA8\r\nL3JkZjpsaT4KICAgICAgICAgICAgICAgPHJkZjpsaSByZGY6cGFyc2VUeXBlPSJSZXNvdXJjZSI+\r\nCiAgICAgICAgICAgICAgICAgIDxzdEV2dDphY3Rpb24+c2F2ZWQ8L3N0RXZ0OmFjdGlvbj4KICAg\r\nICAgICAgICAgICAgICAgPHN0RXZ0Omluc3RhbmNlSUQ+eG1wLmlpZDpkMTA1NDM2ZS1mOWUwLTQ5\r\nMTEtYmUxYi03MDM3MTQzODUwODI8L3N0RXZ0Omluc3RhbmNlSUQ+CiAgICAgICAgICAgICAgICAg\r\nIDxzdEV2dDp3aGVuPjIwMTUtMDMtMjJUMDc6NTA6MjgtMDU6MDA8L3N0RXZ0OndoZW4+CiAgICAg\r\nICAgICAgICAgICAgIDxzdEV2dDpzb2Z0d2FyZUFnZW50PkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE0\r\nIChNYWNpbnRvc2gpPC9zdEV2dDpzb2Z0d2FyZUFnZW50PgogICAgICAgICAgICAgICAgICA8c3RF\r\ndnQ6Y2hhbmdlZD4vPC9zdEV2dDpjaGFuZ2VkPgogICAgICAgICAgICAgICA8L3JkZjpsaT4KICAg\r\nICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L3htcE1NOkhpc3Rvcnk+CiAgICAgICAgIDxw\r\naG90b3Nob3A6RG9jdW1lbnRBbmNlc3RvcnM+CiAgICAgICAgICAgIDxyZGY6QmFnPgogICAgICAg\r\nICAgICAgICA8cmRmOmxpPnhtcC5kaWQ6NEMxRkU2RTZCQzREMTFFNEI3MDg5OEZGODlDRkQ2RUU8\r\nL3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6QmFnPgogICAgICAgICA8L3Bob3Rvc2hvcDpEb2N1\r\nbWVudEFuY2VzdG9ycz4KICAgICAgICAgPHBob3Rvc2hvcDpDb2xvck1vZGU+MzwvcGhvdG9zaG9w\r\nOkNvbG9yTW9kZT4KICAgICAgICAgPHBob3Rvc2hvcDpJQ0NQcm9maWxlPnNSR0IgSUVDNjE5NjYt\r\nMi4xPC9waG90b3Nob3A6SUNDUHJvZmlsZT4KICAgICAgICAgPGRjOmZvcm1hdD5pbWFnZS9wbmc8\r\nL2RjOmZvcm1hdD4KICAgICAgICAgPHRpZmY6T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlv\r\nbj4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzIwMDAwLzEwMDAwPC90aWZmOlhSZXNvbHV0\r\naW9uPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjAwMDAvMTAwMDA8L3RpZmY6WVJlc29s\r\ndXRpb24+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVu\r\naXQ+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAg\r\nICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+MjU8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAg\r\nICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+MjU8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8\r\nL3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAK\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAog\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAK\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAog\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg\r\nICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/Ph0AdIcAAAAgY0hSTQAAeiUAAICDAAD5/wAAgOkA\r\nAHUwAADqYAAAOpgAABdvkl/FRgAAAclJREFUeNrs1s+LjVEYB/DPHe7EYjY2wsaPjaZBZDQLEZGF\r\nhSwkNdlIWbC2UEr5D8ZGSX4sJJINaQjlNkn5lcVMSuSWaagZXImYrsU8N6fT6/JOkcV869T7nOc5\r\n53vO83yf930rzWbT30aHf4AZklKYDQ6tKLvmODZiFpqo4CvquIlzmAQDz4KkHNbjcBv/HvTHGJ1u\r\nunb9QcxmXEHX70g6UI30VNEZ6enN4ibxrWB9H/YWkczBPlzCYzyN8QS30YNlSfwo1mElNuFatt/O\r\nn4WfwgJciIIW4QHmY14ydxeP4nkEDzGMRTG3NL1JJ862IYAaVmVz+ckbmCiW8FQxt2a+LyFLIc2T\r\nOJ/4v8ftUuzH8sSupyQ7suCLOIJP0QMTkaa0oV7gPQbQHUpaG/Et3ElJ+hLHmzhRIyPuxdzEvoqD\r\nMYrwDqfTmnRlaWoULNqS2UNtavg55Ps6JRlJApbgaPRGC1VsS+yP+IDVBZtfDjnfyAt/PUlZBcew\r\nO2oyhBNYnGz2KvpneyaEMbz8lbrO4AAWJr7uRJY9IfMWBqPotTKv+nqcfKwgZrBA3rem+z2pYQNO\r\n4TnG8Rb3sCbs8cj1/TIklZkfif+O5McA9Y1iuiAu5qQAAAAASUVORK5CYII=\r\n\r\n--related-Cpanel::Email::Object-661074-1773140377-0.837476258626111--','2026-03-10 09:59:37'),(19,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Stephen Masimba (2026-03-31 08:30)','New booking request\r\n\r\nName: Stephen Masimba\r\nEmail: stephentmasimba@gmail.com\r\nPhone: 0697316145\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-03-31\r\nTime: 08:30\r\nService ID: 1\r\n\r\nNotes:\r\nakoi','2026-03-27 07:38:06'),(20,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Angela D Too (2026-03-27 13:30)','New booking request\r\n\r\nName: Angela D Too\r\nEmail: stephentmasimba@gmail.com\r\nPhone: 0697316145\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-03-27\r\nTime: 13:30\r\nService ID: 1\r\n\r\nNotes:\r\ncheck again','2026-03-27 06:14:38'),(21,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Test Client (2026-03-30 10:00)','New booking request\r\n\r\nName: Test Client\r\nEmail: test@example.com\r\nPhone: 0123456789\r\nProvider: Kgomotso Caroline Sebeela\r\nType: online\r\nDate: 2026-03-30\r\nTime: 10:00\r\nService ID: 1\r\n\r\nNotes:\r\ntest','2026-03-27 06:12:46'),(22,'Kaycee & Associates ','MISSING_MAILBOX@MISSING_DOMAIN','New Booking - Angela D Too (2026-03-27 14:00)','New booking request\r\n\r\nName: Angela D Too\r\nEmail: stephentmasimba@gmail.com\r\nPhone: 0697316145\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-03-27\r\nTime: 14:00\r\nService ID: 1\r\n\r\nNotes:\r\ncheck now','2026-03-27 06:03:43'),(23,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Angela D Too (2026-03-27 14:00)','New booking request\r\n\r\nName: Angela D Too\r\nEmail: stephentmasimba@gmail.com\r\nPhone: 0697316145\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-03-27\r\nTime: 14:00\r\nService ID: 1\r\n\r\nNotes:\r\ncheck now','2026-03-27 06:03:38'),(24,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - William Grindel (2026-04-01 09:00)','New booking request\r\n\r\nName: William Grindel\r\nEmail: Mikegrindel1984@gmail.com\r\nPhone: 0788181808\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-04-01\r\nTime: 09:00\r\nService ID: 1','2026-03-30 08:29:29'),(25,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Maxine Daniels (2026-04-09 18:00)','New booking request\r\n\r\nName: Maxine Daniels\r\nEmail: maxine739@gmail.com\r\nPhone: 0787150076\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-04-09\r\nTime: 18:00\r\nService ID: 4','2026-04-03 05:11:48'),(26,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Nosipho Mhlongo (2026-04-03 12:00)','New booking request\r\n\r\nName: Nosipho Mhlongo\r\nEmail: nosipho.mhlongo.NM@gmail.com\r\nPhone: 0782105974\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-04-03\r\nTime: 12:00\r\nService ID: 1','2026-04-02 07:28:34'),(27,'Microsoft account team ','account-security-noreply@accountprotection.microsoft.com','Verify your email address','Microsoft account\r\n\r\nVerify your email address\r\n\r\nTo finish setting up your Microsoft account, we just need to make sure this email address is yours.\r\n\r\nTo verify your email address use this security code: 243039\r\n\r\nIf you didn\'t request this code, you can safely ignore this email. Someone else might have typed your email address by mistake.\r\n\r\nThanks,\r\nThe Microsoft account team \r\nPrivacy Statement: https://go.microsoft.com/fwlink/?LinkId=521839\r\nMicrosoft Corporation, One Microsoft Way, Redmond, WA 98052','2026-04-08 06:37:14'),(28,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Wanga Amanda Muchocho-Makhokha (2026-04-11 10:30)','New booking request\r\n\r\nName: Wanga Amanda Muchocho-Makhokha\r\nEmail: amandamunyai@gmail.com\r\nPhone: 0712657318\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-04-11\r\nTime: 10:30\r\nService ID: 4','2026-04-06 17:46:11'),(29,'Skill Up ','kamran@skill-up.org','Branded Learning','Hi,\r\n\r\nWhy not explore a new business opportunity now? You could introduce a\r\nunique online training model in your local market  without building courses\r\nor a platform yourself.\r\n\r\nSkill Up allows *you to resell 2,500+ CPD Quality Standards=E2=80=93accredi=\r\nted\r\ncourses under your own brand*. We handle the content, platform, and\r\ncertification. You focus on branding, pricing, and growing your learners.\r\n\r\nWould you be open to a quick 10-minute call to see if this fits your plans?\r\n\r\nKind regards,\r\nKamran Hussain\r\nBusiness Development Manager\r\nSkill Up','2026-04-10 06:30:23'),(30,'Kaycee & Associates ','booking@kayceea.co.za','New Booking - Natasche Daniels (2026-04-17 17:00)','New booking request\r\n\r\nName: Natasche Daniels\r\nEmail: nataschecdaniels@gmail.com\r\nPhone: 0817839923\r\nProvider: Kgomotso Caroline Sebeela\r\nType: undefined\r\nDate: 2026-04-17\r\nTime: 17:00\r\nService ID: 1','2026-04-08 12:19:14'),(31,'Microsoft account team ','account-security-noreply@accountprotection.microsoft.com','Verify your email address','Microsoft account\r\n\r\nVerify your email address\r\n\r\nTo finish setting up your Microsoft account, we just need to make sure this email address is yours.\r\n\r\nTo verify your email address use this security code: 755946\r\n\r\nIf you didn\'t request this code, you can safely ignore this email. Someone else might have typed your email address by mistake.\r\n\r\nThanks,\r\nThe Microsoft account team \r\nPrivacy Statement: https://go.microsoft.com/fwlink/?LinkId=521839\r\nMicrosoft Corporation, One Microsoft Way, Redmond, WA 98052','2026-04-08 09:04:39');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_logs`
--

DROP TABLE IF EXISTS `notification_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `recipient` varchar(100) NOT NULL,
  `status` varchar(50) DEFAULT NULL,
  `message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `response` text,
  PRIMARY KEY (`id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_type_status` (`type`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_logs`
--

LOCK TABLES `notification_logs` WRITE;
/*!40000 ALTER TABLE `notification_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_settings`
--

DROP TABLE IF EXISTS `notification_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_settings`
--

LOCK TABLES `notification_settings` WRITE;
/*!40000 ALTER TABLE `notification_settings` DISABLE KEYS */;
INSERT INTO `notification_settings` VALUES ('cancellation_notice_hours','2','2026-04-02 07:28:18'),('follow_up_days_after','1','2026-04-02 07:28:18'),('reminder_hours_before','24','2026-04-02 07:28:18'),('sms_api_key','','2026-04-02 07:28:18'),('sms_enabled','0','2026-04-02 07:28:18'),('sms_sender_id','Kaycee','2026-04-02 07:28:18'),('whatsapp_access_token','EAALhJGdL7B0BRFzo1g3o43vwytyOSg5PlPZCfxFZAn057qhSjFSQ7i4l8gvX2WWVWhvJ2eghmsKZAX4bxxdrPNt29UOx2vlVyovTKFTd3ZC1MZBJN9gS2PIMz0X1Fhy0ESsZALeJYmlxMt3t6f99Cl5QSEIndytZA6y1JCRbDH5GuOctFQNUnSjH0sED6VWzihlaYbbUqF5f5hwllsWCwP0wKU2oQ3JCv4Renutf1ITcwhQ9JS2j76w3HkPqh3ce6sDtFHkKbETSqOWkjDKSOAAv2ZC3','2026-04-02 07:28:18'),('whatsapp_enabled','1','2026-04-02 07:28:18'),('whatsapp_phone_number_id',' 1041753955693962','2026-04-02 07:28:18'),('whatsapp_webhook_verify_token','kaycee_whatsapp_webhook_2024','2026-04-02 07:28:18');
/*!40000 ALTER TABLE `notification_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_settings_legacy`
--

DROP TABLE IF EXISTS `notification_settings_legacy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_settings_legacy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sms_enabled` tinyint(1) DEFAULT '0',
  `sms_api_key` text,
  `sms_sender_id` varchar(100) DEFAULT 'Kaycee',
  `whatsapp_enabled` tinyint(1) DEFAULT '0',
  `whatsapp_access_token` text,
  `whatsapp_phone_number_id` varchar(255) DEFAULT NULL,
  `whatsapp_webhook_verify_token` varchar(255) DEFAULT NULL,
  `reminder_hours_before` int DEFAULT '24',
  `follow_up_days_after` int DEFAULT '1',
  `cancellation_notice_hours` int DEFAULT '2',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_settings_legacy`
--

LOCK TABLES `notification_settings_legacy` WRITE;
/*!40000 ALTER TABLE `notification_settings_legacy` DISABLE KEYS */;
INSERT INTO `notification_settings_legacy` VALUES (1,0,'','Kaycee',1,'EAALhJGdL7B0BRFzo1g3o43vwytyOSg5PlPZCfxFZAn057qhSjFSQ7i4l8gvX2WWVWhvJ2eghmsKZAX4bxxdrPNt29UOx2vlVyovTKFTd3ZC1MZBJN9gS2PIMz0X1Fhy0ESsZALeJYmlxMt3t6f99Cl5QSEIndytZA6y1JCRbDH5GuOctFQNUnSjH0sED6VWzihlaYbbUqF5f5hwllsWCwP0wKU2oQ3JCv4Renutf1ITcwhQ9JS2j76w3HkPqh3ce6sDtFHkKbETSqOWkjDKSOAAv2ZC3',' 1041753955693962','kaycee_whatsapp_webhook_2024',24,1,2,'2026-03-27 11:37:46','2026-03-27 11:37:46');
/*!40000 ALTER TABLE `notification_settings_legacy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `outlook_events`
--

DROP TABLE IF EXISTS `outlook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `outlook_events` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `booking_id` int unsigned DEFAULT NULL,
  `outlook_id` varchar(255) NOT NULL,
  `change_key` varchar(255) DEFAULT NULL,
  `subject` varchar(500) DEFAULT NULL,
  `start_datetime` datetime DEFAULT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'Africa/Johannesburg',
  `description` text,
  `location` varchar(255) DEFAULT NULL,
  `is_all_day` tinyint(1) DEFAULT '0',
  `status` enum('active','deleted') DEFAULT 'active',
  `modified_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_synced_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `outlook_id` (`outlook_id`),
  UNIQUE KEY `idx_user_outlook` (`user_id`,`outlook_id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_user_status` (`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outlook_events`
--

LOCK TABLES `outlook_events` WRITE;
/*!40000 ALTER TABLE `outlook_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `outlook_events` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_outlook_events_insert` AFTER INSERT ON `outlook_events` FOR EACH ROW BEGIN
  INSERT INTO outlook_webhook_notifications (subscription_id, resource, change_type, client_state, payload)
  VALUES (NEW.user_id, NEW.outlook_id, 'created', NULL, JSON_OBJECT('event_id', NEW.outlook_id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `outlook_sync_users`
--

DROP TABLE IF EXISTS `outlook_sync_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `outlook_sync_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `delta_link` text,
  `last_sync` datetime DEFAULT NULL,
  `refresh_token` text,
  `access_token` text,
  `token_expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outlook_sync_users`
--

LOCK TABLES `outlook_sync_users` WRITE;
/*!40000 ALTER TABLE `outlook_sync_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `outlook_sync_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `outlook_webhook_notifications`
--

DROP TABLE IF EXISTS `outlook_webhook_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `outlook_webhook_notifications` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `subscription_id` varchar(255) DEFAULT NULL,
  `resource` varchar(255) DEFAULT NULL,
  `change_type` varchar(50) DEFAULT NULL,
  `client_state` varchar(255) DEFAULT NULL,
  `received_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payload` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_subscription_resource` (`subscription_id`,`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outlook_webhook_notifications`
--

LOCK TABLES `outlook_webhook_notifications` WRITE;
/*!40000 ALTER TABLE `outlook_webhook_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `outlook_webhook_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_history`
--

DROP TABLE IF EXISTS `payment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_history` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `action` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL,
  `transaction_id` varchar(191) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `notes` text,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_action_status` (`action`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_history`
--

LOCK TABLES `payment_history` WRITE;
/*!40000 ALTER TABLE `payment_history` DISABLE KEYS */;
INSERT INTO `payment_history` VALUES (1,17,'charge','pending',NULL,0.00,'','system','2026-03-27 07:03:34'),(2,18,'charge','pending',NULL,0.00,'','system','2026-03-27 07:03:39'),(3,20,'charge','pending',NULL,0.00,'','system','2026-03-27 07:12:43'),(4,21,'charge','pending',NULL,0.00,'','system','2026-03-27 07:14:36'),(5,22,'charge','pending',NULL,0.00,'','system','2026-03-27 08:38:03');
/*!40000 ALTER TABLE `payment_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provider_schedule`
--

DROP TABLE IF EXISTS `provider_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_schedule` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `provider_id` int unsigned NOT NULL,
  `day_of_week` tinyint unsigned NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_schedule` (`provider_id`,`day_of_week`),
  CONSTRAINT `provider_schedule_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_schedule`
--

LOCK TABLES `provider_schedule` WRITE;
/*!40000 ALTER TABLE `provider_schedule` DISABLE KEYS */;
/*!40000 ALTER TABLE `provider_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provider_unavailability`
--

DROP TABLE IF EXISTS `provider_unavailability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_unavailability` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `provider_name` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `note` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_name` (`provider_name`),
  KEY `idx_start_end` (`start_date`,`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_unavailability`
--

LOCK TABLES `provider_unavailability` WRITE;
/*!40000 ALTER TABLE `provider_unavailability` DISABLE KEYS */;
/*!40000 ALTER TABLE `provider_unavailability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `providers`
--

DROP TABLE IF EXISTS `providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `providers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT '',
  `role` varchar(255) DEFAULT '',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `providers`
--

LOCK TABLES `providers` WRITE;
/*!40000 ALTER TABLE `providers` DISABLE KEYS */;
INSERT INTO `providers` VALUES (1,'Kgomotso Caroline Sebeela','Caroline@kayceea.co.za','therapist',1,'2026-04-02 06:40:09','2026-04-16 13:47:07'),(2,'Elizabeth Mathibe','Elizabeth@kayceea.co.za','psychometrist',1,'2026-04-02 06:40:09','2026-04-16 13:46:50');
/*!40000 ALTER TABLE `providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `psychometrist_services`
--

DROP TABLE IF EXISTS `psychometrist_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `psychometrist_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` mediumtext,
  `display_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `psychometrist_services`
--

LOCK TABLES `psychometrist_services` WRITE;
/*!40000 ALTER TABLE `psychometrist_services` DISABLE KEYS */;
/*!40000 ALTER TABLE `psychometrist_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_name` varchar(100) NOT NULL,
  `day_of_week` tinyint NOT NULL,
  `start_time` varchar(5) DEFAULT '09:00',
  `end_time` varchar(5) DEFAULT '17:00',
  `is_available` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_schedule` (`provider_name`,`day_of_week`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
INSERT INTO `schedules` VALUES (1,'Kgomotso Caroline Sebeela',0,'08:00','17:00',0,'2026-03-09 16:39:46'),(2,'Kgomotso Caroline Sebeela',1,'08:00','17:00',1,'2026-03-09 16:39:46'),(3,'Kgomotso Caroline Sebeela',2,'08:00','17:00',1,'2026-03-09 16:39:46'),(4,'Kgomotso Caroline Sebeela',3,'08:00','17:00',1,'2026-03-09 16:39:46'),(5,'Kgomotso Caroline Sebeela',4,'08:00','17:00',1,'2026-03-09 16:39:46'),(6,'Kgomotso Caroline Sebeela',5,'08:00','17:00',1,'2026-03-09 16:39:46'),(7,'Kgomotso Caroline Sebeela',6,'08:00','17:00',0,'2026-03-09 16:39:46'),(8,'Elizabeth Mathibe',0,'08:00','17:00',0,'2026-03-09 16:39:46'),(9,'Elizabeth Mathibe',1,'08:00','17:00',1,'2026-03-09 16:39:46'),(10,'Elizabeth Mathibe',2,'08:00','17:00',1,'2026-03-09 16:39:46'),(11,'Elizabeth Mathibe',3,'08:00','17:00',1,'2026-03-09 16:39:46'),(12,'Elizabeth Mathibe',4,'08:00','17:00',1,'2026-03-09 16:39:46'),(13,'Elizabeth Mathibe',5,'08:00','17:00',1,'2026-03-09 16:39:46'),(14,'Elizabeth Mathibe',6,'08:00','17:00',0,'2026-03-09 16:39:46');
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_location_prices`
--

DROP TABLE IF EXISTS `service_location_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_location_prices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_id` int NOT NULL,
  `location_id` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_service_location` (`service_id`,`location_id`),
  KEY `idx_service_id` (`service_id`),
  KEY `idx_location_id` (`location_id`),
  CONSTRAINT `service_location_prices_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_location_prices_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_location_prices`
--

LOCK TABLES `service_location_prices` WRITE;
/*!40000 ALTER TABLE `service_location_prices` DISABLE KEYS */;
INSERT INTO `service_location_prices` VALUES (3,1,2,650.00,'2026-03-25 14:56:11','2026-03-25 14:56:11'),(4,1,1,500.00,'2026-03-25 14:56:11','2026-03-25 14:56:11'),(5,1,3,500.00,'2026-03-25 14:56:11','2026-03-25 14:56:11');
/*!40000 ALTER TABLE `service_location_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `icon` varchar(50) DEFAULT 'activity',
  `duration` int DEFAULT '60',
  `price` decimal(10,2) DEFAULT '850.00',
  `description` text,
  `points` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `category` varchar(100) DEFAULT 'General',
  `tags` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (1,'Individual Counselling','user',60,500.00,'Individual counselling provides a confidential space to explore personal challenges and develop healthier ways of coping with emotional difficulties.','[\"Anxiety and depression\",\"Stress and burnout\",\"Self-esteem and personal growth\",\"Life transitions\",\"Trauma and emotional distress\",\"Unresolved childhood issues\",\"Chronic illness support\",\"Bereavement\"]','2026-03-10 09:09:26','therapy',''),(2,'Addiction Counselling','shield-alert',60,500.00,'Addiction counselling supports individuals who are struggling with substance use or addictive behaviours.','[\"Understanding triggers and underlying causes\",\"Developing healthy coping strategies\",\"Relapse prevention\",\"Supporting long-term recovery\"]','2026-03-10 09:09:26','therapy',NULL),(3,'Trauma and Crisis Counselling','activity',60,500.00,'Traumatic experiences can affect emotional and psychological well-being. Trauma counselling helps individuals process these experiences.','[\"Process traumatic experiences\",\"Manage emotional distress\",\"Develop coping strategies\",\"Restore a sense of safety and stability\"]','2026-03-10 09:09:26','therapy',NULL),(4,'Couples and Relationship Counselling','users',90,600.00,'Relationship counselling helps couples improve communication, resolve conflicts, and strengthen emotional connection.','[\"Communication challenges\",\"Trust issues\",\"Conflict resolution\",\"Relationship stress\",\"Infidelity\"]','2026-03-10 09:09:26','therapy',NULL),(5,'Employee Assistance Programme (EAP)','briefcase',60,500.00,'Confidential counselling services for employees experiencing personal or work-related challenges.','[\"Employee counselling sessions\",\"Trauma debriefing\",\"Stress management support\",\"Mental health awareness programmes\",\"Facilitate and implement wellness workshops\"]','2026-03-10 09:09:26','therapy',NULL),(6,'Stress & Burnout Management','sun',60,500.00,'Helping individuals develop healthy coping mechanisms to manage workplace stress and prevent burnout.','[\"Identify stressors\",\"Develop resilience\",\"Work-life balance strategies\",\"Mindfulness techniques\"]','2026-03-10 09:09:26','therapy',NULL),(7,'Psychometric Assessments','brain',120,2500.00,'Comprehensive educational, IQ, career, and cognitive assessments administered by a registered Psychometrist.','[\"Educational assessments for learning difficulties\",\"Career path identification\",\"IQ and cognitive assessments\",\"Medicolegal assessments\",\"Comprehensive reporting and remedial recommendations\"]','2026-03-10 09:09:26','psychometric',NULL),(8,'15-minute Discovery Call','phone',15,0.00,'Complimentary 15-minute discovery call to understand your needs and suggest the best next step.','[\"Brief intro\",\"Clarify goals\",\"Recommend next step\"]','2026-04-07 16:01:30','therapy','discovery,call,complimentary');
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_settings`
--

DROP TABLE IF EXISTS `site_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(191) NOT NULL,
  `setting_value` text NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_site_settings_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_settings`
--

LOCK TABLES `site_settings` WRITE;
/*!40000 ALTER TABLE `site_settings` DISABLE KEYS */;
INSERT INTO `site_settings` VALUES (1,'cache:admin_dashboard_v1','{\"ts\":1776519026,\"value\":{\"stats\":{\"total\":21,\"pending\":5,\"confirmed\":14,\"cancelled\":1,\"messages\":31,\"outlook_users\":0,\"outlook_last_sync\":null,\"outlook_events\":0,\"outlook_tokens_expiring_24h\":0,\"outlook_webhook_24h\":0,\"outlook_webhook_last_received\":null,\"outlook_webhook_last_run\":null,\"waitlisted\":0,\"overcapacity_groups\":0,\"last_7_days\":1,\"monthly_revenue\":0,\"trend_data\":[{\"day\":\"2026-03-20\",\"count\":1},{\"day\":\"2026-03-21\",\"count\":1},{\"day\":\"2026-03-26\",\"count\":1},{\"day\":\"2026-03-27\",\"count\":3},{\"day\":\"2026-03-30\",\"count\":3},{\"day\":\"2026-03-31\",\"count\":2},{\"day\":\"2026-04-16\",\"count\":1}],\"outlook_webhook_failures_24h\":0},\"bookings\":[{\"id\":22,\"service_id\":1,\"location_id\":3,\"location_name\":\"Wellness Center\",\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"\",\"date\":\"2026-03-31\",\"time\":\"08:30:00\",\"name\":\"Stephen Masimba\",\"email\":\"stephentmasimba@gmail.com\",\"phone\":\"0697316145\",\"notes\":\"akoi\",\"status\":\"pending\",\"paid\":0,\"payment_method\":\"Offline\",\"amount_paid\":\"0.00\",\"amount_due\":\"500.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":\"RCPT-20260327-3234\",\"updated_at\":\"2026-03-27 10:38:03\",\"created_at\":\"2026-03-27 10:38:03\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":21,\"service_id\":1,\"location_id\":2,\"location_name\":\"In-Person | Rivonia Therapy Centre\",\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"\",\"date\":\"2026-03-27\",\"time\":\"13:30:00\",\"name\":\"Angela D Too\",\"email\":\"stephentmasimba@gmail.com\",\"phone\":\"0697316145\",\"notes\":\"check again\",\"status\":\"confirmed\",\"paid\":0,\"payment_method\":\"Offline\",\"amount_paid\":\"0.00\",\"amount_due\":\"650.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":\"RCPT-20260327-9777\",\"updated_at\":\"2026-03-27 09:21:56\",\"created_at\":\"2026-03-27 09:14:36\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":20,\"service_id\":1,\"location_id\":null,\"location_name\":\"Online Session\",\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"online\",\"date\":\"2026-03-30\",\"time\":\"10:00:00\",\"name\":\"Test Client\",\"email\":\"test@example.com\",\"phone\":\"0123456789\",\"notes\":\"test\",\"status\":\"pending\",\"paid\":0,\"payment_method\":\"Offline\",\"amount_paid\":\"0.00\",\"amount_due\":\"500.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":\"RCPT-20260327-9362\",\"updated_at\":\"2026-03-27 09:12:43\",\"created_at\":\"2026-03-27 09:12:43\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":18,\"service_id\":1,\"location_id\":2,\"location_name\":\"In-Person | Rivonia Therapy Centre\",\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"\",\"date\":\"2026-03-27\",\"time\":\"14:00:00\",\"name\":\"Angela D Too\",\"email\":\"stephentmasimba@gmail.com\",\"phone\":\"0697316145\",\"notes\":\"check now \",\"status\":\"pending\",\"paid\":0,\"payment_method\":\"Offline\",\"amount_paid\":\"0.00\",\"amount_due\":\"650.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":\"RCPT-20260327-2365\",\"updated_at\":\"2026-03-27 09:03:39\",\"created_at\":\"2026-03-27 09:03:39\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":17,\"service_id\":1,\"location_id\":2,\"location_name\":\"In-Person | Rivonia Therapy Centre\",\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"\",\"date\":\"2026-03-27\",\"time\":\"14:00:00\",\"name\":\"Angela D Too\",\"email\":\"stephentmasimba@gmail.com\",\"phone\":\"0697316145\",\"notes\":\"check now \",\"status\":\"pending\",\"paid\":0,\"payment_method\":\"Offline\",\"amount_paid\":\"0.00\",\"amount_due\":\"650.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":\"RCPT-20260327-2416\",\"updated_at\":\"2026-03-27 09:03:34\",\"created_at\":\"2026-03-27 09:03:34\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":16,\"service_id\":7,\"location_id\":null,\"location_name\":null,\"provider\":\"Elizabeth Mathibe\",\"type\":\"online\",\"date\":\"2026-03-19\",\"time\":\"09:00:00\",\"name\":\"Stephen Masimba\",\"email\":\"masimbastephen92@gmail.com\",\"phone\":\"0697316145\",\"notes\":\"This is what I want, right ke Kgomotso?\",\"status\":\"confirmed\",\"paid\":0,\"payment_method\":null,\"amount_paid\":\"0.00\",\"amount_due\":\"0.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":null,\"updated_at\":\"2026-03-22 02:15:35\",\"created_at\":\"2026-03-17 05:07:09\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Psychometric Assessments\"},{\"id\":15,\"service_id\":2,\"location_id\":null,\"location_name\":null,\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"in-person\",\"date\":\"2026-03-17\",\"time\":\"10:00:00\",\"name\":\"Kay\",\"email\":\"Kcsebeela@gmail.com\",\"phone\":\"0782003457\",\"notes\":\"\",\"status\":\"confirmed\",\"paid\":0,\"payment_method\":null,\"amount_paid\":\"0.00\",\"amount_due\":\"0.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":null,\"updated_at\":\"2026-03-22 02:15:35\",\"created_at\":\"2026-03-16 19:13:56\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Addiction Counselling\"},{\"id\":14,\"service_id\":1,\"location_id\":null,\"location_name\":null,\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"online\",\"date\":\"2026-03-31\",\"time\":\"13:00:00\",\"name\":\"Tlou Monama\",\"email\":\"tloumonama@gmail.com\",\"phone\":\"0798437218\",\"notes\":\"\",\"status\":\"confirmed\",\"paid\":0,\"payment_method\":null,\"amount_paid\":\"0.00\",\"amount_due\":\"0.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":null,\"updated_at\":\"2026-03-22 02:15:35\",\"created_at\":\"2026-03-16 07:50:32\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":13,\"service_id\":1,\"location_id\":null,\"location_name\":null,\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"in-person\",\"date\":\"2026-03-16\",\"time\":\"10:00:00\",\"name\":\"Kgom\",\"email\":\"kcsebeela@gmail.com\",\"phone\":\"0782003457\",\"notes\":\"\",\"status\":\"confirmed\",\"paid\":0,\"payment_method\":null,\"amount_paid\":\"0.00\",\"amount_due\":\"0.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":null,\"updated_at\":\"2026-03-22 02:15:35\",\"created_at\":\"2026-03-15 21:09:20\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Individual Counselling\"},{\"id\":12,\"service_id\":4,\"location_id\":null,\"location_name\":null,\"provider\":\"Kgomotso Caroline Sebeela\",\"type\":\"in-person\",\"date\":\"2026-03-21\",\"time\":\"11:00:00\",\"name\":\"Jabulane Tshekeli \",\"email\":\"jtshekelip@gmail.com\",\"phone\":\"0714840599\",\"notes\":\"\",\"status\":\"confirmed\",\"paid\":0,\"payment_method\":null,\"amount_paid\":\"0.00\",\"amount_due\":\"0.00\",\"payment_status\":\"pending\",\"transaction_id\":null,\"receipt_number\":null,\"updated_at\":\"2026-03-22 02:15:35\",\"created_at\":\"2026-03-15 09:15:09\",\"reminder_sent\":0,\"follow_up_sent\":0,\"reviewed\":0,\"reviewed_by\":null,\"reviewed_at\":null,\"deleted_at\":null,\"service_name\":\"Couples and Relationship Counselling\"}],\"promotableGroups\":[]}}','2026-04-18 13:30:26'),(9,'cache:eap_reports_portalLoginCohorts_fa9881d0d216048412d12ade4c6061cd','{\"ts\":1774957819,\"value\":[]}','2026-03-31 11:50:19'),(13,'cache:eap_reports_portalLoginCohorts_6b8afe2ef88886f34eb3da4703c8ba32','{\"ts\":1775460227,\"value\":[]}','2026-04-06 07:23:47'),(34,'cache:eap_reports_portalLoginCohorts_035a01a0707c81248ad966fa2cb83180','{\"ts\":1776518947,\"value\":[]}','2026-04-18 13:29:07'),(36,'cache:api_client_locations','{\"ts\":1776522742,\"value\":[{\"id\":2,\"name\":\"In-Person | Rivonia Therapy Centre\",\"address\":\"19 9th Avenue Edenburg, Rivonia 2129\",\"working_days\":\"Monday, Friday, Saturday\",\"working_hours\":\"Monday 21:00-12:00; Friday 13:00-16:00; Saturday 09:00-12:00\",\"active\":1},{\"id\":1,\"name\":\"Online Session\",\"address\":\"Remote \\/ Virtual\",\"working_days\":\"Monday, Tuesday, Wednesday, Thursday, Friday, Saturday\",\"working_hours\":\"Monday 08:00-18:00; Tuesday 08:00-18:00; Wednesday 08:00-18:00; Thursday 08:00-18:00; Friday 08:00-18:00; Saturday 09:00-13:00\",\"active\":1},{\"id\":3,\"name\":\"Wellness Center\",\"address\":\"69 Amanda Avenue, Glenanda, Johannesburg, 2190\",\"working_days\":\"Monday, Tuesday, Wednesday, Thursday, Friday\",\"working_hours\":\"Monday 13:00-18:00; Tuesday 08:00-18:00; Wednesday 08:00-18:00; Thursday 08:00-18:00; Friday 08:00-12:00\",\"active\":1}]}','2026-04-18 14:32:22');
/*!40000 ALTER TABLE `site_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_members`
--

DROP TABLE IF EXISTS `team_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `bio` mediumtext,
  `image_url` varchar(500) DEFAULT NULL,
  `quote` mediumtext,
  `display_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_members`
--

LOCK TABLES `team_members` WRITE;
/*!40000 ALTER TABLE `team_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `testimonials`
--

DROP TABLE IF EXISTS `testimonials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testimonials` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `role` varchar(100) DEFAULT NULL,
  `content` text NOT NULL,
  `rating` int DEFAULT '5',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testimonials`
--

LOCK TABLES `testimonials` WRITE;
/*!40000 ALTER TABLE `testimonials` DISABLE KEYS */;
INSERT INTO `testimonials` VALUES (1,'Haajira Hajee','Client','Kaycee offers exceptional service. She has an incredible ability to understand what you\'re feeling and what you\'re going through. Her healing approach is powerfulΓÇöyou feel noticeably better even after just one session. I would highly recommend her to anyone seeking genuine care and support',5,'2026-03-10 09:09:26'),(2,'L.T MOTSAATHEBE','Client','Their approach is both empathetic and practical, helping me work through challenges with clarity and confidence. They offered thoughtful insights and tools that I could apply to my daily life, which made a real difference in my personal growth. I highly recommend her to anyone looking for a counselor who is patient, caring, and deeply committed to their clients\' well-being.',4,'2026-03-10 09:09:26'),(3,'Charmaine Kgobe','Client','She is good at what she does,you walk out of there as a different person full of hope.I would recommend her any day to others',5,'2026-03-10 09:09:26'),(4,'Siya Bonga','Client','Approachable and Very professional. Assisted me in my journey to recovery. Big up',4,'2026-03-10 09:09:26'),(5,'Lesego Marige','Client','Very professional and reliable Γ¡É∩╕ÅΓ¥ñ∩╕Å',5,'2026-03-10 09:09:26');
/*!40000 ALTER TABLE `testimonials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `role` enum('admin','manager','editor','viewer') NOT NULL DEFAULT 'admin',
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2y$12$7rptOC9W5yo5pcwKla6kKeAZIiyj9lSDT.AUeVJoXtJboVxpn5diq','2026-03-10 09:09:26','admin',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_stats`
--

DROP TABLE IF EXISTS `visitor_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitor_stats` (
  `id` int NOT NULL AUTO_INCREMENT,
  `stat_date` date NOT NULL,
  `total_visits` int DEFAULT '0',
  `unique_visitors` int DEFAULT '0',
  `page_views` int DEFAULT '0',
  `bounce_rate` decimal(5,2) DEFAULT '0.00',
  `avg_session_time` int DEFAULT '0',
  `top_page` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stat_date` (`stat_date`),
  UNIQUE KEY `uq_stat_date` (`stat_date`),
  KEY `idx_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_stats`
--

LOCK TABLES `visitor_stats` WRITE;
/*!40000 ALTER TABLE `visitor_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitors`
--

DROP TABLE IF EXISTS `visitors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text,
  `page_url` varchar(500) NOT NULL,
  `page_title` varchar(255) DEFAULT NULL,
  `referrer` varchar(500) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `visit_date` date NOT NULL,
  `visit_time` time NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ip` (`ip_address`),
  KEY `idx_date` (`visit_date`),
  KEY `idx_page` (`page_url`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=171 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitors`
--

LOCK TABLES `visitors` WRITE;
/*!40000 ALTER TABLE `visitors` DISABLE KEYS */;
INSERT INTO `visitors` VALUES (1,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','02:17:30','2026-03-22 00:17:30'),(2,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','02:20:59','2026-03-22 00:20:59'),(3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8010/login.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','02:57:51','2026-03-22 00:57:51'),(4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8010/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','02:58:07','2026-03-22 00:58:07'),(5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8010/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','02:58:20','2026-03-22 00:58:20'),(6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://localhost:8010/admin/location.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','02:58:46','2026-03-22 00:58:46'),(7,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://localhost:8010/admin/location.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:03:26','2026-03-22 01:03:26'),(8,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8011/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:03:28','2026-03-22 01:03:28'),(9,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8012/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:07:04','2026-03-22 01:07:04'),(10,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:11:03','2026-03-22 01:11:03'),(11,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/booking.php','Book Appointment','',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:16:05','2026-03-22 01:16:05'),(12,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8013/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:16:09','2026-03-22 01:16:09'),(13,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:16:48','2026-03-22 01:16:48'),(14,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:18:30','2026-03-22 01:18:30'),(15,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','',NULL,NULL,NULL,NULL,NULL,'2026-03-22','03:23:02','2026-03-22 01:23:02'),(16,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-23','06:42:14','2026-03-23 04:42:14'),(17,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/',NULL,NULL,NULL,NULL,NULL,'2026-03-23','06:42:21','2026-03-23 04:42:21'),(18,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','',NULL,NULL,NULL,NULL,NULL,'2026-03-23','06:43:51','2026-03-23 04:43:51'),(19,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/services.php','Services','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-23','06:45:42','2026-03-23 04:45:42'),(20,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','http://localhost:8085/php/services.php',NULL,NULL,NULL,NULL,NULL,'2026-03-23','06:57:31','2026-03-23 04:57:31'),(21,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/contact.php','Contact','http://localhost:8085/php/',NULL,NULL,NULL,NULL,NULL,'2026-03-23','06:58:34','2026-03-23 04:58:34'),(22,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/about.php','About Us','http://localhost:8085/php/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-03-23','16:59:38','2026-03-23 14:59:38'),(23,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-25','15:46:46','2026-03-25 13:46:46'),(24,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/',NULL,NULL,NULL,NULL,NULL,'2026-03-25','15:46:52','2026-03-25 13:46:52'),(25,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','15:48:41','2026-03-25 13:48:41'),(26,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','15:49:07','2026-03-25 13:49:07'),(27,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8014/login.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:33:45','2026-03-25 14:33:45'),(28,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8016/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:48:22','2026-03-25 14:48:22'),(29,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8018/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:48:24','2026-03-25 14:48:24'),(30,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8019/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:48:26','2026-03-25 14:48:26'),(31,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8019/admin/services.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:49:12','2026-03-25 14:49:12'),(32,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8019/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:49:36','2026-03-25 14:49:36'),(33,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8020/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:50:29','2026-03-25 14:50:29'),(34,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8019/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:51:27','2026-03-25 14:51:27'),(35,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8019/admin/services.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:55:49','2026-03-25 14:55:49'),(36,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8019/admin/services.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:56:13','2026-03-25 14:56:13'),(37,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8021/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:57:56','2026-03-25 14:57:56'),(38,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8021/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:58:03','2026-03-25 14:58:03'),(39,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8021/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:59:00','2026-03-25 14:59:00'),(40,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8022/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-25','16:59:12','2026-03-25 14:59:12'),(41,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8023/login.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','08:37:05','2026-03-27 06:37:05'),(42,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8023/login.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','08:37:15','2026-03-27 06:37:15'),(43,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8023/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','08:43:22','2026-03-27 06:43:22'),(44,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8024/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','08:45:26','2026-03-27 06:45:26'),(45,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8024/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','08:45:35','2026-03-27 06:45:35'),(46,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:02:46','2026-03-27 07:02:46'),(47,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:02:51','2026-03-27 07:02:51'),(48,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:14:04','2026-03-27 07:14:04'),(49,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8023/admin/index.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:18:39','2026-03-27 07:18:39'),(50,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8024/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:18:41','2026-03-27 07:18:41'),(51,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8026/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:18:44','2026-03-27 07:18:44'),(52,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8028/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','09:24:19','2026-03-27 07:24:19'),(53,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8030/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:10:45','2026-03-27 08:10:45'),(54,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8024/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:11:56','2026-03-27 08:11:56'),(55,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8026/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:12:15','2026-03-27 08:12:15'),(56,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8028/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:12:15','2026-03-27 08:12:15'),(57,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8026/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:15:30','2026-03-27 08:15:30'),(58,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8030/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:15:32','2026-03-27 08:15:32'),(59,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:15:45','2026-03-27 08:15:45'),(60,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8028/admin/bookings.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:15:48','2026-03-27 08:15:48'),(61,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/booking.php','Book Appointment','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:36:47','2026-03-27 08:36:47'),(62,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:40:08','2026-03-27 08:40:08'),(63,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:41:01','2026-03-27 08:41:01'),(64,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8032/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:41:23','2026-03-27 08:41:23'),(65,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8032/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:42:58','2026-03-27 08:42:58'),(66,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:43:00','2026-03-27 08:43:00'),(67,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8033/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:43:13','2026-03-27 08:43:13'),(68,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:45:18','2026-03-27 08:45:18'),(69,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:45:40','2026-03-27 08:45:40'),(70,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:45:46','2026-03-27 08:45:46'),(71,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:47:03','2026-03-27 08:47:03'),(72,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:59:59','2026-03-27 08:59:59'),(73,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8034/admin/invoice.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','10:59:59','2026-03-27 08:59:59'),(74,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8034/admin/notifications.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','11:13:39','2026-03-27 09:13:39'),(75,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8034/admin/notifications.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','11:42:43','2026-03-27 09:42:43'),(76,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','http://localhost:8085/php/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','11:57:12','2026-03-27 09:57:12'),(77,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8034/admin/notifications.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','12:00:58','2026-03-27 10:00:58'),(78,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','12:00:59','2026-03-27 10:00:59'),(79,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8034/admin/notifications.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','12:03:59','2026-03-27 10:03:59'),(80,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','12:04:03','2026-03-27 10:04:03'),(81,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8035/admin/visitors.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','13:42:34','2026-03-27 11:42:34'),(82,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8031/admin/locations.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','13:42:38','2026-03-27 11:42:38'),(83,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8034/admin/notifications.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','13:42:40','2026-03-27 11:42:40'),(84,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','/@vite/client','Client','http://127.0.0.1:8035/admin/visitors.php',NULL,NULL,NULL,NULL,NULL,'2026-03-27','13:54:50','2026-03-27 11:54:50'),(85,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-27','20:37:11','2026-03-27 18:37:11'),(86,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-29','18:19:39','2026-03-29 16:19:39'),(87,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/contact.php','Contact','http://localhost:8085/php/',NULL,NULL,NULL,NULL,NULL,'2026-03-29','18:20:03','2026-03-29 16:20:03'),(88,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/contact.php','Contact','',NULL,NULL,NULL,NULL,NULL,'2026-03-29','18:35:14','2026-03-29 16:35:14'),(89,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/contact.php','Contact','',NULL,NULL,NULL,NULL,NULL,'2026-03-29','18:37:05','2026-03-29 16:37:05'),(90,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/contact.php','Contact','http://localhost:8085/php/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-03-29','18:42:19','2026-03-29 16:42:19'),(91,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/contact.php','Contact','',NULL,NULL,NULL,NULL,NULL,'2026-03-29','19:45:51','2026-03-29 17:45:51'),(92,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-30','11:22:20','2026-03-30 09:22:20'),(93,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/about.php','About Us','http://localhost:8085/php/faq.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','12:17:46','2026-03-30 10:17:46'),(94,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/php/services.php','Services','http://localhost:8085/php/about.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','12:25:11','2026-03-30 10:25:11'),(95,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/services.php','Services','',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:30:11','2026-03-30 11:30:11'),(96,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/','Home','http://localhost:8085/kaycee/services.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:30:16','2026-03-30 11:30:16'),(97,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:31:18','2026-03-30 11:31:18'),(98,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:31:45','2026-03-30 11:31:45'),(99,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/','Home','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:33:17','2026-03-30 11:33:17'),(100,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/about.php','About Us','http://localhost:8085/kaycee/',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:38:59','2026-03-30 11:38:59'),(101,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/services.php','Services','http://localhost:8085/kaycee/about.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:39:36','2026-03-30 11:39:36'),(102,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/services.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:39:59','2026-03-30 11:39:59'),(103,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/contact.php','Contact','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:40:24','2026-03-30 11:40:24'),(104,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/booking.php','Book Appointment','http://localhost:8085/kaycee/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:40:38','2026-03-30 11:40:38'),(105,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:43:49','2026-03-30 11:43:49'),(106,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:43:54','2026-03-30 11:43:54'),(107,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/contact.php','Contact','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:44:05','2026-03-30 11:44:05'),(108,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','13:46:01','2026-03-30 11:46:01'),(109,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:41:12','2026-03-30 12:41:12'),(110,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:41:17','2026-03-30 12:41:17'),(111,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:41:29','2026-03-30 12:41:29'),(112,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:55:44','2026-03-30 12:55:44'),(113,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','http://localhost:8085/kaycee/resources.php?assessment=phq9',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:02','2026-03-30 12:57:02'),(114,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?type=video&audience=','Resources','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:15','2026-03-30 12:57:15'),(115,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?type=&audience=','Resources','http://localhost:8085/kaycee/resources.php?type=video&audience=',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:23','2026-03-30 12:57:23'),(116,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?type=&audience=public','Resources','http://localhost:8085/kaycee/resources.php?type=&audience=',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:33','2026-03-30 12:57:33'),(117,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?type=&audience=individual','Resources','http://localhost:8085/kaycee/resources.php?type=&audience=public',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:40','2026-03-30 12:57:40'),(118,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?type=&audience=corporate','Resources','http://localhost:8085/kaycee/resources.php?type=&audience=individual',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:48','2026-03-30 12:57:48'),(119,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?type=&audience=eap','Resources','http://localhost:8085/kaycee/resources.php?type=&audience=corporate',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:57:56','2026-03-30 12:57:56'),(120,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','http://localhost:8085/kaycee/resources.php?type=&audience=eap',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:58:02','2026-03-30 12:58:02'),(121,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','',NULL,NULL,NULL,NULL,NULL,'2026-03-30','14:58:08','2026-03-30 12:58:08'),(122,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/contact.php','Contact','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:06:18','2026-03-30 13:06:18'),(123,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/contact.php','Contact','http://localhost:8085/kaycee/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:30:55','2026-03-30 13:30:55'),(124,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/resources.php?assessment=phq9',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:38:31','2026-03-30 13:38:31'),(125,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:40:30','2026-03-30 13:40:30'),(126,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php?tier=essential','Corporate Wellness','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:42:01','2026-03-30 13:42:01'),(127,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:57:11','2026-03-30 13:57:11'),(128,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:57:15','2026-03-30 13:57:15'),(129,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','15:57:27','2026-03-30 13:57:27'),(130,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','16:49:56','2026-03-30 14:49:56'),(131,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-30','16:50:06','2026-03-30 14:50:06'),(132,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:31:27','2026-03-31 11:31:27'),(133,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:31:42','2026-03-31 11:31:42'),(134,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:46:08','2026-03-31 11:46:08'),(135,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/resources.php?assessment=phq9',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:53:01','2026-03-31 11:53:01'),(136,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:53:13','2026-03-31 11:53:13'),(137,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:54:29','2026-03-31 11:54:29'),(138,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:56:33','2026-03-31 11:56:33'),(139,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','13:57:29','2026-03-31 11:57:29'),(140,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:00:52','2026-03-31 12:00:52'),(141,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:02:17','2026-03-31 12:02:17'),(142,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:03:32','2026-03-31 12:03:32'),(143,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:05:09','2026-03-31 12:05:09'),(144,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:13:03','2026-03-31 12:13:03'),(145,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:13:12','2026-03-31 12:13:12'),(146,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:14:16','2026-03-31 12:14:16'),(147,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:14:21','2026-03-31 12:14:21'),(148,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:14:25','2026-03-31 12:14:25'),(149,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','14:20:32','2026-03-31 12:20:32'),(150,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?assessment=gad7','Resources','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:27:55','2026-03-31 13:27:55'),(151,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php?assessment=phq9','Resources','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:28:12','2026-03-31 13:28:12'),(152,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/corporate.php','Corporate Wellness','http://localhost:8085/kaycee/resources.php?assessment=phq9',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:31:06','2026-03-31 13:31:06'),(153,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/corporate.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:31:22','2026-03-31 13:31:22'),(154,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:31:34','2026-03-31 13:31:34'),(155,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:31:38','2026-03-31 13:31:38'),(156,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/eap.php','Eap','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:31:46','2026-03-31 13:31:46'),(157,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/platform.php','Platform','http://localhost:8085/kaycee/eap.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:31:59','2026-03-31 13:31:59'),(158,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','http://localhost:8085/kaycee/platform.php',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:32:03','2026-03-31 13:32:03'),(159,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','',NULL,NULL,NULL,NULL,NULL,'2026-03-31','15:42:14','2026-03-31 13:42:14'),(160,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','',NULL,NULL,NULL,NULL,NULL,'2026-03-31','16:13:41','2026-03-31 14:13:41'),(161,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','',NULL,NULL,NULL,NULL,NULL,'2026-04-05','19:03:13','2026-04-05 17:03:13'),(162,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','',NULL,NULL,NULL,NULL,NULL,'2026-04-05','19:06:13','2026-04-05 17:06:13'),(163,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','',NULL,NULL,NULL,NULL,NULL,'2026-04-05','19:14:24','2026-04-05 17:14:24'),(164,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/','Home','',NULL,NULL,NULL,NULL,NULL,'2026-04-07','16:20:18','2026-04-07 14:20:18'),(165,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/services.php','Services','http://localhost:8085/kaycee/',NULL,NULL,NULL,NULL,NULL,'2026-04-07','16:21:47','2026-04-07 14:21:47'),(166,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/contact.php','Contact','http://localhost:8085/kaycee/services.php',NULL,NULL,NULL,NULL,NULL,'2026-04-07','16:22:05','2026-04-07 14:22:05'),(167,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/services.php','Services','http://localhost:8085/kaycee/contact.php',NULL,NULL,NULL,NULL,NULL,'2026-04-07','16:22:31','2026-04-07 14:22:31'),(168,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/resources.php','Resources','http://localhost:8085/kaycee/services.php',NULL,NULL,NULL,NULL,NULL,'2026-04-07','16:22:59','2026-04-07 14:22:59'),(169,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/booking.php','Book Appointment','http://localhost:8085/kaycee/resources.php',NULL,NULL,NULL,NULL,NULL,'2026-04-07','18:01:32','2026-04-07 16:01:32'),(170,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','/kaycee/','Home','http://localhost:8085/kaycee/booking.php',NULL,NULL,NULL,NULL,NULL,'2026-04-07','18:02:18','2026-04-07 16:02:18');
/*!40000 ALTER TABLE `visitors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_booking_summary`
--

DROP TABLE IF EXISTS `vw_booking_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_booking_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_booking_summary` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `email`,
 1 AS `date`,
 1 AS `time`,
 1 AS `status`,
 1 AS `amount_paid`,
 1 AS `payment_status`,
 1 AS `service_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_outlook_sync_status`
--

DROP TABLE IF EXISTS `vw_outlook_sync_status`;
/*!50001 DROP VIEW IF EXISTS `vw_outlook_sync_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_outlook_sync_status` AS SELECT 
 1 AS `user_id`,
 1 AS `last_synced_at`,
 1 AS `event_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_overdue_invoices`
--

DROP TABLE IF EXISTS `vw_overdue_invoices`;
/*!50001 DROP VIEW IF EXISTS `vw_overdue_invoices`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_overdue_invoices` AS SELECT 
 1 AS `id`,
 1 AS `booking_id`,
 1 AS `invoice_number`,
 1 AS `due_date`,
 1 AS `total_amount`,
 1 AS `vat_amount`,
 1 AS `status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `webhook_audit_log`
--

DROP TABLE IF EXISTS `webhook_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_audit_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `event_type` varchar(100) NOT NULL,
  `payload` text,
  `status` enum('success','failure') NOT NULL DEFAULT 'success',
  `response` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_audit_log`
--

LOCK TABLES `webhook_audit_log` WRITE;
/*!40000 ALTER TABLE `webhook_audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whatsapp_incoming_messages`
--

DROP TABLE IF EXISTS `whatsapp_incoming_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `whatsapp_incoming_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender` varchar(255) DEFAULT NULL,
  `message` text,
  `received_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `message_id` varchar(255) NOT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `message_type` varchar(50) NOT NULL DEFAULT 'text',
  `content` text,
  `processed` tinyint(1) NOT NULL DEFAULT '0',
  `media_url` varchar(800) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `raw_payload` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_message_id` (`message_id`),
  KEY `idx_phone_number` (`phone_number`),
  KEY `idx_processed` (`processed`),
  KEY `idx_received_at` (`received_at`),
  KEY `idx_message_type` (`message_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whatsapp_incoming_messages`
--

LOCK TABLES `whatsapp_incoming_messages` WRITE;
/*!40000 ALTER TABLE `whatsapp_incoming_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `whatsapp_incoming_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kaycee_db'
--

--
-- Dumping routines for database 'kaycee_db'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_booking_total_amount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_booking_total_amount`(bookingId INT) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10,2) DEFAULT 0.00;
  SELECT IFNULL(price,0) INTO total FROM services WHERE id = (SELECT service_id FROM bookings WHERE id = bookingId LIMIT 1);
  RETURN total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_days_overdue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_days_overdue`(invoiceId INT) RETURNS int
    DETERMINISTIC
BEGIN
  DECLARE due_date DATE;
  DECLARE today_date DATE;
  SET today_date = CURDATE();
  SELECT due_date INTO due_date FROM invoices WHERE id = invoiceId;
  IF due_date IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN GREATEST(0, DATEDIFF(today_date, due_date));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_invoice_from_booking` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_invoice_from_booking`(IN bookingId INT)
BEGIN
  DECLARE total DECIMAL(10,2);
  DECLARE vat DECIMAL(10,2);
  DECLARE invoiceNo VARCHAR(191);
  SELECT IFNULL(fn_booking_total_amount(bookingId),0) INTO total;
  SET vat = ROUND(total * 0.15, 2);
  SET invoiceNo = CONCAT('INV-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', bookingId);

  INSERT INTO invoices (booking_id, invoice_number, issue_date, due_date, total_amount, vat_amount, status, created_by)
  VALUES (bookingId, invoiceNo, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), total, vat, 'unpaid', 'system');

  INSERT INTO payment_history (booking_id, action, status, amount, created_by)
  VALUES (bookingId, 'invoice_created', 'pending', total + vat, 'system');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mark_booking_confirmed` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mark_booking_confirmed`(IN bookingId INT)
BEGIN
  UPDATE bookings SET status='confirmed', updated_at=NOW() WHERE id = bookingId;
  INSERT INTO booking_audit (booking_id, action, previous_status, new_status, changed_by)
  VALUES (bookingId, 'status_change', 'pending', 'confirmed', 'system');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_sync_outlook_events` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sync_outlook_events`()
BEGIN
  UPDATE outlook_events SET status='active' WHERE status='deleted' AND last_synced_at > DATE_SUB(NOW(), INTERVAL 7 DAY);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `kaycee_db`
--

USE `kaycee_db`;

--
-- Final view structure for view `vw_booking_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_booking_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_booking_summary` AS select `b`.`id` AS `id`,`b`.`name` AS `name`,`b`.`email` AS `email`,`b`.`date` AS `date`,`b`.`time` AS `time`,`b`.`status` AS `status`,`b`.`amount_paid` AS `amount_paid`,`b`.`payment_status` AS `payment_status`,`s`.`name` AS `service_name` from (`bookings` `b` left join `services` `s` on((`b`.`service_id` = `s`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_outlook_sync_status`
--

/*!50001 DROP VIEW IF EXISTS `vw_outlook_sync_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_outlook_sync_status` AS select `u`.`user_id` AS `user_id`,coalesce(max(`oe`.`last_synced_at`),'0000-00-00 00:00:00') AS `last_synced_at`,count(`oe`.`id`) AS `event_count` from (`outlook_sync_users` `u` left join `outlook_events` `oe` on((`u`.`user_id` = `oe`.`user_id`))) group by `u`.`user_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_overdue_invoices`
--

/*!50001 DROP VIEW IF EXISTS `vw_overdue_invoices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_overdue_invoices` AS select `i`.`id` AS `id`,`i`.`booking_id` AS `booking_id`,`i`.`invoice_number` AS `invoice_number`,`i`.`due_date` AS `due_date`,`i`.`total_amount` AS `total_amount`,`i`.`vat_amount` AS `vat_amount`,`i`.`status` AS `status` from `invoices` `i` where (`i`.`status` = 'overdue') */;
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

-- Dump completed on 2026-04-24 12:30:21
