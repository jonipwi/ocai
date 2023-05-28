<?php 
session_start();
date_default_timezone_set('Asia/Bangkok');
error_reporting(0);

$MyWebsite = "http://127.0.0.1/";
$host = "localhost";
$user = "root";
$pass = "";
$db   = "ocaidb";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn -> connect_errno) {
   echo "Failed to connect to MySQL: " . $conn -> connect_error;
   exit();
}

if (!$conn->set_charset("utf8")) {
   printf("Error utf8: %s\n", $conn->error);
} else {
   //printf("Charset: %s\n", $conn->character_set_name());
}

?>