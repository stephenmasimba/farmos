<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class ComplianceController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function authorizePermission(string $permission)
    {
        $middleware = new PermissionMiddleware($this->request, $this->db, $permission);
        return $middleware->handle();
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
            'CREATE TABLE IF NOT EXISTS compliance_requirements (
                id INT AUTO_INCREMENT PRIMARY KEY,
                standard_name VARCHAR(150) NOT NULL,
                section_code VARCHAR(100) NOT NULL,
                description TEXT NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "pending",
                last_audit_date DATE NULL,
                auditor VARCHAR(150) NULL,
                evidence_url VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_compliance_status (status),
                INDEX idx_compliance_standard (standard_name)
            )'
        );
    }

    private function toStorageStatus(string $status): string
    {
        $normalized = strtolower(trim($status));
        if ($normalized === 'compliant') {
            return 'compliant';
        }
        if ($normalized === 'non-compliant') {
            return 'non-compliant';
        }
        if ($normalized === 'n/a') {
            return 'na';
        }

        return 'pending';
    }

    private function toDisplayStatus(?string $status): string
    {
        $normalized = strtolower((string) $status);
        if ($normalized === 'compliant') {
            return 'Compliant';
        }
        if ($normalized === 'non-compliant') {
            return 'Non-Compliant';
        }
        if ($normalized === 'na') {
            return 'N/A';
        }

        return 'Pending';
    }

    public function requirements(): Response
    {
        try {
            $auth = $this->authorizePermission('compliance.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTable();
            $rows = $this->db->query(
                'SELECT id, standard_name, section_code, description, status, last_audit_date, auditor, evidence_url
                 FROM compliance_requirements
                 ORDER BY created_at DESC, id DESC'
            );

            $requirements = array_map([$this, 'mapRequirementRow'], $rows);
            return Response::success($requirements);
        } catch (\Exception $e) {
            Logger::error('Failed to list compliance requirements', ['error' => $e->getMessage()]);
            return Response::error('Failed to list compliance requirements', 'COMPLIANCE_LIST_ERROR', 500);
        }
    }

    public function storeRequirement(): Response
    {
        try {
            $auth = $this->authorizePermission('compliance.manage');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $standard = trim((string) ($input['standard'] ?? ''));
            $section = trim((string) ($input['section'] ?? ''));
            $description = trim((string) ($input['description'] ?? ''));
            $status = $this->toStorageStatus((string) ($input['status'] ?? 'Pending'));
            $lastAuditDate = (string) ($input['last_audit_date'] ?? '');
            $evidenceUrl = trim((string) ($input['evidence_url'] ?? ''));

            $errors = [];
            if ($standard === '') {
                $errors['standard'] = 'Standard is required';
            }
            if ($section === '') {
                $errors['section'] = 'Section is required';
            }
            if ($description === '') {
                $errors['description'] = 'Description is required';
            }
            if ($lastAuditDate !== '' && !Validation::validateDate($lastAuditDate, 'Y-m-d')) {
                $errors['last_audit_date'] = 'Invalid audit date';
            }
            if ($evidenceUrl !== '' && !filter_var($evidenceUrl, FILTER_VALIDATE_URL)) {
                $errors['evidence_url'] = 'Evidence URL must be valid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO compliance_requirements (standard_name, section_code, description, status, last_audit_date, auditor, evidence_url, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    Validation::sanitizeString($standard),
                    Validation::sanitizeString($section),
                    Validation::sanitizeString($description),
                    $status,
                    $lastAuditDate !== '' ? $lastAuditDate : null,
                    Validation::sanitizeString((string) ($input['auditor'] ?? '')),
                    $evidenceUrl !== '' ? $evidenceUrl : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Compliance requirement created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create compliance requirement', ['error' => $e->getMessage()]);
            return Response::error('Failed to create compliance requirement', 'COMPLIANCE_CREATE_ERROR', 500);
        }
    }

    private function mapRequirementRow(array $row): array
    {
        return [
            'id' => (int) $row['id'],
            'standard' => $row['standard_name'] ?? '',
            'section' => $row['section_code'] ?? '',
            'description' => $row['description'] ?? '',
            'status' => $this->toDisplayStatus($row['status'] ?? null),
            'last_audit_date' => $row['last_audit_date'] ?? null,
            'auditor' => $row['auditor'] ?? '',
            'evidence_url' => $row['evidence_url'] ?? '',
        ];
    }
}
