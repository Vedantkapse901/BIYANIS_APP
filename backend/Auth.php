<?php
/**
 * Authentication Handler
 * Manages JWT tokens, user authentication, and authorization
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/Database.php';
require_once __DIR__ . '/Response.php';

class Auth
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Generate JWT Token
     */
    public function generateJWT($userId, $email, $role)
    {
        $header = [
            'alg' => JWT_ALGORITHM,
            'typ' => 'JWT'
        ];

        $payload = [
            'iat' => time(),
            'exp' => time() + JWT_EXPIRATION,
            'iss' => API_BASE_URL,
            'sub' => $userId,
            'email' => $email,
            'role' => $role
        ];

        $headerEncoded = $this->base64UrlEncode(json_encode($header));
        $payloadEncoded = $this->base64UrlEncode(json_encode($payload));

        $signature = hash_hmac(
            'sha256',
            $headerEncoded . '.' . $payloadEncoded,
            JWT_SECRET,
            true
        );
        $signatureEncoded = $this->base64UrlEncode($signature);

        return $headerEncoded . '.' . $payloadEncoded . '.' . $signatureEncoded;
    }

    /**
     * Verify JWT Token
     */
    public function verifyJWT($token)
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }

        list($headerEncoded, $payloadEncoded, $signatureEncoded) = $parts;

        // Verify signature
        $signature = hash_hmac(
            'sha256',
            $headerEncoded . '.' . $payloadEncoded,
            JWT_SECRET,
            true
        );
        $signatureEncoded2 = $this->base64UrlEncode($signature);

        if ($signatureEncoded !== $signatureEncoded2) {
            return false;
        }

        // Decode payload
        $payload = json_decode($this->base64UrlDecode($payloadEncoded), true);

        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }

        return $payload;
    }

    /**
     * Get current user from token
     */
    public function getCurrentUser()
    {
        $token = $this->getBearerToken();

        if (!$token) {
            return null;
        }

        $payload = $this->verifyJWT($token);

        if (!$payload) {
            return null;
        }

        return $payload;
    }

    /**
     * Extract Bearer token from headers
     */
    public function getBearerToken()
    {
        $headers = getallheaders();

        if (isset($headers['Authorization'])) {
            $matches = [];
            if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
                return $matches[1];
            }
        }

        return null;
    }

    /**
     * Check if user is authenticated
     */
    public function isAuthenticated()
    {
        return $this->getCurrentUser() !== null;
    }

    /**
     * Check if user has a specific role
     */
    public function hasRole($role)
    {
        $user = $this->getCurrentUser();
        return $user && $user['role'] === $role;
    }

    /**
     * Check if user is student
     */
    public function isStudent()
    {
        return $this->hasRole('student');
    }

    /**
     * Check if user is teacher
     */
    public function isTeacher()
    {
        return $this->hasRole('teacher');
    }

    /**
     * Verify password
     */
    public function verifyPassword($plainPassword, $hash)
    {
        return password_verify($plainPassword, $hash);
    }

    /**
     * Hash password
     */
    public function hashPassword($password)
    {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => BCRYPT_COST]);
    }

    /**
     * Base64 URL encode
     */
    private function base64UrlEncode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * Base64 URL decode
     */
    private function base64UrlDecode($data)
    {
        return base64_decode(strtr($data, '-_', '+/') . str_repeat('=', 4 - strlen($data) % 4));
    }

    /**
     * Require authentication
     */
    public function requireAuth()
    {
        if (!$this->isAuthenticated()) {
            die(Response::unauthorized('Authentication required'));
        }
    }

    /**
     * Require student role
     */
    public function requireStudent()
    {
        if (!$this->isStudent()) {
            die(Response::forbidden('Student access required'));
        }
    }

    /**
     * Require teacher role
     */
    public function requireTeacher()
    {
        if (!$this->isTeacher()) {
            die(Response::forbidden('Teacher access required'));
        }
    }
}
