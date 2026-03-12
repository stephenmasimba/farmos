<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * FinancialRecord Model - Represents financial transactions
 */
class FinancialRecord extends Model
{
    protected static string $table = 'financial_records';
    
    protected static array $fillable = [
        'farm_id',
        'type',
        'category',
        'description',
        'amount',
        'currency',
        'date',
        'reference_number',
        'payment_method',
        'status',
        'notes',
    ];

    protected static array $casts = [
        'id' => 'int',
        'farm_id' => 'int',
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
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY date DESC LIMIT ? OFFSET ?',
            [$farmId, $limit, $offset]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get records by type (income/expense)
     */
    public static function byType(int $farmId, string $type, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND type = ? ORDER BY date DESC',
            [$farmId, $type]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get records by category
     */
    public static function byCategory(int $farmId, string $category, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND category = ? ORDER BY date DESC',
            [$farmId, $category]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get records in date range
     */
    public static function byDateRange(int $farmId, string $startDate, string $endDate, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND date >= ? AND date <= ? ORDER BY date DESC',
            [$farmId, $startDate, $endDate]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get categories for a farm
     */
    public static function categories(int $farmId, Database $db): array
    {
        $results = $db->query(
            'SELECT DISTINCT category FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY category ASC',
            [$farmId]
        );
        return array_map(fn($row) => $row['category'], $results);
    }

    /**
     * Get total by type
     */
    public static function totalByType(int $farmId, string $type, Database $db): float
    {
        $result = $db->queryOne(
            'SELECT SUM(amount) as total FROM ' . self::$table . ' WHERE farm_id = ? AND type = ?',
            [$farmId, $type]
        );
        return $result['total'] ? (float) $result['total'] : 0.0;
    }

    /**
     * Get total by category
     */
    public static function totalByCategory(int $farmId, string $category, Database $db): float
    {
        $result = $db->queryOne(
            'SELECT SUM(amount) as total FROM ' . self::$table . ' WHERE farm_id = ? AND category = ?',
            [$farmId, $category]
        );
        return $result['total'] ? (float) $result['total'] : 0.0;
    }

    /**
     * Get monthly summary
     */
    public static function monthlySummary(int $farmId, string $year, string $month, Database $db): array
    {
        $startDate = "$year-$month-01";
        $endDate = date('Y-m-t', strtotime($startDate));

        $income = self::query($db)
            ->where('farm_id', $farmId)
            ->where('type', 'income')
            ->where('date >= ', $startDate)
            ->where('date <= ', $endDate)
            ->get();

        $expenses = self::query($db)
            ->where('farm_id', $farmId)
            ->where('type', 'expense')
            ->where('date >= ', $startDate)
            ->where('date <= ', $endDate)
            ->get();

        $totalIncome = array_sum(array_map(fn($r) => $r->attributes['amount'] ?? 0, $income));
        $totalExpense = array_sum(array_map(fn($r) => $r->attributes['amount'] ?? 0, $expenses));

        return [
            'month' => "$year-$month",
            'income_count' => count($income),
            'expense_count' => count($expenses),
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
        $result = $db->queryOne(
            'SELECT 
                SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) as total_income,
                SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END) as total_expense,
                COUNT(*) as total_records
             FROM ' . self::$table . ' 
             WHERE farm_id = ? AND YEAR(date) = ?',
            [$farmId, $year]
        );

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
        return array_merge($this->toArray(), [
            'is_income' => $this->isIncome(),
            'formatted_amount' => $this->attributes['currency'] . ' ' . number_format($this->attributes['amount'] ?? 0, 2),
        ]);
    }
}
