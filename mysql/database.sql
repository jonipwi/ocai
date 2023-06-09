CREATE DATABASE `ocaidb`;

USE `ocaidb`;

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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `iplog` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `dt` datetime NOT NULL,
  `ip` char(16) CHARACTER SET utf8mb4 NOT NULL,
  `stat` int(10) unsigned NOT NULL,
  `uid` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `SECONDARY` (`ip`,`uid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `follow` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uid` bigint(20) unsigned NOT NULL COMMENT 'user',
  `fid` bigint(20) unsigned NOT NULL COMMENT 'friend',
  `dt` datetime NOT NULL COMMENT 'dt.follow',
  `data` longtext NOT NULL COMMENT 'details',
  `stat` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `SECONDARY` (`uid`,`fid`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

CREATE TABLE `story` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uid` bigint(20) unsigned NOT NULL COMMENT 'creator',
  `dt` datetime NOT NULL,
  `data` longtext NOT NULL COMMENT 'context',
  `photo` longtext NOT NULL COMMENT 'url',
  `img` longtext NOT NULL COMMENT 'base64',
  `stat` int(10) unsigned NOT NULL,
  `tag` longtext NOT NULL COMMENT '#users',
  PRIMARY KEY (`id`),
  KEY `SECONDARY` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

