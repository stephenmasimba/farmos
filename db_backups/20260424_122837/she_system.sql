-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: she_system
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
-- Current Database: `she_system`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `she_system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `she_system`;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `details` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `checklist_items`
--

DROP TABLE IF EXISTS `checklist_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `checklist_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `checklist_id` int DEFAULT NULL,
  `question` text,
  `order_index` int DEFAULT NULL,
  `is_critical` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `checklist_id` (`checklist_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checklist_items`
--

LOCK TABLES `checklist_items` WRITE;
/*!40000 ALTER TABLE `checklist_items` DISABLE KEYS */;
INSERT INTO `checklist_items` VALUES (1,1,'Are all workers wearing PPE?',1,0),(2,1,'Is the site free of trip hazards?',2,0),(3,1,'Is the first aid kit accessible?',3,0);
/*!40000 ALTER TABLE `checklist_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `checklists`
--

DROP TABLE IF EXISTS `checklists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `checklists` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `frequency` enum('daily','weekly','monthly') DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checklists`
--

LOCK TABLES `checklists` WRITE;
/*!40000 ALTER TABLE `checklists` DISABLE KEYS */;
INSERT INTO `checklists` VALUES (1,'Daily Site Safety','daily',NULL);
/*!40000 ALTER TABLE `checklists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `covid_screening`
--

DROP TABLE IF EXISTS `covid_screening`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `covid_screening` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `temperature` decimal(4,1) DEFAULT NULL,
  `has_symptoms` tinyint(1) DEFAULT '0',
  `screening_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `screener_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `covid_screening`
--

LOCK TABLES `covid_screening` WRITE;
/*!40000 ALTER TABLE `covid_screening` DISABLE KEYS */;
/*!40000 ALTER TABLE `covid_screening` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_versions`
--

DROP TABLE IF EXISTS `document_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_versions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_id` int NOT NULL,
  `version_number` varchar(20) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `changed_by` int DEFAULT NULL,
  `change_note` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `document_id` (`document_id`),
  KEY `changed_by` (`changed_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_versions`
--

LOCK TABLES `document_versions` WRITE;
/*!40000 ALTER TABLE `document_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `module_code` varchar(10) DEFAULT NULL,
  `title` varchar(150) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `upload_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('draft','pending','approved','expired') DEFAULT 'draft',
  `expiry_date` date DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `file_type` varchar(50) DEFAULT 'docx',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,NULL,'GT-TLK-OS-LN-FTTX-OSP-G2-V03-05-09-2024-Signed','C:\\wamp64\\www\\SHE\\Word_Converted\\00 Openserve G2 Spread Sheet  Team Compositions\\GT-TLK-OS-LN-FTTX-OSP-G2-V03-05-09-2024-Signed.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'GT-TLK-OS-LN-FTTX-OSP-G2-V03-05-09-2024-Signed.docx','docx','2026-01-04 05:27:35'),(2,NULL,'GT-TLK-OS-LN-FTTX-OSP-G2-V03-05-09-Dec 2025-Signed','C:\\wamp64\\www\\SHE\\Word_Converted\\00 Openserve G2 Spread Sheet  Team Compositions\\GT-TLK-OS-LN-FTTX-OSP-G2-V03-05-09-Dec 2025-Signed.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'GT-TLK-OS-LN-FTTX-OSP-G2-V03-05-09-Dec 2025-Signed.docx','docx','2026-01-04 05:27:35'),(3,NULL,'NOK-OHS-001 HS Specs 2024 V12 - signed','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\011 Nokia HS specification\\NOK-OHS-001 HS Specs 2024 V12 - signed.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'NOK-OHS-001 HS Specs 2024 V12 - signed.docx','docx','2026-01-04 05:27:35'),(4,NULL,'NOK-OHS-001 HS Specs Dec 2025 V12 - signed','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\011 Nokia HS specification\\NOK-OHS-001 HS Specs Dec 2025 V12 - signed.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'NOK-OHS-001 HS Specs Dec 2025 V12 - signed.docx','docx','2026-01-04 05:27:35'),(5,NULL,'LAELNET DETAILED SCOPE OF WORK 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\012 Detailed project specific scope of work\\LAELNET DETAILED SCOPE OF WORK 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'LAELNET DETAILED SCOPE OF WORK 2024.docx','docx','2026-01-04 05:27:35'),(6,NULL,'OS - Homes Connect SOW','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\012 Detailed project specific scope of work\\OS - Homes Connect SOW.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'OS - Homes Connect SOW.docx','docx','2026-01-04 05:27:35'),(7,NULL,'OS - Homes Passed SOW','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\012 Detailed project specific scope of work\\OS - Homes Passed SOW.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'OS - Homes Passed SOW.docx','docx','2026-01-04 05:27:35'),(8,NULL,'RAMTHEL DETAILED SCOPE OF WORK 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\012 Detailed project specific scope of work\\RAMTHEL DETAILED SCOPE OF WORK 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'RAMTHEL DETAILED SCOPE OF WORK 2024.docx','docx','2026-01-04 05:27:35'),(9,NULL,'~$ELNET DETAILED SCOPE OF WORK Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\012 Detailed project specific scope of work\\~$ELNET DETAILED SCOPE OF WORK Dec 2025.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'~$ELNET DETAILED SCOPE OF WORK Dec 2025.docx','docx','2026-01-04 05:27:35'),(10,NULL,'2. NOKIA Openserve SOW and SMI Document Ramthel 2024 Rev','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\013 Scope of work declaration completed\\2. NOKIA Openserve SOW and SMI Document Ramthel 2024 Rev.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'2. NOKIA Openserve SOW and SMI Document Ramthel 2024 Rev.docx','docx','2026-01-04 05:27:35'),(11,NULL,'2. NOKIA Openserve SOW and SMI Document Ramthel Dec 2025 Rev','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\013 Scope of work declaration completed\\2. NOKIA Openserve SOW and SMI Document Ramthel Dec 2025 Rev.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'2. NOKIA Openserve SOW and SMI Document Ramthel Dec 2025 Rev.docx','docx','2026-01-04 05:27:35'),(12,NULL,'Organogram August 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\015 Site specific org chart\\Organogram August 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Organogram August 2024.docx','docx','2026-01-04 05:27:35'),(13,NULL,'Organogram August Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\015 Site specific org chart\\Organogram August Dec 2025.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Organogram August Dec 2025.docx','docx','2026-01-04 05:27:35'),(14,NULL,'Gladys Permit','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\016 Completed workers register ID number full name  surname\\1062 Employees work permits when required\\Gladys Permit.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Gladys Permit.docx','docx','2026-01-04 05:27:35'),(15,NULL,'SITE WORKERS REGISTER','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\016 Completed workers register ID number full name  surname\\SITE WORKERS REGISTER.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'SITE WORKERS REGISTER.docx','docx','2026-01-04 05:27:35'),(16,NULL,'Notification of Construction (Annexure 2) 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\017 Proof of Notification of Construction work to DOL Annexure 2\\Notification of Construction (Annexure 2) 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Notification of Construction (Annexure 2) 2024.docx','docx','2026-01-04 05:27:35'),(17,NULL,'Notification of Construction (Annexure 2) Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\01 Scope of Work  Site Documents\\017 Proof of Notification of Construction work to DOL Annexure 2\\Notification of Construction (Annexure 2) Dec 2025.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Notification of Construction (Annexure 2) Dec 2025.docx','docx','2026-01-04 05:27:35'),(18,NULL,'OT107322948_1_20690583665245','C:\\wamp64\\www\\SHE\\Word_Converted\\02 Legal Insurances\\022Public Liability Insurance 10 Million\\OT107322948_1_20690583665245.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'OT107322948_1_20690583665245.docx','docx','2026-01-04 05:27:35'),(19,NULL,'Incident Management Procedure 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\031 Incident reporting procedures\\Incident Management Procedure 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Incident Management Procedure 2024.docx','docx','2026-01-04 05:27:35'),(20,NULL,'Incident Management Procedure Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\031 Incident reporting procedures\\Incident Management Procedure Dec 2025.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Incident Management Procedure Dec 2025.docx','docx','2026-01-04 05:27:35'),(21,NULL,'ONSITE EMERGENCY PROCEDURE 2024 Rev','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\032 Emergency response procedures\\ONSITE EMERGENCY PROCEDURE 2024 Rev.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'ONSITE EMERGENCY PROCEDURE 2024 Rev.docx','docx','2026-01-04 05:27:35'),(22,NULL,'ONSITE EMERGENCY PROCEDURE Dec 2025 Rev','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\032 Emergency response procedures\\ONSITE EMERGENCY PROCEDURE Dec 2025 Rev.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'ONSITE EMERGENCY PROCEDURE Dec 2025 Rev.docx','docx','2026-01-04 05:27:35'),(23,NULL,'Emergency Numbers 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\033 Emergency contact numbers Company  Province\\Emergency Numbers 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Emergency Numbers 2024.docx','docx','2026-01-04 05:27:35'),(24,NULL,'Emergency Numbers Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\033 Emergency contact numbers Company  Province\\Emergency Numbers Dec 2025.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Emergency Numbers Dec 2025.docx','docx','2026-01-04 05:27:35'),(25,NULL,'Waste Management 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\034 Waste management procedure\\Waste Management 2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Waste Management 2024.docx','docx','2026-01-04 05:27:35'),(26,NULL,'Waste Management Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\034 Waste management procedure\\Waste Management Dec 2025.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'Waste Management Dec 2025.docx','docx','2026-01-04 05:27:35'),(27,NULL,'W.Cl. 2 EMPLOYERS REPORT OF AN ACCIDENT  2024','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\035 HSE report Forms WCL2\\W.Cl. 2 EMPLOYERS REPORT OF AN ACCIDENT  2024.docx',1,'2026-01-04 07:25:19','draft',NULL,1,'W.Cl. 2 EMPLOYERS REPORT OF AN ACCIDENT  2024.docx','docx','2026-01-04 05:27:35'),(28,NULL,'W.Cl. 2 EMPLOYERS REPORT OF AN ACCIDENT  Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\035 HSE report Forms WCL2\\W.Cl. 2 EMPLOYERS REPORT OF AN ACCIDENT  Dec 2025.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'W.Cl. 2 EMPLOYERS REPORT OF AN ACCIDENT  Dec 2025.docx','docx','2026-01-04 05:27:35'),(29,NULL,'Diesel 50','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\Diesel 50.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Diesel 50.docx','docx','2026-01-04 05:27:35'),(30,NULL,'Engen Premium Motor Oil 50','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\Engen Premium Motor Oil 50.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Engen Premium Motor Oil 50.docx','docx','2026-01-04 05:27:35'),(31,NULL,'Isopropyl_Alcohol','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\Isopropyl_Alcohol.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Isopropyl_Alcohol.docx','docx','2026-01-04 05:27:35'),(32,NULL,'MSDS-Cementitous-Materials-Safety','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\MSDS-Cementitous-Materials-Safety.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'MSDS-Cementitous-Materials-Safety.docx','docx','2026-01-04 05:27:35'),(33,NULL,'Sasol Turbo Unleaded 95_1134631723491','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\Sasol Turbo Unleaded 95_1134631723491.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Sasol Turbo Unleaded 95_1134631723491.docx','docx','2026-01-04 05:27:35'),(34,NULL,'Sasol Tutbo Unleaded 93_1134631679193','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\Sasol Tutbo Unleaded 93_1134631679193.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Sasol Tutbo Unleaded 93_1134631679193.docx','docx','2026-01-04 05:27:35'),(35,NULL,'Soudal-Fill-Fix-Foam-MSDS','C:\\wamp64\\www\\SHE\\Word_Converted\\03 HSE Incident Management\\036 MSDSs where applicable\\Soudal-Fill-Fix-Foam-MSDS.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Soudal-Fill-Fix-Foam-MSDS.docx','docx','2026-01-04 05:27:35'),(36,NULL,'Risk Matrix Methodology 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\04 Risk Assessments\\041 HIRA methodology\\Risk Matrix Methodology 2024.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Risk Matrix Methodology 2024.docx','docx','2026-01-04 05:27:35'),(37,NULL,'Risk Matrix Methodology Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\04 Risk Assessments\\041 HIRA methodology\\Risk Matrix Methodology Dec 2025.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Risk Matrix Methodology Dec 2025.docx','docx','2026-01-04 05:27:35'),(38,NULL,'RAMTHEL PROJECT SPECIFIC HIRA 2024 REV 1','C:\\wamp64\\www\\SHE\\Word_Converted\\04 Risk Assessments\\042 Project specific risk assessment with adequate controls\\RAMTHEL PROJECT SPECIFIC HIRA 2024 REV 1.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'RAMTHEL PROJECT SPECIFIC HIRA 2024 REV 1.docx','docx','2026-01-04 05:27:35'),(39,NULL,'RAMTHEL PROJECT SPECIFIC HIRA Dec 2025 REV 1','C:\\wamp64\\www\\SHE\\Word_Converted\\04 Risk Assessments\\042 Project specific risk assessment with adequate controls\\RAMTHEL PROJECT SPECIFIC HIRA Dec 2025 REV 1.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'RAMTHEL PROJECT SPECIFIC HIRA Dec 2025 REV 1.docx','docx','2026-01-04 05:27:35'),(40,NULL,'HOT WORK PERMIT','C:\\wamp64\\www\\SHE\\Word_Converted\\04 Risk Assessments\\044 Hot work permit template\\HOT WORK PERMIT.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'HOT WORK PERMIT.docx','docx','2026-01-04 05:27:35'),(41,NULL,'RAMTHEL  PROJECT SPECIFIC HSE MANAGEMENT PLAN 2024 Rev 1','C:\\wamp64\\www\\SHE\\Word_Converted\\05 Project Plans\\051 Project Specific Health and Safety Plan\\RAMTHEL  PROJECT SPECIFIC HSE MANAGEMENT PLAN 2024 Rev 1.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'RAMTHEL  PROJECT SPECIFIC HSE MANAGEMENT PLAN 2024 Rev 1.docx','docx','2026-01-04 05:27:35'),(42,NULL,'RAMTHEL  PROJECT SPECIFIC HSE MANAGEMENT PLAN Dec 2025 Rev 1','C:\\wamp64\\www\\SHE\\Word_Converted\\05 Project Plans\\051 Project Specific Health and Safety Plan\\RAMTHEL  PROJECT SPECIFIC HSE MANAGEMENT PLAN Dec 2025 Rev 1.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'RAMTHEL  PROJECT SPECIFIC HSE MANAGEMENT PLAN Dec 2025 Rev 1.docx','docx','2026-01-04 05:27:35'),(43,NULL,'Environmental  Management Plan 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\05 Project Plans\\052 Environmental management plan\\Environmental  Management Plan 2024.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Environmental  Management Plan 2024.docx','docx','2026-01-04 05:27:35'),(44,NULL,'Environmental  Management Plan Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\05 Project Plans\\052 Environmental management plan\\Environmental  Management Plan Dec 2025.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Environmental  Management Plan Dec 2025.docx','docx','2026-01-04 05:27:35'),(45,NULL,'Traffic Management Plan 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\05 Project Plans\\054 Traffic management plan\\Traffic Management Plan 2024.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Traffic Management Plan 2024.docx','docx','2026-01-04 05:27:35'),(46,NULL,'Traffic Management Plan Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\05 Project Plans\\054 Traffic management plan\\Traffic Management Plan Dec 2025.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Traffic Management Plan Dec 2025.docx','docx','2026-01-04 05:27:35'),(47,NULL,'Appointments 16.2 Appointee','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0601 Sec 162 assistant to CEO\\Appointment\\Appointments 16.2 Appointee.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Appointments 16.2 Appointee.docx','docx','2026-01-04 05:27:35'),(48,NULL,'She Rep','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0602 Sec 171 HS representative\\Appointment\\She Rep.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'She Rep.docx','docx','2026-01-04 05:27:35'),(49,NULL,'supervisor of machinery','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0604 Sec 82i General supervision of plant or machinery\\Appointment\\supervisor of machinery.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'supervisor of machinery.docx','docx','2026-01-04 05:27:35'),(50,NULL,'Hand Tool Inspector','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0605 Sec 8 Hand tool inspector designation\\Designation\\Hand Tool Inspector.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Hand Tool Inspector.docx','docx','2026-01-04 05:27:35'),(51,NULL,'Incident Investigator','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0606 GAR 92 Incident investigator\\Appointment\\Incident Investigator.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'Incident Investigator.docx','docx','2026-01-04 05:27:35'),(52,NULL,'PPE inspector (2)','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0607 GSR 2 PPE inspector designation\\Designation\\PPE inspector (2).docx',1,'2026-01-04 07:25:20','draft',NULL,1,'PPE inspector (2).docx','docx','2026-01-04 05:27:35'),(53,NULL,'first aider','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0608 GSR 3 First aider designation\\Designation\\first aider.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'first aider.docx','docx','2026-01-04 05:27:35'),(54,NULL,'confined space tester','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0609 GSR 5 Confined space tester and evaluator designation\\Appointment\\confined space tester.docx',1,'2026-01-04 07:25:20','draft',NULL,1,'confined space tester.docx','docx','2026-01-04 05:27:35'),(55,NULL,'Ladder Inspector','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0610 GSR 13 Ladder inspector designation\\Designation\\Ladder Inspector.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Ladder Inspector.docx','docx','2026-01-04 05:27:35'),(56,NULL,'safety officer','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0613 CR 85 Safety officer\\Appointment\\safety officer.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'safety officer.docx','docx','2026-01-04 05:27:35'),(57,NULL,'construction supervisor','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0614 CR 87 Site supervisor\\Appointment\\construction supervisor.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'construction supervisor.docx','docx','2026-01-04 05:27:35'),(58,NULL,'Assistant construction Supervisor','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0615 CR 88 Assistant site supervisor\\Appointment\\Assistant construction Supervisor.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Assistant construction Supervisor.docx','docx','2026-01-04 05:27:35'),(59,NULL,'RISK ASSESSOR','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0616 CR 91 Risk assessor\\Appointment\\RISK ASSESSOR.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'RISK ASSESSOR.docx','docx','2026-01-04 05:27:35'),(60,NULL,'Fall Protection Gear Inspector','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0618 Fall protection gear inspector designation CR 102d\\Designation\\Fall Protection Gear Inspector.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Fall Protection Gear Inspector.docx','docx','2026-01-04 05:27:35'),(61,NULL,'Excavation Supervisor','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0619 Excavation supervisor CR 131a\\Appointment\\Excavation Supervisor.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Excavation Supervisor.docx','docx','2026-01-04 05:27:35'),(62,NULL,'Vehicle Inspector','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0623 CR 231d  k Construction vehicle operator\\Appointment\\Vehicle Inspector.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Vehicle Inspector.docx','docx','2026-01-04 05:27:35'),(63,NULL,'vehicle operator','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0623 CR 231d  k Construction vehicle operator\\Appointment\\vehicle operator.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'vehicle operator.docx','docx','2026-01-04 05:27:35'),(64,NULL,'SABASABA BANDILE','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0623 CR 231d  k Construction vehicle operator\\Valid operators medical Annexure 3\\SABASABA BANDILE.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'SABASABA BANDILE.docx','docx','2026-01-04 05:27:35'),(65,NULL,'Flagman','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0624 Flagman CR 23\\Appointment\\Flagman.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Flagman.docx','docx','2026-01-04 05:27:35'),(66,NULL,'stacking and storage supervisor','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0627 CR 28a Stacking and storage supervisor\\Appointment\\stacking and storage supervisor.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'stacking and storage supervisor.docx','docx','2026-01-04 05:27:35'),(67,NULL,'Fire Equipment Inspector','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0628 CR 29h Fire equipment inspector\\Appointment\\Fire Equipment Inspector.docx',1,'2026-01-04 07:25:21','draft',NULL,1,'Fire Equipment Inspector.docx','docx','2026-01-04 05:27:35'),(68,NULL,'Portable Electrical Equipment','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0632 Portable Elec Equip Inspector designation EMR 104  11\\Designation\\Portable Electrical Equipment.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Portable Electrical Equipment.docx','docx','2026-01-04 05:27:35'),(69,NULL,'Scanner Operator','C:\\wamp64\\www\\SHE\\Word_Converted\\06 Legal Appointments  Designations\\0633 Scanning Equip operator-GPR\\Appointment\\Scanner Operator.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Scanner Operator.docx','docx','2026-01-04 05:27:35'),(70,NULL,'SAFETY INDUCTION SYLLABUS 2024','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0701 Company HS induction training syllabus\\SAFETY INDUCTION SYLLABUS 2024.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'SAFETY INDUCTION SYLLABUS 2024.docx','docx','2026-01-04 05:27:35'),(71,NULL,'SAFETY INDUCTION SYLLABUS Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0701 Company HS induction training syllabus\\SAFETY INDUCTION SYLLABUS Dec 2025.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'SAFETY INDUCTION SYLLABUS Dec 2025.docx','docx','2026-01-04 05:27:35'),(72,NULL,'INDUCTION TRAINING','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0703 Signed induction training register\\INDUCTION TRAINING.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'INDUCTION TRAINING.docx','docx','2026-01-04 05:27:35'),(73,NULL,'Hira Training','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0704 Proof available that all employees are trained on HIRA\\Hira Training.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Hira Training.docx','docx','2026-01-04 05:27:35'),(74,NULL,'Nokia Life Saving Rules Slide show','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0705 NOKIA Life Saving Rules slideshow available\\Nokia Life Saving Rules Slide show.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Nokia Life Saving Rules Slide show.docx','docx','2026-01-04 05:27:35'),(75,NULL,'NOKIA LIFE SAVING RULES TRAINING REGISTER','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0706 Company Life Saving Rules signed attendance register\\NOKIA LIFE SAVING RULES TRAINING REGISTER.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'NOKIA LIFE SAVING RULES TRAINING REGISTER.docx','docx','2026-01-04 05:27:35'),(76,NULL,'Nokia SA - Life Saving Rules MD_CEO (new logo) (1)','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0708 Signed Nokia Life Saving Rules declaration by CEO\\Nokia SA - Life Saving Rules MD_CEO (new logo) (1).docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Nokia SA - Life Saving Rules MD_CEO (new logo) (1).docx','docx','2026-01-04 05:27:35'),(77,NULL,'1_Completed Toolbox Talks Register_','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\1_Completed Toolbox Talks Register_.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'1_Completed Toolbox Talks Register_.docx','docx','2026-01-04 05:27:35'),(78,NULL,'A flood of Danger','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\A flood of Danger.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'A flood of Danger.docx','docx','2026-01-04 05:27:35'),(79,NULL,'All in Fun','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\All in Fun.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'All in Fun.docx','docx','2026-01-04 05:27:35'),(80,NULL,'Back Injuries','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\Back Injuries.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Back Injuries.docx','docx','2026-01-04 05:27:35'),(81,NULL,'Correct Use of PPE','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\Correct Use of PPE.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Correct Use of PPE.docx','docx','2026-01-04 05:27:35'),(82,NULL,'Employee Responsibility','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\Employee Responsibility.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Employee Responsibility.docx','docx','2026-01-04 05:27:35'),(83,NULL,'Motor Vehicles','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\Motor Vehicles.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Motor Vehicles.docx','docx','2026-01-04 05:27:35'),(84,NULL,'Power Tools','C:\\wamp64\\www\\SHE\\Word_Converted\\07 Training  Awareness  Manuals  Instructions\\0709 Toolbox talk topics\\Power Tools.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Power Tools.docx','docx','2026-01-04 05:27:35'),(85,NULL,'Ladder SWP training','C:\\wamp64\\www\\SHE\\Word_Converted\\09 Legal  Site Safety Management Training\\0912 Proof of ladder training\\Ladder SWP training.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Ladder SWP training.docx','docx','2026-01-04 05:27:35'),(86,NULL,'RAMTHEL  Site visitor register - 2018','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1001 Site diary  Visitors register\\RAMTHEL  Site visitor register - 2018.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'RAMTHEL  Site visitor register - 2018.docx','docx','2026-01-04 05:27:35'),(87,NULL,'RAMTHEL Site Diary','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1001 Site diary  Visitors register\\RAMTHEL Site Diary.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'RAMTHEL Site Diary.docx','docx','2026-01-04 05:27:35'),(88,NULL,'ramthel Commuter Daily Risk Assessment','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1002 DSTI - Site specific risk assessment template\\ramthel Commuter Daily Risk Assessment.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'ramthel Commuter Daily Risk Assessment.docx','docx','2026-01-04 05:27:35'),(89,NULL,'Management Safety Checklist','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1003 Management  Supervisor inspection checklist\\Management Safety Checklist.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Management Safety Checklist.docx','docx','2026-01-04 05:27:35'),(90,NULL,'Safety Officer Checklist','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1004 Safety Officer inspection checklist\\Safety Officer Checklist.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Safety Officer Checklist.docx','docx','2026-01-04 05:27:35'),(91,NULL,'SHE REPRESENTATIVE CHECKLIST','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1005 HS Rep inspection checklist\\SHE REPRESENTATIVE CHECKLIST.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'SHE REPRESENTATIVE CHECKLIST.docx','docx','2026-01-04 05:27:35'),(92,NULL,'PPE INSPECTION 2024 REV','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1006 PPE inspection checklists latest completed\\PPE INSPECTION 2024 REV.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'PPE INSPECTION 2024 REV.docx','docx','2026-01-04 05:27:35'),(93,NULL,'PPE INSPECTION Dec 2025 REV','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1006 PPE inspection checklists latest completed\\PPE INSPECTION Dec 2025 REV.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'PPE INSPECTION Dec 2025 REV.docx','docx','2026-01-04 05:27:35'),(94,NULL,'BANDILE PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\BANDILE PPE ISSUE.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'BANDILE PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(95,NULL,'GENESIS PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\GENESIS PPE ISSUE.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'GENESIS PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(96,NULL,'Gerard PPE Issue','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\Gerard PPE Issue.docx',1,'2026-01-04 07:25:22','draft',NULL,1,'Gerard PPE Issue.docx','docx','2026-01-04 05:27:35'),(97,NULL,'Lonnie PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\Lonnie PPE ISSUE.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'Lonnie PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(98,NULL,'NGONIDZASHE PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\NGONIDZASHE PPE ISSUE.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'NGONIDZASHE PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(99,NULL,'PPE Respect','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\PPE Respect.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'PPE Respect.docx','docx','2026-01-04 05:27:35'),(100,NULL,'SIPHESIHLE PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\SIPHESIHLE PPE ISSUE.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'SIPHESIHLE PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(101,NULL,'SIPHO AMON PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\SIPHO AMON PPE ISSUE.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'SIPHO AMON PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(102,NULL,'THABANG PPE ISSE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\THABANG PPE ISSE.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'THABANG PPE ISSE.docx','docx','2026-01-04 05:27:35'),(103,NULL,'TODI PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\TODI PPE ISSUE.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'TODI PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(104,NULL,'gladys ppe issue','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1007 PPE issue registers completed signed\\gladys ppe issue.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'gladys ppe issue.docx','docx','2026-01-04 05:27:35'),(105,NULL,'Ramthel JMP Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1008 Journey management plan template\\Ramthel JMP Dec 2025.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'Ramthel JMP Dec 2025.docx','docx','2026-01-04 05:27:35'),(106,NULL,'Daily Trailer Checklist Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1009 Daily vehicle  Trailer checklist\\Daily Trailer Checklist Dec 2025.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'Daily Trailer Checklist Dec 2025.docx','docx','2026-01-04 05:27:35'),(107,NULL,'Daily Vehicle Checklist Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1009 Daily vehicle  Trailer checklist\\Daily Vehicle Checklist Dec 2025.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'Daily Vehicle Checklist Dec 2025.docx','docx','2026-01-04 05:27:35'),(108,NULL,'Ramthel Fire Extinguishers CHECKLIST -register','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1012 Fire extinguisher checklist\\Ramthel Fire Extinguishers CHECKLIST -register.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'Ramthel Fire Extinguishers CHECKLIST -register.docx','docx','2026-01-04 05:27:35'),(109,NULL,'Ramthel commuter  First aid box checklist','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1013 First aid kit checklist\\Ramthel commuter  First aid box checklist.docx',1,'2026-01-04 07:25:23','draft',NULL,1,'Ramthel commuter  First aid box checklist.docx','docx','2026-01-04 05:27:35'),(110,NULL,'PORTABLE ELECTRICAL CHECKLIST Dec 2025','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1016 Portable electrical equipment checklist\\PORTABLE ELECTRICAL CHECKLIST Dec 2025.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'PORTABLE ELECTRICAL CHECKLIST Dec 2025.docx','docx','2026-01-04 05:27:35'),(111,NULL,'ramthel Daily Ladder Checklist','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1017 Portable  extension ladders checklist\\ramthel Daily Ladder Checklist.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'ramthel Daily Ladder Checklist.docx','docx','2026-01-04 05:27:35'),(112,NULL,'Compactor Register','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1018 Petrol Driven Machinery Checklist - Compactors Generator etc\\Compactor Register.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Compactor Register.docx','docx','2026-01-04 05:27:35'),(113,NULL,'GENERATOR REGISTER','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1018 Petrol Driven Machinery Checklist - Compactors Generator etc\\GENERATOR REGISTER.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'GENERATOR REGISTER.docx','docx','2026-01-04 05:27:35'),(114,NULL,'JACK HAMMER','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1018 Petrol Driven Machinery Checklist - Compactors Generator etc\\JACK HAMMER.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'JACK HAMMER.docx','docx','2026-01-04 05:27:35'),(115,NULL,'tar cutter','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1018 Petrol Driven Machinery Checklist - Compactors Generator etc\\tar cutter.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'tar cutter.docx','docx','2026-01-04 05:27:35'),(116,NULL,'AIR COMPRESSOR CHECKLIST','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1019 Compressors  pressure equipment\\AIR COMPRESSOR CHECKLIST.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'AIR COMPRESSOR CHECKLIST.docx','docx','2026-01-04 05:27:35'),(117,NULL,'tar cutter','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1020 Road saw-Surface cutter checklist\\tar cutter.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'tar cutter.docx','docx','2026-01-04 05:27:35'),(118,NULL,'Excavation Inspection Register','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1021 Excavation-Trenching checklist\\Excavation Inspection Register.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Excavation Inspection Register.docx','docx','2026-01-04 05:27:35'),(119,NULL,'CONFINED SPACE CHECKLIST','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1022 Confined space - Man hole entry checklist\\CONFINED SPACE CHECKLIST.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'CONFINED SPACE CHECKLIST.docx','docx','2026-01-04 05:27:35'),(120,NULL,'Traffic Signage Register','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1023 Traffic signage  Daily traffic management checklist\\Traffic Signage Register.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Traffic Signage Register.docx','docx','2026-01-04 05:27:35'),(121,NULL,'SCANNER EQUIPMENT CHECKLIST','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1024 Scanning report checklist\\SCANNER EQUIPMENT CHECKLIST.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'SCANNER EQUIPMENT CHECKLIST.docx','docx','2026-01-04 05:27:35'),(122,NULL,'WAH PRE USE CHECKLIST','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1026 Pre-use  3-Monthly gear  equip insp checklists latest completed\\WAH PRE USE CHECKLIST.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'WAH PRE USE CHECKLIST.docx','docx','2026-01-04 05:27:35'),(123,NULL,'safety harness invoice','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1026 Pre-use  3-Monthly gear  equip insp checklists latest completed\\safety harness invoice.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'safety harness invoice.docx','docx','2026-01-04 05:27:35'),(124,NULL,'Ramthel comm Stacking and storage checklist','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1027 Stacking  storage checklist\\Ramthel comm Stacking and storage checklist.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Ramthel comm Stacking and storage checklist.docx','docx','2026-01-04 05:27:35'),(125,NULL,'PUBLIC SAFETY CHECKLIST','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1028 Public safety checklist\\PUBLIC SAFETY CHECKLIST.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'PUBLIC SAFETY CHECKLIST.docx','docx','2026-01-04 05:27:35'),(126,NULL,'MOBILE TOILET REGISTER','C:\\wamp64\\www\\SHE\\Word_Converted\\10 Inspections checklistregisters templates\\1030 On site sanitary - ablution facilities checklist\\MOBILE TOILET REGISTER.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'MOBILE TOILET REGISTER.docx','docx','2026-01-04 05:27:35'),(127,NULL,'Nokia Section 37(2) Indemnity Agreement (2)','C:\\wamp64\\www\\SHE\\Word_Converted\\11 Contracting\\1 Section 372 indemnity agreement\\Nokia Section 37(2) Indemnity Agreement (2).docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Nokia Section 37(2) Indemnity Agreement (2).docx','docx','2026-01-04 05:27:35'),(128,NULL,'GAU-TLK-OS-LC-FTTx-CR5(1)(k) (3)','C:\\wamp64\\www\\SHE\\Word_Converted\\11 Contracting\\2 Contractor appointment\\GAU-TLK-OS-LC-FTTx-CR5(1)(k) (3).docx',1,'2026-01-04 07:25:24','draft',NULL,1,'GAU-TLK-OS-LC-FTTx-CR5(1)(k) (3).docx','docx','2026-01-04 05:27:35'),(129,NULL,'COVID 19 Awareness','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\1 Company awareness training completed for COVID-19\\COVID 19 Awareness.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'COVID 19 Awareness.docx','docx','2026-01-04 05:27:35'),(130,NULL,'BANDILE PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\BANDILE PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'BANDILE PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(131,NULL,'GENESIS PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\GENESIS PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'GENESIS PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(132,NULL,'Gerard PPE Issue','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\Gerard PPE Issue.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Gerard PPE Issue.docx','docx','2026-01-04 05:27:35'),(133,NULL,'Lonnie PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\Lonnie PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Lonnie PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(134,NULL,'NGONIDZASHE PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\NGONIDZASHE PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'NGONIDZASHE PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(135,NULL,'PPE Respect','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\PPE Respect.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'PPE Respect.docx','docx','2026-01-04 05:27:35'),(136,NULL,'SIPHESIHLE PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\SIPHESIHLE PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'SIPHESIHLE PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(137,NULL,'SIPHO AMON PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\SIPHO AMON PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'SIPHO AMON PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(138,NULL,'THABANG PPE ISSE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\THABANG PPE ISSE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'THABANG PPE ISSE.docx','docx','2026-01-04 05:27:35'),(139,NULL,'TODI PPE ISSUE','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\TODI PPE ISSUE.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'TODI PPE ISSUE.docx','docx','2026-01-04 05:27:35'),(140,NULL,'gladys ppe issue','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\2 PPE evaluated and issued for COVID-19\\gladys ppe issue.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'gladys ppe issue.docx','docx','2026-01-04 05:27:35'),(141,NULL,'Covid PPE Inspection Checklist','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\3 COVID-19 PPE inspections carried out\\Covid PPE Inspection Checklist.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Covid PPE Inspection Checklist.docx','docx','2026-01-04 05:27:35'),(142,NULL,'Covid 19 Travel Awareness','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\4 Workers aware of COVID-19 requirements during travelling\\Covid 19 Travel Awareness.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'Covid 19 Travel Awareness.docx','docx','2026-01-04 05:27:35'),(143,NULL,'ramthel  COMMUTER Covid 19 tracking form','C:\\wamp64\\www\\SHE\\Word_Converted\\12 COVID-19\\5 COVID-19 Tracking for visitors complied with\\ramthel  COMMUTER Covid 19 tracking form.docx',1,'2026-01-04 07:25:24','draft',NULL,1,'ramthel  COMMUTER Covid 19 tracking form.docx','docx','2026-01-04 05:27:35');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `id_number` varchar(20) DEFAULT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `medical_expiry_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_number` (`id_number`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'John','Doe','8001015009087','Site Manager',NULL,'2025-12-31 13:32:01'),(2,'Jane','Smith','9002020050081','Safety Officer',NULL,'2025-12-31 13:32:01'),(3,'Mike','Johnson','8505055009082','Electrician',NULL,'2025-12-31 13:32:01');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_submissions`
--

DROP TABLE IF EXISTS `form_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_submissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int NOT NULL,
  `project_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `data_json` json NOT NULL,
  `signature_image` longtext,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  KEY `project_id` (`project_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_submissions`
--

LOCK TABLES `form_submissions` WRITE;
/*!40000 ALTER TABLE `form_submissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_templates`
--

DROP TABLE IF EXISTS `form_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `form_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `structure_json` json NOT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_templates`
--

LOCK TABLES `form_templates` WRITE;
/*!40000 ALTER TABLE `form_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hazards`
--

DROP TABLE IF EXISTS `hazards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hazards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` text,
  `standard_mitigation` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hazards`
--

LOCK TABLES `hazards` WRITE;
/*!40000 ALTER TABLE `hazards` DISABLE KEYS */;
INSERT INTO `hazards` VALUES (1,'Physical','Working at Heights',NULL,'Use safety harness and secure ladder'),(2,'Electrical','Exposed Wiring',NULL,'Lockout/Tagout procedures'),(3,'Chemical','Cleaning Solvents',NULL,'Use PPE (Gloves, Mask)');
/*!40000 ALTER TABLE `hazards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidents`
--

DROP TABLE IF EXISTS `incidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `incidents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `reported_by` int DEFAULT NULL,
  `incident_date` datetime NOT NULL,
  `location` varchar(200) DEFAULT NULL,
  `incident_type` enum('near_miss','first_aid','medical_treatment','lost_time','fatality','property_damage','environmental') DEFAULT NULL,
  `description` text,
  `immediate_action_taken` text,
  `severity_level` enum('low','medium','high','critical') DEFAULT NULL,
  `status` enum('open','investigating','closed') DEFAULT 'open',
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `reported_by` (`reported_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidents`
--

LOCK TABLES `incidents` WRITE;
/*!40000 ALTER TABLE `incidents` DISABLE KEYS */;
/*!40000 ALTER TABLE `incidents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspections`
--

DROP TABLE IF EXISTS `inspections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `checklist_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `inspector_name` varchar(100) DEFAULT NULL,
  `inspection_date` datetime DEFAULT NULL,
  `result` enum('pass','fail','pass_with_remarks') DEFAULT NULL,
  `comments` text,
  PRIMARY KEY (`id`),
  KEY `checklist_id` (`checklist_id`),
  KEY `project_id` (`project_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspections`
--

LOCK TABLES `inspections` WRITE;
/*!40000 ALTER TABLE `inspections` DISABLE KEYS */;
/*!40000 ALTER TABLE `inspections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `legal_appointments`
--

DROP TABLE IF EXISTS `legal_appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `legal_appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `appointment_type` varchar(50) DEFAULT NULL,
  `appointment_date` date DEFAULT NULL,
  `status` enum('active','expired') DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `legal_appointments`
--

LOCK TABLES `legal_appointments` WRITE;
/*!40000 ALTER TABLE `legal_appointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `legal_appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project_code` varchar(50) DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `client_name` varchar(150) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('planning','active','completed','suspended') DEFAULT 'planning',
  `location` text,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_code` (`project_code`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,'PROJ-001','HQ Renovation','Telkom',NULL,NULL,'active','Pretoria Campus',NULL);
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `risk_assessment_items`
--

DROP TABLE IF EXISTS `risk_assessment_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `risk_assessment_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `risk_assessment_id` int DEFAULT NULL,
  `hazard_id` int DEFAULT NULL,
  `activity_step` varchar(200) DEFAULT NULL,
  `risk_score_pre_mitigation` int DEFAULT NULL,
  `mitigation_measures` text,
  `risk_score_post_mitigation` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `risk_assessment_id` (`risk_assessment_id`),
  KEY `hazard_id` (`hazard_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `risk_assessment_items`
--

LOCK TABLES `risk_assessment_items` WRITE;
/*!40000 ALTER TABLE `risk_assessment_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `risk_assessment_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `risk_assessments`
--

DROP TABLE IF EXISTS `risk_assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `risk_assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `title` varchar(150) DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  `review_date` date DEFAULT NULL,
  `assessor_name` varchar(100) DEFAULT NULL,
  `status` enum('draft','approved','archived') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `risk_assessments`
--

LOCK TABLES `risk_assessments` WRITE;
/*!40000 ALTER TABLE `risk_assessments` DISABLE KEYS */;
/*!40000 ALTER TABLE `risk_assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `training_records`
--

DROP TABLE IF EXISTS `training_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int DEFAULT NULL,
  `training_type` varchar(100) DEFAULT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `completion_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `certificate_file` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_records`
--

LOCK TABLES `training_records` WRITE;
/*!40000 ALTER TABLE `training_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `training_records` ENABLE KEYS */;
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
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','manager','safety_officer','employee') DEFAULT 'employee',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2y$10$9gkXXy.cUif6K02OnaHG1OV3Ozu8xjv/ZRW/2me2BdLTTfhsJUpZy','System Admin','admin@she.com','admin','2025-12-31 13:06:53','2025-12-31 13:06:53',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'she_system'
--

--
-- Dumping routines for database 'she_system'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:30:38
