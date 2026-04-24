-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: atis_db
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
-- Current Database: `atis_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `atis_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `atis_db`;

--
-- Table structure for table `bid_decisions`
--

DROP TABLE IF EXISTS `bid_decisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bid_decisions` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `decision` varchar(20) DEFAULT NULL,
  `risk_score` int DEFAULT NULL,
  `margin_score` int DEFAULT NULL,
  `capacity_score` int DEFAULT NULL,
  `strategic_fit_score` int DEFAULT NULL,
  `reason` text,
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_bid_decisions_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bid_decisions`
--

LOCK TABLES `bid_decisions` WRITE;
/*!40000 ALTER TABLE `bid_decisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `bid_decisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bid_tasks`
--

DROP TABLE IF EXISTS `bid_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bid_tasks` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `assignee` varchar(100) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `due_date` varchar(20) DEFAULT NULL,
  `priority` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_bid_tasks_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bid_tasks`
--

LOCK TABLES `bid_tasks` WRITE;
/*!40000 ALTER TABLE `bid_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `bid_tasks` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_task_insert` AFTER INSERT ON `bid_tasks` FOR EACH ROW BEGIN
                UPDATE tenders SET stage = 'Feasibility' WHERE id = NEW.tender_id AND stage = 'Discovery';
            END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `boq_items`
--

DROP TABLE IF EXISTS `boq_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `boq_items` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `description` text,
  `unit` varchar(50) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `unit_rate` int DEFAULT NULL,
  `unit_rate_id` varchar(50) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_boq_items_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boq_items`
--

LOCK TABLES `boq_items` WRITE;
/*!40000 ALTER TABLE `boq_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `boq_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sector` varchar(100) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `contacts` json DEFAULT NULL,
  `notes` json DEFAULT NULL,
  `sentiment` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_clients_name` (`name`(250)),
  KEY `ix_clients_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `bbbee_level` int DEFAULT NULL,
  `cidb_grading` json DEFAULT NULL,
  `documents` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_companies_name` (`name`(250)),
  KEY `ix_companies_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES ('c-1771415588551','Gutakura Tradings','Electrical projects',6,'[\"7CE\"]','[]');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `engagements`
--

DROP TABLE IF EXISTS `engagements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `engagements` (
  `id` varchar(50) NOT NULL,
  `client_id` varchar(50) DEFAULT NULL,
  `contact_id` varchar(50) DEFAULT NULL,
  `engagement_type` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `notes` text,
  `related_tender_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `ix_engagements_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `engagements`
--

LOCK TABLES `engagements` WRITE;
/*!40000 ALTER TABLE `engagements` DISABLE KEYS */;
/*!40000 ALTER TABLE `engagements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` varchar(50) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `message` text,
  `link` varchar(255) DEFAULT NULL,
  `read` tinyint(1) DEFAULT NULL,
  `created_at` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_notifications_id` (`id`)
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
-- Table structure for table `organizations`
--

DROP TABLE IF EXISTS `organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organizations` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_organizations_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organizations`
--

LOCK TABLES `organizations` WRITE;
/*!40000 ALTER TABLE `organizations` DISABLE KEYS */;
/*!40000 ALTER TABLE `organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pricing_scenarios`
--

DROP TABLE IF EXISTS `pricing_scenarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pricing_scenarios` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `assumptions` json DEFAULT NULL,
  `results` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_pricing_scenarios_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pricing_scenarios`
--

