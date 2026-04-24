-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: banceasy_db
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
-- Current Database: `banceasy_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `banceasy_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `banceasy_db`;

--
-- Table structure for table `agent_profiles`
--

DROP TABLE IF EXISTS `agent_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_profiles` (
  `user_id` char(36) NOT NULL,
  `commission_rate` decimal(5,4) DEFAULT '0.0200',
  `total_commission_earned` decimal(12,2) DEFAULT '0.00',
  `successful_payouts` int DEFAULT '0',
  `target_group` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_profiles`
--

LOCK TABLES `agent_profiles` WRITE;
/*!40000 ALTER TABLE `agent_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `applications`
--

DROP TABLE IF EXISTS `applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `applications` (
  `id` char(36) NOT NULL,
  `client_id` char(36) NOT NULL,
  `ref_id` varchar(15) DEFAULT NULL,
  `ministry` varchar(100) NOT NULL,
  `ec_number` varchar(15) NOT NULL,
  `rank_` varchar(50) DEFAULT NULL,
  `grade` varchar(10) DEFAULT NULL,
  `net_salary` decimal(12,2) NOT NULL,
  `allowances` decimal(12,2) DEFAULT '0.00',
  `include_allowances` tinyint(1) DEFAULT '0',
  `loan_product_id` int DEFAULT NULL,
  `loan_amount` decimal(12,2) NOT NULL,
  `loan_period` int NOT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `interest_rate_at_submission` decimal(5,4) DEFAULT NULL,
  `status` enum('Pending','Verifying','Approved','Paid','Rejected') DEFAULT 'Pending',
  `rejection_reason` text,
  `verification_code` char(6) DEFAULT NULL,
  `assigned_to` char(36) DEFAULT NULL,
  `agent_id` char(36) DEFAULT NULL,
  `id_copy` longtext,
  `payslip` longtext,
  `confirmation_letter` longtext,
  `signature` longtext,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_at` timestamp NULL DEFAULT NULL,
  `disbursed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ref_id` (`ref_id`),
  KEY `client_id` (`client_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `agent_id` (`agent_id`),
  KEY `loan_product_id` (`loan_product_id`),
  KEY `idx_app_ec` (`ec_number`),
  KEY `idx_app_ref` (`ref_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applications`
--

LOCK TABLES `applications` WRITE;
/*!40000 ALTER TABLE `applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` char(36) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `national_id` varchar(20) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `source` enum('Organic','Imported','Walk-in') DEFAULT 'Organic',
  `is_otp_verified` tinyint(1) DEFAULT '0',
  `last_contacted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `national_id` (`national_id`),
  UNIQUE KEY `mobile` (`mobile`),
  KEY `idx_client_mobile` (`mobile`),
  KEY `idx_client_id` (`national_id`)
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
-- Table structure for table `loan_products`
--

DROP TABLE IF EXISTS `loan_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_name` varchar(50) NOT NULL,
  `min_amount` decimal(12,2) NOT NULL,
  `max_amount` decimal(12,2) NOT NULL,
  `default_interest_rate` decimal(5,4) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan_products`
--

LOCK TABLES `loan_products` WRITE;
/*!40000 ALTER TABLE `loan_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `loan_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loan_rate_matrix`
--

DROP TABLE IF EXISTS `loan_rate_matrix`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_rate_matrix` (
  `id` int NOT NULL AUTO_INCREMENT,
  `principal_amount` decimal(12,2) NOT NULL,
  `tenure_months` int NOT NULL,
  `monthly_installment` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `principal_amount` (`principal_amount`,`tenure_months`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan_rate_matrix`
--

LOCK TABLES `loan_rate_matrix` WRITE;
/*!40000 ALTER TABLE `loan_rate_matrix` DISABLE KEYS */;
INSERT INTO `loan_rate_matrix` VALUES (1,50.00,12,6.48),(2,100.00,12,12.96),(3,200.00,12,25.93),(4,300.00,12,38.89),(5,500.00,12,64.81),(6,1000.00,12,129.63),(7,2000.00,12,259.26);
/*!40000 ALTER TABLE `loan_rate_matrix` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ministries`
--

DROP TABLE IF EXISTS `ministries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ministries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ministries`
--

LOCK TABLES `ministries` WRITE;
/*!40000 ALTER TABLE `ministries` DISABLE KEYS */;
INSERT INTO `ministries` VALUES (1,'Primary & Secondary Education','2026-02-14 08:59:59'),(2,'Health & Child Care','2026-02-14 08:59:59'),(3,'Home Affairs (ZRP)','2026-02-14 08:59:59'),(4,'Defence (ZNA)','2026-02-14 08:59:59'),(5,'Higher & Tertiary Education','2026-02-14 08:59:59'),(6,'Public Service, Labour & Social Welfare','2026-02-14 08:59:59'),(7,'Local Government','2026-02-14 08:59:59'),(8,'Judicial Service Commission','2026-02-14 08:59:59'),(9,'Test Ministry 1771060056276','2026-02-14 09:07:36'),(10,'Test Ministry 1771060100747','2026-02-14 09:08:20');
/*!40000 ALTER TABLE `ministries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ranks`
--

DROP TABLE IF EXISTS `ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ranks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ministry_id` int NOT NULL,
  `rank_name` varchar(100) NOT NULL,
  `min_salary` decimal(12,2) DEFAULT NULL,
  `max_salary` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ministry_id` (`ministry_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ranks`
--

LOCK TABLES `ranks` WRITE;
/*!40000 ALTER TABLE `ranks` DISABLE KEYS */;
/*!40000 ALTER TABLE `ranks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `repayments`
--

DROP TABLE IF EXISTS `repayments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `repayments` (
  `id` char(36) NOT NULL,
  `application_id` char(36) NOT NULL,
  `installment_no` int NOT NULL,
  `due_date` date NOT NULL,
  `expected_amount` decimal(12,2) NOT NULL,
  `paid_amount` decimal(12,2) DEFAULT '0.00',
  `paid_at` timestamp NULL DEFAULT NULL,
  `status` enum('Upcoming','Paid','Arrears','Partial') DEFAULT 'Upcoming',
  PRIMARY KEY (`id`),
  KEY `application_id` (`application_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `repayments`
--

LOCK TABLES `repayments` WRITE;
/*!40000 ALTER TABLE `repayments` DISABLE KEYS */;
/*!40000 ALTER TABLE `repayments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_users`
--

DROP TABLE IF EXISTS `system_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_users` (
  `id` char(36) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('Super Admin','Credit Officer','Agent') DEFAULT 'Credit Officer',
  `status` enum('Active','Disabled') DEFAULT 'Active',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_users`
--

LOCK TABLES `system_users` WRITE;
/*!40000 ALTER TABLE `system_users` DISABLE KEYS */;
INSERT INTO `system_users` VALUES ('U1','BancEASY Admin','admin@banceasy.co.zw','','Super Admin','Active',NULL,'2026-02-14 08:59:59');
/*!40000 ALTER TABLE `system_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_admin_summary`
--

DROP TABLE IF EXISTS `v_admin_summary`;
/*!50001 DROP VIEW IF EXISTS `v_admin_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_admin_summary` AS SELECT 
 1 AS `total_disbursed`,
 1 AS `pending_count`,
 1 AS `active_agents`,
 1 AS `leads_today`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'banceasy_db'
--

--
-- Dumping routines for database 'banceasy_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_DisburseLoan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DisburseLoan`(IN p_app_id CHAR(36))
BEGIN
    DECLARE v_months INT;
    DECLARE v_amount DECIMAL(12,2);
    DECLARE v_monthly DECIMAL(12,2);
    DECLARE i INT DEFAULT 1;
    
    -- Get application details
    SELECT loan_period, loan_amount INTO v_months, v_amount 
    FROM applications WHERE id = p_app_id;
    
    -- Calculate simple installment (assumes 7% flat rate in matrix logic)
    -- In a real prod environment, this would pull from the rate_matrix table
    SET v_monthly = (v_amount * (1 + (0.07 * v_months))) / v_months;
    
    -- Update application
    UPDATE applications SET status = 'Paid', disbursed_at = CURRENT_TIMESTAMP WHERE id = p_app_id;
    
    -- Generate Repayment Schedule
    WHILE i <= v_months DO
        INSERT INTO repayments (id, application_id, installment_no, due_date, expected_amount, status)
        VALUES (UUID(), p_app_id, i, DATE_ADD(CURDATE(), INTERVAL i MONTH), v_monthly, 'Upcoming');
        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `banceasy_db`
--

USE `banceasy_db`;

--
-- Final view structure for view `v_admin_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_admin_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_admin_summary` AS select ifnull(sum(`applications`.`loan_amount`),0) AS `total_disbursed`,(select count(0) from `applications` where (`applications`.`status` = 'Pending')) AS `pending_count`,(select count(0) from `system_users` where ((`system_users`.`role` = 'Agent') and (`system_users`.`status` = 'Active'))) AS `active_agents`,(select count(0) from `clients` where (`clients`.`created_at` >= curdate())) AS `leads_today` from `applications` where (`applications`.`status` = 'Paid') */;
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

-- Dump completed on 2026-04-24 12:28:55
