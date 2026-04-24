-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: stephbt_db
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
-- Current Database: `stephbt_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `stephbt_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `stephbt_db`;

--
-- Table structure for table `bet_selections`
--

DROP TABLE IF EXISTS `bet_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bet_selections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `slip_id` int NOT NULL,
  `match_name` varchar(255) NOT NULL,
  `selection` varchar(255) NOT NULL,
  `market` varchar(100) DEFAULT NULL,
  `odds` decimal(10,2) NOT NULL,
  `match_time` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `slip_id` (`slip_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bet_selections`
--

LOCK TABLES `bet_selections` WRITE;
/*!40000 ALTER TABLE `bet_selections` DISABLE KEYS */;
INSERT INTO `bet_selections` VALUES (1,1,'19:00 vs Crystal Palace','1X','Double Chance',1.44,'19:00'),(2,1,'19:00 vs West Ham','Over 2.5','Total Goals',2.21,'19:00'),(3,1,'20:10 vs Paris FC','Over 2.5','Total Goals',1.74,'20:10'),(4,1,'19:45 vs Cremonese','19:45 Win','Match Result',1.32,'19:45'),(5,1,'20:00 vs Celta Vigo','Over 2.5','Total Goals',2.43,'20:00');
/*!40000 ALTER TABLE `bet_selections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bet_slips`
--

DROP TABLE IF EXISTS `bet_slips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bet_slips` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bet_code` varchar(20) NOT NULL,
  `total_odds` decimal(10,2) NOT NULL,
  `confidence` int DEFAULT NULL,
  `is_real_code` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bet_code` (`bet_code`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bet_slips`
--

