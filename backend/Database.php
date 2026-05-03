<?php
/**
 * Database Connection Handler
 * Manages all database operations using mysqli
 */

require_once __DIR__ . '/config.php';

class Database
{
    private static $instance = null;
    private $connection;

    /**
     * Singleton pattern - Get database instance
     */
    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Constructor - Establish database connection
     */
    private function __construct()
    {
        $this->connection = new mysqli(
            DB_HOST,
            DB_USER,
            DB_PASS,
            DB_NAME,
            DB_PORT
        );

        if ($this->connection->connect_error) {
            error_log("Database Connection Error: " . $this->connection->connect_error);
            die(json_encode([
                'status' => 'error',
                'message' => 'Database connection failed'
            ]));
        }

        $this->connection->set_charset('utf8mb4');
    }

    /**
     * Get raw connection
     */
    public function getConnection()
    {
        return $this->connection;
    }

    /**
     * Execute a query
     */
    public function query($sql)
    {
        $result = $this->connection->query($sql);

        if ($this->connection->error) {
            error_log("Database Error: " . $this->connection->error . " | Query: " . $sql);
            return null;
        }

        return $result;
    }

    /**
     * Execute a prepared statement
     */
    public function prepare($sql)
    {
        return $this->connection->prepare($sql);
    }

    /**
     * Fetch all results as associative array
     */
    public function fetchAll($sql)
    {
        $result = $this->query($sql);
        if (!$result) return [];

        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        return $data;
    }

    /**
     * Fetch single row
     */
    public function fetchOne($sql)
    {
        $result = $this->query($sql);
        if (!$result) return null;

        return $result->fetch_assoc();
    }

    /**
     * Fetch single value
     */
    public function fetchValue($sql)
    {
        $result = $this->query($sql);
        if (!$result) return null;

        $row = $result->fetch_array(MYSQLI_NUM);
        return $row ? $row[0] : null;
    }

    /**
     * Execute insert/update/delete
     */
    public function execute($sql)
    {
        return $this->query($sql) !== false;
    }

    /**
     * Get last insert ID
     */
    public function lastInsertId()
    {
        return $this->connection->insert_id;
    }

    /**
     * Get affected rows
     */
    public function affectedRows()
    {
        return $this->connection->affected_rows;
    }

    /**
     * Escape string for safety
     */
    public function escape($string)
    {
        return $this->connection->real_escape_string($string);
    }

    /**
     * Begin transaction
     */
    public function beginTransaction()
    {
        return $this->connection->begin_transaction();
    }

    /**
     * Commit transaction
     */
    public function commit()
    {
        return $this->connection->commit();
    }

    /**
     * Rollback transaction
     */
    public function rollback()
    {
        return $this->connection->rollback();
    }

    /**
     * Close connection
     */
    public function closeConnection()
    {
        if ($this->connection) {
            $this->connection->close();
        }
    }

    /**
     * Prevent cloning
     */
    private function __clone() {}

    /**
     * Destructor
     */
    public function __destruct()
    {
        $this->closeConnection();
    }
}
