-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: farmos
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
-- Current Database: `farmos`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `farmos` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `farmos`;

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
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biogas_systems`
--

LOCK TABLES `biogas_systems` WRITE;
/*!40000 ALTER TABLE `biogas_systems` DISABLE KEYS */;
INSERT INTO `biogas_systems` VALUES (1,'default','Main Digester Alpha',500,0.85,1.2,0.2,12.5,10.2,'normal',1,'2026-02-13 14:38:23');
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
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biogas_zones`
--

LOCK TABLES `biogas_zones` WRITE;
/*!40000 ALTER TABLE `biogas_zones` DISABLE KEYS */;
INSERT INTO `biogas_zones` VALUES (1,'default',1,'Primary Digester Tank','digester',0.85,5.2,'open','normal',0.01,1),(2,'default',1,'Gas Storage Tank A','storage',0.82,0,'open','normal',0.005,1),(3,'default',1,'Main Distribution Line','pipeline',0.78,4.8,'open','warning',0.06,1);
/*!40000 ALTER TABLE `biogas_zones` ENABLE KEYS */;
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
  KEY `ix_compliance_requirements_tenant_id` (`tenant_id`),
  KEY `ix_compliance_requirements_id` (`id`)
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
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compost_piles`
--

LOCK TABLES `compost_piles` WRITE;
/*!40000 ALTER TABLE `compost_piles` DISABLE KEYS */;
INSERT INTO `compost_piles` VALUES (1,'default','Primary Aerobic Pile','Hot Compost','OPTIMAL',58.5,55,6.8,12,NULL),(2,'default','Manure Curing Pile','Cold Compost','SLOW',32,40,7.2,45,NULL);
/*!40000 ALTER TABLE `compost_piles` ENABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
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
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_cost_centers_tenant_id` (`tenant_id`),
  KEY `ix_cost_centers_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cost_centers`
--

LOCK TABLES `cost_centers` WRITE;
/*!40000 ALTER TABLE `cost_centers` DISABLE KEYS */;
/*!40000 ALTER TABLE `cost_centers` ENABLE KEYS */;
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
  KEY `ix_customers_id` (`id`),
  KEY `ix_customers_tenant_id` (`tenant_id`)
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
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `energy_loads`
--

LOCK TABLES `energy_loads` WRITE;
/*!40000 ALTER TABLE `energy_loads` DISABLE KEYS */;
INSERT INTO `energy_loads` VALUES (1,'default','Cold Storage A','Main Barn','cooling',450,1,'on',10),(2,'default','Incubator #1','Hatchery','heating',200,1,'on',10),(3,'default','Irrigation Pump 1','North Field','pump',1200,0,'off',5),(4,'default','Workshop Lighting','Workshop','lighting',150,0,'on',3);
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
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `energy_logs`
--

