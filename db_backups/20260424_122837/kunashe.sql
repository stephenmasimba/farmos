-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: kunashe
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
-- Current Database: `kunashe`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `kunashe` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `kunashe`;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aircraft_accident_reports`
--

DROP TABLE IF EXISTS `aircraft_accident_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aircraft_accident_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reference` varchar(50) DEFAULT NULL,
  `form_number` varchar(50) DEFAULT NULL,
  `report_type` text,
  `aircraft_registration` varchar(10) DEFAULT NULL,
  `type_of_operation` text,
  `date_of_accident` date DEFAULT NULL,
  `time_of_accident` time DEFAULT NULL,
  `location_description` text,
  `gps_coord1_direction` char(1) DEFAULT NULL,
  `gps_coord1_degrees` int DEFAULT NULL,
  `gps_coord1_minutes` int DEFAULT NULL,
  `gps_coord1_seconds` decimal(10,2) DEFAULT NULL,
  `gps_coord2_direction` char(1) DEFAULT NULL,
  `gps_coord2_degrees` int DEFAULT NULL,
  `gps_coord2_minutes` int DEFAULT NULL,
  `gps_coord2_seconds` decimal(10,2) DEFAULT NULL,
  `elevation_feet` int DEFAULT NULL,
  `wind_direction_degrees` int DEFAULT NULL,
  `wind_speed_knots` int DEFAULT NULL,
  `temperature_celsius` decimal(5,2) DEFAULT NULL,
  `visibility` text,
  `people_onboard` int DEFAULT NULL,
  `people_injured` int DEFAULT NULL,
  `people_killed` int DEFAULT NULL,
  `pic_age` int DEFAULT NULL,
  `pic_licence_type` text,
  `pic_ratings` text,
  `pic_restrictions` text,
  `pic_medical_expiry` date DEFAULT NULL,
  `pic_licence_valid` enum('Yes','No') DEFAULT NULL,
  `pic_total_hours` decimal(10,1) DEFAULT NULL,
  `pic_last90_days_hours` decimal(10,1) DEFAULT NULL,
  `pic_hours_on_type` decimal(10,1) DEFAULT NULL,
  `pic_last90_days_on_type` decimal(10,1) DEFAULT NULL,
  `airframe_manufacturer` text,
  `airframe_model` text,
  `airframe_serial` varchar(50) DEFAULT NULL,
  `airframe_date_manufacture` date DEFAULT NULL,
  `airframe_total_hours` decimal(10,1) DEFAULT NULL,
  `airframe_last_mpi_date` date DEFAULT NULL,
  `airframe_last_mpi_hours` decimal(10,1) DEFAULT NULL,
  `engine1_type` text,
  `engine1_serial` varchar(50) DEFAULT NULL,
  `engine1_hours_new` decimal(10,1) DEFAULT NULL,
  `engine1_hours_overhaul` decimal(10,1) DEFAULT NULL,
  `engine1_cycles` int DEFAULT NULL,
  `engine2_type` text,
  `engine2_serial` varchar(50) DEFAULT NULL,
  `engine2_hours_new` decimal(10,1) DEFAULT NULL,
  `engine2_hours_overhaul` decimal(10,1) DEFAULT NULL,
  `engine2_cycles` int DEFAULT NULL,
  `probable_cause` text,
  `contributing_factors` text,
  `investigation_notes` text,
  `certificate_airworthiness_expiry` date DEFAULT NULL,
  `maintenance_compliant` enum('Yes','No') DEFAULT NULL,
  `mass_balance_ok` enum('Yes','No') DEFAULT NULL,
  `engine_failure` enum('Yes','No') DEFAULT NULL,
  `airframe_failure` enum('Yes','No') DEFAULT NULL,
  `last_departure` text,
  `next_intended_landing` text,
  `weather_wind` text,
  `weather_temperature` text,
  `weather_cloud` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aircraft_accident_reports`
--

