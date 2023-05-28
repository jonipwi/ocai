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

/************************** TABLES *********************************
CREATE TABLE `auths` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `hp` char(25) COLLATE utf8_unicode_ci NOT NULL COMMENT '25-digit',
  `nick` char(15) COLLATE utf8_unicode_ci NOT NULL COMMENT '15-digit',
  `dt` datetime NOT NULL COMMENT 'bangkok/jkt',
  `otp` char(6) CHARACTER SET utf8mb4 NOT NULL COMMENT '6-digit',
  `tipe` char(1) CHARACTER SET utf8mb4 NOT NULL COMMENT 'A,B,C,D',
  `stat` int(10) unsigned NOT NULL COMMENT '0,1,2,400',
  `act` int(10) unsigned NOT NULL COMMENT '0,1,400',
  `data` longtext COLLATE utf8_unicode_ci NOT NULL COMMENT 'nosql',
  `iplog` char(15) COLLATE utf8_unicode_ci NOT NULL COMMENT '15-digit',
  `alatid` char(100) COLLATE utf8_unicode_ci NOT NULL COMMENT '100-digit',
  PRIMARY KEY (`id`),
  KEY `SECONDARY` (`hp`,`nick`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci

CREATE TABLE `iplog` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `dt` datetime NOT NULL,
  `ip` char(16) CHARACTER SET utf8mb4 NOT NULL,
  `stat` int(10) unsigned NOT NULL,
  `uid` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `SECONDARY` (`ip`,`uid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
?>