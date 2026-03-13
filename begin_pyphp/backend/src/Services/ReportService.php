<?php

namespace FarmOS\Services;

use FarmOS\Database;
use FarmOS\Validation;
use FarmOS\Repositories\ReportExportRepository;
use FarmOS\Models\{FinancialRecord, Inventory, Livestock, Task};

final class ReportService
{
    private Database $db;
    private ReportExportRepository $exports;

    public function __construct(Database $db)
    {
        $this->db = $db;
        $this->exports = new ReportExportRepository($db);
    }

    public function getTypes(): array
    {
        return [
            'Financial',
            'Inventory',
            'Livestock',
            'Tasks',
        ];
    }

    public function generate(int $farmId, string $type, string $format, string $startDate, string $endDate): array
    {
        $report = $this->buildReport(strtolower($type), $farmId, $startDate, $endDate, $format);

        $token = bin2hex(random_bytes(24));
        $expiresAt = date('Y-m-d H:i:s', time() + 600);

        $this->exports->save(
            $token,
            (string) $report['content_type'],
            (string) $report['filename'],
            (string) $report['body'],
            $expiresAt
        );

        return [
            'url' => '/api/reports/download?token=' . $token,
            'expires_at' => $expiresAt,
        ];
    }

    public function getExportByToken(string $token): ?array
    {
        $token = Validation::sanitizeString($token);
        if ($token === '') {
            return null;
        }

        try {
            return $this->exports->findValidByToken($token);
        } catch (\Exception $e) {
            return null;
        }
    }

    private function buildReport(string $type, int $farmId, string $startDate, string $endDate, string $format): array
    {
        if ($type === 'financial') {
            return $this->buildFinancialReport($farmId, $startDate, $endDate, $format);
        }
        if ($type === 'inventory') {
            return $this->buildInventoryReport($farmId, $format);
        }
        if ($type === 'livestock') {
            return $this->buildLivestockReport($farmId, $format);
        }
        if ($type === 'tasks') {
            return $this->buildTasksReport($farmId, $startDate, $endDate, $format);
        }

        throw new \InvalidArgumentException('Unknown report type');
    }