LOCK TABLES `bet_slips` WRITE;
/*!40000 ALTER TABLE `bet_slips` DISABLE KEYS */;
INSERT INTO `bet_slips` VALUES (1,'SIM-BW1-790',17.76,76,0,'2026-01-12 18:13:23');
/*!40000 ALTER TABLE `bet_slips` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_performance`
--

DROP TABLE IF EXISTS `daily_performance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_performance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `total_bets` int DEFAULT '0',
  `wins` int DEFAULT '0',
  `losses` int DEFAULT '0',
  `total_staked` decimal(10,2) DEFAULT '0.00',
  `total_returned` decimal(10,2) DEFAULT '0.00',
  `roi` decimal(5,2) DEFAULT '0.00',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_performance`
--

LOCK TABLES `daily_performance` WRITE;
/*!40000 ALTER TABLE `daily_performance` DISABLE KEYS */;
/*!40000 ALTER TABLE `daily_performance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `market_snapshots`
--

DROP TABLE IF EXISTS `market_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `market_snapshots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `active_matches` int DEFAULT NULL,
  `avg_market_odds` decimal(10,2) DEFAULT NULL,
  `scanner_status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `market_snapshots`
--

LOCK TABLES `market_snapshots` WRITE;
/*!40000 ALTER TABLE `market_snapshots` DISABLE KEYS */;
/*!40000 ALTER TABLE `market_snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `level` varchar(10) NOT NULL,
  `component` varchar(50) DEFAULT NULL,
  `message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
INSERT INTO `system_logs` VALUES (1,'ERROR','Gemini','429 quota: {\"error\":{\"code\":429,\"message\":\"You exceeded your current quota, please check your plan and billing details. For more information on this error, head to: https://ai.google.dev/gemini-api/docs/rate-limits. To monitor your current usage, head to: https://ai.dev/rate-limit. \\n* Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_input_token_count, limit: 0, model: gemini-2.0-flash\\n* Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 0, model: gemini-2.0-flash\\n* Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 0, model: gemini-2.0-flash\\nPlease retry in 37.908583814s.\",\"status\":\"RESOURCE_EXHAUSTED\",\"details\":[{\"@type\":\"type.googleapis.com/google.rpc.Help\",\"links\":[{\"description\":\"Learn more about Gemini API quotas\",\"url\":\"https://ai.google.dev/gemini-api/docs/rate-limits\"}]},{\"@type\":\"type.googleapis.com/google.rpc.QuotaFailure\",\"violations\":[{\"quotaMetric\":\"generativelanguage.googleapis.com/generate_content_free_tier_input_token_count\",\"quotaId\":\"GenerateContentInputTokensPerModelPerMinute-FreeTier\",\"quotaDimensions\":{\"model\":\"gemini-2.0-flash\",\"location\":\"global\"}},{\"quotaMetric\":\"generativelanguage.googleapis.com/generate_content_free_tier_requests\",\"quotaId\":\"GenerateRequestsPerMinutePerProjectPerModel-FreeTier\",\"quotaDimensions\":{\"location\":\"global\",\"model\":\"gemini-2.0-flash\"}},{\"quotaMetric\":\"generativelanguage.googleapis.com/generate_content_free_tier_requests\",\"quotaId\":\"GenerateRequestsPerDayPerProjectPerModel-FreeTier\",\"quotaDimensions\":{\"location\":\"global\",\"model\":\"gemini-2.0-flash\"}}]},{\"@type\":\"type.googleapis.com/google.rpc.RetryInfo\",\"retryDelay\":\"37s\"}]}}','2026-01-12 10:01:19'),(2,'ERROR','Gemini','429 quota: {\"error\":{\"code\":429,\"message\":\"You exceeded your current quota, please check your plan and billing details. For more information on this error, head to: https://ai.google.dev/gemini-api/docs/rate-limits. To monitor your current usage, head to: https://ai.dev/rate-limit. \\n* Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 0, model: gemini-2.0-flash\\n* Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 0, model: gemini-2.0-flash\\n* Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_input_token_count, limit: 0, model: gemini-2.0-flash\\nPlease retry in 56.592078566s.\",\"status\":\"RESOURCE_EXHAUSTED\",\"details\":[{\"@type\":\"type.googleapis.com/google.rpc.Help\",\"links\":[{\"description\":\"Learn more about Gemini API quotas\",\"url\":\"https://ai.google.dev/gemini-api/docs/rate-limits\"}]},{\"@type\":\"type.googleapis.com/google.rpc.QuotaFailure\",\"violations\":[{\"quotaMetric\":\"generativelanguage.googleapis.com/generate_content_free_tier_requests\",\"quotaId\":\"GenerateRequestsPerDayPerProjectPerModel-FreeTier\",\"quotaDimensions\":{\"location\":\"global\",\"model\":\"gemini-2.0-flash\"}},{\"quotaMetric\":\"generativelanguage.googleapis.com/generate_content_free_tier_requests\",\"quotaId\":\"GenerateRequestsPerMinutePerProjectPerModel-FreeTier\",\"quotaDimensions\":{\"location\":\"global\",\"model\":\"gemini-2.0-flash\"}},{\"quotaMetric\":\"generativelanguage.googleapis.com/generate_content_free_tier_input_token_count\",\"quotaId\":\"GenerateContentInputTokensPerModelPerMinute-FreeTier\",\"quotaDimensions\":{\"location\":\"global\",\"model\":\"gemini-2.0-flash\"}}]},{\"@type\":\"type.googleapis.com/google.rpc.RetryInfo\",\"retryDelay\":\"56s\"}]}}','2026-01-12 10:02:00'),(3,'ERROR','Claude','Scan error: 400 {\"type\":\"error\",\"error\":{\"type\":\"invalid_request_error\",\"message\":\"Your credit balance is too low to access the Anthropic API. Please go to Plans & Billing to upgrade or purchase credits.\"},\"request_id\":\"req_011CX3UtNQYTaTXSxy42hZRX\"}','2026-01-12 12:26:34'),(4,'ERROR','Claude','Scan error: 400 {\"type\":\"error\",\"error\":{\"type\":\"invalid_request_error\",\"message\":\"Your credit balance is too low to access the Anthropic API. Please go to Plans & Billing to upgrade or purchase credits.\"},\"request_id\":\"req_011CX3Uwqb1NzJJ4BYKkCGvr\"}','2026-01-12 12:27:21'),(5,'ERROR','Server-Claude','Scan error: 400 {\"type\":\"error\",\"error\":{\"type\":\"invalid_request_error\",\"message\":\"Your credit balance is too low to access the Anthropic API. Please go to Plans & Billing to upgrade or purchase credits.\"},\"request_id\":\"req_011CX3XSLMPgj7h4AZr1VWdF\"}','2026-01-12 13:00:03'),(6,'ERROR','Claude-Service','Scan error: Server error: Internal Server Error','2026-01-12 13:00:05'),(7,'ERROR','Server-Claude','Scan error: 400 {\"type\":\"error\",\"error\":{\"type\":\"invalid_request_error\",\"message\":\"Your credit balance is too low to access the Anthropic API. Please go to Plans & Billing to upgrade or purchase credits.\"},\"request_id\":\"req_011CX3aJCvHohTvrkWVwZbu1\"}','2026-01-12 13:37:32'),(8,'ERROR','Server-Claude','Scan error: 400 {\"type\":\"error\",\"error\":{\"type\":\"invalid_request_error\",\"message\":\"Your credit balance is too low to access the Anthropic API. Please go to Plans & Billing to upgrade or purchase credits.\"},\"request_id\":\"req_011CX3eEBmgnF65xcLw9juDU\"}','2026-01-12 14:29:07'),(9,'ERROR','Server-Claude','Scan error: 400 {\"type\":\"error\",\"error\":{\"type\":\"invalid_request_error\",\"message\":\"Your credit balance is too low to access the Anthropic API. Please go to Plans & Billing to upgrade or purchase credits.\"},\"request_id\":\"req_011CX3vf46swWbBK21Jj5msa\"}','2026-01-12 18:04:34'),(10,'INFO','API','New bet saved: SIM-BW1-790','2026-01-12 18:13:23');
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'stephbt_db'
--

--
-- Dumping routines for database 'stephbt_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 12:30:47
