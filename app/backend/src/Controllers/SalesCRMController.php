<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class SalesCRMController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function getUserId(): ?int
    {
        $user = $this->request->getUser();
        if (!$user || empty($user['user_id'])) {
            return null;
        }

        return (int) $user['user_id'];
    }

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS sales_crm_leads (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                first_name VARCHAR(100) NOT NULL,
                last_name VARCHAR(100) NOT NULL,
                email VARCHAR(150) NULL,
                phone VARCHAR(50) NULL,
                company VARCHAR(150) NULL,
                lead_temperature VARCHAR(20) NOT NULL DEFAULT "WARM_LEAD",
                conversion_probability INT NOT NULL DEFAULT 25,
                expected_deal_value DECIMAL(10,2) NOT NULL DEFAULT 0,
                recommended_action VARCHAR(255) NULL,
                notes TEXT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_sales_crm_farm (farm_id, created_at),
                INDEX idx_sales_crm_status (status),
                INDEX idx_sales_crm_created_at (created_at)
            )'
        );
        try {
            $this->db->execute('ALTER TABLE sales_crm_leads ADD COLUMN farm_id INT NOT NULL DEFAULT 1');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE sales_crm_leads ADD COLUMN phone VARCHAR(50) NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE sales_crm_leads ADD COLUMN notes TEXT NULL');
        } catch (\Throwable $e) {
        }
    }

    private function getFarmId(): int
    {
        $input = $this->request->getBody();
        $farmId = (int) ($input['farm_id'] ?? 0);
        if ($farmId > 0) {
            return $farmId;
        }

        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 0);
    }

    private function normalizeLeadTemperature(string $value): string
    {
        $normalized = strtoupper(trim($value));
        if ($normalized === 'HOT' || $normalized === 'HOT_LEAD') {
            return 'HOT_LEAD';
        }
        if ($normalized === 'COLD' || $normalized === 'COLD_LEAD') {
            return 'COLD_LEAD';
        }

        return 'WARM_LEAD';
    }

    private function defaultRecommendedAction(string $temperature, int $probability): string
    {
        if ($temperature === 'HOT_LEAD' || $probability >= 70) {
            return 'Call within 24 hours';
        }
        if ($probability >= 40) {
            return 'Send a quote and follow up';
        }

        return 'Send introduction message';
    }

    public function leads(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $rows = $this->db->query(
                'SELECT id, first_name, last_name, email, company, lead_temperature,
                        conversion_probability, expected_deal_value, recommended_action, status
                 FROM sales_crm_leads
                 WHERE farm_id = ? AND status = ?
                 ORDER BY conversion_probability DESC, expected_deal_value DESC, id DESC',
                [$farmId, 'open']
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list sales CRM leads', ['error' => $e->getMessage()]);
            return Response::error('Failed to list sales leads', 'SALES_CRM_LEADS_ERROR', 500);
        }
    }

    public function createLead(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $firstName = trim((string) ($input['first_name'] ?? ''));
            $lastName = trim((string) ($input['last_name'] ?? ''));
            $email = trim((string) ($input['email'] ?? ''));
            $phone = trim((string) ($input['phone'] ?? ''));
            $company = trim((string) ($input['company'] ?? ''));
            $leadTemperature = $this->normalizeLeadTemperature((string) ($input['lead_temperature'] ?? 'WARM_LEAD'));
            $conversionProbability = (int) ($input['conversion_probability'] ?? 25);
            $expectedDealValue = $input['expected_deal_value'] ?? 0;
            $recommendedAction = trim((string) ($input['recommended_action'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));
            $errors = [];
            if ($firstName === '') {
                $errors['first_name'] = 'First name is required';
            }
            if ($lastName === '') {
                $errors['last_name'] = 'Last name is required';
            }
            if ($email !== '' && !Validation::validateEmail($email)) {
                $errors['email'] = 'Invalid email format';
            }
            if ($conversionProbability < 0 || $conversionProbability > 100) {
                $errors['conversion_probability'] = 'Conversion probability must be between 0 and 100';
            }
            if (!is_numeric($expectedDealValue) || (float) $expectedDealValue < 0) {
                $errors['expected_deal_value'] = 'Expected deal value must be numeric';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            if ($recommendedAction === '') {
                $recommendedAction = $this->defaultRecommendedAction($leadTemperature, $conversionProbability);
            }

            $this->db->execute('INSERT INTO sales_crm_leads (farm_id, first_name, last_name, email, phone, company, lead_temperature, conversion_probability, expected_deal_value, recommended_action, notes, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $farmId,
                    Validation::sanitizeString($firstName),
                    Validation::sanitizeString($lastName),
                    $email !== '' ? $email : null,
                    $phone !== '' ? Validation::sanitizeString($phone) : null,
                    $company !== '' ? Validation::sanitizeString($company) : null,
                    $leadTemperature,
                    $conversionProbability,
                    (float) $expectedDealValue,
                    Validation::sanitizeString($recommendedAction),
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    'open',
                    $userId,
                ]);
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Lead created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create sales CRM lead', ['error' => $e->getMessage()]);
            return Response::error('Failed to create sales lead', 'SALES_CRM_LEAD_CREATE_ERROR', 500);
        }
    }

    public function forecast(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $rows = $this->db->query(
                'SELECT expected_deal_value, conversion_probability
                 FROM sales_crm_leads
                 WHERE farm_id = ? AND status = ?',
                [$farmId, 'open']
            );

            $dealCount = count($rows);
            $totalDealsValue = 0.0;
            $totalWeightedValue = 0.0;

            foreach ($rows as $row) {
                $dealValue = (float) ($row['expected_deal_value'] ?? 0);
                $probability = (int) ($row['conversion_probability'] ?? 0);
                $totalDealsValue += $dealValue;
                $totalWeightedValue += $dealValue * max(0, min(100, $probability)) / 100;
            }

            return Response::success([
                'total_deals_value' => round($totalDealsValue, 2),
                'total_weighted_value' => round($totalWeightedValue, 2),
                'deal_count' => $dealCount,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to compute sales forecast', ['error' => $e->getMessage()]);
            return Response::error('Failed to compute sales forecast', 'SALES_CRM_FORECAST_ERROR', 500);
        }
    }
}