    private function buildFinancialReport(int $farmId, string $startDate, string $endDate, string $format): array
    {
        $rows = $this->db->query(
            'SELECT type, category, amount, currency, date, status, description
             FROM ' . FinancialRecord::table() . '
             WHERE farm_id = ? AND DATE(date) >= ? AND DATE(date) <= ?
             ORDER BY date DESC',
            [$farmId, $startDate, $endDate]
        );

        $income = 0.0;
        $expense = 0.0;
        foreach ($rows as $r) {
            $amt = isset($r['amount']) ? (float) $r['amount'] : 0.0;
            if (($r['type'] ?? '') === 'income') {
                $income += $amt;
            } else {
                $expense += $amt;
            }
        }

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['date', 'type', 'category', 'amount', 'currency', 'status', 'description']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['date'] ?? ''),
                    (string) ($r['type'] ?? ''),
                    (string) ($r['category'] ?? ''),
                    (string) ($r['amount'] ?? ''),
                    (string) ($r['currency'] ?? ''),
                    (string) ($r['status'] ?? ''),
                    (string) ($r['description'] ?? ''),
                ]);
            }
            fputcsv($out, []);
            fputcsv($out, ['total_income', number_format($income, 2, '.', '')]);
            fputcsv($out, ['total_expense', number_format($expense, 2, '.', '')]);
            fputcsv($out, ['net_profit', number_format($income - $expense, 2, '.', '')]);
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'financial_report_' . $startDate . '_to_' . $endDate . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Financial Report</title></head><body>';
        $html .= '<h1>Financial Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Period: ' . $escape($startDate) . ' to ' . $escape($endDate) . '</p>';
        $html .= '<p>Total income: ' . $escape(number_format($income, 2)) . '</p>';
        $html .= '<p>Total expense: ' . $escape(number_format($expense, 2)) . '</p>';
        $html .= '<p>Net profit: ' . $escape(number_format($income - $expense, 2)) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['Date', 'Type', 'Category', 'Amount', 'Currency', 'Status', 'Description'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['date'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['type'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['category'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['amount'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['currency'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['status'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['description'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'financial_report_' . $startDate . '_to_' . $endDate . '.html',
            'body' => $html,
        ];
    }

    private function buildInventoryReport(int $farmId, string $format): array
    {
        $rows = $this->db->query(
            'SELECT name, category, quantity, unit, min_level, max_level, cost_per_unit, supplier, location, expiry_date
             FROM ' . Inventory::table() . '
             WHERE farm_id = ?
             ORDER BY category ASC, name ASC',
            [$farmId]
        );

        $totalValue = 0.0;
        $lowStock = 0;
        foreach ($rows as $r) {
            $qty = isset($r['quantity']) ? (float) $r['quantity'] : 0.0;
            $cpu = isset($r['cost_per_unit']) ? (float) $r['cost_per_unit'] : 0.0;
            $totalValue += $qty * $cpu;
            $min = isset($r['min_level']) ? (float) $r['min_level'] : 0.0;
            if ($min > 0 && $qty < $min) {
                $lowStock++;
            }
        }

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['name', 'category', 'quantity', 'unit', 'min_level', 'max_level', 'cost_per_unit', 'supplier', 'location', 'expiry_date']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['name'] ?? ''),
                    (string) ($r['category'] ?? ''),
                    (string) ($r['quantity'] ?? ''),
                    (string) ($r['unit'] ?? ''),
                    (string) ($r['min_level'] ?? ''),
                    (string) ($r['max_level'] ?? ''),
                    (string) ($r['cost_per_unit'] ?? ''),
                    (string) ($r['supplier'] ?? ''),
                    (string) ($r['location'] ?? ''),
                    (string) ($r['expiry_date'] ?? ''),
                ]);
            }
            fputcsv($out, []);
            fputcsv($out, ['total_value', number_format($totalValue, 2, '.', '')]);
            fputcsv($out, ['low_stock_items', (string) $lowStock]);
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'inventory_report_' . date('Y-m-d') . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Inventory Report</title></head><body>';
        $html .= '<h1>Inventory Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Total value: ' . $escape(number_format($totalValue, 2)) . '</p>';
        $html .= '<p>Low stock items: ' . $escape((string) $lowStock) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['Name', 'Category', 'Qty', 'Unit', 'Min', 'Max', 'CPU', 'Supplier', 'Location', 'Expiry'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['name'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['category'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['quantity'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['unit'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['min_level'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['max_level'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['cost_per_unit'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['supplier'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['location'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['expiry_date'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'inventory_report_' . date('Y-m-d') . '.html',
            'body' => $html,
        ];
    }

    private function buildLivestockReport(int $farmId, string $format): array
    {
        $rows = $this->db->query(
            'SELECT id, name, species, breed, gender, weight, status, acquisition_date
             FROM ' . Livestock::table() . '
             WHERE farm_id = ?
             ORDER BY species ASC, id DESC',
            [$farmId]
        );

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['id', 'name', 'species', 'breed', 'gender', 'weight', 'status', 'acquisition_date']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['id'] ?? ''),
                    (string) ($r['name'] ?? ''),
                    (string) ($r['species'] ?? ''),
                    (string) ($r['breed'] ?? ''),
                    (string) ($r['gender'] ?? ''),
                    (string) ($r['weight'] ?? ''),
                    (string) ($r['status'] ?? ''),
                    (string) ($r['acquisition_date'] ?? ''),
                ]);
            }
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'livestock_report_' . date('Y-m-d') . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Livestock Report</title></head><body>';
        $html .= '<h1>Livestock Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['ID', 'Name', 'Species', 'Breed', 'Gender', 'Weight', 'Status', 'Acquired'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['id'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['name'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['species'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['breed'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['gender'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['weight'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['status'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['acquisition_date'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'livestock_report_' . date('Y-m-d') . '.html',
            'body' => $html,
        ];
    }

    private function buildTasksReport(int $farmId, string $startDate, string $endDate, string $format): array
    {
        $rows = $this->db->query(
            'SELECT id, title, status, priority, due_date, created_at
             FROM ' . Task::table() . '
             WHERE farm_id = ? AND DATE(created_at) >= ? AND DATE(created_at) <= ?
             ORDER BY created_at DESC',
            [$farmId, $startDate, $endDate]
        );

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['id', 'title', 'status', 'priority', 'due_date', 'created_at']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['id'] ?? ''),
                    (string) ($r['title'] ?? ''),
                    (string) ($r['status'] ?? ''),
                    (string) ($r['priority'] ?? ''),
                    (string) ($r['due_date'] ?? ''),
                    (string) ($r['created_at'] ?? ''),
                ]);
            }
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'tasks_report_' . $startDate . '_to_' . $endDate . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Tasks Report</title></head><body>';
        $html .= '<h1>Tasks Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Period: ' . $escape($startDate) . ' to ' . $escape($endDate) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['ID', 'Title', 'Status', 'Priority', 'Due', 'Created'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['id'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['title'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['status'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['priority'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['due_date'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['created_at'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'tasks_report_' . $startDate . '_to_' . $endDate . '.html',
            'body' => $html,
        ];
    }
}