LOCK TABLES `energy_logs` WRITE;
/*!40000 ALTER TABLE `energy_logs` DISABLE KEYS */;
INSERT INTO `energy_logs` VALUES (1,'default','2026-02-13 14:38:24',50,70,1200,1500,'disconnected',NULL,NULL,NULL),(2,'default','2026-02-13 13:38:24',51,71,1210,1500,'connected',NULL,NULL,NULL),(3,'default','2026-02-13 12:38:24',52,72,1220,1500,'connected',NULL,NULL,NULL),(4,'default','2026-02-13 11:38:24',53,73,1230,1500,'connected',NULL,NULL,NULL),(5,'default','2026-02-13 10:38:24',54,74,1240,1500,'connected',NULL,NULL,NULL),(6,'default','2026-02-13 09:38:24',50,75,1250,1500,'connected',NULL,NULL,NULL),(7,'default','2026-02-13 08:38:24',51,76,1260,1500,'connected',NULL,NULL,NULL),(8,'default','2026-02-13 07:38:24',52,77,1270,1500,'connected',NULL,NULL,NULL),(9,'default','2026-02-13 06:38:24',53,78,1280,0,'connected',NULL,NULL,NULL),(10,'default','2026-02-13 05:38:24',54,79,1290,0,'connected',NULL,NULL,NULL),(11,'default','2026-02-13 04:38:24',50,80,1300,0,'connected',NULL,NULL,NULL),(12,'default','2026-02-13 03:38:24',51,81,1310,0,'connected',NULL,NULL,NULL),(13,'default','2026-02-13 02:38:24',52,82,1320,0,'disconnected',NULL,NULL,NULL),(14,'default','2026-02-13 01:38:24',53,83,1330,0,'connected',NULL,NULL,NULL),(15,'default','2026-02-13 00:38:24',54,84,1340,0,'connected',NULL,NULL,NULL),(16,'default','2026-02-12 23:38:24',50,85,1350,0,'connected',NULL,NULL,NULL),(17,'default','2026-02-12 22:38:24',51,86,1360,0,'connected',NULL,NULL,NULL),(18,'default','2026-02-12 21:38:24',52,87,1370,0,'connected',NULL,NULL,NULL),(19,'default','2026-02-12 20:38:24',53,88,1380,0,'connected',NULL,NULL,NULL),(20,'default','2026-02-12 19:38:24',54,89,1390,0,'connected',NULL,NULL,NULL),(21,'default','2026-02-12 18:38:24',50,70,1400,0,'connected',NULL,NULL,NULL),(22,'default','2026-02-12 17:38:24',51,71,1410,1500,'connected',NULL,NULL,NULL),(23,'default','2026-02-12 16:38:24',52,72,1420,1500,'connected',NULL,NULL,NULL),(24,'default','2026-02-12 15:38:24',53,73,1430,1500,'connected',NULL,NULL,NULL);
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
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `vibration_baseline` float DEFAULT NULL,
  `temperature_baseline` float DEFAULT NULL,
  `current_draw_baseline` float DEFAULT NULL,
  `last_maintenance` datetime DEFAULT NULL,
  `next_maintenance` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_equipment_tenant_id` (`tenant_id`),
  KEY `ix_equipment_name` (`name`),
  KEY `ix_equipment_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (1,'default','Irrigation Pump Main','Dam 1','healthy',4.2,45,15,NULL,NULL),(2,'default','Cold Storage Compressor','Warehouse B','healthy',2.5,35,32,NULL,NULL),(3,'default','Milling Unit 3','Processing Plant','healthy',5,60,25,NULL,NULL);
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
  KEY `ix_feed_formulations_id` (`id`),
  KEY `ix_feed_formulations_tenant_id` (`tenant_id`)
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
  KEY `ix_feed_ingredients_id` (`id`),
  KEY `ix_feed_ingredients_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_ingredients`
--

LOCK TABLES `feed_ingredients` WRITE;
/*!40000 ALTER TABLE `feed_ingredients` DISABLE KEYS */;
INSERT INTO `feed_ingredients` VALUES (1,'default','Maize Meal',9,1000,0.45,NULL),(2,'default','Soya Bean Meal',44,500,0.85,NULL),(3,'default','Fish Meal',60,100,1.5,NULL),(4,'default','Wheat Bran',14,300,0.35,NULL),(5,'default','Sunflower Cake',28,200,0.55,NULL);
/*!40000 ALTER TABLE `feed_ingredients` ENABLE KEYS */;
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
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `area` float DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `crop` varchar(50) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_fields_id` (`id`),
  KEY `ix_fields_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fields`
--

LOCK TABLES `fields` WRITE;
/*!40000 ALTER TABLE `fields` DISABLE KEYS */;
INSERT INTO `fields` VALUES (1,'default','Home Field',5,'hectares','Maize','planted'),(2,'default','River Plot',2.5,'hectares','Vegetables','active'),(3,'default','Grazing Land',50,'hectares','Pasture','active');
/*!40000 ALTER TABLE `fields` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  KEY `ix_financial_transactions_id` (`id`),
  KEY `ix_financial_transactions_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_transactions`
--

LOCK TABLES `financial_transactions` WRITE;
/*!40000 ALTER TABLE `financial_transactions` DISABLE KEYS */;
INSERT INTO `financial_transactions` VALUES (1,'default','income','Sales',5000,'Sold 5 steers','2023-09-15'),(2,'default','expense','Inputs',1200,'Purchased Fertilizer','2023-09-20'),(3,'default','expense','Labor',800,'Casual labor wages','2023-09-30');
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
  KEY `ix_harvest_logs_id` (`id`),
  KEY `ix_harvest_logs_tenant_id` (`tenant_id`)
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_inventory_items_qr_code` (`qr_code`),
  KEY `ix_inventory_items_id` (`id`),
  KEY `ix_inventory_items_name` (`name`),
  KEY `ix_inventory_items_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_items`
--