LOCK TABLES `pricing_scenarios` WRITE;
/*!40000 ALTER TABLE `pricing_scenarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `pricing_scenarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proposal_documents`
--

DROP TABLE IF EXISTS `proposal_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proposal_documents` (
  `id` varchar(50) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `status` varchar(50) DEFAULT NULL,
  `version` int DEFAULT NULL,
  `last_edited` varchar(20) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_proposal_documents_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proposal_documents`
--

LOCK TABLES `proposal_documents` WRITE;
/*!40000 ALTER TABLE `proposal_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `proposal_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saved_searches`
--

DROP TABLE IF EXISTS `saved_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `saved_searches` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `query` varchar(255) DEFAULT NULL,
  `negative_keywords` varchar(255) DEFAULT NULL,
  `cidb_grade` varchar(50) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `radius` varchar(50) DEFAULT NULL,
  `sector` varchar(100) DEFAULT NULL,
  `portals` json DEFAULT NULL,
  `last_run` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_saved_searches_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saved_searches`
--

LOCK TABLES `saved_searches` WRITE;
/*!40000 ALTER TABLE `saved_searches` DISABLE KEYS */;
/*!40000 ALTER TABLE `saved_searches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_visits`
--

DROP TABLE IF EXISTS `site_visits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_visits` (
  `id` varchar(50) NOT NULL,
  `tender_ref` varchar(100) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `client` varchar(100) DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `time` varchar(20) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `coordinates` json DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `attendees` json DEFAULT NULL,
  `check_in` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_site_visits_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_visits`
--

LOCK TABLES `site_visits` WRITE;
/*!40000 ALTER TABLE `site_visits` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_visits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snippets`
--

DROP TABLE IF EXISTS `snippets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snippets` (
  `id` varchar(50) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `content` text,
  PRIMARY KEY (`id`),
  KEY `ix_snippets_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snippets`
--

LOCK TABLES `snippets` WRITE;
/*!40000 ALTER TABLE `snippets` DISABLE KEYS */;
/*!40000 ALTER TABLE `snippets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stage_config`
--

DROP TABLE IF EXISTS `stage_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stage_config` (
  `id` varchar(50) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `order` int DEFAULT NULL,
  `is_final` tinyint(1) DEFAULT NULL,
  `rules` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `ix_stage_config_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stage_config`
--

LOCK TABLES `stage_config` WRITE;
/*!40000 ALTER TABLE `stage_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `stage_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subcontractors`
--

DROP TABLE IF EXISTS `subcontractors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subcontractors` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `trade` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `bbbee_level` int DEFAULT NULL,
  `classification` varchar(50) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_subcontractors_id` (`id`),
  KEY `ix_subcontractors_name` (`name`(250))
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subcontractors`
--

LOCK TABLES `subcontractors` WRITE;
/*!40000 ALTER TABLE `subcontractors` DISABLE KEYS */;
/*!40000 ALTER TABLE `subcontractors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_templates`
--

DROP TABLE IF EXISTS `task_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_templates` (
  `id` varchar(50) NOT NULL,
  `sector` varchar(100) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `default_assignee_role` varchar(100) DEFAULT NULL,
  `relative_due_days` int DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_task_templates_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_templates`
--

LOCK TABLES `task_templates` WRITE;
/*!40000 ALTER TABLE `task_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_members`
--

DROP TABLE IF EXISTS `team_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_members` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `role` varchar(100) DEFAULT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `years_experience` int DEFAULT NULL,
  `qualifications` json DEFAULT NULL,
  `skills` json DEFAULT NULL,
  `cv_status` varchar(50) DEFAULT NULL,
  `last_updated` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_team_members_name` (`name`(250)),
  KEY `ix_team_members_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_members`
--

LOCK TABLES `team_members` WRITE;
/*!40000 ALTER TABLE `team_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tender_compliance_requirements`
--

DROP TABLE IF EXISTS `tender_compliance_requirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tender_compliance_requirements` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `bbbee_min_level` int DEFAULT NULL,
  `cidb_required_grades` json DEFAULT NULL,
  `needs_tax_pin` tinyint(1) DEFAULT NULL,
  `needs_iso` tinyint(1) DEFAULT NULL,
  `needs_coid` tinyint(1) DEFAULT NULL,
  `min_local_content` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_tender_compliance_requirements_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tender_compliance_requirements`
--

LOCK TABLES `tender_compliance_requirements` WRITE;
/*!40000 ALTER TABLE `tender_compliance_requirements` DISABLE KEYS */;
/*!40000 ALTER TABLE `tender_compliance_requirements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tender_documents`
--

DROP TABLE IF EXISTS `tender_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tender_documents` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `doc_type` varchar(50) DEFAULT NULL,
  `version` int DEFAULT NULL,
  `uploaded_by` varchar(50) DEFAULT NULL,
  `uploaded_at` varchar(50) DEFAULT NULL,
  `storage_path` varchar(500) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_tender_documents_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tender_documents`
--

LOCK TABLES `tender_documents` WRITE;
/*!40000 ALTER TABLE `tender_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `tender_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tender_intake`
--

DROP TABLE IF EXISTS `tender_intake`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tender_intake` (
  `id` varchar(50) NOT NULL,
  `tender_id` varchar(50) DEFAULT NULL,
  `source` varchar(100) DEFAULT NULL,
  `owner_id` varchar(50) DEFAULT NULL,
  `qualification_notes` text,
  PRIMARY KEY (`id`),
  KEY `tender_id` (`tender_id`),
  KEY `ix_tender_intake_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tender_intake`
--

LOCK TABLES `tender_intake` WRITE;
/*!40000 ALTER TABLE `tender_intake` DISABLE KEYS */;
/*!40000 ALTER TABLE `tender_intake` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenders`
--

DROP TABLE IF EXISTS `tenders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenders` (
  `id` varchar(50) NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `issuer` varchar(100) DEFAULT NULL,
  `link` varchar(500) DEFAULT NULL,
  `closing_date` varchar(20) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `sector` varchar(100) DEFAULT NULL,
  `risk_level` varchar(50) DEFAULT NULL,
  `compliance` json DEFAULT NULL,
  `summary` text,
  `documents_count` int DEFAULT NULL,
  `published_date` varchar(20) DEFAULT NULL,
  `deep_analysis` json DEFAULT NULL,
  `is_pinned` tinyint(1) DEFAULT NULL,
  `stage` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_tenders_reference` (`reference`),
  KEY `ix_tenders_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenders`
--

LOCK TABLES `tenders` WRITE;
/*!40000 ALTER TABLE `tenders` DISABLE KEYS */;
INSERT INTO `tenders` VALUES ('za-tnd-88219','SANRAL N.011-040-2024/1','Periodic Maintenance on National Route 11 Section 4 from Ladysmith (km 0.0) to Elandslaagte (km 24.0)','SANRAL','https://www.nra.co.za/service-provider-zone/tenders/open-tenders/','2024-03-27','Open','Civil Construction','High','{\"cidbGrade\": \"8CE\", \"bbbeeLevel\": 1, \"localContent\": 100, \"taxPinRequired\": true}','The project involves the periodic maintenance and repair of a 24km stretch of the N11 national route including asphalt overlays.',14,'2024-02-14','null',0,'Discovery');
/*!40000 ALTER TABLE `tenders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unit_rates`
--

DROP TABLE IF EXISTS `unit_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unit_rates` (
  `id` varchar(50) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `item_description` text,
  `unit` varchar(50) DEFAULT NULL,
  `rate` int DEFAULT NULL,
  `last_updated` varchar(20) DEFAULT NULL,
  `source_tender` varchar(100) DEFAULT NULL,
  `trend` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_unit_rates_id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unit_rates`
--

LOCK TABLES `unit_rates` WRITE;
/*!40000 ALTER TABLE `unit_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `unit_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `sections` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_users_id` (`id`),
  KEY `ix_users_name` (`name`(250))
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `view_high_risk_tenders`
--

DROP TABLE IF EXISTS `view_high_risk_tenders`;
/*!50001 DROP VIEW IF EXISTS `view_high_risk_tenders`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_high_risk_tenders` AS SELECT 
 1 AS `id`,
 1 AS `reference`,
 1 AS `title`,
 1 AS `issuer`,
 1 AS `closing_date`,
 1 AS `stage`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_pending_tasks`
--

DROP TABLE IF EXISTS `view_pending_tasks`;
/*!50001 DROP VIEW IF EXISTS `view_pending_tasks`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_pending_tasks` AS SELECT 
 1 AS `task_id`,
 1 AS `task_title`,
 1 AS `tender_title`,
 1 AS `assignee`,
 1 AS `due_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'atis_db'
--

--
-- Dumping routines for database 'atis_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `get_tender_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_tender_stats`()
BEGIN
                SELECT status, COUNT(*) as count FROM tenders GROUP BY status;
            END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `atis_db`
--

USE `atis_db`;

--
-- Final view structure for view `view_high_risk_tenders`
--

/*!50001 DROP VIEW IF EXISTS `view_high_risk_tenders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_high_risk_tenders` AS select `tenders`.`id` AS `id`,`tenders`.`reference` AS `reference`,`tenders`.`title` AS `title`,`tenders`.`issuer` AS `issuer`,`tenders`.`closing_date` AS `closing_date`,`tenders`.`stage` AS `stage` from `tenders` where (`tenders`.`risk_level` = 'High') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_pending_tasks`
--

/*!50001 DROP VIEW IF EXISTS `view_pending_tasks`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_pending_tasks` AS select `t`.`id` AS `task_id`,`t`.`title` AS `task_title`,`ten`.`title` AS `tender_title`,`t`.`assignee` AS `assignee`,`t`.`due_date` AS `due_date` from (`bid_tasks` `t` join `tenders` `ten` on((`t`.`tender_id` = `ten`.`id`))) where (`t`.`status` <> 'Completed') */;
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

-- Dump completed on 2026-04-24 12:28:52
