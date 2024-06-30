<?php

function unserialize_data($data) {
    $out = [];
    foreach($data as $key => $v) {
        $out[$key] = @unserialize($v);
    }
    return $out;
}

http_response_code(200);
header('Content-Type: application/json');

try {
    $data = json_decode(file_get_contents('php://input'), true);
    print json_encode(unserialize_data($data));
} catch(\Exception $e) {
    http_response_code(500);
    print json_encode(['error' => $e->getMessage()]);
}
