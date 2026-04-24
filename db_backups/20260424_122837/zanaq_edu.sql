-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: zanaq_edu
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
-- Current Database: `zanaq_edu`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `zanaq_edu` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `zanaq_edu`;

--
-- Table structure for table `academic_holiday`
--

DROP TABLE IF EXISTS `academic_holiday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `academic_holiday` (
  `id` int NOT NULL AUTO_INCREMENT,
  `trackId` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `startDate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endDate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_70ec16cf1ae74b164c4fb01b846` (`trackId`),
  CONSTRAINT `FK_70ec16cf1ae74b164c4fb01b846` FOREIGN KEY (`trackId`) REFERENCES `academic_track` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `academic_holiday`
--

LOCK TABLES `academic_holiday` WRITE;
/*!40000 ALTER TABLE `academic_holiday` DISABLE KEYS */;
/*!40000 ALTER TABLE `academic_holiday` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `academic_term`
--

DROP TABLE IF EXISTS `academic_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `academic_term` (
  `id` int NOT NULL AUTO_INCREMENT,
  `trackId` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `startDate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endDate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `orderIndex` int NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_07cbda1a8ad7849cc9e7c419df2` (`trackId`),
  CONSTRAINT `FK_07cbda1a8ad7849cc9e7c419df2` FOREIGN KEY (`trackId`) REFERENCES `academic_track` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `academic_term`
--

LOCK TABLES `academic_term` WRITE;
/*!40000 ALTER TABLE `academic_term` DISABLE KEYS */;
/*!40000 ALTER TABLE `academic_term` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `academic_track`
--

DROP TABLE IF EXISTS `academic_track`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `academic_track` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `curriculum` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'General',
  `startDate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endDate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `isActive` tinyint NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_fd9c6d3f2bd6eeebd395e5fd6f3` (`branchId`),
  CONSTRAINT `FK_fd9c6d3f2bd6eeebd395e5fd6f3` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `academic_track`
--

LOCK TABLES `academic_track` WRITE;
/*!40000 ALTER TABLE `academic_track` DISABLE KEYS */;
/*!40000 ALTER TABLE `academic_track` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'asset',
  `balance` float NOT NULL DEFAULT '0',
  `description` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_f1f1f99afc5b3d3c2bb0b9bea76` (`branchId`),
  CONSTRAINT `FK_f1f1f99afc5b3d3c2bb0b9bea76` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounting_period`
--

DROP TABLE IF EXISTS `accounting_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounting_period` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `periodKey` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `closedByUserId` int DEFAULT NULL,
  `closedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounting_period`
--

LOCK TABLES `accounting_period` WRITE;
/*!40000 ALTER TABLE `accounting_period` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounting_period` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admission_inquiry`
--

DROP TABLE IF EXISTS `admission_inquiry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admission_inquiry` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `firstName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preferredGrade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Grade 1',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `stage` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'inquiry',
  `assignedToUserId` int DEFAULT NULL,
  `interviewAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `score` int DEFAULT NULL,
  `applicationDataJson` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_6286c946f367006fc1fcb5b522` (`email`),
  KEY `FK_5da3d5fd1227eee96bdc1bdb460` (`branchId`),
  KEY `FK_e5db01e866fb2157cde91329001` (`assignedToUserId`),
  CONSTRAINT `FK_5da3d5fd1227eee96bdc1bdb460` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_e5db01e866fb2157cde91329001` FOREIGN KEY (`assignedToUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admission_inquiry`
--

LOCK TABLES `admission_inquiry` WRITE;
/*!40000 ALTER TABLE `admission_inquiry` DISABLE KEYS */;
/*!40000 ALTER TABLE `admission_inquiry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alumni`
--

DROP TABLE IF EXISTS `alumni`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alumni` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `firstName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `graduationYear` int DEFAULT NULL,
  `program` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentEmployer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linkedIn` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mentorAvailable` tinyint NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_519b877f666eac6cc12cd243c9` (`email`),
  KEY `FK_0fde0085976efef9c82e7111827` (`branchId`),
  CONSTRAINT `FK_0fde0085976efef9c82e7111827` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumni`
--

LOCK TABLES `alumni` WRITE;
/*!40000 ALTER TABLE `alumni` DISABLE KEYS */;
/*!40000 ALTER TABLE `alumni` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcement`
--

DROP TABLE IF EXISTS `announcement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `targetAudience` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `targetUserIdsJson` text COLLATE utf8mb4_unicode_ci,
  `priority` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `pinned` tinyint NOT NULL DEFAULT '0',
  `startDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_70e4cd1ab2265026985db717ae9` (`branchId`),
  KEY `FK_ed17cfb7d8844a0cbb8f82fe415` (`createdByUserId`),
  CONSTRAINT `FK_70e4cd1ab2265026985db717ae9` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ed17cfb7d8844a0cbb8f82fe415` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcement`
--

LOCK TABLES `announcement` WRITE;
/*!40000 ALTER TABLE `announcement` DISABLE KEYS */;
/*!40000 ALTER TABLE `announcement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcement_acknowledgement`
--

DROP TABLE IF EXISTS `announcement_acknowledgement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcement_acknowledgement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `announcementId` int NOT NULL,
  `userId` int DEFAULT NULL,
  `anonymous` tinyint NOT NULL DEFAULT '0',
  `acknowledgedAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_4a966fafc536ae5c205b778d777` (`branchId`),
  KEY `FK_b7459ca4672c5c6f9274162f48a` (`announcementId`),
  KEY `FK_e490003b5673a68df9b3546b25d` (`userId`),
  CONSTRAINT `FK_4a966fafc536ae5c205b778d777` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_b7459ca4672c5c6f9274162f48a` FOREIGN KEY (`announcementId`) REFERENCES `announcement` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_e490003b5673a68df9b3546b25d` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcement_acknowledgement`
--

LOCK TABLES `announcement_acknowledgement` WRITE;
/*!40000 ALTER TABLE `announcement_acknowledgement` DISABLE KEYS */;
/*!40000 ALTER TABLE `announcement_acknowledgement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appraisal`
--

DROP TABLE IF EXISTS `appraisal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appraisal` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `staffProfileId` int NOT NULL,
  `goalLibraryId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `managerUserId` int DEFAULT NULL,
  `cycle` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `goalSummary` text COLLATE utf8mb4_unicode_ci,
  `selfRating` int DEFAULT NULL,
  `managerRating` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `comments` text COLLATE utf8mb4_unicode_ci,
  `calibrationStatus` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `calibrationNotes` text COLLATE utf8mb4_unicode_ci,
  `calibratedByUserId` int DEFAULT NULL,
  `calibratedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submittedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_467a7b90879f1fa2d45bcf6e739` (`staffProfileId`),
  KEY `FK_cb381915bcc60c70f76c787d835` (`goalLibraryId`),
  CONSTRAINT `FK_467a7b90879f1fa2d45bcf6e739` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_cb381915bcc60c70f76c787d835` FOREIGN KEY (`goalLibraryId`) REFERENCES `appraisal_goal` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appraisal`
--

LOCK TABLES `appraisal` WRITE;
/*!40000 ALTER TABLE `appraisal` DISABLE KEYS */;
/*!40000 ALTER TABLE `appraisal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appraisal_feedback`
--

DROP TABLE IF EXISTS `appraisal_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appraisal_feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appraisalId` int NOT NULL,
  `reviewerUserId` int DEFAULT NULL,
  `relationship` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'peer',
  `rating` int NOT NULL,
  `comments` text COLLATE utf8mb4_unicode_ci,
  `submittedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_6100aa2f93de1b9aecbd1d39de8` (`appraisalId`),
  KEY `FK_8a364e2212d860ea595d3b3a71d` (`reviewerUserId`),
  CONSTRAINT `FK_6100aa2f93de1b9aecbd1d39de8` FOREIGN KEY (`appraisalId`) REFERENCES `appraisal` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_8a364e2212d860ea595d3b3a71d` FOREIGN KEY (`reviewerUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appraisal_feedback`
--

LOCK TABLES `appraisal_feedback` WRITE;
/*!40000 ALTER TABLE `appraisal_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `appraisal_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appraisal_goal`
--

DROP TABLE IF EXISTS `appraisal_goal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appraisal_goal` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_6324ad90c8a4554d67f5f708afc` (`branchId`),
  KEY `FK_32cf74d0b177df34f94f2943da8` (`createdByUserId`),
  CONSTRAINT `FK_32cf74d0b177df34f94f2943da8` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_6324ad90c8a4554d67f5f708afc` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appraisal_goal`
--

LOCK TABLES `appraisal_goal` WRITE;
/*!40000 ALTER TABLE `appraisal_goal` DISABLE KEYS */;
/*!40000 ALTER TABLE `appraisal_goal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_record`
--

DROP TABLE IF EXISTS `attendance_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `sectionId` int DEFAULT NULL,
  `attendanceDate` date NOT NULL,
  `period` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'present',
  `captureMethod` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `capturedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notifiedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `absenceReason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `evidenceDocumentId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_195baefbf724ced6a6bb07b8b59` (`branchId`),
  KEY `FK_f2fd165992fdb7938cbf664dd5b` (`studentId`),
  KEY `FK_2d26e8ea9e7f1e2fc288fd132e0` (`sectionId`),
  KEY `FK_1fa54102d7257da9d606a95e3bf` (`evidenceDocumentId`),
  KEY `FK_5c87a464850b92c312c80e88a8e` (`createdByUserId`),
  CONSTRAINT `FK_195baefbf724ced6a6bb07b8b59` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_1fa54102d7257da9d606a95e3bf` FOREIGN KEY (`evidenceDocumentId`) REFERENCES `document_record` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_2d26e8ea9e7f1e2fc288fd132e0` FOREIGN KEY (`sectionId`) REFERENCES `class_section` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_5c87a464850b92c312c80e88a8e` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_f2fd165992fdb7938cbf664dd5b` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_record`
--

LOCK TABLES `attendance_record` WRITE;
/*!40000 ALTER TABLE `attendance_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actorUserId` int DEFAULT NULL,
  `actorRole` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `method` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `userAgent` text COLLATE utf8mb4_unicode_ci,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entityType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entityId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadataJson` text COLLATE utf8mb4_unicode_ci,
  `geoJson` text COLLATE utf8mb4_unicode_ci,
  `beforeJson` text COLLATE utf8mb4_unicode_ci,
  `afterJson` text COLLATE utf8mb4_unicode_ci,
  `prevHash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,2,'superadmin',NULL,'POST','/api/auth/login','::ffff:127.0.0.1','node','auth.login','User','2','{\"_geo\":{\"ip\":\"::ffff:127.0.0.1\",\"forwardedFor\":[],\"ipIsPrivate\":false}}','{\"ip\":\"::ffff:127.0.0.1\",\"forwardedFor\":[],\"ipIsPrivate\":false}',NULL,NULL,NULL,'5f0841be3b93db67d5f4e49cf3c5cfc290f559036c0baa7405ce19dad9fc2967','2026-04-06 17:10:03.289000'),(2,2,'superadmin',NULL,'POST','/api/auth/login','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36','auth.login','User','2','{\"_geo\":{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}}','{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}',NULL,NULL,'5f0841be3b93db67d5f4e49cf3c5cfc290f559036c0baa7405ce19dad9fc2967','f2afd0a8a4cfedfb9ac0765bc5b4a88bf951f2e45f0bbda55767733b90f21902','2026-04-06 17:46:46.847000'),(3,2,'superadmin',NULL,'POST','/api/auth/login','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','auth.login','User','2','{\"_geo\":{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}}','{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}',NULL,NULL,'f2afd0a8a4cfedfb9ac0765bc5b4a88bf951f2e45f0bbda55767733b90f21902','e917411c50de78549c49e4ffd87b0bbfa1a4c13a6c333d872b29638866c2298a','2026-04-06 17:47:53.947000'),(4,1,'staff',NULL,'POST','/api/auth/login','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','auth.login','User','1','{\"_geo\":{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}}','{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}',NULL,NULL,'e917411c50de78549c49e4ffd87b0bbfa1a4c13a6c333d872b29638866c2298a','c7243832b3c39d5f3a37d347ce8c71409834c7fec31f6bee7c6edeac085a0255','2026-04-07 00:19:32.338000'),(5,2,'superadmin',NULL,'POST','/api/auth/login','::ffff:127.0.0.1',NULL,'auth.login','User','2','{\"_geo\":{\"ip\":\"::ffff:127.0.0.1\",\"forwardedFor\":[],\"ipIsPrivate\":false}}','{\"ip\":\"::ffff:127.0.0.1\",\"forwardedFor\":[],\"ipIsPrivate\":false}',NULL,NULL,'c7243832b3c39d5f3a37d347ce8c71409834c7fec31f6bee7c6edeac085a0255','3508fed37c1292bf2bba130642b9ccaaaab7bd28232f1202bd9da37ef91357eb','2026-04-07 00:19:51.849000'),(6,2,'superadmin',NULL,'POST','/api/auth/login','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','auth.login','User','2','{\"_geo\":{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}}','{\"ip\":\"::1\",\"forwardedFor\":[],\"ipIsPrivate\":true}',NULL,NULL,'3508fed37c1292bf2bba130642b9ccaaaab7bd28232f1202bd9da37ef91357eb','2306d03314012eacb4c5f49bf63ea5884b34a80f67ac0836d7a3b0a64b66f014','2026-04-07 00:20:04.314000');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch`
--

DROP TABLE IF EXISTS `branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `timezone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `isActive` tinyint NOT NULL DEFAULT '1',
  `policyJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_638479fc29fab932b7ab0aea91` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch`
--

LOCK TABLES `branch` WRITE;
/*!40000 ALTER TABLE `branch` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `budget_plan`
--

DROP TABLE IF EXISTS `budget_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `budget_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `periodStart` date DEFAULT NULL,
  `periodEnd` date DEFAULT NULL,
  `plannedAmount` float NOT NULL DEFAULT '0',
  `committedAmount` float NOT NULL DEFAULT '0',
  `spentAmount` float NOT NULL DEFAULT '0',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `budget_plan`
--

LOCK TABLES `budget_plan` WRITE;
/*!40000 ALTER TABLE `budget_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `budget_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_channel`
--

DROP TABLE IF EXISTS `chat_channel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_channel` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowedRoles` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `moderated` tinyint NOT NULL DEFAULT '0',
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_channel`
--

LOCK TABLES `chat_channel` WRITE;
/*!40000 ALTER TABLE `chat_channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_message`
--

DROP TABLE IF EXISTS `chat_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `senderId` int DEFAULT NULL,
  `threadName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `attachmentDocumentId` int DEFAULT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `audience` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `flagged` tinyint NOT NULL DEFAULT '0',
  `flagReason` text COLLATE utf8mb4_unicode_ci,
  `flaggedByUserId` int DEFAULT NULL,
  `isDeleted` tinyint NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'visible',
  `moderatedByUserId` int DEFAULT NULL,
  `moderatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `moderationReason` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `FK_713ae7ff327d6c754335695c0d4` (`branchId`),
  KEY `FK_a2be22c99b34156574f4e02d0a0` (`senderId`),
  KEY `FK_45d6a66c98de615185e274d2ba4` (`moderatedByUserId`),
  CONSTRAINT `FK_45d6a66c98de615185e274d2ba4` FOREIGN KEY (`moderatedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_713ae7ff327d6c754335695c0d4` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_a2be22c99b34156574f4e02d0a0` FOREIGN KEY (`senderId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_message`
--

LOCK TABLES `chat_message` WRITE;
/*!40000 ALTER TABLE `chat_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_section`
--

DROP TABLE IF EXISTS `class_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_section` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Grade 1',
  `sectionCode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int NOT NULL DEFAULT '30',
  `teacherName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_45f2d9e47b089c2ae8c2a058f2` (`sectionCode`),
  KEY `FK_54e8cbc8719f045a480f27b2ec6` (`branchId`),
  CONSTRAINT `FK_54e8cbc8719f045a480f27b2ec6` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_section`
--

LOCK TABLES `class_section` WRITE;
/*!40000 ALTER TABLE `class_section` DISABLE KEYS */;
/*!40000 ALTER TABLE `class_section` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communication_message`
--

DROP TABLE IF EXISTS `communication_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `communication_message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `senderId` int DEFAULT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'email',
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `targetAudience` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'queued',
  `recipientCount` int NOT NULL DEFAULT '0',
  `sentAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tags` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_ccee42815a41d6f8cdb118dc747` (`branchId`),
  KEY `FK_ead70ffaf9bd8ea6be1813740e3` (`senderId`),
  CONSTRAINT `FK_ccee42815a41d6f8cdb118dc747` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ead70ffaf9bd8ea6be1813740e3` FOREIGN KEY (`senderId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communication_message`
--

LOCK TABLES `communication_message` WRITE;
/*!40000 ALTER TABLE `communication_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `communication_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communication_provider_config`
--

DROP TABLE IF EXISTS `communication_provider_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `communication_provider_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint NOT NULL DEFAULT '0',
  `senderName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senderAddress` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `configJson` text COLLATE utf8mb4_unicode_ci,
  `updatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communication_provider_config`
--

LOCK TABLES `communication_provider_config` WRITE;
/*!40000 ALTER TABLE `communication_provider_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `communication_provider_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communication_segment`
--

DROP TABLE IF EXISTS `communication_segment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `communication_segment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `filterJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `lastEstimatedCount` int NOT NULL DEFAULT '0',
  `lastEstimatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communication_segment`
--

LOCK TABLES `communication_segment` WRITE;
/*!40000 ALTER TABLE `communication_segment` DISABLE KEYS */;
/*!40000 ALTER TABLE `communication_segment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communication_template`
--

DROP TABLE IF EXISTS `communication_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `communication_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'email',
  `subjectTemplate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bodyTemplate` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `variablesJson` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communication_template`
--

LOCK TABLES `communication_template` WRITE;
/*!40000 ALTER TABLE `communication_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `communication_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compliance_evidence`
--

DROP TABLE IF EXISTS `compliance_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compliance_evidence` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `documentId` int NOT NULL,
  `frameworkKey` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `controlCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'mapped',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `mappedByUserId` int DEFAULT NULL,
  `mappedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_d0a7527953172feb5e335721310` (`documentId`),
  KEY `FK_eaaa3a6ffff9392df05d5b68151` (`mappedByUserId`),
  CONSTRAINT `FK_d0a7527953172feb5e335721310` FOREIGN KEY (`documentId`) REFERENCES `document_record` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_eaaa3a6ffff9392df05d5b68151` FOREIGN KEY (`mappedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compliance_evidence`
--

LOCK TABLES `compliance_evidence` WRITE;
/*!40000 ALTER TABLE `compliance_evidence` DISABLE KEYS */;
/*!40000 ALTER TABLE `compliance_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compliance_framework`
--

DROP TABLE IF EXISTS `compliance_framework`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compliance_framework` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `controlsJson` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compliance_framework`
--

LOCK TABLES `compliance_framework` WRITE;
/*!40000 ALTER TABLE `compliance_framework` DISABLE KEYS */;
/*!40000 ALTER TABLE `compliance_framework` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consent_record`
--

DROP TABLE IF EXISTS `consent_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consent_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `studentId` int NOT NULL,
  `consentType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `granted` tinyint NOT NULL DEFAULT '1',
  `grantedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `revokedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `capturedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_de870c3f9fff15570a7e5409a9c` (`studentId`),
  KEY `FK_b7ea32bea2220d7fd6247c181f6` (`capturedByUserId`),
  CONSTRAINT `FK_b7ea32bea2220d7fd6247c181f6` FOREIGN KEY (`capturedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_de870c3f9fff15570a7e5409a9c` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consent_record`
--

LOCK TABLES `consent_record` WRITE;
/*!40000 ALTER TABLE `consent_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `consent_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `prerequisiteCourseIdsJson` text COLLATE utf8mb4_unicode_ci,
  `competencyTags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estimatedHours` float DEFAULT NULL,
  `certificateEnabled` tinyint NOT NULL DEFAULT '0',
  `certificateTitle` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certificateBodyTemplate` text COLLATE utf8mb4_unicode_ci,
  `subjectId` int DEFAULT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_5cf4963ae12285cda6432d5a3a` (`code`),
  KEY `FK_499cf2e497ad40617c711a31387` (`branchId`),
  KEY `FK_fb83f36a12d973980aa060d3e0b` (`createdByUserId`),
  CONSTRAINT `FK_499cf2e497ad40617c711a31387` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_fb83f36a12d973980aa060d3e0b` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

LOCK TABLES `course` WRITE;
/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES (1,'Maths','0014','Mathematics',NULL,NULL,NULL,0,NULL,NULL,NULL,'1',NULL,1,2,'2026-04-07 02:24:18.551268');
/*!40000 ALTER TABLE `course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_module`
--

DROP TABLE IF EXISTS `course_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_module` (
  `id` int NOT NULL AUTO_INCREMENT,
  `courseId` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci,
  `resourceUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `moduleType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'content',
  `releaseAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contentVersion` int NOT NULL DEFAULT '1',
  `prerequisiteModuleIdsJson` text COLLATE utf8mb4_unicode_ci,
  `scormPackageUrl` text COLLATE utf8mb4_unicode_ci,
  `scormManifestJson` text COLLATE utf8mb4_unicode_ci,
  `estimatedMinutes` int NOT NULL DEFAULT '0',
  `order` int NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_e27b3a3cf92fd9b32f152a4f7fc` (`courseId`),
  CONSTRAINT `FK_e27b3a3cf92fd9b32f152a4f7fc` FOREIGN KEY (`courseId`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_module`
--

LOCK TABLES `course_module` WRITE;
/*!40000 ALTER TABLE `course_module` DISABLE KEYS */;
INSERT INTO `course_module` VALUES (1,1,'Pure Maths ','Pure Mathematics',NULL,'content',NULL,1,NULL,NULL,NULL,0,2,'2026-04-07 02:24:54.531895');
/*!40000 ALTER TABLE `course_module` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_progress`
--

DROP TABLE IF EXISTS `course_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `courseId` int NOT NULL,
  `userId` int NOT NULL,
  `completedModuleIdsJson` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'in_progress',
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certificateDocumentId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_2cfdeb07b732bd12041e29bf328` (`courseId`),
  KEY `FK_29a49682b3b764662029ec6a1cb` (`userId`),
  CONSTRAINT `FK_29a49682b3b764662029ec6a1cb` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_2cfdeb07b732bd12041e29bf328` FOREIGN KEY (`courseId`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_progress`
--

LOCK TABLES `course_progress` WRITE;
/*!40000 ALTER TABLE `course_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curriculum_plan`
--

DROP TABLE IF EXISTS `curriculum_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `curriculum_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `subjectId` int NOT NULL,
  `version` int NOT NULL DEFAULT '1',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `learningObjectives` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assessmentCriteria` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `outcomesJson` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `approvedByUserId` int DEFAULT NULL,
  `approvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isActive` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_f0d75d3d7509f6d6c373c9c9131` (`subjectId`),
  CONSTRAINT `FK_f0d75d3d7509f6d6c373c9c9131` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curriculum_plan`
--

LOCK TABLES `curriculum_plan` WRITE;
/*!40000 ALTER TABLE `curriculum_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `curriculum_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_approval`
--

DROP TABLE IF EXISTS `document_approval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_approval` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `documentId` int NOT NULL,
  `stage` int NOT NULL DEFAULT '1',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `requestedByUserId` int DEFAULT NULL,
  `requestedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decidedByUserId` int DEFAULT NULL,
  `decidedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `decisionReason` text COLLATE utf8mb4_unicode_ci,
  `signatureProvider` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signatureRef` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signaturePayloadJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_4f3902ce6d3da09a7e953348f2d` (`documentId`),
  KEY `FK_ff38226156a03e68c3135d187f5` (`requestedByUserId`),
  KEY `FK_9a9bc8a78f06f4f0f5c7a6f378c` (`decidedByUserId`),
  CONSTRAINT `FK_4f3902ce6d3da09a7e953348f2d` FOREIGN KEY (`documentId`) REFERENCES `document_record` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_9a9bc8a78f06f4f0f5c7a6f378c` FOREIGN KEY (`decidedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ff38226156a03e68c3135d187f5` FOREIGN KEY (`requestedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_approval`
--

LOCK TABLES `document_approval` WRITE;
/*!40000 ALTER TABLE `document_approval` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_approval` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_record`
--

DROP TABLE IF EXISTS `document_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `verificationCode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'document',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` text COLLATE utf8mb4_unicode_ci,
  `sha256Hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issuedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isRevoked` tinyint NOT NULL DEFAULT '0',
  `revokedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `revokedByUserId` int DEFAULT NULL,
  `contentType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sizeBytes` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `studentId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `rootDocumentId` int DEFAULT NULL,
  `versionNumber` int NOT NULL DEFAULT '1',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `approvalRequestedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvalRequestedByUserId` int DEFAULT NULL,
  `approvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvedByUserId` int DEFAULT NULL,
  `rejectedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rejectedByUserId` int DEFAULT NULL,
  `rejectionReason` text COLLATE utf8mb4_unicode_ci,
  `publishedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `publishedByUserId` int DEFAULT NULL,
  `archivedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `archivedByUserId` int DEFAULT NULL,
  `eSignProvider` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eSignRef` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eSignedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eSignedByUserId` int DEFAULT NULL,
  `retentionPolicyDays` int DEFAULT NULL,
  `retainUntil` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `legalHold` tinyint NOT NULL DEFAULT '0',
  `disposedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `disposedByUserId` int DEFAULT NULL,
  `complianceMappingsJson` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_b5052358c886e7025dc0e573e3` (`verificationCode`),
  KEY `FK_409412673374fc83995cc9efdac` (`revokedByUserId`),
  KEY `FK_16f3f8812ba46312fef27580d34` (`branchId`),
  KEY `FK_b07fb209c45a20523966da8cafc` (`studentId`),
  KEY `FK_6a64007498ba7d76490ec7aeaed` (`createdByUserId`),
  CONSTRAINT `FK_16f3f8812ba46312fef27580d34` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_409412673374fc83995cc9efdac` FOREIGN KEY (`revokedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_6a64007498ba7d76490ec7aeaed` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_b07fb209c45a20523966da8cafc` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_record`
--

LOCK TABLES `document_record` WRITE;
/*!40000 ALTER TABLE `document_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `startDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `venue` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `targetAudience` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `capacity` int NOT NULL DEFAULT '0',
  `allowRegistration` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_2149bcd6d0f2b78c73d0f48f581` (`branchId`),
  KEY `FK_d76567fb22ae5872643c19d9ca0` (`createdByUserId`),
  CONSTRAINT `FK_2149bcd6d0f2b78c73d0f48f581` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_d76567fb22ae5872643c19d9ca0` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event`
--

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_registration`
--

DROP TABLE IF EXISTS `event_registration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_registration` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `eventId` int NOT NULL,
  `userId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'registered',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_ebd16a55e8ad05fdb6cf0b325af` (`eventId`),
  KEY `FK_a4d960e4a113017e7e6b15f14b9` (`userId`),
  CONSTRAINT `FK_a4d960e4a113017e7e6b15f14b9` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ebd16a55e8ad05fdb6cf0b325af` FOREIGN KEY (`eventId`) REFERENCES `event` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_registration`
--

LOCK TABLES `event_registration` WRITE;
/*!40000 ALTER TABLE `event_registration` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_registration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam`
--

DROP TABLE IF EXISTS `exam`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `startAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_48a9e0d306982c19c7988f5b9de` (`branchId`),
  CONSTRAINT `FK_48a9e0d306982c19c7988f5b9de` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam`
--

LOCK TABLES `exam` WRITE;
/*!40000 ALTER TABLE `exam` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_mark`
--

DROP TABLE IF EXISTS `exam_mark`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_mark` (
  `id` int NOT NULL AUTO_INCREMENT,
  `examId` int NOT NULL,
  `subjectId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `marksObtained` float DEFAULT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_c2968ad72dd9d56e927bc00b383` (`examId`),
  KEY `FK_2e18fb06b79ca89e19da3890b7c` (`subjectId`),
  KEY `FK_400aa3793d8acd382810ec5871d` (`studentId`),
  CONSTRAINT `FK_2e18fb06b79ca89e19da3890b7c` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_400aa3793d8acd382810ec5871d` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_c2968ad72dd9d56e927bc00b383` FOREIGN KEY (`examId`) REFERENCES `exam` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_mark`
--

LOCK TABLES `exam_mark` WRITE;
/*!40000 ALTER TABLE `exam_mark` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_mark` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_subject`
--

DROP TABLE IF EXISTS `exam_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_subject` (
  `id` int NOT NULL AUTO_INCREMENT,
  `examId` int NOT NULL,
  `subjectId` int DEFAULT NULL,
  `maxMarks` int NOT NULL DEFAULT '100',
  `scheduledAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_e45698f0729a8afd5a66b22154b` (`examId`),
  KEY `FK_e27267f7d63a0ac680fc1f87f75` (`subjectId`),
  CONSTRAINT `FK_e27267f7d63a0ac680fc1f87f75` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_e45698f0729a8afd5a66b22154b` FOREIGN KEY (`examId`) REFERENCES `exam` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_subject`
--

LOCK TABLES `exam_subject` WRITE;
/*!40000 ALTER TABLE `exam_subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_store_record`
--

DROP TABLE IF EXISTS `feature_store_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feature_store_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `entityType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entityId` int NOT NULL,
  `featureKey` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `valueJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recordedAt` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_store_record`
--

LOCK TABLES `feature_store_record` WRITE;
/*!40000 ALTER TABLE `feature_store_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_store_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_dunning_attempt`
--

DROP TABLE IF EXISTS `fee_dunning_attempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_dunning_attempt` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `feePaymentId` int NOT NULL,
  `level` int NOT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'email',
  `communicationMessageId` int DEFAULT NULL,
  `sentAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_db00aed539156a1ec2ecb029ceb` (`feePaymentId`),
  KEY `FK_26acb86857a354d41d487215510` (`communicationMessageId`),
  CONSTRAINT `FK_26acb86857a354d41d487215510` FOREIGN KEY (`communicationMessageId`) REFERENCES `communication_message` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_db00aed539156a1ec2ecb029ceb` FOREIGN KEY (`feePaymentId`) REFERENCES `fee_payment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_dunning_attempt`
--

LOCK TABLES `fee_dunning_attempt` WRITE;
/*!40000 ALTER TABLE `fee_dunning_attempt` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_dunning_attempt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_gateway_transaction`
--

DROP TABLE IF EXISTS `fee_gateway_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_gateway_transaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `feePaymentId` int NOT NULL,
  `provider` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gatewayReference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` float NOT NULL DEFAULT '0',
  `currency` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'callback_received',
  `payloadJson` text COLLATE utf8mb4_unicode_ci,
  `receivedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `processedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_b99f81847f28a90097a314e708a` (`feePaymentId`),
  CONSTRAINT `FK_b99f81847f28a90097a314e708a` FOREIGN KEY (`feePaymentId`) REFERENCES `fee_payment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_gateway_transaction`
--

LOCK TABLES `fee_gateway_transaction` WRITE;
/*!40000 ALTER TABLE `fee_gateway_transaction` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_gateway_transaction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_payment`
--

DROP TABLE IF EXISTS `fee_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_payment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `feeStructureId` int NOT NULL,
  `totalAmount` float NOT NULL DEFAULT '0',
  `discountAmount` float NOT NULL DEFAULT '0',
  `lateFeeAmount` float NOT NULL DEFAULT '0',
  `amountDue` float NOT NULL DEFAULT '0',
  `amountPaid` float NOT NULL DEFAULT '0',
  `dueDate` date NOT NULL,
  `paidDate` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `paymentMethod` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `gatewayReference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receiptDocumentId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_3b5d97f3b6cbeb617b309cfc565` (`studentId`),
  KEY `FK_37be31a018b8659b5d5909d2f4b` (`feeStructureId`),
  KEY `FK_5d0d8bacf8c444c9ae8c63226de` (`receiptDocumentId`),
  CONSTRAINT `FK_37be31a018b8659b5d5909d2f4b` FOREIGN KEY (`feeStructureId`) REFERENCES `fee_structure` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_3b5d97f3b6cbeb617b309cfc565` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_5d0d8bacf8c444c9ae8c63226de` FOREIGN KEY (`receiptDocumentId`) REFERENCES `document_record` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_payment`
--

LOCK TABLES `fee_payment` WRITE;
/*!40000 ALTER TABLE `fee_payment` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_structure`
--

DROP TABLE IF EXISTS `fee_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_structure` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'tuition',
  `amount` float NOT NULL DEFAULT '0',
  `frequency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'annual',
  `dueDayOfMonth` int DEFAULT NULL,
  `lateFeePerDay` float NOT NULL DEFAULT '0',
  `maxLateFee` float NOT NULL DEFAULT '0',
  `description` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_c948dd945940aee1b5c6a773a69` (`branchId`),
  CONSTRAINT `FK_c948dd945940aee1b5c6a773a69` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_structure`
--

LOCK TABLES `fee_structure` WRITE;
/*!40000 ALTER TABLE `fee_structure` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_structure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fixed_asset`
--

DROP TABLE IF EXISTS `fixed_asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fixed_asset` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `assetTag` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `purchaseDate` date NOT NULL,
  `cost` float NOT NULL DEFAULT '0',
  `usefulLifeMonths` int NOT NULL DEFAULT '36',
  `salvageValue` float NOT NULL DEFAULT '0',
  `depreciationMethod` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'straight_line',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `disposedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fixed_asset`
--

LOCK TABLES `fixed_asset` WRITE;
/*!40000 ALTER TABLE `fixed_asset` DISABLE KEYS */;
/*!40000 ALTER TABLE `fixed_asset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guardian`
--

DROP TABLE IF EXISTS `guardian`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guardian` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `userId` int DEFAULT NULL,
  `firstName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `relationship` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_49e928e8c50cb738ef30d29e19` (`email`),
  KEY `FK_e3047affa1277afea0d7d64f52c` (`branchId`),
  KEY `FK_319fcb5c6046d704e4cfd18579b` (`studentId`),
  KEY `FK_c26c0fe4f572dfb4a69e26d1386` (`userId`),
  CONSTRAINT `FK_319fcb5c6046d704e4cfd18579b` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_c26c0fe4f572dfb4a69e26d1386` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_e3047affa1277afea0d7d64f52c` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guardian`
--

LOCK TABLES `guardian` WRITE;
/*!40000 ALTER TABLE `guardian` DISABLE KEYS */;
/*!40000 ALTER TABLE `guardian` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `homework_assignment`
--

DROP TABLE IF EXISTS `homework_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `homework_assignment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `subjectId` int DEFAULT NULL,
  `sectionId` int DEFAULT NULL,
  `dueDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `totalMarks` int NOT NULL DEFAULT '100',
  `rubricJson` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_3eab17529e13675d071b23cc86c` (`sectionId`),
  KEY `FK_e86c21ea39e9d8be5848eb0c59d` (`subjectId`),
  CONSTRAINT `FK_3eab17529e13675d071b23cc86c` FOREIGN KEY (`sectionId`) REFERENCES `class_section` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_e86c21ea39e9d8be5848eb0c59d` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homework_assignment`
--

LOCK TABLES `homework_assignment` WRITE;
/*!40000 ALTER TABLE `homework_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `homework_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `homework_submission`
--

DROP TABLE IF EXISTS `homework_submission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `homework_submission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assignmentId` int NOT NULL,
  `studentId` int NOT NULL,
  `submittedByUserId` int DEFAULT NULL,
  `submittedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contentText` text COLLATE utf8mb4_unicode_ci,
  `attachmentUrl` text COLLATE utf8mb4_unicode_ci,
  `plagiarismScore` float DEFAULT NULL,
  `reviewNotes` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `marksAwarded` int DEFAULT NULL,
  `feedback` text COLLATE utf8mb4_unicode_ci,
  `gradedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gradedByUserId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_30bd85e334327d7fbd2f122dfae` (`assignmentId`),
  KEY `FK_152d08ada2faad46ec676708d85` (`studentId`),
  KEY `FK_515dc874788e1844a5b96f6fd10` (`submittedByUserId`),
  KEY `FK_af3fd255e4668b48d6cea52ccbf` (`gradedByUserId`),
  CONSTRAINT `FK_152d08ada2faad46ec676708d85` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_30bd85e334327d7fbd2f122dfae` FOREIGN KEY (`assignmentId`) REFERENCES `homework_assignment` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_515dc874788e1844a5b96f6fd10` FOREIGN KEY (`submittedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_af3fd255e4668b48d6cea52ccbf` FOREIGN KEY (`gradedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homework_submission`
--

LOCK TABLES `homework_submission` WRITE;
/*!40000 ALTER TABLE `homework_submission` DISABLE KEYS */;
/*!40000 ALTER TABLE `homework_submission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_allocation`
--

DROP TABLE IF EXISTS `hostel_allocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_allocation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `roomId` int NOT NULL,
  `studentUserId` int NOT NULL,
  `bedNo` int DEFAULT NULL,
  `startDate` date NOT NULL,
  `endDate` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `allocatedByUserId` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_b5f4a7fd82b23f6448bb361fd72` (`roomId`),
  KEY `FK_e2ed97640d3a59d1fc7504e2fec` (`studentUserId`),
  KEY `FK_5de9e834090ec1c7cf43e318a45` (`allocatedByUserId`),
  CONSTRAINT `FK_5de9e834090ec1c7cf43e318a45` FOREIGN KEY (`allocatedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_b5f4a7fd82b23f6448bb361fd72` FOREIGN KEY (`roomId`) REFERENCES `hostel_room` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_e2ed97640d3a59d1fc7504e2fec` FOREIGN KEY (`studentUserId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_allocation`
--

LOCK TABLES `hostel_allocation` WRITE;
/*!40000 ALTER TABLE `hostel_allocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_allocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_incident`
--

DROP TABLE IF EXISTS `hostel_incident`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_incident` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `roomId` int NOT NULL,
  `reportedByUserId` int DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `escalatedToUserId` int DEFAULT NULL,
  `escalatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `escalationNotes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolutionNotes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `studentUserId` int DEFAULT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `actionTaken` text COLLATE utf8mb4_unicode_ci,
  `followUpAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `closedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_d018fe92395b1a1818718add50b` (`roomId`),
  KEY `FK_f30f569429c60adfc35fc5a48c9` (`reportedByUserId`),
  KEY `FK_2554f05a18806f96d317825a0d5` (`escalatedToUserId`),
  KEY `FK_7e8b1f00cb517443789924a18c7` (`studentUserId`),
  CONSTRAINT `FK_2554f05a18806f96d317825a0d5` FOREIGN KEY (`escalatedToUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_7e8b1f00cb517443789924a18c7` FOREIGN KEY (`studentUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_d018fe92395b1a1818718add50b` FOREIGN KEY (`roomId`) REFERENCES `hostel_room` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_f30f569429c60adfc35fc5a48c9` FOREIGN KEY (`reportedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_incident`
--

LOCK TABLES `hostel_incident` WRITE;
/*!40000 ALTER TABLE `hostel_incident` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_incident` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_inspection`
--

DROP TABLE IF EXISTS `hostel_inspection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_inspection` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `roomId` int NOT NULL,
  `inspectorUserId` int DEFAULT NULL,
  `inspectionDate` date NOT NULL,
  `result` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pass',
  `score` float DEFAULT NULL,
  `findings` text COLLATE utf8mb4_unicode_ci,
  `checklistJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_61f29ad3bc1e8f7655f820993ed` (`roomId`),
  KEY `FK_c3019c2267473b5cb5cedbe628c` (`inspectorUserId`),
  CONSTRAINT `FK_61f29ad3bc1e8f7655f820993ed` FOREIGN KEY (`roomId`) REFERENCES `hostel_room` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_c3019c2267473b5cb5cedbe628c` FOREIGN KEY (`inspectorUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_inspection`
--

LOCK TABLES `hostel_inspection` WRITE;
/*!40000 ALTER TABLE `hostel_inspection` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_inspection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_leave_request`
--

DROP TABLE IF EXISTS `hostel_leave_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_leave_request` (
  `id` int NOT NULL AUTO_INCREMENT,
  `roomId` int NOT NULL,
  `studentUserId` int NOT NULL,
  `leaveStart` date NOT NULL,
  `leaveEnd` date NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reviewNotes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_05bf1baf30a5dd8cbdd2b386cd4` (`roomId`),
  KEY `FK_dd202e5cc65f6bfce341366f30f` (`studentUserId`),
  CONSTRAINT `FK_05bf1baf30a5dd8cbdd2b386cd4` FOREIGN KEY (`roomId`) REFERENCES `hostel_room` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_dd202e5cc65f6bfce341366f30f` FOREIGN KEY (`studentUserId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_leave_request`
--

LOCK TABLES `hostel_leave_request` WRITE;
/*!40000 ALTER TABLE `hostel_leave_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_leave_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_policy`
--

DROP TABLE IF EXISTS `hostel_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_policy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `genderRestriction` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'any',
  `minAge` int DEFAULT NULL,
  `maxAge` int DEFAULT NULL,
  `allowVisitors` tinyint NOT NULL DEFAULT '1',
  `visitorRequiresApproval` tinyint NOT NULL DEFAULT '1',
  `inspectionFrequencyDays` int NOT NULL DEFAULT '30',
  `rulesJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_policy`
--

LOCK TABLES `hostel_policy` WRITE;
/*!40000 ALTER TABLE `hostel_policy` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_room`
--

DROP TABLE IF EXISTS `hostel_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_room` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `building` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `floor` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roomNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int NOT NULL DEFAULT '1',
  `occupiedBeds` int NOT NULL DEFAULT '0',
  `roomType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amenities` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `genderRestriction` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `minAge` int DEFAULT NULL,
  `maxAge` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_room`
--

LOCK TABLES `hostel_room` WRITE;
/*!40000 ALTER TABLE `hostel_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_visitor`
--

DROP TABLE IF EXISTS `hostel_visitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_visitor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `roomId` int NOT NULL,
  `visitorName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `relation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `visitDate` date NOT NULL,
  `entryTime` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exitTime` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `purpose` text COLLATE utf8mb4_unicode_ci,
  `badgeNumber` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `badgeStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `badgeIssuedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `badgeReturnedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `escortedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `approvalStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approvedByUserId` int DEFAULT NULL,
  `approvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvalNotes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `FK_9238f7855802b4a0f73cdbda24e` (`roomId`),
  KEY `FK_0753924d29544c1de048a99315f` (`escortedByUserId`),
  KEY `FK_7eb4f5d5bdecbf03779ba22711f` (`approvedByUserId`),
  CONSTRAINT `FK_0753924d29544c1de048a99315f` FOREIGN KEY (`escortedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_7eb4f5d5bdecbf03779ba22711f` FOREIGN KEY (`approvedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_9238f7855802b4a0f73cdbda24e` FOREIGN KEY (`roomId`) REFERENCES `hostel_room` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_visitor`
--

LOCK TABLES `hostel_visitor` WRITE;
/*!40000 ALTER TABLE `hostel_visitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_visitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostel_wellbeing_alert`
--

DROP TABLE IF EXISTS `hostel_wellbeing_alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostel_wellbeing_alert` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `roomId` int DEFAULT NULL,
  `studentUserId` int NOT NULL,
  `severity` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `notes` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolvedByUserId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_9b00db88a707d189cbafea7d974` (`roomId`),
  KEY `FK_192ed18cf3bdee9a7e1a446fc71` (`studentUserId`),
  KEY `FK_fb8edaad9a3e02d5fd7d3f7abce` (`resolvedByUserId`),
  CONSTRAINT `FK_192ed18cf3bdee9a7e1a446fc71` FOREIGN KEY (`studentUserId`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_9b00db88a707d189cbafea7d974` FOREIGN KEY (`roomId`) REFERENCES `hostel_room` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_fb8edaad9a3e02d5fd7d3f7abce` FOREIGN KEY (`resolvedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostel_wellbeing_alert`
--

LOCK TABLES `hostel_wellbeing_alert` WRITE;
/*!40000 ALTER TABLE `hostel_wellbeing_alert` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostel_wellbeing_alert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `id_card`
--

DROP TABLE IF EXISTS `id_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_card` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `userId` int NOT NULL,
  `cardNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issuedDate` date NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `accessAreas` text COLLATE utf8mb4_unicode_ci,
  `issuedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `templateId` int DEFAULT NULL,
  `externalUid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `printedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `revokedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `revokedReason` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `FK_1a242b1783ab7420f4ae891a7d5` (`userId`),
  CONSTRAINT `FK_1a242b1783ab7420f4ae891a7d5` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `id_card`
--

LOCK TABLES `id_card` WRITE;
/*!40000 ALTER TABLE `id_card` DISABLE KEYS */;
/*!40000 ALTER TABLE `id_card` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `id_card_access_log`
--

DROP TABLE IF EXISTS `id_card_access_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_card_access_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cardId` int NOT NULL,
  `userId` int DEFAULT NULL,
  `area` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `doorId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deviceId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `occurredAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `granted` tinyint NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_7ce935a21d3cfd184fd456eb936` (`cardId`),
  KEY `FK_33fa770bb0d2d61cf8a8b9a6e33` (`userId`),
  CONSTRAINT `FK_33fa770bb0d2d61cf8a8b9a6e33` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_7ce935a21d3cfd184fd456eb936` FOREIGN KEY (`cardId`) REFERENCES `id_card` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `id_card_access_log`
--

LOCK TABLES `id_card_access_log` WRITE;
/*!40000 ALTER TABLE `id_card_access_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `id_card_access_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `id_card_device`
--

DROP TABLE IF EXISTS `id_card_device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_card_device` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `deviceId` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `lastSeenAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_432e873f74aed355708b036712` (`deviceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `id_card_device`
--

LOCK TABLES `id_card_device` WRITE;
/*!40000 ALTER TABLE `id_card_device` DISABLE KEYS */;
/*!40000 ALTER TABLE `id_card_device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `id_card_template`
--

DROP TABLE IF EXISTS `id_card_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_card_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cardType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'standard',
  `layoutJson` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `id_card_template`
--

LOCK TABLES `id_card_template` WRITE;
/*!40000 ALTER TABLE `id_card_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `id_card_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `intervention_case`
--

DROP TABLE IF EXISTS `intervention_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `intervention_case` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `riskType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `reason` text COLLATE utf8mb4_unicode_ci,
  `recommendedActionsJson` text COLLATE utf8mb4_unicode_ci,
  `assignedToUserId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `resolvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_975029806fcc72a16ea6b812d80` (`branchId`),
  KEY `FK_ed80bfe0f6d44d15fa320ebc965` (`studentId`),
  KEY `FK_6691d0e48ddbccceccecd70789e` (`assignedToUserId`),
  KEY `FK_3b22c501fe90fc66b7d08d93d6d` (`createdByUserId`),
  CONSTRAINT `FK_3b22c501fe90fc66b7d08d93d6d` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_6691d0e48ddbccceccecd70789e` FOREIGN KEY (`assignedToUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_975029806fcc72a16ea6b812d80` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ed80bfe0f6d44d15fa320ebc965` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `intervention_case`
--

LOCK TABLES `intervention_case` WRITE;
/*!40000 ALTER TABLE `intervention_case` DISABLE KEYS */;
/*!40000 ALTER TABLE `intervention_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_item`
--

DROP TABLE IF EXISTS `inventory_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `sku` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` float NOT NULL DEFAULT '0',
  `unitPrice` float NOT NULL DEFAULT '0',
  `reorderLevel` float NOT NULL DEFAULT '0',
  `vendor` text COLLATE utf8mb4_unicode_ci,
  `lastReceivedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_item`
--

LOCK TABLES `inventory_item` WRITE;
/*!40000 ALTER TABLE `inventory_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_application`
--

DROP TABLE IF EXISTS `job_application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_application` (
  `id` int NOT NULL AUTO_INCREMENT,
  `jobPostingId` int NOT NULL,
  `branchId` int DEFAULT NULL,
  `applicantName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resumeUrl` text COLLATE utf8mb4_unicode_ci,
  `coverLetter` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'applied',
  `interviewAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `hiredStaffProfileId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `stageKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stageUpdatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_35b42ed2be0cf7d5803a9ed868e` (`jobPostingId`),
  KEY `FK_9a10e6186b9690e3e424baef6a6` (`hiredStaffProfileId`),
  CONSTRAINT `FK_35b42ed2be0cf7d5803a9ed868e` FOREIGN KEY (`jobPostingId`) REFERENCES `job_posting` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_9a10e6186b9690e3e424baef6a6` FOREIGN KEY (`hiredStaffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_application`
--

LOCK TABLES `job_application` WRITE;
/*!40000 ALTER TABLE `job_application` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_application` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_posting`
--

DROP TABLE IF EXISTS `job_posting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_posting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `employmentType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `postedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `closesAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_2fe5b2cd341c475699deb511f38` (`branchId`),
  KEY `FK_de0d09bef76c6ff4b714b0b266a` (`createdByUserId`),
  CONSTRAINT `FK_2fe5b2cd341c475699deb511f38` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_de0d09bef76c6ff4b714b0b266a` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_posting`
--

LOCK TABLES `job_posting` WRITE;
/*!40000 ALTER TABLE `job_posting` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_posting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_entry`
--

DROP TABLE IF EXISTS `journal_entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_entry` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `accountId` int NOT NULL,
  `entryDate` date NOT NULL,
  `debit` float NOT NULL DEFAULT '0',
  `credit` float NOT NULL DEFAULT '0',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `createdByUserId` int DEFAULT NULL,
  `approvedByUserId` int DEFAULT NULL,
  `approvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `transactionId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lineNo` int NOT NULL DEFAULT '0',
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `fxRate` float NOT NULL DEFAULT '1',
  `baseDebit` float NOT NULL DEFAULT '0',
  `baseCredit` float NOT NULL DEFAULT '0',
  `reconciliationStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unreconciled',
  `reconciledByUserId` int DEFAULT NULL,
  `reconciledAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankReference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_5eb980cfdd7c2a31dad9cc7ab49` (`accountId`),
  CONSTRAINT `FK_5eb980cfdd7c2a31dad9cc7ab49` FOREIGN KEY (`accountId`) REFERENCES `account` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entry`
--

LOCK TABLES `journal_entry` WRITE;
/*!40000 ALTER TABLE `journal_entry` DISABLE KEYS */;
/*!40000 ALTER TABLE `journal_entry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_balance`
--

DROP TABLE IF EXISTS `leave_balance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_balance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `staffProfileId` int NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `year` int NOT NULL,
  `openingBalanceDays` float NOT NULL DEFAULT '0',
  `accruedDays` float NOT NULL DEFAULT '0',
  `usedDays` float NOT NULL DEFAULT '0',
  `remainingDays` float NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_dfd65bb49d07ffd0ed18eea68aa` (`staffProfileId`),
  CONSTRAINT `FK_dfd65bb49d07ffd0ed18eea68aa` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balance`
--

LOCK TABLES `leave_balance` WRITE;
/*!40000 ALTER TABLE `leave_balance` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_balance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_policy`
--

DROP TABLE IF EXISTS `leave_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_policy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `annualEntitlementDays` int NOT NULL DEFAULT '0',
  `accrualRatePerMonth` float NOT NULL DEFAULT '0',
  `maxCarryOverDays` int NOT NULL DEFAULT '0',
  `isActive` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_d4aed7335fd773960ae476b1170` (`branchId`),
  CONSTRAINT `FK_d4aed7335fd773960ae476b1170` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_policy`
--

LOCK TABLES `leave_policy` WRITE;
/*!40000 ALTER TABLE `leave_policy` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_request`
--

DROP TABLE IF EXISTS `leave_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_request` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `staffProfileId` int NOT NULL,
  `requestedByUserId` int DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sick',
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `days` int NOT NULL DEFAULT '1',
  `reason` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approverId` int DEFAULT NULL,
  `approverComments` text COLLATE utf8mb4_unicode_ci,
  `decidedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attachmentUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_ae8f55b2a1a1c32543d9a3e14e3` (`staffProfileId`),
  CONSTRAINT `FK_ae8f55b2a1a1c32543d9a3e14e3` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_request`
--

LOCK TABLES `leave_request` WRITE;
/*!40000 ALTER TABLE `leave_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_plan`
--

DROP TABLE IF EXISTS `lesson_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `sectionId` int DEFAULT NULL,
  `subjectId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `objectives` text COLLATE utf8mb4_unicode_ci,
  `content` text COLLATE utf8mb4_unicode_ci,
  `resourcesJson` text COLLATE utf8mb4_unicode_ci,
  `plannedFor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `version` int NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_f5997c95322b3a8207d90824a67` (`branchId`),
  KEY `FK_4596a740c54eaa13e9a68ad5ad4` (`sectionId`),
  KEY `FK_b1f50148d8f0cce94b492c9c123` (`subjectId`),
  KEY `FK_7bab43e3e9b00bbf5dbe6655143` (`createdByUserId`),
  CONSTRAINT `FK_4596a740c54eaa13e9a68ad5ad4` FOREIGN KEY (`sectionId`) REFERENCES `class_section` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_7bab43e3e9b00bbf5dbe6655143` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_b1f50148d8f0cce94b492c9c123` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_f5997c95322b3a8207d90824a67` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_plan`
--

LOCK TABLES `lesson_plan` WRITE;
/*!40000 ALTER TABLE `lesson_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `lesson_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_acquisition_order`
--

DROP TABLE IF EXISTS `library_acquisition_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_acquisition_order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `vendorId` int DEFAULT NULL,
  `vendorName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `orderDate` date NOT NULL,
  `expectedDeliveryDate` date DEFAULT NULL,
  `receivedDate` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `totalCost` float NOT NULL DEFAULT '0',
  `linesJson` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `receivedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_cd1062557b028bbe00659ab9eba` (`vendorId`),
  CONSTRAINT `FK_cd1062557b028bbe00659ab9eba` FOREIGN KEY (`vendorId`) REFERENCES `vendor` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_acquisition_order`
--

LOCK TABLES `library_acquisition_order` WRITE;
/*!40000 ALTER TABLE `library_acquisition_order` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_acquisition_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_book`
--

DROP TABLE IF EXISTS `library_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_book` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `author` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isbn` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barcode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shelfLocation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `totalCopies` int NOT NULL DEFAULT '1',
  `availableCopies` int NOT NULL DEFAULT '1',
  `description` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `publisher` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `publicationYear` int DEFAULT NULL,
  `edition` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deweyDecimal` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `callNumber` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subjectsJson` text COLLATE utf8mb4_unicode_ci,
  `catalogSource` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `catalogImportedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `catalogRecordJson` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `FK_c1dec4cc65f95a3a159f8df1e69` (`branchId`),
  CONSTRAINT `FK_c1dec4cc65f95a3a159f8df1e69` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_book`
--

LOCK TABLES `library_book` WRITE;
/*!40000 ALTER TABLE `library_book` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_copy`
--

DROP TABLE IF EXISTS `library_copy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_copy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `bookId` int NOT NULL,
  `copyNo` int NOT NULL DEFAULT '1',
  `barcode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `condition` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `shelfLocation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_ea9fb4d3956740def299cd7e63` (`barcode`),
  KEY `FK_94105d3916ee0d4170ae57cd03e` (`bookId`),
  CONSTRAINT `FK_94105d3916ee0d4170ae57cd03e` FOREIGN KEY (`bookId`) REFERENCES `library_book` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_copy`
--

LOCK TABLES `library_copy` WRITE;
/*!40000 ALTER TABLE `library_copy` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_copy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_fine`
--

DROP TABLE IF EXISTS `library_fine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_fine` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `loanId` int NOT NULL,
  `studentId` int NOT NULL,
  `amount` float NOT NULL DEFAULT '0',
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid',
  `assessedDate` date NOT NULL,
  `settledDate` date DEFAULT NULL,
  `settledByUserId` int DEFAULT NULL,
  `paymentMethod` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_d527fac13f2f46b9091cd202249` (`loanId`),
  KEY `FK_3d6bdb5edbb122668244d5a29c9` (`studentId`),
  CONSTRAINT `FK_3d6bdb5edbb122668244d5a29c9` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_d527fac13f2f46b9091cd202249` FOREIGN KEY (`loanId`) REFERENCES `library_loan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_fine`
--

LOCK TABLES `library_fine` WRITE;
/*!40000 ALTER TABLE `library_fine` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_fine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_hold`
--

DROP TABLE IF EXISTS `library_hold`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_hold` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `bookId` int NOT NULL,
  `reservedCopyId` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `queuePosition` int NOT NULL DEFAULT '1',
  `expiresAt` date DEFAULT NULL,
  `fulfilledAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_6b3f45b0e207107177530d776a7` (`studentId`),
  KEY `FK_66131b8a89d936f3e0d850c4e88` (`bookId`),
  KEY `FK_8c02b4f4aefbad3e2c61cc68371` (`reservedCopyId`),
  CONSTRAINT `FK_66131b8a89d936f3e0d850c4e88` FOREIGN KEY (`bookId`) REFERENCES `library_book` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_6b3f45b0e207107177530d776a7` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_8c02b4f4aefbad3e2c61cc68371` FOREIGN KEY (`reservedCopyId`) REFERENCES `library_copy` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_hold`
--

LOCK TABLES `library_hold` WRITE;
/*!40000 ALTER TABLE `library_hold` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_hold` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_loan`
--

DROP TABLE IF EXISTS `library_loan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_loan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `bookId` int NOT NULL,
  `loanDate` date NOT NULL,
  `dueDate` date NOT NULL,
  `returnDate` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'borrowed',
  `fineAmount` float NOT NULL DEFAULT '0',
  `renewalCount` int NOT NULL DEFAULT '0',
  `issuedByUserId` int DEFAULT NULL,
  `returnedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `copyId` int DEFAULT NULL,
  `holdId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_ee4b2b2a9e48ce96b3870279d56` (`studentId`),
  KEY `FK_3dc88eabaffcb7a64f97a690a8f` (`bookId`),
  KEY `FK_7d29846fc97ac3e30372a73fa38` (`copyId`),
  CONSTRAINT `FK_3dc88eabaffcb7a64f97a690a8f` FOREIGN KEY (`bookId`) REFERENCES `library_book` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_7d29846fc97ac3e30372a73fa38` FOREIGN KEY (`copyId`) REFERENCES `library_copy` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ee4b2b2a9e48ce96b3870279d56` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_loan`
--

LOCK TABLES `library_loan` WRITE;
/*!40000 ALTER TABLE `library_loan` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_loan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_policy`
--

DROP TABLE IF EXISTS `library_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_policy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `borrowerType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student',
  `loanDays` int NOT NULL DEFAULT '14',
  `maxLoans` int NOT NULL DEFAULT '5',
  `renewalsAllowed` int NOT NULL DEFAULT '1',
  `renewalDays` int NOT NULL DEFAULT '7',
  `holdExpiryDays` int NOT NULL DEFAULT '3',
  `graceDays` int NOT NULL DEFAULT '0',
  `perDayFine` float NOT NULL DEFAULT '1',
  `maxFineAmount` float NOT NULL DEFAULT '50',
  `lostBookFee` float NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_policy`
--

LOCK TABLES `library_policy` WRITE;
/*!40000 ALTER TABLE `library_policy` DISABLE KEYS */;
/*!40000 ALTER TABLE `library_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meal_menu_day`
--

DROP TABLE IF EXISTS `meal_menu_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meal_menu_day` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `menuDate` date NOT NULL,
  `itemsJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meal_menu_day`
--

LOCK TABLES `meal_menu_day` WRITE;
/*!40000 ALTER TABLE `meal_menu_day` DISABLE KEYS */;
/*!40000 ALTER TABLE `meal_menu_day` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meal_plan`
--

DROP TABLE IF EXISTS `meal_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meal_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'breakfast',
  `price` float NOT NULL DEFAULT '0',
  `description` text COLLATE utf8mb4_unicode_ci,
  `nutritionInfo` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint NOT NULL DEFAULT '1',
  `allergenInfo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `nutritionJson` text COLLATE utf8mb4_unicode_ci,
  `allergensJson` text COLLATE utf8mb4_unicode_ci,
  `inventoryItemId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meal_plan`
--

LOCK TABLES `meal_plan` WRITE;
/*!40000 ALTER TABLE `meal_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `meal_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meal_purchase`
--

DROP TABLE IF EXISTS `meal_purchase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meal_purchase` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `mealPlanId` int NOT NULL,
  `amount` float NOT NULL DEFAULT '0',
  `paymentMethod` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'card',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `allergyWarning` tinyint NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_81463cafde722f6c2071854cb39` (`branchId`),
  KEY `FK_01bbb3040f59daef31913ee9110` (`studentId`),
  KEY `FK_5c30519530243ad25d84da67d24` (`mealPlanId`),
  CONSTRAINT `FK_01bbb3040f59daef31913ee9110` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_5c30519530243ad25d84da67d24` FOREIGN KEY (`mealPlanId`) REFERENCES `meal_plan` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_81463cafde722f6c2071854cb39` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meal_purchase`
--

LOCK TABLES `meal_purchase` WRITE;
/*!40000 ALTER TABLE `meal_purchase` DISABLE KEYS */;
/*!40000 ALTER TABLE `meal_purchase` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meal_reservation`
--

DROP TABLE IF EXISTS `meal_reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meal_reservation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `studentId` int NOT NULL,
  `mealPlanId` int NOT NULL,
  `mealDate` date NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'reserved',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_1a18093d5d19a695ceb25793959` (`studentId`),
  KEY `FK_894f7016c0b122543789825872a` (`mealPlanId`),
  CONSTRAINT `FK_1a18093d5d19a695ceb25793959` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_894f7016c0b122543789825872a` FOREIGN KEY (`mealPlanId`) REFERENCES `meal_plan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meal_reservation`
--

LOCK TABLES `meal_reservation` WRITE;
/*!40000 ALTER TABLE `meal_reservation` DISABLE KEYS */;
/*!40000 ALTER TABLE `meal_reservation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_asset`
--

DROP TABLE IF EXISTS `media_asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `media_asset` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'document',
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `license` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rightsOwner` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiresAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'approved',
  `reviewedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewedByUserId` int DEFAULT NULL,
  `reviewNotes` text COLLATE utf8mb4_unicode_ci,
  `viewCount` int NOT NULL DEFAULT '0',
  `downloadCount` int NOT NULL DEFAULT '0',
  `uploadedByUserId` int DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_fed97c7fce7fe4e0201d94e829f` (`branchId`),
  KEY `FK_354f8872225c51f8fd9536f5505` (`reviewedByUserId`),
  KEY `FK_5eafe0e8b3d7702b2376f571f7e` (`uploadedByUserId`),
  CONSTRAINT `FK_354f8872225c51f8fd9536f5505` FOREIGN KEY (`reviewedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_5eafe0e8b3d7702b2376f571f7e` FOREIGN KEY (`uploadedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_fed97c7fce7fe4e0201d94e829f` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media_asset`
--

LOCK TABLES `media_asset` WRITE;
/*!40000 ALTER TABLE `media_asset` DISABLE KEYS */;
/*!40000 ALTER TABLE `media_asset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ml_inference_log`
--

DROP TABLE IF EXISTS `ml_inference_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ml_inference_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `modelId` int DEFAULT NULL,
  `modelKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `studentId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `inputJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `outputJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `durationMs` int DEFAULT NULL,
  `riskScore` int DEFAULT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `success` tinyint NOT NULL DEFAULT '1',
  `errorMessage` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ml_inference_log`
--

LOCK TABLES `ml_inference_log` WRITE;
/*!40000 ALTER TABLE `ml_inference_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ml_inference_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ml_model`
--

DROP TABLE IF EXISTS `ml_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ml_model` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'predict',
  `provider` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'heuristic',
  `endpointUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '0',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_1c2ff1501b84ec3ab3e496d8c6` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ml_model`
--

LOCK TABLES `ml_model` WRITE;
/*!40000 ALTER TABLE `ml_model` DISABLE KEYS */;
/*!40000 ALTER TABLE `ml_model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ml_training_job`
--

DROP TABLE IF EXISTS `ml_training_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ml_training_job` (
  `id` int NOT NULL AUTO_INCREMENT,
  `modelId` int DEFAULT NULL,
  `modelKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'queued',
  `datasetRef` text COLLATE utf8mb4_unicode_ci,
  `startedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metricsJson` text COLLATE utf8mb4_unicode_ci,
  `errorMessage` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ml_training_job`
--

LOCK TABLES `ml_training_job` WRITE;
/*!40000 ALTER TABLE `ml_training_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `ml_training_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_benefit_enrollment`
--

DROP TABLE IF EXISTS `payroll_benefit_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_benefit_enrollment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `staffProfileId` int NOT NULL,
  `benefitPlanId` int NOT NULL,
  `branchId` int DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `employeeContributionFixed` float NOT NULL DEFAULT '0',
  `employerContributionFixed` float NOT NULL DEFAULT '0',
  `startMonth` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endMonth` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_f8fb3e0fc07a8ebf40edea22685` (`staffProfileId`),
  KEY `FK_e7f1511956ad45907279af10b54` (`benefitPlanId`),
  CONSTRAINT `FK_e7f1511956ad45907279af10b54` FOREIGN KEY (`benefitPlanId`) REFERENCES `payroll_benefit_plan` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_f8fb3e0fc07a8ebf40edea22685` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_benefit_enrollment`
--

LOCK TABLES `payroll_benefit_enrollment` WRITE;
/*!40000 ALTER TABLE `payroll_benefit_enrollment` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_benefit_enrollment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_benefit_plan`
--

DROP TABLE IF EXISTS `payroll_benefit_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_benefit_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kind` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'benefit',
  `employeeRate` float NOT NULL DEFAULT '0',
  `employerRate` float NOT NULL DEFAULT '0',
  `maxEmployeeContribution` float NOT NULL DEFAULT '0',
  `maxEmployerContribution` float NOT NULL DEFAULT '0',
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `effectiveFrom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_benefit_plan`
--

LOCK TABLES `payroll_benefit_plan` WRITE;
/*!40000 ALTER TABLE `payroll_benefit_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_benefit_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_fx_rate`
--

DROP TABLE IF EXISTS `payroll_fx_rate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_fx_rate` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `month` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fromCurrency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `toCurrency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate` float NOT NULL,
  `source` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_fx_rate`
--

LOCK TABLES `payroll_fx_rate` WRITE;
/*!40000 ALTER TABLE `payroll_fx_rate` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_fx_rate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_loan`
--

DROP TABLE IF EXISTS `payroll_loan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_loan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `staffProfileId` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `principal` float NOT NULL DEFAULT '0',
  `balance` float NOT NULL DEFAULT '0',
  `monthlyDeduction` float NOT NULL DEFAULT '0',
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `startMonth` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endMonth` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_5580e07b3a496e3e8348da326aa` (`staffProfileId`),
  CONSTRAINT `FK_5580e07b3a496e3e8348da326aa` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_loan`
--

LOCK TABLES `payroll_loan` WRITE;
/*!40000 ALTER TABLE `payroll_loan` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_loan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_loan_repayment`
--

DROP TABLE IF EXISTS `payroll_loan_repayment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_loan_repayment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `loanId` int NOT NULL,
  `payrollRunId` int DEFAULT NULL,
  `staffProfileId` int DEFAULT NULL,
  `month` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` float NOT NULL DEFAULT '0',
  `remainingBalance` float NOT NULL DEFAULT '0',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_f57b14fd3269b816fca1f1943c6` (`loanId`),
  KEY `FK_6d74d4f0c6a521fbc7654b86d04` (`payrollRunId`),
  CONSTRAINT `FK_6d74d4f0c6a521fbc7654b86d04` FOREIGN KEY (`payrollRunId`) REFERENCES `payroll_run` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_f57b14fd3269b816fca1f1943c6` FOREIGN KEY (`loanId`) REFERENCES `payroll_loan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_loan_repayment`
--

LOCK TABLES `payroll_loan_repayment` WRITE;
/*!40000 ALTER TABLE `payroll_loan_repayment` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_loan_repayment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_run`
--

DROP TABLE IF EXISTS `payroll_run`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_run` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `month` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `baseCurrencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `generatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `generatedByUserId` int DEFAULT NULL,
  `approvalRequestedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvalRequestedByUserId` int DEFAULT NULL,
  `approvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvedByUserId` int DEFAULT NULL,
  `rejectedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rejectedByUserId` int DEFAULT NULL,
  `rejectionReason` text COLLATE utf8mb4_unicode_ci,
  `paidAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paidByUserId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_5add0d6c0f47afde06f78a449c7` (`branchId`),
  KEY `FK_fc35a0350e59549001b8ccea560` (`createdByUserId`),
  CONSTRAINT `FK_5add0d6c0f47afde06f78a449c7` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_fc35a0350e59549001b8ccea560` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_run`
--

LOCK TABLES `payroll_run` WRITE;
/*!40000 ALTER TABLE `payroll_run` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_run` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_run_approval_log`
--

DROP TABLE IF EXISTS `payroll_run_approval_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_run_approval_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payrollRunId` int NOT NULL,
  `branchId` int DEFAULT NULL,
  `actorUserId` int DEFAULT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `metadataJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_9aa9d27c6bda37d916256a84043` (`payrollRunId`),
  KEY `FK_00eb5eec683bac7e1b4409f82f7` (`actorUserId`),
  CONSTRAINT `FK_00eb5eec683bac7e1b4409f82f7` FOREIGN KEY (`actorUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_9aa9d27c6bda37d916256a84043` FOREIGN KEY (`payrollRunId`) REFERENCES `payroll_run` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_run_approval_log`
--

LOCK TABLES `payroll_run_approval_log` WRITE;
/*!40000 ALTER TABLE `payroll_run_approval_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_run_approval_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_run_item`
--

DROP TABLE IF EXISTS `payroll_run_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_run_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payrollRunId` int NOT NULL,
  `staffProfileId` int NOT NULL,
  `payrollStructureId` int NOT NULL,
  `branchId` int DEFAULT NULL,
  `basicSalary` float NOT NULL DEFAULT '0',
  `allowances` float NOT NULL DEFAULT '0',
  `overtimeHours` float NOT NULL DEFAULT '0',
  `overtimePay` float NOT NULL DEFAULT '0',
  `deductions` float NOT NULL DEFAULT '0',
  `gross` float NOT NULL DEFAULT '0',
  `net` float NOT NULL DEFAULT '0',
  `metadataJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `taxDeduction` float NOT NULL DEFAULT '0',
  `benefitDeduction` float NOT NULL DEFAULT '0',
  `pensionEmployeeDeduction` float NOT NULL DEFAULT '0',
  `loanDeduction` float NOT NULL DEFAULT '0',
  `employerBenefitContribution` float NOT NULL DEFAULT '0',
  `pensionEmployerContribution` float NOT NULL DEFAULT '0',
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fxRateToBranch` float NOT NULL DEFAULT '1',
  `grossBase` float NOT NULL DEFAULT '0',
  `netBase` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_a4c5ba9433eaa424065859c4701` (`payrollRunId`),
  KEY `FK_4fad67a55b590f08d1e96a06942` (`staffProfileId`),
  KEY `FK_0014e0ffd68ca6a77b9f414e5ce` (`payrollStructureId`),
  CONSTRAINT `FK_0014e0ffd68ca6a77b9f414e5ce` FOREIGN KEY (`payrollStructureId`) REFERENCES `payroll_structure` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_4fad67a55b590f08d1e96a06942` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_a4c5ba9433eaa424065859c4701` FOREIGN KEY (`payrollRunId`) REFERENCES `payroll_run` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_run_item`
--

LOCK TABLES `payroll_run_item` WRITE;
/*!40000 ALTER TABLE `payroll_run_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_run_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_structure`
--

DROP TABLE IF EXISTS `payroll_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_structure` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `staffProfileId` int NOT NULL,
  `basicSalary` float NOT NULL DEFAULT '0',
  `allowances` float NOT NULL DEFAULT '0',
  `deductions` float NOT NULL DEFAULT '0',
  `period` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `netSalary` float NOT NULL DEFAULT '0',
  `remarks` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `effectiveFrom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fxRateToBranch` float NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `FK_24a59b66e172eb3554a8b9fc623` (`staffProfileId`),
  CONSTRAINT `FK_24a59b66e172eb3554a8b9fc623` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_structure`
--

LOCK TABLES `payroll_structure` WRITE;
/*!40000 ALTER TABLE `payroll_structure` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_structure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_tax_table`
--

DROP TABLE IF EXISTS `payroll_tax_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_tax_table` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `countryCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currencyCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `effectiveFrom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `bracketsJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_tax_table`
--

LOCK TABLES `payroll_tax_table` WRITE;
/*!40000 ALTER TABLE `payroll_tax_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_tax_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotion_record`
--

DROP TABLE IF EXISTS `promotion_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promotion_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `promotionRunId` int NOT NULL,
  `studentId` int NOT NULL,
  `fromGrade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `toGrade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `decision` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'promoted',
  `toSectionId` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_575212720d0367a50f329c42256` (`promotionRunId`),
  KEY `FK_68953055e4801761d24d9dad593` (`studentId`),
  CONSTRAINT `FK_575212720d0367a50f329c42256` FOREIGN KEY (`promotionRunId`) REFERENCES `promotion_run` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_68953055e4801761d24d9dad593` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotion_record`
--

LOCK TABLES `promotion_record` WRITE;
/*!40000 ALTER TABLE `promotion_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotion_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotion_run`
--

DROP TABLE IF EXISTS `promotion_run`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promotion_run` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `fromGrade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `toGrade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rulesJson` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `appliedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_ceae78da4b4dd17daa6e64d53d7` (`branchId`),
  CONSTRAINT `FK_ceae78da4b4dd17daa6e64d53d7` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotion_run`
--

LOCK TABLES `promotion_run` WRITE;
/*!40000 ALTER TABLE `promotion_run` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotion_run` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_order`
--

DROP TABLE IF EXISTS `purchase_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `itemId` int NOT NULL,
  `quantity` float NOT NULL DEFAULT '0',
  `unitPrice` float NOT NULL DEFAULT '0',
  `totalPrice` float NOT NULL DEFAULT '0',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `vendor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vendorId` int DEFAULT NULL,
  `orderDate` date NOT NULL,
  `expectedDeliveryDate` date DEFAULT NULL,
  `receivedDate` date DEFAULT NULL,
  `receivedAcceptedQty` float NOT NULL DEFAULT '0',
  `receivedRejectedQty` float NOT NULL DEFAULT '0',
  `createdByUserId` int DEFAULT NULL,
  `receivedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_faea61bb23c7e8294b76ee8fb1d` (`itemId`),
  KEY `FK_0cfd30f4aadb68debc6a32554c1` (`vendorId`),
  CONSTRAINT `FK_0cfd30f4aadb68debc6a32554c1` FOREIGN KEY (`vendorId`) REFERENCES `vendor` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_faea61bb23c7e8294b76ee8fb1d` FOREIGN KEY (`itemId`) REFERENCES `inventory_item` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_order`
--

LOCK TABLES `purchase_order` WRITE;
/*!40000 ALTER TABLE `purchase_order` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_order_receipt`
--

DROP TABLE IF EXISTS `purchase_order_receipt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_order_receipt` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `purchaseOrderId` int NOT NULL,
  `acceptedQty` float NOT NULL DEFAULT '0',
  `rejectedQty` float NOT NULL DEFAULT '0',
  `receivedDate` date NOT NULL,
  `receivedByUserId` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_19c174d75f7980641e093fb2867` (`purchaseOrderId`),
  CONSTRAINT `FK_19c174d75f7980641e093fb2867` FOREIGN KEY (`purchaseOrderId`) REFERENCES `purchase_order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_order_receipt`
--

LOCK TABLES `purchase_order_receipt` WRITE;
/*!40000 ALTER TABLE `purchase_order_receipt` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_order_receipt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz`
--

DROP TABLE IF EXISTS `quiz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `sectionId` int DEFAULT NULL,
  `subjectId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `dueAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `questionsJson` text COLLATE utf8mb4_unicode_ci,
  `settingsJson` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_7ed0fe545641820f6c3c4a571b5` (`branchId`),
  KEY `FK_fae23175c0a2c0db63f4ff689fb` (`sectionId`),
  KEY `FK_51ef827d0bf4efecd202aab034c` (`subjectId`),
  CONSTRAINT `FK_51ef827d0bf4efecd202aab034c` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_7ed0fe545641820f6c3c4a571b5` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_fae23175c0a2c0db63f4ff689fb` FOREIGN KEY (`sectionId`) REFERENCES `class_section` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz`
--

LOCK TABLES `quiz` WRITE;
/*!40000 ALTER TABLE `quiz` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_attempt`
--

DROP TABLE IF EXISTS `quiz_attempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_attempt` (
  `id` int NOT NULL AUTO_INCREMENT,
  `quizId` int NOT NULL,
  `studentId` int NOT NULL,
  `answersJson` text COLLATE utf8mb4_unicode_ci,
  `score` float DEFAULT NULL,
  `submittedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_6df8c7e41f7c5db85548efdb4fa` (`quizId`),
  KEY `FK_0840cee6a6213b3d285c044afa3` (`studentId`),
  CONSTRAINT `FK_0840cee6a6213b3d285c044afa3` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_6df8c7e41f7c5db85548efdb4fa` FOREIGN KEY (`quizId`) REFERENCES `quiz` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_attempt`
--

LOCK TABLES `quiz_attempt` WRITE;
/*!40000 ALTER TABLE `quiz_attempt` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz_attempt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_background_check`
--

DROP TABLE IF EXISTS `recruitment_background_check`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_background_check` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `applicationId` int NOT NULL,
  `provider` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reportUrl` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `requestedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_10f723f8044b3956f0ccca82da0` (`branchId`),
  KEY `FK_a7603fe4a3222d3903201948a20` (`applicationId`),
  KEY `FK_331850d85e6f1ddbe1c7fc1a17a` (`createdByUserId`),
  CONSTRAINT `FK_10f723f8044b3956f0ccca82da0` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_331850d85e6f1ddbe1c7fc1a17a` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_a7603fe4a3222d3903201948a20` FOREIGN KEY (`applicationId`) REFERENCES `job_application` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_background_check`
--

LOCK TABLES `recruitment_background_check` WRITE;
/*!40000 ALTER TABLE `recruitment_background_check` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_background_check` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_interview`
--

DROP TABLE IF EXISTS `recruitment_interview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_interview` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `jobPostingId` int NOT NULL,
  `applicationId` int NOT NULL,
  `scheduledAt` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `durationMinutes` int NOT NULL DEFAULT '30',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meetingUrl` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `interviewerUserIdsJson` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `calendarUid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_683816829caf7490a760eafa2dd` (`branchId`),
  KEY `FK_dd2c2fc95b7696e82eca1a5c7d6` (`jobPostingId`),
  KEY `FK_b5ec629c17fc35f30f14fe1011f` (`applicationId`),
  KEY `FK_1af14945154abc10204ac02c5ad` (`createdByUserId`),
  CONSTRAINT `FK_1af14945154abc10204ac02c5ad` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_683816829caf7490a760eafa2dd` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_b5ec629c17fc35f30f14fe1011f` FOREIGN KEY (`applicationId`) REFERENCES `job_application` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_dd2c2fc95b7696e82eca1a5c7d6` FOREIGN KEY (`jobPostingId`) REFERENCES `job_posting` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_interview`
--

LOCK TABLES `recruitment_interview` WRITE;
/*!40000 ALTER TABLE `recruitment_interview` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_interview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_offer`
--

DROP TABLE IF EXISTS `recruitment_offer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_offer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `jobPostingId` int NOT NULL,
  `applicationId` int NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `letterHtml` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `compensationJson` text COLLATE utf8mb4_unicode_ci,
  `expiresAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sentAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `respondedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_ae9e98a7c4176c37badee8dd9b6` (`branchId`),
  KEY `FK_7c23bc920275e47fd291aeb3105` (`jobPostingId`),
  KEY `FK_48c2d05b2b5e388f83392b773aa` (`applicationId`),
  KEY `FK_fbf3e0c01929daea411816afce3` (`createdByUserId`),
  CONSTRAINT `FK_48c2d05b2b5e388f83392b773aa` FOREIGN KEY (`applicationId`) REFERENCES `job_application` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_7c23bc920275e47fd291aeb3105` FOREIGN KEY (`jobPostingId`) REFERENCES `job_posting` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_ae9e98a7c4176c37badee8dd9b6` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_fbf3e0c01929daea411816afce3` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_offer`
--

LOCK TABLES `recruitment_offer` WRITE;
/*!40000 ALTER TABLE `recruitment_offer` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_offer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_pipeline_stage`
--

DROP TABLE IF EXISTS `recruitment_pipeline_stage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_pipeline_stage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `jobPostingId` int DEFAULT NULL,
  `stageKey` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sortOrder` int NOT NULL DEFAULT '0',
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'screening',
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_84b0e28f3f72d18778bfe856279` (`branchId`),
  KEY `FK_dccdba249849956f06e215c6e66` (`jobPostingId`),
  CONSTRAINT `FK_84b0e28f3f72d18778bfe856279` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_dccdba249849956f06e215c6e66` FOREIGN KEY (`jobPostingId`) REFERENCES `job_posting` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_pipeline_stage`
--

LOCK TABLES `recruitment_pipeline_stage` WRITE;
/*!40000 ALTER TABLE `recruitment_pipeline_stage` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_pipeline_stage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_portal_token`
--

DROP TABLE IF EXISTS `recruitment_portal_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_portal_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `applicationId` int NOT NULL,
  `tokenHash` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiresAt` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastUsedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_70d9929a5568801a987069417f7` (`applicationId`),
  CONSTRAINT `FK_70d9929a5568801a987069417f7` FOREIGN KEY (`applicationId`) REFERENCES `job_application` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_portal_token`
--

LOCK TABLES `recruitment_portal_token` WRITE;
/*!40000 ALTER TABLE `recruitment_portal_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_portal_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_scorecard_submission`
--

DROP TABLE IF EXISTS `recruitment_scorecard_submission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_scorecard_submission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `applicationId` int NOT NULL,
  `interviewId` int DEFAULT NULL,
  `templateId` int DEFAULT NULL,
  `reviewerUserId` int DEFAULT NULL,
  `scoresJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `recommendation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `overallScore` float DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_970f49b53379e6d43b8a4159e62` (`branchId`),
  KEY `FK_9fd484cb6220f032740e4ed11cb` (`applicationId`),
  KEY `FK_909516c5e30e61fa9db0d9c1770` (`interviewId`),
  KEY `FK_daa3213208680ff31c6a765c8a7` (`templateId`),
  KEY `FK_f434fdb7827a715aafab70368ef` (`reviewerUserId`),
  CONSTRAINT `FK_909516c5e30e61fa9db0d9c1770` FOREIGN KEY (`interviewId`) REFERENCES `recruitment_interview` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_970f49b53379e6d43b8a4159e62` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_9fd484cb6220f032740e4ed11cb` FOREIGN KEY (`applicationId`) REFERENCES `job_application` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_daa3213208680ff31c6a765c8a7` FOREIGN KEY (`templateId`) REFERENCES `recruitment_scorecard_template` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_f434fdb7827a715aafab70368ef` FOREIGN KEY (`reviewerUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_scorecard_submission`
--

LOCK TABLES `recruitment_scorecard_submission` WRITE;
/*!40000 ALTER TABLE `recruitment_scorecard_submission` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_scorecard_submission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_scorecard_template`
--

DROP TABLE IF EXISTS `recruitment_scorecard_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_scorecard_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `criteriaJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_scorecard_template`
--

LOCK TABLES `recruitment_scorecard_template` WRITE;
/*!40000 ALTER TABLE `recruitment_scorecard_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `recruitment_scorecard_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_run`
--

DROP TABLE IF EXISTS `report_run`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_run` (
  `id` int NOT NULL AUTO_INCREMENT,
  `templateId` int NOT NULL,
  `triggeredByUserId` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'running',
  `startedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `outputFormat` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'json',
  `outputJson` text COLLATE utf8mb4_unicode_ci,
  `outputCsv` text COLLATE utf8mb4_unicode_ci,
  `error` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_59846430a07b75c501cffc04522` (`templateId`),
  KEY `FK_4c56bfa68d750ec3b5b866c5c58` (`triggeredByUserId`),
  CONSTRAINT `FK_4c56bfa68d750ec3b5b866c5c58` FOREIGN KEY (`triggeredByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_59846430a07b75c501cffc04522` FOREIGN KEY (`templateId`) REFERENCES `report_template` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_run`
--

LOCK TABLES `report_run` WRITE;
/*!40000 ALTER TABLE `report_run` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_run` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_template`
--

DROP TABLE IF EXISTS `report_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reportType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `configJson` text COLLATE utf8mb4_unicode_ci,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `scheduleCron` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nextRunAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_37b9a4c609eefc7ea67e36e4e82` (`branchId`),
  KEY `FK_61e474e95c9f766222562078a89` (`createdByUserId`),
  CONSTRAINT `FK_37b9a4c609eefc7ea67e36e4e82` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_61e474e95c9f766222562078a89` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_template`
--

LOCK TABLES `report_template` WRITE;
/*!40000 ALTER TABLE `report_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff_attendance`
--

DROP TABLE IF EXISTS `staff_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `userId` int NOT NULL,
  `attendanceDate` date NOT NULL,
  `checkInTime` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `checkOutTime` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'present',
  `captureMethod` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `location` text COLLATE utf8mb4_unicode_ci,
  `geofenceStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unknown',
  `lateMinutes` int DEFAULT NULL,
  `leftEarlyMinutes` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `dutyNotes` text COLLATE utf8mb4_unicode_ci,
  `overtimeHours` float DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_58f5504bd79b699d70b17bb7794` (`userId`),
  CONSTRAINT `FK_58f5504bd79b699d70b17bb7794` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff_attendance`
--

LOCK TABLES `staff_attendance` WRITE;
/*!40000 ALTER TABLE `staff_attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `staff_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff_credential`
--

DROP TABLE IF EXISTS `staff_credential`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_credential` (
  `id` int NOT NULL AUTO_INCREMENT,
  `staffProfileId` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issuer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issuedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiresAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creditHours` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_882bb7488bd5cf71a9577bbab0e` (`staffProfileId`),
  CONSTRAINT `FK_882bb7488bd5cf71a9577bbab0e` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff_credential`
--

LOCK TABLES `staff_credential` WRITE;
/*!40000 ALTER TABLE `staff_credential` DISABLE KEYS */;
/*!40000 ALTER TABLE `staff_credential` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff_duty_roster`
--

DROP TABLE IF EXISTS `staff_duty_roster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_duty_roster` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `userId` int NOT NULL,
  `rosterDate` date NOT NULL,
  `shiftStart` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shiftEnd` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_e2c6fa805a4e2c35cfdf96e8ce9` (`userId`),
  CONSTRAINT `FK_e2c6fa805a4e2c35cfdf96e8ce9` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff_duty_roster`
--

LOCK TABLES `staff_duty_roster` WRITE;
/*!40000 ALTER TABLE `staff_duty_roster` DISABLE KEYS */;
/*!40000 ALTER TABLE `staff_duty_roster` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff_profile`
--

DROP TABLE IF EXISTS `staff_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_profile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `position` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hireDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `employmentType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `managerName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `skills` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `bankAccountHolderName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankAccountNumber` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankRoutingCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_0a00db0c8a3ba226bcffc2bd147` (`branchId`),
  KEY `FK_dcf4c54c6e051cb725aa69304df` (`userId`),
  CONSTRAINT `FK_0a00db0c8a3ba226bcffc2bd147` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_dcf4c54c6e051cb725aa69304df` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff_profile`
--

LOCK TABLES `staff_profile` WRITE;
/*!40000 ALTER TABLE `staff_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `staff_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `sectionId` int DEFAULT NULL,
  `firstName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Grade 1',
  `dateOfBirth` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `emergencyContact` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `healthNotes` text COLLATE utf8mb4_unicode_ci,
  `behaviourSummary` text COLLATE utf8mb4_unicode_ci,
  `extracurriculars` text COLLATE utf8mb4_unicode_ci,
  `academicSummary` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_a56c051c91dbe1068ad683f536` (`email`),
  KEY `FK_5f94399d84bb398de83e414cb0f` (`branchId`),
  KEY `FK_430e8c066063ef82018539fb5e9` (`sectionId`),
  CONSTRAINT `FK_430e8c066063ef82018539fb5e9` FOREIGN KEY (`sectionId`) REFERENCES `class_section` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_5f94399d84bb398de83e414cb0f` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_branch_history`
--

DROP TABLE IF EXISTS `student_branch_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_branch_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `studentId` int NOT NULL,
  `fromBranchId` int DEFAULT NULL,
  `toBranchId` int DEFAULT NULL,
  `transferredByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_ef256f838f6436dcf491963cf47` (`studentId`),
  KEY `FK_d1be9b2d3d9f414cd30b47e8e61` (`transferredByUserId`),
  CONSTRAINT `FK_d1be9b2d3d9f414cd30b47e8e61` FOREIGN KEY (`transferredByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_ef256f838f6436dcf491963cf47` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_branch_history`
--

LOCK TABLES `student_branch_history` WRITE;
/*!40000 ALTER TABLE `student_branch_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_branch_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_timeline_event`
--

DROP TABLE IF EXISTS `student_timeline_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_timeline_event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `studentId` int NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `occurredAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `metadataJson` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_6b174bb1ddde6dc5efcfe139c1b` (`studentId`),
  KEY `FK_4791c47815ab2cc2ebc1533ba7a` (`createdByUserId`),
  CONSTRAINT `FK_4791c47815ab2cc2ebc1533ba7a` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_6b174bb1ddde6dc5efcfe139c1b` FOREIGN KEY (`studentId`) REFERENCES `student` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_timeline_event`
--

LOCK TABLES `student_timeline_event` WRITE;
/*!40000 ALTER TABLE `student_timeline_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_timeline_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_material`
--

DROP TABLE IF EXISTS `study_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_material` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `courseId` int DEFAULT NULL,
  `subjectId` int DEFAULT NULL,
  `materialType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `version` int NOT NULL DEFAULT '1',
  `previousMaterialId` int DEFAULT NULL,
  `releaseAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiresAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `accessCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `downloadCount` int NOT NULL DEFAULT '0',
  `active` tinyint NOT NULL DEFAULT '1',
  `uploadedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_970098c35675223ab2cb1f204f` (`accessCode`),
  KEY `FK_81cde3e2436dbab4624cabcad47` (`branchId`),
  KEY `FK_e3b7a01177b31c85aa330c2880c` (`uploadedByUserId`),
  CONSTRAINT `FK_81cde3e2436dbab4624cabcad47` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_e3b7a01177b31c85aa330c2880c` FOREIGN KEY (`uploadedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_material`
--

LOCK TABLES `study_material` WRITE;
/*!40000 ALTER TABLE `study_material` DISABLE KEYS */;
/*!40000 ALTER TABLE `study_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject`
--

DROP TABLE IF EXISTS `subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Grade 1',
  `description` text COLLATE utf8mb4_unicode_ci,
  `standard` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isElective` tinyint NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_92374adc6b583e8cf659977e48` (`code`),
  KEY `FK_a6523932eb599c6f7ea15dda446` (`branchId`),
  CONSTRAINT `FK_a6523932eb599c6f7ea15dda446` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject`
--

LOCK TABLES `subject` WRITE;
/*!40000 ALTER TABLE `subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey`
--

DROP TABLE IF EXISTS `survey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `questions` text COLLATE utf8mb4_unicode_ci,
  `targetAudience` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `anonymousAllowed` tinyint NOT NULL DEFAULT '0',
  `startDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_02b469487765976d92f7656344d` (`branchId`),
  KEY `FK_70fb7a0541cecc43e376f0eebce` (`createdByUserId`),
  CONSTRAINT `FK_02b469487765976d92f7656344d` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_70fb7a0541cecc43e376f0eebce` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey`
--

LOCK TABLES `survey` WRITE;
/*!40000 ALTER TABLE `survey` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_distribution`
--

DROP TABLE IF EXISTS `survey_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_distribution` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `surveyId` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'inapp',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `filterJson` text COLLATE utf8mb4_unicode_ci,
  `invitedCount` int NOT NULL DEFAULT '0',
  `sentCount` int NOT NULL DEFAULT '0',
  `openedCount` int NOT NULL DEFAULT '0',
  `completedCount` int NOT NULL DEFAULT '0',
  `failedCount` int NOT NULL DEFAULT '0',
  `sendAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `messageTemplate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_9cea0f5fd8fb8d1ec878a0f1379` (`surveyId`),
  KEY `FK_bb00c0e9ecad887a0db07ba2e7a` (`createdByUserId`),
  CONSTRAINT `FK_9cea0f5fd8fb8d1ec878a0f1379` FOREIGN KEY (`surveyId`) REFERENCES `survey` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_bb00c0e9ecad887a0db07ba2e7a` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_distribution`
--

LOCK TABLES `survey_distribution` WRITE;
/*!40000 ALTER TABLE `survey_distribution` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_distribution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_invite`
--

DROP TABLE IF EXISTS `survey_invite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_invite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `distributionId` int NOT NULL,
  `surveyId` int NOT NULL,
  `userId` int DEFAULT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'queued',
  `sentAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `openedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `responseId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_71ce1d578385f67b8992b180f4b` (`distributionId`),
  KEY `FK_bf4c6c11fe09c365febacc5a3d9` (`surveyId`),
  KEY `FK_7a812f27eeda336c31af1b8f74b` (`userId`),
  KEY `FK_882d6afd02183fb0893d5f0e2a3` (`responseId`),
  CONSTRAINT `FK_71ce1d578385f67b8992b180f4b` FOREIGN KEY (`distributionId`) REFERENCES `survey_distribution` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_7a812f27eeda336c31af1b8f74b` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_882d6afd02183fb0893d5f0e2a3` FOREIGN KEY (`responseId`) REFERENCES `survey_response` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_bf4c6c11fe09c365febacc5a3d9` FOREIGN KEY (`surveyId`) REFERENCES `survey` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_invite`
--

LOCK TABLES `survey_invite` WRITE;
/*!40000 ALTER TABLE `survey_invite` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_invite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_response`
--

DROP TABLE IF EXISTS `survey_response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_response` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `surveyId` int NOT NULL,
  `userId` int DEFAULT NULL,
  `isAnonymous` tinyint NOT NULL DEFAULT '0',
  `answers` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `submittedAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_325dc8ed7bbdea328af1670dc0a` (`surveyId`),
  KEY `FK_6f270d46c6b0e0b68373a417c5a` (`userId`),
  CONSTRAINT `FK_325dc8ed7bbdea328af1670dc0a` FOREIGN KEY (`surveyId`) REFERENCES `survey` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_6f270d46c6b0e0b68373a417c5a` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_response`
--

LOCK TABLES `survey_response` WRITE;
/*!40000 ALTER TABLE `survey_response` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_response` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timetable_entry`
--

DROP TABLE IF EXISTS `timetable_entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetable_entry` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sectionId` int NOT NULL,
  `subjectId` int DEFAULT NULL,
  `dayOfWeek` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Monday',
  `period` int NOT NULL,
  `room` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `teacherName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_91f76ecedf30ebbbd7df3d0ae23` (`sectionId`),
  KEY `FK_29552ec1d91c035654a37e88957` (`subjectId`),
  CONSTRAINT `FK_29552ec1d91c035654a37e88957` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_91f76ecedf30ebbbd7df3d0ae23` FOREIGN KEY (`sectionId`) REFERENCES `class_section` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetable_entry`
--

LOCK TABLES `timetable_entry` WRITE;
/*!40000 ALTER TABLE `timetable_entry` DISABLE KEYS */;
/*!40000 ALTER TABLE `timetable_entry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `training_assignment`
--

DROP TABLE IF EXISTS `training_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_assignment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `courseId` int NOT NULL,
  `staffProfileId` int NOT NULL,
  `assignedByUserId` int DEFAULT NULL,
  `dueDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'assigned',
  `completedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certificateDocumentId` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_f09d801de944e76fb230910aadd` (`courseId`),
  KEY `FK_9a240b4f3b4e75dc9f51aa638f4` (`staffProfileId`),
  KEY `FK_e06c7fa4802f7ec74523b374224` (`assignedByUserId`),
  KEY `FK_cbfa6eff9e57e0e2504cc9e6c2c` (`certificateDocumentId`),
  CONSTRAINT `FK_9a240b4f3b4e75dc9f51aa638f4` FOREIGN KEY (`staffProfileId`) REFERENCES `staff_profile` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_cbfa6eff9e57e0e2504cc9e6c2c` FOREIGN KEY (`certificateDocumentId`) REFERENCES `document_record` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_e06c7fa4802f7ec74523b374224` FOREIGN KEY (`assignedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_f09d801de944e76fb230910aadd` FOREIGN KEY (`courseId`) REFERENCES `training_course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_assignment`
--

LOCK TABLES `training_assignment` WRITE;
/*!40000 ALTER TABLE `training_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `training_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `training_course`
--

DROP TABLE IF EXISTS `training_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_course` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `competencyTags` text COLLATE utf8mb4_unicode_ci,
  `durationHours` float DEFAULT NULL,
  `isActive` tinyint NOT NULL DEFAULT '1',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_78cdc19c94d6adbd13b263d109f` (`branchId`),
  KEY `FK_0cf9a3ae2ba195aa6bf466b6a03` (`createdByUserId`),
  CONSTRAINT `FK_0cf9a3ae2ba195aa6bf466b6a03` FOREIGN KEY (`createdByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_78cdc19c94d6adbd13b263d109f` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_course`
--

LOCK TABLES `training_course` WRITE;
/*!40000 ALTER TABLE `training_course` DISABLE KEYS */;
/*!40000 ALTER TABLE `training_course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_geofence`
--

DROP TABLE IF EXISTS `transport_geofence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_geofence` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `routeId` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'circle',
  `centerLat` float DEFAULT NULL,
  `centerLng` float DEFAULT NULL,
  `radiusMeters` float DEFAULT NULL,
  `polygonJson` text COLLATE utf8mb4_unicode_ci,
  `notifyOn` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'enter_exit',
  `notifyAudience` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'staff',
  `active` tinyint NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_geofence`
--

LOCK TABLES `transport_geofence` WRITE;
/*!40000 ALTER TABLE `transport_geofence` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_geofence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_geofence_event`
--

DROP TABLE IF EXISTS `transport_geofence_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_geofence_event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `routeId` int NOT NULL,
  `geofenceId` int NOT NULL,
  `eventType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'enter',
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `occurredAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notified` tinyint NOT NULL DEFAULT '0',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_geofence_event`
--

LOCK TABLES `transport_geofence_event` WRITE;
/*!40000 ALTER TABLE `transport_geofence_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_geofence_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_incident`
--

DROP TABLE IF EXISTS `transport_incident`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_incident` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `routeId` int NOT NULL,
  `tripId` int DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'delay',
  `severity` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `occurredAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `reportedByUserId` int DEFAULT NULL,
  `resolutionNotes` text COLLATE utf8mb4_unicode_ci,
  `resolvedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolvedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_incident`
--

LOCK TABLES `transport_incident` WRITE;
/*!40000 ALTER TABLE `transport_incident` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_incident` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_location_ping`
--

DROP TABLE IF EXISTS `transport_location_ping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_location_ping` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `routeId` int NOT NULL,
  `lat` float NOT NULL,
  `lng` float NOT NULL,
  `speedKph` float DEFAULT NULL,
  `headingDeg` float DEFAULT NULL,
  `deviceId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recordedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_6e7606d9fb640ecf8b34c4f97bc` (`routeId`),
  CONSTRAINT `FK_6e7606d9fb640ecf8b34c4f97bc` FOREIGN KEY (`routeId`) REFERENCES `transport_route` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_location_ping`
--

LOCK TABLES `transport_location_ping` WRITE;
/*!40000 ALTER TABLE `transport_location_ping` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_location_ping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_maintenance_log`
--

DROP TABLE IF EXISTS `transport_maintenance_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_maintenance_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `routeId` int NOT NULL,
  `performedOn` date NOT NULL,
  `workDone` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `nextServiceDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completed',
  `performedByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_bf3840f841ffdc74defc7b0e012` (`routeId`),
  KEY `FK_e4356135205605df7e5c9d2a88e` (`performedByUserId`),
  CONSTRAINT `FK_bf3840f841ffdc74defc7b0e012` FOREIGN KEY (`routeId`) REFERENCES `transport_route` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_e4356135205605df7e5c9d2a88e` FOREIGN KEY (`performedByUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_maintenance_log`
--

LOCK TABLES `transport_maintenance_log` WRITE;
/*!40000 ALTER TABLE `transport_maintenance_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_maintenance_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_route`
--

DROP TABLE IF EXISTS `transport_route`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_route` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `routeName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pickupPoints` text COLLATE utf8mb4_unicode_ci,
  `vehicleNumber` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `driverName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacity` int NOT NULL DEFAULT '0',
  `active` tinyint NOT NULL DEFAULT '1',
  `maintenanceLogIds` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_route`
--

LOCK TABLES `transport_route` WRITE;
/*!40000 ALTER TABLE `transport_route` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_route` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport_trip`
--

DROP TABLE IF EXISTS `transport_trip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport_trip` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `routeId` int NOT NULL,
  `tripDate` date NOT NULL,
  `tripType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'morning',
  `startTime` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endTime` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `notes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_321be6519464bfebb15e9982f12` (`routeId`),
  CONSTRAINT `FK_321be6519464bfebb15e9982f12` FOREIGN KEY (`routeId`) REFERENCES `transport_route` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_trip`
--

LOCK TABLES `transport_trip` WRITE;
/*!40000 ALTER TABLE `transport_trip` DISABLE KEYS */;
/*!40000 ALTER TABLE `transport_trip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'staff',
  `isActive` tinyint NOT NULL DEFAULT '1',
  `tokenVersion` int NOT NULL DEFAULT '0',
  `lastLoginAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passwordChangedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passwordHash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `permissionsJson` text COLLATE utf8mb4_unicode_ci,
  `preferredCommChannel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commOptOutChannels` text COLLATE utf8mb4_unicode_ci,
  `failedLoginCount` int NOT NULL DEFAULT '0',
  `lockedUntil` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_e12875dfb3b1d92d7d7c5377e2` (`email`),
  KEY `FK_8b17d5d91bf27d0a33fb80ade8f` (`branchId`),
  CONSTRAINT `FK_8b17d5d91bf27d0a33fb80ade8f` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,NULL,'admin@local','stephen','staff',1,0,'2026-04-07T00:19:29.082Z','2026-04-06T16:49:31.467Z','$2a$10$mu/UEk7elgUYbqZY0wawZ.PoZGA1.CQI8i7MIQ9VzJ0q1bXY7lU4q',NULL,NULL,NULL,0,NULL,'2026-04-06 18:49:31.485977'),(2,NULL,'superadmin@zanaq.edu','Super Admin','superadmin',1,0,'2026-04-07T00:20:04.187Z','2026-04-06T17:03:53.729Z','$2a$10$Aim0eNCJ9LxPMNbkrXMyQezYYbTdNTYg84.5XfYuXSCQu51wgVYCm',NULL,NULL,NULL,0,NULL,'2026-04-06 19:03:53.799392');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor`
--

DROP TABLE IF EXISTS `vendor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contactPerson` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `createdByUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor`
--

LOCK TABLES `vendor` WRITE;
/*!40000 ALTER TABLE `vendor` DISABLE KEYS */;
/*!40000 ALTER TABLE `vendor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtual_session`
--

DROP TABLE IF EXISTS `virtual_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `virtual_session` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `sessionDate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `durationMinutes` int NOT NULL DEFAULT '0',
  `joinUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recordingUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recordingDocumentId` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `endedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attendanceCount` int NOT NULL DEFAULT '0',
  `hostUserId` int DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `FK_986b3d550c4f2e74616cfdb7ca1` (`branchId`),
  KEY `FK_c7bcfe23aea0969dde92a618417` (`hostUserId`),
  CONSTRAINT `FK_986b3d550c4f2e74616cfdb7ca1` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_c7bcfe23aea0969dde92a618417` FOREIGN KEY (`hostUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtual_session`
--

LOCK TABLES `virtual_session` WRITE;
/*!40000 ALTER TABLE `virtual_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtual_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook_delivery`
--

DROP TABLE IF EXISTS `webhook_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_delivery` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subscriptionId` int NOT NULL,
  `eventType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `eventCreatedAt` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bodyJson` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `attemptCount` int NOT NULL DEFAULT '0',
  `nextAttemptAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastAttemptAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastStatusCode` int DEFAULT NULL,
  `lastError` text COLLATE utf8mb4_unicode_ci,
  `deliveredAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_delivery`
--

LOCK TABLES `webhook_delivery` WRITE;
/*!40000 ALTER TABLE `webhook_delivery` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook_delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook_delivery_attempt`
--

DROP TABLE IF EXISTS `webhook_delivery_attempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_delivery_attempt` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deliveryId` int NOT NULL,
  `attemptNumber` int NOT NULL,
  `responseStatusCode` int DEFAULT NULL,
  `responseBodySnippet` text COLLATE utf8mb4_unicode_ci,
  `durationMs` int DEFAULT NULL,
  `errorMessage` text COLLATE utf8mb4_unicode_ci,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_delivery_attempt`
--

LOCK TABLES `webhook_delivery_attempt` WRITE;
/*!40000 ALTER TABLE `webhook_delivery_attempt` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook_delivery_attempt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook_subscription`
--

DROP TABLE IF EXISTS `webhook_subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_subscription` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `eventTypesJson` text COLLATE utf8mb4_unicode_ci,
  `secret` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint NOT NULL DEFAULT '1',
  `createdByUserId` int DEFAULT NULL,
  `rotatedAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastSuccessAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastFailureAt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_subscription`
--

LOCK TABLES `webhook_subscription` WRITE;
/*!40000 ALTER TABLE `webhook_subscription` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook_subscription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'zanaq_edu'
--

--
-- Dumping routines for database 'zanaq_edu'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:30:57