LOCK TABLES `aircraft_accident_reports` WRITE;
/*!40000 ALTER TABLE `aircraft_accident_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `aircraft_accident_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attribute_values`
--

DROP TABLE IF EXISTS `attribute_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attribute_values` (
  `id` int NOT NULL AUTO_INCREMENT,
  `attribute_id` int NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_av_attribute` (`attribute_id`),
  CONSTRAINT `attribute_values_ibfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `product_attributes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_av_attribute` FOREIGN KEY (`attribute_id`) REFERENCES `product_attributes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attribute_values`
--

LOCK TABLES `attribute_values` WRITE;
/*!40000 ALTER TABLE `attribute_values` DISABLE KEYS */;
INSERT INTO `attribute_values` VALUES (1,8,'Red',0,'2025-05-19 16:23:28');
/*!40000 ALTER TABLE `attribute_values` ENABLE KEYS */;
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
  `content` text,
  `image_url` varchar(255) DEFAULT NULL,
  `author_id` int DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `author_id` (`author_id`)
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
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `brands` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brands`
--

LOCK TABLES `brands` WRITE;
/*!40000 ALTER TABLE `brands` DISABLE KEYS */;
/*!40000 ALTER TABLE `brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `guest_cart_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cart_item` (`user_id`,`guest_cart_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES (6,1,12,2,0,'2025-05-30 08:04:47','2025-06-17 03:50:21'),(11,0,12,2,564446,'2025-06-03 16:40:20','2025-06-03 16:40:51'),(19,1,22,1,0,'2025-06-11 10:14:10','2025-06-11 10:14:10'),(21,2,24,1,0,'2025-06-11 18:36:59','2025-06-11 18:36:59'),(23,0,12,1,446994,'2025-06-21 13:04:25','2025-06-21 13:04:25');
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(145) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Electronics','icon-device-laptop','2025-05-19 16:12:50'),(2,'Furniture','icon-chair','2025-05-19 16:12:50'),(3,'Cooking','icon-kitchen-set','2025-05-19 16:12:50'),(4,'Clothing','icon-hanger','2025-05-19 16:12:50');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verification_token` varchar(64) DEFAULT NULL,
  `verification_expires` datetime DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`),
  KEY `verification_token` (`verification_token`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (2,'tino','tendergrpupdate@gmail.com','$2y$10$TD4L1HH2KdE2EtljmA34GeMA54EJ5hxh/SW1ykd2kDn8M5WLF0nRW','Tender','Stephen',NULL,NULL,NULL,NULL,NULL,'2025-05-25 20:30:38','2025-05-25 20:30:38',NULL,'active',0,NULL,NULL,0),(3,'titi','titi@ti.com','$2y$10$HzAFtlbcP7ZNkXHYXgdBNeB.vlhdzyp373KSCQCaaV.drv5y65seu','Titi','Titi',NULL,NULL,NULL,NULL,NULL,'2025-05-30 06:20:20','2025-05-30 06:20:20',NULL,'active',0,NULL,NULL,0);
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency`
--

DROP TABLE IF EXISTS `currency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `currency` (
  `currency_id` int NOT NULL AUTO_INCREMENT,
  `currency_name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`currency_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency`
--

LOCK TABLES `currency` WRITE;
/*!40000 ALTER TABLE `currency` DISABLE KEYS */;
INSERT INTO `currency` VALUES (1,'Rands'),(2,'USD'),(3,'ZiGi');
/*!40000 ALTER TABLE `currency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_attempts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(45) NOT NULL,
  `timestamp` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ip_timestamp` (`ip`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_history`
--

DROP TABLE IF EXISTS `order_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `orderId` int DEFAULT NULL,
  `orderDate` datetime DEFAULT NULL,
  `totalAmount` decimal(10,2) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `items` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_history`
--

LOCK TABLES `order_history` WRITE;
/*!40000 ALTER TABLE `order_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `unit_price` decimal(10,2) DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `idx_order_items_product` (`product_id`),
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,13,14,1,76.00,NULL,'2025-06-09 05:55:06'),(2,13,17,1,110.00,NULL,'2025-06-09 05:55:06'),(3,13,21,1,80.00,NULL,'2025-06-09 05:55:06'),(4,14,14,1,76.00,NULL,'2025-06-09 05:58:20'),(5,14,17,1,110.00,NULL,'2025-06-09 05:58:20'),(6,14,21,1,80.00,NULL,'2025-06-09 05:58:20'),(8,15,14,1,76.00,NULL,'2025-06-09 05:59:27'),(9,15,17,1,110.00,NULL,'2025-06-09 05:59:27'),(10,15,21,1,80.00,NULL,'2025-06-09 05:59:27'),(12,16,14,1,76.00,NULL,'2025-06-09 06:01:14'),(13,16,17,1,110.00,NULL,'2025-06-09 06:01:14'),(14,16,21,1,80.00,NULL,'2025-06-09 06:01:14'),(17,4,14,1,76.00,76.00,'2025-06-09 06:03:10'),(18,17,14,1,76.00,NULL,'2025-06-09 06:03:27'),(19,17,17,1,110.00,NULL,'2025-06-09 06:03:27'),(20,17,21,1,80.00,NULL,'2025-06-09 06:03:27'),(21,5,14,1,76.00,76.00,'2025-06-09 06:03:27'),(22,5,17,1,110.00,110.00,'2025-06-09 06:03:27'),(23,5,21,1,80.00,80.00,'2025-06-09 06:03:27'),(24,18,13,1,120.00,NULL,'2025-06-11 09:02:19'),(25,18,22,1,56.00,NULL,'2025-06-11 09:02:19'),(26,6,13,1,120.00,120.00,'2025-06-11 09:02:19'),(27,6,22,1,56.00,56.00,'2025-06-11 09:02:19'),(28,19,12,1,84.00,NULL,'2025-06-11 10:09:49'),(29,7,12,1,84.00,84.00,'2025-06-11 10:09:49'),(30,20,13,1,120.00,NULL,'2025-06-11 10:16:08'),(31,8,13,1,120.00,120.00,'2025-06-11 10:16:08'),(32,21,13,1,120.00,NULL,'2025-06-11 10:20:09'),(33,9,13,1,120.00,120.00,'2025-06-11 10:20:09');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_history`
--

DROP TABLE IF EXISTS `order_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `updated_by` (`updated_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_history`
--

LOCK TABLES `order_status_history` WRITE;
/*!40000 ALTER TABLE `order_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_statuses`
--

DROP TABLE IF EXISTS `order_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_statuses` (
  `status_id` tinyint NOT NULL,
  `status_name` varchar(50) NOT NULL,
  PRIMARY KEY (`status_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_statuses`
--

LOCK TABLES `order_statuses` WRITE;
/*!40000 ALTER TABLE `order_statuses` DISABLE KEYS */;
INSERT INTO `order_statuses` VALUES (0,'pending'),(1,'processing'),(2,'completed'),(3,'cancelled');
/*!40000 ALTER TABLE `order_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `order_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'unpaid',
  `total_amount` decimal(10,2) DEFAULT NULL,
  `shipping_address` text COLLATE utf8mb4_unicode_ci,
  `billing_address` text COLLATE utf8mb4_unicode_ci,
  `shipping_cost` decimal(10,2) DEFAULT NULL,
  `tax_amount` decimal(10,2) DEFAULT NULL,
  `order_notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (13,3,'2025-06-09 07:55:06','pending','credit_card','pending',276.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,13.30,'SEDFA','2025-06-09 05:55:06','2025-06-09 05:55:06'),(14,3,'2025-06-09 07:58:20','pending','credit_card','pending',276.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,13.30,'SEDFA','2025-06-09 05:58:20','2025-06-09 05:58:20'),(15,3,'2025-06-09 07:59:27','pending','credit_card','pending',276.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,13.30,'SEDFA','2025-06-09 05:59:27','2025-06-09 05:59:27'),(16,3,'2025-06-09 08:01:14','pending','credit_card','pending',276.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,13.30,'SEDFA','2025-06-09 06:01:14','2025-06-09 06:01:14'),(17,3,'2025-06-09 08:03:27','pending','credit_card','pending',276.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,13.30,'SEDFA','2025-06-09 06:03:27','2025-06-09 06:03:27'),(18,3,'2025-06-11 11:02:19','pending','credit_card','pending',186.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,8.80,'222','2025-06-11 09:02:19','2025-06-11 09:02:19'),(19,3,'2025-06-11 12:09:49','pending','credit_card','pending',94.00,NULL,'{\"first_name\":\"Stephen\",\"last_name\":\"Masimba\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,4.20,'45','2025-06-11 10:09:49','2025-06-11 10:09:49'),(20,3,'2025-06-11 12:16:08','pending','credit_card','pending',130.00,NULL,'{\"first_name\":\"Tender\",\"last_name\":\"Stephen\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"l\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,6.00,'835','2025-06-11 10:16:08','2025-06-11 10:16:08'),(21,3,'2025-06-11 12:20:09','pending','credit_card','pending',130.00,NULL,'{\"first_name\":\"Tender\",\"last_name\":\"Stephen\",\"address\":\"10 Mahem Kirkney Pretoria\",\"city\":\"Pretoria\",\"state\":\"er\",\"zip\":\"0182\",\"country\":\"South Africa\"}',10.00,6.00,'5','2025-06-11 10:20:09','2025-06-11 10:20:09');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
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
-- Table structure for table `payment_logs`
--

DROP TABLE IF EXISTS `payment_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_id` int unsigned NOT NULL,
  `status` varchar(50) NOT NULL,
  `message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `payment_id` (`payment_id`),
  CONSTRAINT `payment_logs_ibfk_1` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_logs`
--

LOCK TABLES `payment_logs` WRITE;
/*!40000 ALTER TABLE `payment_logs` DISABLE KEYS */;
INSERT INTO `payment_logs` VALUES (1,1,'completed','Demo payment processed successfully','2025-06-09 05:55:06'),(2,2,'completed','Demo payment processed successfully','2025-06-09 05:58:20'),(3,3,'completed','Demo payment processed successfully','2025-06-09 05:59:27'),(4,4,'completed','Demo payment processed successfully','2025-06-09 06:01:14'),(5,5,'completed','Demo payment processed successfully','2025-06-09 06:03:27'),(6,7,'completed','Demo payment processed successfully','2025-06-11 09:02:19'),(7,9,'completed','Demo payment processed successfully','2025-06-11 10:09:49'),(8,11,'completed','Demo payment processed successfully','2025-06-11 10:16:08'),(9,12,'completed','Demo payment processed successfully','2025-06-11 10:20:09');
/*!40000 ALTER TABLE `payment_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_statuses`
--

DROP TABLE IF EXISTS `payment_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_statuses` (
  `status_id` tinyint NOT NULL,
  `status_name` varchar(50) NOT NULL,
  PRIMARY KEY (`status_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_statuses`
--

LOCK TABLES `payment_statuses` WRITE;
/*!40000 ALTER TABLE `payment_statuses` DISABLE KEYS */;
INSERT INTO `payment_statuses` VALUES (0,'unpaid'),(1,'paid'),(2,'refunded');
/*!40000 ALTER TABLE `payment_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `transaction_id` varchar(100) NOT NULL,
  `status` enum('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,13,276.00,'credit_card','DEMO_1749448506_4877','completed','2025-06-09 05:55:06','2025-06-09 05:55:06'),(2,14,276.00,'credit_card','DEMO_1749448700_4967','completed','2025-06-09 05:58:20','2025-06-09 05:58:20'),(3,15,276.00,'credit_card','DEMO_1749448767_6189','completed','2025-06-09 05:59:27','2025-06-09 05:59:27'),(4,16,276.00,'credit_card','DEMO_1749448874_7318','completed','2025-06-09 06:01:14','2025-06-09 06:01:14'),(5,17,276.00,'credit_card','DEMO_1749449007_4307','completed','2025-06-09 06:03:27','2025-06-09 06:03:27'),(6,5,276.00,'credit_card','trans_6846792fa437a','pending','2025-06-09 06:03:27','2025-06-09 06:03:27'),(7,18,186.00,'credit_card','DEMO_1749632539_3358','completed','2025-06-11 09:02:19','2025-06-11 09:02:19'),(8,6,186.00,'credit_card','trans_6849461b5e1bd','pending','2025-06-11 09:02:19','2025-06-11 09:02:19'),(9,19,94.00,'credit_card','DEMO_1749636589_6442','completed','2025-06-11 10:09:49','2025-06-11 10:09:49'),(10,7,94.00,'credit_card','trans_684955ed3c1b6','pending','2025-06-11 10:09:49','2025-06-11 10:09:49'),(11,20,130.00,'credit_card','DEMO_1749636968_5949','completed','2025-06-11 10:16:08','2025-06-11 10:16:08'),(12,21,130.00,'credit_card','DEMO_1749637209_4197','completed','2025-06-11 10:20:09','2025-06-11 10:20:09'),(13,9,130.00,'credit_card','trans_684958592f349','pending','2025-06-11 10:20:09','2025-06-11 10:20:09');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'manage_products','Create, edit, delete products'),(2,'view_products','View product listings'),(3,'manage_categories','Create, edit, delete categories'),(4,'manage_attributes','Manage product attributes'),(5,'manage_orders','Process and manage orders'),(6,'view_orders','View order details'),(7,'manage_shipping','Manage shipping settings'),(8,'manage_users','Create, edit, delete users'),(9,'view_users','View user listings'),(10,'manage_roles','Manage user roles'),(11,'manage_inventory','Update product stock'),(12,'view_inventory','View inventory reports'),(13,'view_sales_reports','Access sales reports'),(14,'view_analytics','Access analytics dashboard'),(15,'manage_settings','Modify system settings'),(16,'manage_site_content','Manage website content');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_attributes`
--

DROP TABLE IF EXISTS `product_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_attributes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'select',
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_attributes`
--

LOCK TABLES `product_attributes` WRITE;
/*!40000 ALTER TABLE `product_attributes` DISABLE KEYS */;
INSERT INTO `product_attributes` VALUES (8,'Tender','Mecj Ner','radio',1,1,'2025-05-19 16:23:28','2025-05-19 16:23:28');
/*!40000 ALTER TABLE `product_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_tags`
--

DROP TABLE IF EXISTS `product_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `productId` int DEFAULT NULL,
  `tag` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `productId` (`productId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_tags`
--

LOCK TABLES `product_tags` WRITE;
/*!40000 ALTER TABLE `product_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_views`
--

DROP TABLE IF EXISTS `product_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_views` (
  `id` int NOT NULL AUTO_INCREMENT,
  `productId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `viewDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `duration` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `productId` (`productId`),
  KEY `userId` (`userId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_views`
--

LOCK TABLES `product_views` WRITE;
/*!40000 ALTER TABLE `product_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subcategory_id` int DEFAULT NULL,
  `product_category` int DEFAULT NULL,
  `product_price` decimal(10,2) DEFAULT NULL,
  `product_qnt` double DEFAULT '1',
  `reorder_level` int DEFAULT '10',
  `product_price_old` decimal(10,2) DEFAULT NULL,
  `product_description` text COLLATE utf8mb4_unicode_ci,
  `product_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_brand` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_weight` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_gender` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_colors` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_discount` decimal(10,2) DEFAULT NULL,
  `product_tex` decimal(10,2) DEFAULT NULL,
  `product_stock` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `product_tag_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_tags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isNew` tinyint(1) DEFAULT '0',
  `isTrending` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `product_category` (`product_category`),
  KEY `created_by` (`created_by`),
  KEY `idx_subcategory` (`subcategory_id`),
  KEY `user_id` (`user_id`),
  FULLTEXT KEY `ft_product_search` (`product_name`,`product_description`,`product_tags`),
  CONSTRAINT `fk_products_subcat` FOREIGN KEY (`subcategory_id`) REFERENCES `subcategories` (`id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`subcategory_id`) REFERENCES `subcategories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_ibfk_2` FOREIGN KEY (`product_category`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (11,'Brown paperbag waist pencil skirt',7,4,60.00,1,10,75.00,'A stylish brown pencil skirt with a paperbag waist, perfect for office wear.','uploads/products/prod_6836e169020741.28183671.jpg','Ni','120','Women','[\"XS\",\"M\",\"XXL\"]','0',20.00,0.00,41,1,'Now','[\"\"]',NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(12,'Dark yellow lace cut out swing dress',7,NULL,84.00,52,40,NULL,'A vibrant dark yellow dress with lace cutouts, ideal for summer outings.','product-5.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,21,2,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(13,'Khaki utility boiler jumpsuit',7,NULL,120.00,15,12,150.00,'A versatile khaki jumpsuit with utility pockets, great for casual wear.','product-6.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,9,1,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(14,'Blue utility pinafore denim dress',7,NULL,76.00,23,30,NULL,'A chic blue denim dress with a pinafore style, perfect for layering.','product-7.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(15,'Beige knitted elastic runner shoes',7,NULL,84.00,4,2,100.00,'Comfortable beige runner shoes with elastic knit, suitable for everyday wear.','product-8.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,11,1,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(16,'Orange saddle lock front chain cross body bag',7,NULL,84.00,1,5,NULL,'A trendy orange cross body bag with a saddle lock and chain detail.','product-9.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(17,'Light brown studded Wide fit wedges',7,NULL,110.00,8,10,130.00,'Stylish light brown wedges with studded details, offering a wide fit.','product-11.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,45,1,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(18,'Yellow button front tea top',7,NULL,56.00,5,12,NULL,'A casual yellow tea top with button front, perfect for a relaxed look.','product-10.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(19,'Black soft RI weekend travel bag',7,NULL,68.00,6,10,85.00,'A spacious black travel bag, ideal for weekend getaways.','product-12.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(20,'Beige metal hoop tote bag',7,NULL,76.00,7,5,NULL,'A fashionable beige tote bag with metal hoop handles.','product-13.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,41,2,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:15',0,0),(21,'Brown zebra print dungaree dress',7,NULL,80.00,8,5,95.00,'A unique brown dungaree dress with a zebra print, perfect for a bold look.','product-14.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:30',0,0),(22,'Beige ring handle circle cross body bag',7,NULL,56.00,1,2,NULL,'A chic beige cross body bag with a ring handle, great for daily use.','product-15.jpg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2025-03-19 02:02:07','2025-06-11 14:30:30',0,0),(23,'Men Shirt',8,4,56.00,1,10,62.00,'Quality','uploads/products/prod_6849cb30e49383.57383723.jpg','Ni','10','Men','[\"S\",\"L\",\"3XL\"]','0',0.00,0.00,410,2,'0221','[\"ope\"]',2,'2025-06-11 18:30:08','2025-06-11 18:31:09',0,0),(24,'TV nice',1,1,4850.00,1,10,5010.00,'A TV nice','uploads/products/prod_6849cc6eb13eb7.26146438.jpg','LIY','24','Other','[\"L\"]','0',0.00,0.00,52,2,'0121','[\"KI\"]',2,'2025-06-11 18:35:26','2025-06-11 18:35:26',0,0);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` int NOT NULL DEFAULT '0',
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_review` (`product_id`,`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_rating` (`rating`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK (((`rating` >= 0) and (`rating` <= 5)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`),
  KEY `permission_id` (`permission_id`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,11),(12,12),(13,13),(14,14),(15,15),(16,16),(17,1),(18,2),(19,6),(20,11),(21,12),(22,13);
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_analytics`
--

DROP TABLE IF EXISTS `seller_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_analytics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `seller_id` int DEFAULT NULL,
  `total_sales` decimal(10,2) DEFAULT NULL,
  `total_orders` int DEFAULT NULL,
  `date_recorded` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_id` (`seller_id`),
  KEY `idx_seller_analytics_date` (`date_recorded`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_analytics`
--

LOCK TABLES `seller_analytics` WRITE;
/*!40000 ALTER TABLE `seller_analytics` DISABLE KEYS */;
INSERT INTO `seller_analytics` VALUES (1,2,2.00,2,NULL);
/*!40000 ALTER TABLE `seller_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sellers`
--

DROP TABLE IF EXISTS `sellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sellers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `company_name` varchar(100) NOT NULL,
  `company_address` text NOT NULL,
  `business_registration_number` varchar(50) DEFAULT NULL,
  `tax_number` varchar(50) DEFAULT NULL,
  `bank_account_details` text,
  `commission_rate` decimal(5,2) DEFAULT '10.00',
  `status` varchar(20) DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `sellers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sellers`
--

LOCK TABLES `sellers` WRITE;
/*!40000 ALTER TABLE `sellers` DISABLE KEYS */;
INSERT INTO `sellers` VALUES (1,2,'Tecbeg','10 Mahem Kirkney Pretoria','Tecbeg','452','22',10.00,'1','2025-05-28 19:18:03','2025-05-28 19:18:33');
/*!40000 ALTER TABLE `sellers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `value` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shopping_behavior`
--

DROP TABLE IF EXISTS `shopping_behavior`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shopping_behavior` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` varchar(255) DEFAULT NULL,
  `viewedProducts` json DEFAULT NULL,
  `abandonedCarts` json DEFAULT NULL,
  `favoriteCategories` json DEFAULT NULL,
  `averageOrderValue` decimal(10,2) DEFAULT NULL,
  `purchaseFrequency` decimal(5,2) DEFAULT NULL,
  `lastPurchaseDate` datetime DEFAULT NULL,
  `stylePreferences` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`(250))
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shopping_behavior`
--

LOCK TABLES `shopping_behavior` WRITE;
/*!40000 ALTER TABLE `shopping_behavior` DISABLE KEYS */;
/*!40000 ALTER TABLE `shopping_behavior` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `style_preferences`
--

DROP TABLE IF EXISTS `style_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `style_preferences` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` varchar(255) DEFAULT NULL,
  `preferences` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`(250))
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `style_preferences`
--

LOCK TABLES `style_preferences` WRITE;
/*!40000 ALTER TABLE `style_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `style_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subcategories`
--

DROP TABLE IF EXISTS `subcategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subcategories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_subcat_category` (`category_id`),
  CONSTRAINT `fk_subcat_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `subcategories_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subcategories`
--

LOCK TABLES `subcategories` WRITE;
/*!40000 ALTER TABLE `subcategories` DISABLE KEYS */;
INSERT INTO `subcategories` VALUES (1,'Laptops & Computers',1,'2025-05-19 16:12:50'),(2,'TV & Video',1,'2025-05-19 16:12:50'),(3,'Bedroom',2,'2025-05-19 16:12:50'),(4,'Living Room',2,'2025-05-19 16:12:50'),(5,'Cookware',3,'2025-05-19 16:12:50'),(6,'Dinnerware & Tabletop',3,'2025-05-19 16:12:50'),(7,'Women',4,'2025-05-19 16:12:50'),(8,'Men',4,'2025-05-19 16:12:50'),(9,'Boys',4,'2025-05-19 16:12:50'),(10,'Girls',4,'2025-05-19 16:12:50');
/*!40000 ALTER TABLE `subcategories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_responses`
--

DROP TABLE IF EXISTS `support_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_responses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int DEFAULT NULL,
  `admin_id` int DEFAULT NULL,
  `response` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_id` (`ticket_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_responses`
--

LOCK TABLES `support_responses` WRITE;
/*!40000 ALTER TABLE `support_responses` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `description` text,
  `priority` enum('high','medium','low') DEFAULT NULL,
  `status` enum('open','in_progress','resolved','closed') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_tickets`
--

LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_profiles`
--

DROP TABLE IF EXISTS `user_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(90) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `shippingAddress` text,
  `billingAddress` text,
  `preferences` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userId` (`userId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_profiles`
--

LOCK TABLES `user_profiles` WRITE;
/*!40000 ALTER TABLE `user_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,'admin','all','2025-05-19 10:22:27'),(2,'seller','products,orders,inventory,reports','2025-05-19 10:22:27');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tokens`
--

LOCK TABLES `user_tokens` WRITE;
/*!40000 ALTER TABLE `user_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `user_roles` (`role_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@example.com','$2y$10$RjBZvMmzVQYpJGdIaT7WUOe7KqXtFhZnLkzDlEwVx1fQYgHcC7oN5sV.',1,1,'2025-06-26 22:33:12','2025-05-19 16:12:50','2025-06-26 20:33:12'),(2,'seller','seller@ri.co.za','',2,1,'2025-06-12 12:18:29','2025-05-28 18:02:09','2025-06-12 10:18:29'),(3,'seller1','tendergrpupdate@gmail.com','$2y$10$gED0QPa20wxIlW/krMyRz.6Z2fOFdGSSGA32IXsx3GkAH/Tqd8KzC',2,1,NULL,'2025-06-17 03:45:40','2025-06-17 03:45:40'),(4,'seller2','tendergrp@gmail.com','$2y$10$Xi2NQH6HhyGKoIGTHFR/4u3OcLJQBwZ28HBmkzpeAcvbVX274qFtG',2,1,NULL,'2025-06-17 03:47:17','2025-06-17 03:47:17');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_wishlist_item` (`user_id`,`product_id`),
  KEY `idx_wishlist_product` (`product_id`),
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `wishlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `wishlist_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlist`
--

LOCK TABLES `wishlist` WRITE;
/*!40000 ALTER TABLE `wishlist` DISABLE KEYS */;
INSERT INTO `wishlist` VALUES (1,1,12,'2025-05-25 20:25:20');
/*!40000 ALTER TABLE `wishlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kunashe'
--

--
-- Dumping routines for database 'kunashe'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:30:24