LOCK TABLES `inventory_items` WRITE;
/*!40000 ALTER TABLE `inventory_items` DISABLE KEYS */;
INSERT INTO `inventory_items` VALUES (1,'default','Maize Seed (SC727)','Seeds',250,'kg','Shed A',10,NULL),(2,'default','Compound D Fertilizer','Fertilizer',1000,'kg','Shed B',10,NULL),(3,'default','Diesel','Fuel',500,'liters','Fuel Tank',10,NULL),(4,'default','Cattle Dip','Chemicals',20,'liters','Chemical Store',10,NULL);
/*!40000 ALTER TABLE `inventory_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `quantity` float DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `ix_inventory_transactions_id` (`id`),
  KEY `ix_inventory_transactions_tenant_id` (`tenant_id`)
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
  KEY `ix_irrigation_events_tenant_id` (`tenant_id`),
  KEY `ix_irrigation_events_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `irrigation_events`
--

LOCK TABLES `irrigation_events` WRITE;
/*!40000 ALTER TABLE `irrigation_events` DISABLE KEYS */;
INSERT INTO `irrigation_events` VALUES (1,'default',1,'2026-02-13 16:38:23',45,'AUTO_SKIPPED','Rain Forecast'),(2,'default',1,'2026-02-13 11:38:23',60,'COMPLETED',NULL);
/*!40000 ALTER TABLE `irrigation_events` ENABLE KEYS */;
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
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `irrigation_zones`
--

LOCK TABLES `irrigation_zones` WRITE;
/*!40000 ALTER TABLE `irrigation_zones` DISABLE KEYS */;
INSERT INTO `irrigation_zones` VALUES (1,'default','North Orchard',1,40,72,'WET'),(2,'default','Vegetable Patch 2',1,35,38,'OPTIMAL'),(3,'default','Main Pasture',1,30,22,'DRY');
/*!40000 ALTER TABLE `irrigation_zones` ENABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listings`
--

LOCK TABLES `listings` WRITE;
/*!40000 ALTER TABLE `listings` DISABLE KEYS */;
/*!40000 ALTER TABLE `listings` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  KEY `ix_livestock_batches_tenant_id` (`tenant_id`),
  KEY `ix_livestock_batches_id` (`id`),
  KEY `ix_livestock_batches_type` (`type`),
  CONSTRAINT `check_count_positive` CHECK ((`count` >= 0)),
  CONSTRAINT `check_quantity_positive` CHECK ((`quantity` >= 0))
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livestock_batches`
--

LOCK TABLES `livestock_batches` WRITE;
/*!40000 ALTER TABLE `livestock_batches` DISABLE KEYS */;
INSERT INTO `livestock_batches` VALUES (1,'default','Cattle','Batch 001',45,45,'healthy','2023-01-01 00:00:00','Mashona','North Paddock',NULL),(2,'default','Goats','Batch 002',30,30,'healthy','2023-02-15 00:00:00','Matabele','East Pen',NULL),(3,'default','Chickens','Batch 003',500,500,'healthy','2023-03-10 00:00:00','Broilers','Coop 1',NULL),(4,'default','Cattle','Batch 004',5,5,'sick','2023-04-05 00:00:00','Brahman','Quarantine Area',NULL);
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
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  KEY `ix_livestock_events_tenant_id` (`tenant_id`),
  KEY `ix_livestock_events_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livestock_events`
--

