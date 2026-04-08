<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * Query Builder for fluent database queries
 */
class QueryBuilder
{
    protected string $model;
    protected string $table;
    protected Database $db;

    protected array $select = ['*'];
    protected array $wheres = [];
    protected array $params = [];
    protected array $joins = [];
    protected array $orders = [];
    protected ?int $limit = null;
    protected int $offset = 0;

    public function __construct(string $model, string $table, Database $db)
    {
        $this->model = $model;
        $this->table = $table;
        $this->db = $db;
    }

    /**
     * Select specific columns
     */
    public function select(...$columns): self
    {
        $this->select = $columns;
        return $this;
    }

    /**
     * Add WHERE clause
     */
    public function where(string $column, $operator = null, $value = null): self
    {
        // Handle where(column, value) syntax
        if ($value === null && $operator !== null) {
            $value = $operator;
            $operator = '=';
            if (preg_match('/^(.+?)\s*(>=|<=|<>|!=|=|<|>|LIKE)$/i', $column, $m)) {
                $column = trim($m[1]);
                $operator = strtoupper($m[2]);
            }
        }

        $this->wheres[] = [
            'column' => $column,
            'operator' => $this->normalizeOperator((string) $operator),
            'value' => $value,
        ];

        return $this;
    }

    /**
     * Add OR WHERE clause
     */
    public function orWhere(string $column, $operator = null, $value = null): self
    {
        if ($value === null && $operator !== null) {
            $value = $operator;
            $operator = '=';
            if (preg_match('/^(.+?)\s*(>=|<=|<>|!=|=|<|>|LIKE)$/i', $column, $m)) {
                $column = trim($m[1]);
                $operator = strtoupper($m[2]);
            }
        }

        $this->wheres[] = [
            'column' => $column,
            'operator' => $this->normalizeOperator((string) $operator),
            'value' => $value,
            'boolean' => 'or',
        ];

        return $this;
    }

    /**
     * Order by column
     */
    public function orderBy(string $column, string $direction = 'ASC'): self
    {
        $this->assertSafeIdentifierChain($column);
        $dir = strtoupper($direction);
        if (!in_array($dir, ['ASC', 'DESC'], true)) {
            $dir = 'ASC';
        }
        $this->orders[] = [
            'column' => $column,
            'direction' => $dir,
        ];
        return $this;
    }

    public function getConnection(): Database
    {
        return $this->db;
    }

    protected function quoteIdentifier(string $identifier): string
    {
        if ($identifier === '*') {
            return $identifier;
        }

        if (strpos($identifier, '`') !== false) {
            throw new \InvalidArgumentException('Unsafe identifier');
        }

        $parts = explode('.', $identifier);
        foreach ($parts as $i => $part) {
            if ($part === '*') {
                continue;
            }
            if (preg_match('/^[A-Za-z_][A-Za-z0-9_]*$/', $part)) {
                $parts[$i] = '`' . $part . '`';
            } else {
                throw new \InvalidArgumentException('Unsafe identifier');
            }
        }

        return implode('.', $parts);
    }

    protected function assertSafeIdentifierChain(string $identifier): void
    {
        if ($identifier === '*') {
            return;
        }
        if ($identifier === '' || strpos($identifier, '`') !== false) {
            throw new \InvalidArgumentException('Unsafe identifier');
        }
        foreach (explode('.', $identifier) as $part) {
            if ($part === '*') {
                continue;
            }
            if (!preg_match('/^[A-Za-z_][A-Za-z0-9_]*$/', $part)) {
                throw new \InvalidArgumentException('Unsafe identifier');
            }
        }
    }

    protected function normalizeOperator(string $operator): string
    {
        $op = strtoupper(trim($operator));
        $allowed = ['=', '!=', '<>', '<', '<=', '>', '>=', 'LIKE'];
        if (!in_array($op, $allowed, true)) {
            return '=';
        }
        return $op;
    }

    protected function sanitizeSelectPart(string $part): string
    {
        $trimmed = trim($part);
        if ($trimmed === '' || strpos($trimmed, '`') !== false) {
            throw new \InvalidArgumentException('Unsafe select expression');
        }

        if (strcasecmp($trimmed, 'DISTINCT') === 0) {
            return 'DISTINCT';
        }

        if (preg_match('/^DISTINCT\\s+([A-Za-z_][A-Za-z0-9_]*(?:\\.[A-Za-z_][A-Za-z0-9_]*)*|\\*)$/i', $trimmed, $m)) {
            return 'DISTINCT ' . $this->quoteIdentifier($m[1]);
        }

        if (preg_match('/^[A-Za-z_][A-Za-z0-9_]*(?:\\.[A-Za-z_][A-Za-z0-9_]*)*|\\*$/', $trimmed)) {
            return $this->quoteIdentifier($trimmed);
        }

        throw new \InvalidArgumentException('Unsafe select expression');
    }

