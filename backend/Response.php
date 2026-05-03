<?php
/**
 * API Response Handler
 * Standardized response format for all API endpoints
 */

class Response
{
    private static $statusCode = 200;
    private static $data = [];
    private static $message = '';
    private static $errors = [];

    /**
     * Send success response
     */
    public static function success($data = [], $message = 'Success', $statusCode = 200)
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');

        $response = [
            'status' => 'success',
            'message' => $message,
            'data' => $data,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Send error response
     */
    public static function error($message = 'Error', $statusCode = 400, $errors = [])
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');

        $response = [
            'status' => 'error',
            'message' => $message,
            'errors' => $errors,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Send validation error response
     */
    public static function validation($errors = [])
    {
        http_response_code(422);
        header('Content-Type: application/json');

        $response = [
            'status' => 'validation_error',
            'message' => 'Validation failed',
            'errors' => $errors,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Send unauthorized response
     */
    public static function unauthorized($message = 'Unauthorized')
    {
        http_response_code(401);
        header('Content-Type: application/json');

        $response = [
            'status' => 'error',
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Send forbidden response
     */
    public static function forbidden($message = 'Forbidden')
    {
        http_response_code(403);
        header('Content-Type: application/json');

        $response = [
            'status' => 'error',
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Send not found response
     */
    public static function notFound($message = 'Resource not found')
    {
        http_response_code(404);
        header('Content-Type: application/json');

        $response = [
            'status' => 'error',
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Send paginated response
     */
    public static function paginated($data = [], $page = 1, $pageSize = 10, $total = 0, $message = 'Success')
    {
        http_response_code(200);
        header('Content-Type: application/json');

        $response = [
            'status' => 'success',
            'message' => $message,
            'data' => $data,
            'pagination' => [
                'page' => (int)$page,
                'pageSize' => (int)$pageSize,
                'total' => (int)$total,
                'pages' => ceil($total / $pageSize)
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ];

        return json_encode($response);
    }

    /**
     * Set CORS headers
     */
    public static function setCORS()
    {
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        header('Access-Control-Max-Age: 3600');

        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit();
        }
    }
}
