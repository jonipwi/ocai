<?php

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
if ($secret != "") {
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

if ($serverToken != $key) {
   print "Error: system failed!"; exit;
}

?>