    /**
     * Limit results
     */
    public function limit(int $limit): self
    {
        $this->limit = $limit;
        return $this;
    }

    /**
     * Offset results
     */
    public function offset(int $offset): self
    {
        $this->offset = $offset;
        return $this;
    }

    /**
     * Skip (alias for offset)
     */
    public function skip(int $offset): self
    {
        return $this->offset($offset);
    }

    /**
     * Take (alias for limit)
     */
    public function take(int $limit): self
    {
        return $this->limit($limit);
    }

    /**
     * Pagination helper
     */
    public function paginate(int $page = 1, int $perPage = 15): array
    {
        $page = max(1, $page);
        $offset = ($page - 1) * $perPage;

        $this->offset($offset)->limit($perPage);

        $results = $this->get();
        $total = $this->count();

        return [
            'data' => $results,
            'page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage),
        ];
    }

    /**
     * Build SQL query
     */
    protected function buildSql(): array
    {
        $selectParts = array_map(fn ($part) => $this->sanitizeSelectPart((string) $part), $this->select);
        $sql = 'SELECT ' . implode(', ', $selectParts) . ' FROM ' . $this->quoteIdentifier($this->table);
        $params = [];

        // Add JOINs
        if (!empty($this->joins)) {
            $sql .= ' ' . implode(' ', $this->joins);
        }

        // Build WHERE clause
        if (!empty($this->wheres)) {
            $whereParts = [];
            $currentBoolean = 'AND';

            foreach ($this->wheres as $where) {
                $boolean = $where['boolean'] ?? 'and';

                if (!empty($whereParts) && $boolean === 'or') {
                    $currentBoolean = 'OR';
                }

                $this->assertSafeIdentifierChain((string) $where['column']);
                $whereParts[] = $this->quoteIdentifier($where['column']) . ' ' . $where['operator'] . ' ?';
                $params[] = $where['value'];
            }

            $sql .= ' WHERE ' . implode(' ' . $currentBoolean . ' ', $whereParts);
        }

        // Add ORDER BY
        if (!empty($this->orders)) {
            $orderParts = [];
            foreach ($this->orders as $order) {
                $this->assertSafeIdentifierChain((string) $order['column']);
                $orderParts[] = $this->quoteIdentifier($order['column']) . ' ' . $order['direction'];
            }
            $sql .= ' ORDER BY ' . implode(', ', $orderParts);
        }

        // Add LIMIT
        if ($this->limit !== null) {
            $sql .= ' LIMIT ' . $this->limit;
        }

        // Add OFFSET
        if ($this->offset > 0) {
            $sql .= ' OFFSET ' . $this->offset;
        }

        return [$sql, $params];
    }

    /**
     * Get all results
     */
    public function get(): array
    {
        [$sql, $params] = $this->buildSql();
        $results = $this->db->query($sql, $params);

        return array_map(fn($row) => new $this->model($this->db, $row), $results);
    }

    /**
     * Get first result
     */
    public function first(): ?object
    {
        $this->limit(1);
        $results = $this->get();
        return $results[0] ?? null;
    }

    /**
     * Get last result
     */
    public function last(): ?object
    {
        $results = $this->get();
        return end($results) ?: null;
    }

    /**
     * Count results
     */
    public function count(): int
    {
        [$sql, $params] = $this->buildSql();

        // Replace SELECT clause with COUNT(*)
        $sql = preg_replace('/^SELECT .+ FROM/', 'SELECT COUNT(*) as count FROM', $sql);
        // Remove LIMIT and OFFSET for count
        $sql = preg_replace('/ LIMIT .+$/', '', $sql);
        $sql = preg_replace('/ OFFSET .+$/', '', $sql);

        $result = $this->db->queryOne($sql, $params);
        return $result['count'] ?? 0;
    }

    /**
     * Check if exists
     */
    public function exists(): bool
    {
        return $this->count() > 0;
    }

    /**
     * Pluck single column
     */
    public function pluck(string $column): array
    {
        $this->select = [$column];
        $results = $this->get();

        return array_map(fn($model) => $model->{$column}, $results);
    }

    /**
     * Get unique values
     */
    public function distinct(string $column = null): array
    {
        if ($column) {
            $this->assertSafeIdentifierChain($column);
            $this->select = ['DISTINCT ' . $column];
        } else {
            array_unshift($this->select, 'DISTINCT');
        }

        return $this->pluck($column ?? '*');
    }
}
