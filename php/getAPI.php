<?php

/** 
 * Get header Authorization
 * */
function getAuthorizationHeader(){
    $headers = null;
    if (isset($_SERVER['Authorization'])) {
        $headers = trim($_SERVER["Authorization"]);
    }
    else if (isset($_SERVER['HTTP_AUTHORIZATION'])) { //Nginx or fast CGI
        $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
    } elseif (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        // Server-side fix for bug in old Android versions (a nice side-effect of this fix means we don't care about capitalization for Authorization)
        $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
        //print_r($requestHeaders);
        if (isset($requestHeaders['Authorization'])) {
            $headers = trim($requestHeaders['Authorization']);
        }
    }
    return $headers;
}

/**
 * get access token from header
 * */
function getBearerToken() {
    $headers = getAuthorizationHeader();
    // HEADER: Get the access token from the header
    if (!empty($headers)) {
        if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
            return $matches[1];
        }
    }
    return null;
}

function getRequestHeaders() {
    $headers = array();
    foreach($_SERVER as $key => $value) {
        if (substr($key, 0, 5) <> 'HTTP_') {
            continue;
        }
        $header = str_replace(' ', '-', ucwords(str_replace('_', ' ', strtolower(substr($key, 5)))));
        $headers[$header] = $value;
    }
    return $headers;
}

$bearer  = getBearerToken();

$f = fopen("./header.log", "w+");
fputs($f, $bearer);
fclose($f);

$headers = getRequestHeaders();
$secret  = "";
foreach ($headers as $header => $value) {
    if ((strtolower($header)) == "x-device") {
	$device = "$header|$value";
    }
    if ((strtolower($header)) == "x-target") {
	$target = "$header|$value";
    }
    if ((strtolower($header)) == "x-key") {
	$secret = "$header|$value";
    } 
}

$serverToken = "[SERVER_BASE_API_TOKEN]";   //Change this into your API Key
if (($secret != "") || ($bearer != "")) {
   $sdevice  = explode("|", $device); 
   $deviceid = $sdevice[1];
   $starget  = explode("|", $target); 
   $targetid = $starget[1];
   $skey     = explode("|", $secret); 
   $key      = $skey[1];
}

if ($deviceid == "") {
   print "Error: device failed!"; exit;
}

if ($bearer == $serverToken) {
} else {
  if ($serverToken != $key) {
     print "Error: system failed!"; exit;
  }
}

?>