LOCK TABLES `livestock_events` WRITE;
/*!40000 ALTER TABLE `livestock_events` DISABLE KEYS */;
INSERT INTO `livestock_events` VALUES (1,1,'default','Vaccination','2023-10-01 00:00:00','Anthrax booster','Dr. Vet',150),(2,1,'default','Feeding','2023-10-15 00:00:00','Supplement','Worker',50);
/*!40000 ALTER TABLE `livestock_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_logs`
--

DROP TABLE IF EXISTS `maintenance_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `vibration` float DEFAULT NULL,
  `temperature` float DEFAULT NULL,
  `current_draw` float DEFAULT NULL,
  `risk_score` float DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `ix_maintenance_logs_id` (`id`),
  KEY `ix_maintenance_logs_tenant_id` (`tenant_id`)
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
  KEY `ix_orders_id` (`id`),
  KEY `ix_orders_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_inventory_items`
--

DROP TABLE IF EXISTS `qr_inventory_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qr_inventory_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `item_type` varchar(50) DEFAULT NULL,
  `qr_data` text,
  `qr_image_url` text,
  `generated_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `generated_by` (`generated_by`),
  KEY `ix_qr_inventory_items_tenant_id` (`tenant_id`),
  KEY `ix_qr_inventory_items_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_inventory_items`
--

LOCK TABLES `qr_inventory_items` WRITE;
/*!40000 ALTER TABLE `qr_inventory_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `qr_inventory_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_scans`
--

DROP TABLE IF EXISTS `qr_scans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qr_scans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `item_type` varchar(50) DEFAULT NULL,
  `scan_type` varchar(50) DEFAULT NULL,
  `scanned_by` int DEFAULT NULL,
  `scan_data` text,
  `scan_timestamp` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scanned_by` (`scanned_by`),
  KEY `ix_qr_scans_id` (`id`),
  KEY `ix_qr_scans_tenant_id` (`tenant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_scans`
--

LOCK TABLES `qr_scans` WRITE;
/*!40000 ALTER TABLE `qr_scans` DISABLE KEYS */;
/*!40000 ALTER TABLE `qr_scans` ENABLE KEYS */;
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
  KEY `ix_scouting_logs_id` (`id`),
  KEY `ix_scouting_logs_tenant_id` (`tenant_id`)
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
-- Table structure for table `sensor_data`
--

DROP TABLE IF EXISTS `sensor_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor_data` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `sensor_type` varchar(50) DEFAULT NULL,
  `value` float DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_sensor_data_tenant_id` (`tenant_id`),
  KEY `ix_sensor_data_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensor_data`
--

LOCK TABLES `sensor_data` WRITE;
/*!40000 ALTER TABLE `sensor_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `sensor_data` ENABLE KEYS */;
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
  KEY `ix_soil_health_logs_tenant_id` (`tenant_id`),
  KEY `ix_soil_health_logs_id` (`id`)
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
  KEY `ix_sop_executions_id` (`id`),
  KEY `ix_sop_executions_tenant_id` (`tenant_id`)
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sops`
--

LOCK TABLES `sops` WRITE;
/*!40000 ALTER TABLE `sops` DISABLE KEYS */;
/*!40000 ALTER TABLE `sops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `description` text,
  `assigned_to` varchar(100) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `priority` varchar(20) DEFAULT NULL,
  `due_date` varchar(20) DEFAULT NULL,
  `is_recurring` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_tasks_tenant_id` (`tenant_id`),
  KEY `ix_tasks_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'default','Scout Home Field','Check for armyworm','Field Worker','pending','high','2023-11-01',0),(2,'default','Buy Diesel','Refill main tank','Farm Manager','in_progress','medium','2023-10-30',0),(3,'default','Vaccinate Goats','Routine checkup','Vet','completed','high','2023-10-20',0);
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timesheets`
--

DROP TABLE IF EXISTS `timesheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timesheets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `work_date` varchar(20) DEFAULT NULL,
  `hours_worked` float DEFAULT NULL,
  `task_description` text,
  `status` varchar(20) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `approved_by` (`approved_by`),
  KEY `ix_timesheets_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timesheets`
--

LOCK TABLES `timesheets` WRITE;
/*!40000 ALTER TABLE `timesheets` DISABLE KEYS */;
INSERT INTO `timesheets` VALUES (1,1,'2026-02-18',1,'Test insert from script','pending',NULL,'2026-02-18 08:26:43');
/*!40000 ALTER TABLE `timesheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `hashed_password` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_email` (`email`),
  KEY `ix_users_name` (`name`),
  KEY `ix_users_id` (`id`),
  KEY `ix_users_tenant_id` (`tenant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'default','Admin User','admin@example.com','admin','active','$2b$12$FzuT2MON9S7MTwexuf9ZtOuXlblLfxBmyaonFx6Ruaa1bEn7DCK3y','2026-02-13 14:38:22'),(2,'default','Farm Manager','manager@example.com','manager','active','$2b$12$hOuQ3ebyrZ5wr0iv34NQ1O.sfL0ubHbjxdzBR6cnZZMf2IQhcND3m','2026-02-13 14:38:22'),(3,'default','Field Worker','worker@example.com','worker','active','$2b$12$Qnmz9S3OZNmojEmZcCroCudLRvnC7ZoCwJcUv..poeicEEFWa20ju','2026-02-13 14:38:22');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'farmos'
--

--
-- Dumping routines for database 'farmos'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:29:23
