<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * FinancialRecord Model - Represents financial transactions
 */
class FinancialRecord extends Model
{
    protected static string $table = 'financial_records';
    private static ?bool $hasFarmId = null;

    protected static array $fillable = [
        'type',
        'category',
        'category_source',
        'mapped_rule_id',
        'vendor',
        'tags_json',
        'description',
        'amount',
        'currency',
        'date',
        'reference_number',
        'payment_method',
        'status',
        'notes',
        'period_id',
        'created_by',
        'updated_by',
    ];

    protected static array $casts = [
        'id' => 'int',
        'amount' => 'float',
        'date' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected static array $hidden = [];

    /**
     * Get all financial records for a farm
     */
    public static function byFarm(int $farmId, Database $db, int $limit = 100, int $offset = 0): array
    {
        if (self::hasFarmId($db)) {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY date DESC LIMIT ? OFFSET ?',
                [$farmId, $limit, $offset]
            );
        } else {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' ORDER BY date DESC LIMIT ? OFFSET ?',
                [$limit, $offset]
            );
        }
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get records by type (income/expense)
     */
    public static function byType(int $farmId, string $type, Database $db): array
    {
        if (self::hasFarmId($db)) {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND type = ? ORDER BY date DESC',
                [$farmId, $type]
            );
        } else {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE type = ? ORDER BY date DESC',
                [$type]
            );
        }
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get records by category
     */
    public static function byCategory(int $farmId, string $category, Database $db): array
    {
        if (self::hasFarmId($db)) {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND category = ? ORDER BY date DESC',
                [$farmId, $category]
            );
        } else {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE category = ? ORDER BY date DESC',
                [$category]
            );
        }
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get records in date range
     */
    public static function byDateRange(int $farmId, string $startDate, string $endDate, Database $db): array
    {
        if (self::hasFarmId($db)) {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND date >= ? AND date <= ? ORDER BY date DESC',
                [$farmId, $startDate, $endDate]
            );
        } else {
            $results = $db->query(
                'SELECT * FROM ' . self::$table . ' WHERE date >= ? AND date <= ? ORDER BY date DESC',
                [$startDate, $endDate]
            );
        }
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get categories for a farm
     */
    public static function categories(int $farmId, Database $db): array
    {
        if (self::hasFarmId($db)) {
            $results = $db->query(
                'SELECT DISTINCT category FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY category ASC',
                [$farmId]
            );
        } else {
            $results = $db->query(
                'SELECT DISTINCT category FROM ' . self::$table . ' ORDER BY category ASC'
            );
        }
        return array_map(fn($row) => $row['category'], $results);
    }

    /**
     * Get total by type
     */
    public static function totalByType(int $farmId, string $type, Database $db): float
    {
        if (self::hasFarmId($db)) {
            $result = $db->queryOne(
                'SELECT SUM(amount) as total FROM ' . self::$table . ' WHERE farm_id = ? AND type = ?',
                [$farmId, $type]
            );
        } else {
            $result = $db->queryOne(
                'SELECT SUM(amount) as total FROM ' . self::$table . ' WHERE type = ?',
                [$type]
            );
        }
        return $result['total'] ? (float) $result['total'] : 0.0;
    }

    /**
     * Get total by category
     */
    public static function totalByCategory(int $farmId, string $category, Database $db): float
    {
        if (self::hasFarmId($db)) {
            $result = $db->queryOne(
                'SELECT SUM(amount) as total FROM ' . self::$table . ' WHERE farm_id = ? AND category = ?',
                [$farmId, $category]
            );
        } else {
            $result = $db->queryOne(
                'SELECT SUM(amount) as total FROM ' . self::$table . ' WHERE category = ?',
                [$category]
            );
        }
        return $result['total'] ? (float) $result['total'] : 0.0;
    }

    /**
     * Get monthly summary
     */
    public static function monthlySummary(int $farmId, string $year, string $month, Database $db): array
    {
        $startDate = "$year-$month-01";
        $endDate = date('Y-m-t', strtotime($startDate));

        if (self::hasFarmId($db)) {
            $result = $db->queryOne(
                'SELECT
                    SUM(CASE WHEN type = \'income\' THEN amount ELSE 0 END) as total_income,
                    SUM(CASE WHEN type = \'expense\' THEN amount ELSE 0 END) as total_expense,
                    SUM(CASE WHEN type = \'income\' THEN 1 ELSE 0 END) as income_count,
                    SUM(CASE WHEN type = \'expense\' THEN 1 ELSE 0 END) as expense_count
                 FROM ' . self::$table . '
                 WHERE farm_id = ? AND date >= ? AND date <= ?',
                [$farmId, $startDate, $endDate]
            );
        } else {
            $result = $db->queryOne(
                'SELECT
                    SUM(CASE WHEN type = \'income\' THEN amount ELSE 0 END) as total_income,
                    SUM(CASE WHEN type = \'expense\' THEN amount ELSE 0 END) as total_expense,
                    SUM(CASE WHEN type = \'income\' THEN 1 ELSE 0 END) as income_count,
                    SUM(CASE WHEN type = \'expense\' THEN 1 ELSE 0 END) as expense_count
                 FROM ' . self::$table . '
                 WHERE date >= ? AND date <= ?',
                [$startDate, $endDate]
            );
        }
        $totalIncome = (float) ($result['total_income'] ?? 0);
        $totalExpense = (float) ($result['total_expense'] ?? 0);
        $incomeCount = (int) ($result['income_count'] ?? 0);
        $expenseCount = (int) ($result['expense_count'] ?? 0);

        return [
            'month' => "$year-$month",
            'income_count' => $incomeCount,
            'expense_count' => $expenseCount,
            'total_income' => round($totalIncome, 2),
            'total_expense' => round($totalExpense, 2),
            'net_profit' => round($totalIncome - $totalExpense, 2),
        ];
    }

    /**
     * Get year summary
     */
    public static function yearSummary(int $farmId, string $year, Database $db): array
    {
        if (self::hasFarmId($db)) {
            $result = $db->queryOne(
                'SELECT 
                    SUM(CASE WHEN type = \'income\' THEN amount ELSE 0 END) as total_income,
                    SUM(CASE WHEN type = \'expense\' THEN amount ELSE 0 END) as total_expense,
                    COUNT(*) as total_records
                 FROM ' . self::$table . ' 
                 WHERE farm_id = ? AND YEAR(date) = ?',
                [$farmId, $year]
            );
        } else {
            $result = $db->queryOne(
                'SELECT 
                    SUM(CASE WHEN type = \'income\' THEN amount ELSE 0 END) as total_income,
                    SUM(CASE WHEN type = \'expense\' THEN amount ELSE 0 END) as total_expense,
                    COUNT(*) as total_records
                 FROM ' . self::$table . ' 
                 WHERE YEAR(date) = ?',
                [$year]
            );
        }

        $income = $result['total_income'] ?? 0;
        $expense = $result['total_expense'] ?? 0;

        return [
            'year' => $year,
            'total_income' => round($income, 2),
            'total_expense' => round($expense, 2),
            'net_profit' => round($income - $expense, 2),
            'total_records' => $result['total_records'] ?? 0,
        ];
    }

    /**
     * Check if record is income or expense
     */
    public function isIncome(): bool
    {
        return $this->attributes['type'] === 'income';
    }

    /**
     * Get financial record reference
     */
    public function reference(): string
    {
        return "[Financial #{$this->attributes['id']} {$this->attributes['type']} {$this->attributes['amount']} ({$this->attributes['category']})]";
    }

    /**
     * Get full profile
     */
    public function getFullProfile(): array
    {
        $tags = [];
        $rawTags = (string) ($this->attributes['tags_json'] ?? '');
        if ($rawTags !== '') {
            $decoded = json_decode($rawTags, true);
            if (is_array($decoded)) {
                $tags = $decoded;
            }
        }
        return array_merge($this->toArray(), [
            'is_income' => $this->isIncome(),
            'formatted_amount' => $this->attributes['currency'] . ' ' . number_format($this->attributes['amount'] ?? 0, 2),
            'tags' => $tags,
        ]);
    }

    private static function hasFarmId(Database $db): bool
    {
        if (self::$hasFarmId !== null) {
            return self::$hasFarmId;
        }
        try {
            $row = $db->queryOne("SHOW COLUMNS FROM " . self::$table . " LIKE 'farm_id'");
            self::$hasFarmId = $row !== null;
        } catch (\Throwable $e) {
            self::$hasFarmId = false;
        }
        return self::$hasFarmId;
    }
}
