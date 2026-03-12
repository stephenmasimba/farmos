<?php

namespace FarmOS\Models;

use FarmOS\{Database, ValidationException, DatabaseException, Logger, NotFoundException};
use DateTime;

/**
 * Base Model class for database entities
 * Provides common CRUD operations and data access patterns
 */
abstract class Model
{
    protected static string $table;
    protected static array $fillable = [];
    protected static array $hidden = [];
    protected static array $casts = [];
    protected static string $primaryKey = 'id';

    protected Database $db;
    protected array $attributes = [];
    protected array $original = [];

    /**
     * Constructor
     */
    public function __construct(Database $db, array $attributes = [])
    {
        $this->db = $db;
        $this->attributes = $attributes;
        $this->original = $attributes;
    }

    /**
     * Get table name
     */
    public static function table(): string
    {
        return static::$table;
    }

    /**
     * Get primary key
     */
    public static function primaryKey(): string
    {
        return static::$primaryKey;
    }

    /**
     * Get fillable fields
     */
    public static function fillable(): array
    {
        return static::$fillable;
    }

    /**
     * Magic getter
     */
    public function __get(string $name): mixed
    {
        if (array_key_exists($name, $this->attributes)) {
            return $this->castAttribute($name, $this->attributes[$name]);
        }
        return null;
    }

    /**
     * Magic setter
     */
    public function __set(string $name, mixed $value): void
    {
        if (in_array($name, static::$fillable) || !isset(static::$fillable)) {
            $this->attributes[$name] = $value;
        }
    }

    /**
     * Magic isset
     */
    public function __isset(string $name): bool
    {
        return array_key_exists($name, $this->attributes);
    }

    /**
     * Cast attribute to specified type
     */
    protected function castAttribute(string $name, mixed $value): mixed
    {
        if (!isset(static::$casts[$name]) || $value === null) {
            return $value;
        }

        $cast = static::$casts[$name];

        switch ($cast) {
            case 'int':
            case 'integer':
                return (int) $value;
            case 'float':
            case 'double':
                return (float) $value;
            case 'bool':
            case 'boolean':
                return (bool) $value;
            case 'string':
                return (string) $value;
            case 'array':
                return is_string($value) ? json_decode($value, true) : $value;
            case 'json':
                return is_string($value) ? json_decode($value, true) : $value;
            case 'datetime':
            case 'date':
                return new DateTime($value);
            default:
                return $value;
        }
    }

    /**
     * Get all attributes
     */
    public function toArray(): array
    {
        $array = $this->attributes;
        
        // Apply type casting
        foreach ($array as $key => $value) {
            $array[$key] = $this->castAttribute($key, $value);
        }
        
        // Remove hidden fields
        foreach (static::$hidden as $field) {
            unset($array[$field]);
        }

        return $array;
    }

    /**
     * Get attributes as JSON
     */
    public function toJson(): string
    {
        return json_encode($this->toArray());
    }

    /**
     * Find by primary key
     */
    public static function find(mixed $id, Database $db): ?static
    {
        $result = $db->queryOne(
            'SELECT * FROM ' . static::table() . ' WHERE ' . static::primaryKey() . ' = ?',
            [$id]
        );

        if ($result) {
            return new static($db, $result);
        }

        return null;
    }

    /**
     * Find or fail
     */
    public static function findOrFail(mixed $id, Database $db): static
    {
        $model = static::find($id, $db);
        if (!$model) {
            throw new NotFoundException(static::class . ' not found', ['id' => $id]);
        }
        return $model;
    }

    /**
     * Get all records
     */
    public static function all(Database $db, int $limit = 100, int $offset = 0): array
    {
        $results = $db->query(
            'SELECT * FROM ' . static::table() . ' LIMIT ? OFFSET ?',
            [$limit, $offset]
        );

        return array_map(fn($row) => new static($db, $row), $results);
    }

    /**
     * Query builder pattern
     */
    public static function query(Database $db): QueryBuilder
    {
        return new QueryBuilder(static::class, static::table(), $db);
    }

    /**
     * Find by column
     */
    public static function where(string $column, mixed $value, Database $db): ?static
    {
        $result = $db->queryOne(
            'SELECT * FROM ' . static::table() . ' WHERE ' . $column . ' = ?',
            [$value]
        );

        if ($result) {
            return new static($db, $result);
        }

        return null;
    }

    /**
     * Create a new record
     */
    public function save(): mixed
    {
        if (isset($this->attributes[static::$primaryKey])) {
            return $this->update();
        }

        return $this->insert();
    }

    /**
     * Insert new record
     */
    protected function insert(): mixed
    {
        $fields = [];
        $values = [];
        $params = [];

        foreach ($this->attributes as $key => $value) {
            if ($key !== static::$primaryKey) {
                $fields[] = $key;
                $values[] = '?';
                $params[] = $value;
            }
        }

        if (empty($fields)) {
            throw new ValidationException('No fields to insert', [static::class]);
        }

        $sql = 'INSERT INTO ' . static::table() . ' (' . implode(', ', $fields) . ') VALUES (' . implode(', ', $values) . ')';
        
        $this->db->execute($sql, $params);
        $this->attributes[static::$primaryKey] = $this->db->lastInsertId();

        return $this->attributes[static::$primaryKey];
    }

    /**
     * Update existing record
     */
    protected function update(): int
    {
        $id = $this->attributes[static::$primaryKey] ?? null;
        
        if (!$id) {
            throw new ValidationException('No primary key for update', [static::class]);
        }

        $sets = [];
        $params = [];

        foreach ($this->attributes as $key => $value) {
            if ($key !== static::$primaryKey && $key !== 'created_at') {
                $sets[] = $key . ' = ?';
                $params[] = $value;
            }
        }

        if (empty($sets)) {
            return 0;
        }

        $params[] = $id;
        $sql = 'UPDATE ' . static::table() . ' SET ' . implode(', ', $sets) . ' WHERE ' . static::$primaryKey . ' = ?';
        
        return $this->db->execute($sql, $params);
    }

    /**
     * Delete record
     */
    public function delete(): int
    {
        $id = $this->attributes[static::$primaryKey] ?? null;
        
        if (!$id) {
            throw new ValidationException('No primary key for delete', [static::class]);
        }

        $sql = 'DELETE FROM ' . static::table() . ' WHERE ' . static::$primaryKey . ' = ?';
        return $this->db->execute($sql, [$id]);
    }

    /**
     * Delete by id
     */
    public static function destroy(mixed $id, Database $db): int
    {
        $sql = 'DELETE FROM ' . static::table() . ' WHERE ' . static::primaryKey() . ' = ?';
        return $db->execute($sql, [$id]);
    }

    /**
     * Count records
     */
    public static function count(Database $db): int
    {
        $result = $db->queryOne(
            'SELECT COUNT(*) as count FROM ' . static::table()
        );
        return $result['count'] ?? 0;
    }

    /**
     * Check if dirty (modified)
     */
    public function isDirty(string $field = null): bool
    {
        if ($field) {
            return isset($this->attributes[$field]) && 
                   isset($this->original[$field]) && 
                   $this->attributes[$field] !== $this->original[$field];
        }

        return $this->attributes !== $this->original;
    }

    /**
     * Get original value
     */
    public function getOriginal(string $field = null): mixed
    {
        if ($field) {
            return $this->original[$field] ?? null;
        }
        return $this->original;
    }

    /**
     * Clear dirty state
     */
    public function clearDirty(): void
    {
        $this->original = $this->attributes;
    }
}
