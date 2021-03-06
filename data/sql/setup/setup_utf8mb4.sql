CREATE TABLE `member` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `group` int(3) NOT NULL DEFAULT 1,
  `status` tinyint(2) NOT NULL DEFAULT 0,
  `file_name` varchar(128) DEFAULT NULL,
  `filesize_total` int(11) NOT NULL DEFAULT 0 COMMENT 'Total file size',
  `register_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0: normal, 1:facebook, 2:twitter, 3:google',
  `sex` varchar(16) DEFAULT NULL,
  `sex_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `birthyear` int(4) DEFAULT NULL,
  `birthyear_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `birthdate` varchar(5) DEFAULT NULL,
  `birthdate_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `login_hash` varchar(255) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `previous_login` datetime DEFAULT NULL,
  `invite_member_id` int(11) NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `birthdate_id` (`birthdate`,`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_auth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_UNIQUE_idx` (`member_id`),
  UNIQUE KEY `email_UNIQUE_idx` (`email`),
  CONSTRAINT `member_auth_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id` int(11) NOT NULL COMMENT 'Member id',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT 'Configuration name',
  `value` text NOT NULL COMMENT 'Configuration value',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `member_id_idx` (`member_id`),
  UNIQUE KEY `member_id_name_UNIQUE_idx` (`member_id`, `name`),
  CONSTRAINT `member_config_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_email_pre` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `code` varchar(24) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_UNIQUE_idx` (`member_id`),
  UNIQUE KEY `token_UNIQUE_idx` (`token`),
  KEY `email_idx` (`email`),
  CONSTRAINT `member_email_pre_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `oauth_provider` (
  `id` tinyint(2) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_oauth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `oauth_provider_id` tinyint(2) NOT NULL,
  `uid` varchar(50) NOT NULL,
  `token` varchar(255) NOT NULL,
  `secret` varchar(255) NULL,
  `expires` int(11) NULL,
  `service_name` varchar(255) NULL,
  `service_url` varchar(255) NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `oauth_provider_id_uid_idx` (`oauth_provider_id`,`uid`),
  KEY `oauth_provider_id_uid_member_idx` (`oauth_provider_id`,`uid`,`member_id`),
  CONSTRAINT `member_oauth_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE,
  CONSTRAINT `oauth_provider_id_oauth_provider_id` FOREIGN KEY (`oauth_provider_id`) REFERENCES `oauth_provider` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_password_pre` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_UNIQUE_idx` (`member_id`),
  UNIQUE KEY `token_UNIQUE_idx` (`token`),
  CONSTRAINT `member_password_pre_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_pre` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NULL,
  `invite_member_id` int(11) NULL,
  `token` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email_idx` (`email`),
  UNIQUE KEY `token_UNIQUE_idx` (`token`),
  UNIQUE KEY `invite_member_id_email_UNIQUE_idx` (`invite_member_id`,`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_delete_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `name` varchar(255) NULL,
  `email` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_UNIQUE_idx` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id_to` int(11) NOT NULL COMMENT 'Target member id',
  `member_id_from` int(11) NOT NULL COMMENT 'Subject member id',
  `is_follow` tinyint(1) DEFAULT NULL COMMENT 'The subject member is followed the target',
  `is_friend` tinyint(1) DEFAULT NULL COMMENT 'The members are friends',
  `is_friend_pre` tinyint(1) DEFAULT NULL COMMENT 'The members are going to be friends',
  `is_access_block` tinyint(1) DEFAULT NULL COMMENT 'The subject member is blocked the target',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_to_from_UNIQUE_idx` (`member_id_to`,`member_id_from`),
  UNIQUE KEY `member_id_from_to_UNIQUE_idx` (`member_id_from`,`member_id_to`),
  KEY `member_id_to_idx` (`member_id_to`),
  KEY `member_id_from_idx` (`member_id_from`),
  CONSTRAINT `member_relation_member_id_from_member_id` FOREIGN KEY (`member_id_from`) REFERENCES `member` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_relation_member_id_to_member_id` FOREIGN KEY (`member_id_to`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves ralations of each members';

CREATE TABLE `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `album` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `name` text COLLATE utf8_unicode_ci NOT NULL,
  `body` text COLLATE utf8_unicode_ci NULL,
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `cover_album_image_id` int(11) DEFAULT NULL,
  `foreign_table` varchar(20) NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `created_at_idx` (`created_at`),
  KEY `member_id_created_at_idx` (`member_id`,`created_at`),
  KEY `public_flag_craeted_at_idx` (`public_flag`,`created_at`),
  KEY `member_id_foreign_table_idx` (`member_id`,`foreign_table`),
  CONSTRAINT `album_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;

CREATE TABLE `album_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) NOT NULL,
  `file_name` varchar(128) NOT NULL,
  `name` text COLLATE utf8_unicode_ci NULL,
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `comment_count` int(11) NOT NULL DEFAULT '0',
  `like_count` int(11) NOT NULL DEFAULT '0',
  `shot_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `album_id_public_flag_id` (`album_id`,`public_flag`,`id`),
  KEY `album_id_public_flag_shot_at` (`album_id`,`public_flag`,`shot_at`),
  KEY `sort_datetime_idx` (`sort_datetime`),
  KEY `file_name_idx` (`file_name`),
  CONSTRAINT `album_image_album_id_album_id` FOREIGN KEY (`album_id`) REFERENCES `album` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;

CREATE TABLE `album_image_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_image_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_album_image_id_UNIQUE_idx` (`member_id`,`album_image_id`),
  KEY `album_image_id_id_idx` (`album_image_id`,`id`),
  CONSTRAINT `album_image_like_album_image_id_album_image_id` FOREIGN KEY (`album_image_id`) REFERENCES `album_image` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `album_image_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_image_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `like_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `album_image_id_created_at` (`album_image_id`,`created_at`),
  KEY `album_image_id_idx` (`album_image_id`),
  CONSTRAINT `album_image_comment_album_image_id_album_image_id` FOREIGN KEY (`album_image_id`) REFERENCES `album_image` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;

CREATE TABLE `album_image_comment_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_image_comment_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_album_image_comment_id_UNIQUE_idx` (`member_id`,`album_image_comment_id`),
  KEY `album_image_comment_id_id_idx` (`album_image_comment_id`,`id`),
  CONSTRAINT `aicl_album_image_comment_id_aic_id` FOREIGN KEY (`album_image_comment_id`) REFERENCES `album_image_comment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `album_image_location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_image_id` int(11) NOT NULL,
  `latitude`  DECIMAL(9,6) NOT NULL DEFAULT '0',
  `longitude` DECIMAL(9,6) NOT NULL DEFAULT '0',
  -- `latlng` geometry NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `album_image_id_UNIQUE_idx` (`album_image_id`),
  KEY `latitude_longitude_idx` (`latitude`,`longitude`),
  CONSTRAINT `album_image_location_album_image_id_album_image_id` FOREIGN KEY (`album_image_id`) REFERENCES `album_image` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- ) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `ua` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;


CREATE TABLE `file` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT 'File name',
  `type` varchar(256) NOT NULL DEFAULT '' COMMENT 'Type of this file',
  `filesize` int(11) NOT NULL DEFAULT '0' COMMENT 'File size',
  `original_filename` text COMMENT 'Original filename',
  `member_id` int(11) DEFAULT NULL,
  `user_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: site member, 1:admin_user',
  `exif` text NULL,
  `shot_at` datetime NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`),
  KEY `user_type_member_id_idx` (`user_type`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves informations of files uploaded';

CREATE TABLE `file_tmp` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT 'File name',
  `type` varchar(256) NOT NULL DEFAULT '' COMMENT 'Type of this file',
  `filesize` int(11) NOT NULL DEFAULT '0' COMMENT 'File size',
  `original_filename` text COMMENT 'Original filename',
  `member_id` int(11) NULL,
  `user_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: site member, 1:admin_user',
  `description` text DEFAULT NULL,
  `exif` text DEFAULT NULL,
  `shot_at` datetime NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`),
  KEY `user_type_member_id_idx` (`user_type`,`member_id`),
  KEY `name_user_type_member_id_idx` (`name`,`user_type`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves informations of temporary files uploaded';


CREATE TABLE `file_tmp_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `file_tmp_id` INT NOT NULL COMMENT 'file_tmp id',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT 'Configuration name',
  `value` text NOT NULL COMMENT 'Configuration value',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  INDEX file_tmp_id_idx (file_tmp_id),
  UNIQUE KEY `file_tmp_id_name_UNIQUE_idx` (`file_tmp_id`, `name`),
  CONSTRAINT `file_tmp_config_file_tmp_id_file_tmp_id` FOREIGN KEY (`file_tmp_id`) REFERENCES `file_tmp` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves configurations of each temporary files';

CREATE TABLE `file_bin` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(64) NOT NULL COMMENT 'File path and name',
  `bin` longblob COMMENT 'Content of file',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves content of files';

CREATE TABLE `file_bin_delete_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(64) NOT NULL COMMENT 'File path and name',
  `is_tmp` tinyint(2) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves content of files';


CREATE TABLE `migration` (
  `name` varchar(50) NOT NULL,
  `type` varchar(25) NOT NULL,
  `version` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `migration` VALUES ('default','app',4);


CREATE TABLE `note` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `is_published` tinyint(2) NOT NULL DEFAULT '0',
  `published_at` datetime NULL,
  `comment_count` int(11) NOT NULL DEFAULT '0',
  `like_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `member_id_is_published_published_at_public_flag_idx` (`member_id`,`is_published`,`published_at`,`public_flag`),
  KEY `member_id_created_at_idx` (`member_id`,`created_at`),
  KEY `public_flag_craeted_at_idx` (`public_flag`,`created_at`),
  KEY `is_published_published_at_public_flag_idx` (`is_published`,`published_at`,`public_flag`),
  CONSTRAINT `note_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;


CREATE TABLE `note_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_note_id_UNIQUE_idx` (`member_id`,`note_id`),
  KEY `note_id_id_idx` (`note_id`,`id`),
  CONSTRAINT `note_like_note_id_note_id` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `note_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `like_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `note_id_id_idx` (`note_id`,`id`),
  KEY `member_id_idx` (`member_id`),
  CONSTRAINT `note_comment_note_id_note_id` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;


CREATE TABLE `note_comment_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_comment_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_note_comment_id_UNIQUE_idx` (`member_id`,`note_comment_id`),
  KEY `note_comment_id_id_idx` (`note_comment_id`,`id`),
  CONSTRAINT `note_comment_like_note_comment_id_note_comment_id` FOREIGN KEY (`note_comment_id`) REFERENCES `note_comment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `note_album_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) NOT NULL,
  `album_image_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `note_id_idx` (`note_id`),
  CONSTRAINT `note_album_image_note_id_note_id` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`) ON DELETE CASCADE,
  CONSTRAINT `note_album_image_album_image_id_album_image_id` FOREIGN KEY (`album_image_id`) REFERENCES `album_image` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_category_id` int(11) DEFAULT NULL COMMENT 'News category id',
  `slug` varchar(64) NOT NULL DEFAULT '' COMMENT 'Identified news (ASCII)',
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `body` text COLLATE utf8_unicode_ci NULL,
  `format` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:text, 1:raw(html_editor), 2:markdown',
  `importance_level` tinyint(2) NOT NULL DEFAULT '0',
  `is_published` tinyint(2) NOT NULL DEFAULT '0',
  `published_at` datetime NULL,
  `users_id` int(11) NOT NULL,
  `is_secure` tinyint(2) NOT NULL DEFAULT '0',
  `token` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug_UNIQUE_idx` (`slug`),
  KEY `created_at_idx` (`created_at`),
  KEY `published_at_idx` (`published_at`),
  KEY `is_published_is_secure_published_at_idx` (`is_published`,`is_secure`,`published_at`)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;

CREATE TABLE `news_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_id` int(11) NOT NULL,
  `file_name` varchar(128) NOT NULL,
  `name` text NULL,
  `shot_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `news_id_created_at` (`news_id`,`created_at`),
  KEY `news_id_idx` (`news_id`),
  KEY `file_name_idx` (`file_name`),
  CONSTRAINT `news_image_news_id_news_id` FOREIGN KEY (`news_id`) REFERENCES `news` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `news_file` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_id` int(11) NOT NULL,
  `file_name` varchar(128) NOT NULL,
  `name` text NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `news_id_created_at` (`news_id`,`created_at`),
  KEY `news_id_idx` (`news_id`),
  KEY `file_name_idx` (`file_name`),
  CONSTRAINT `news_file_news_id_news_id` FOREIGN KEY (`news_id`) REFERENCES `news` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `news_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_id` int(11) NOT NULL,
  `uri` text NOT NULL,
  `label` text NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `news_id_idx` (`news_id`),
  CONSTRAINT `news_link_news_id_news_id` FOREIGN KEY (`news_id`) REFERENCES `news` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `news_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT 'Identified news category name (ASCII)',
  `label` text COLLATE utf8_unicode_ci NOT NULL,
  `sort_order` int(11) DEFAULT NULL COMMENT 'Order to sort',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`),
  KEY `sort_order_idx` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves categories of news';

CREATE TABLE `news_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `news_id` int(11) NOT NULL default '0',
  `tag_id` int(11) NOT NULL default '0',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `news_id_tag_id_UNIQUE_idx` (`news_id`,`tag_id`),
  CONSTRAINT `news_tag_tag_id_tag_id` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON DELETE CASCADE,
  CONSTRAINT `news_tag_news_id_news_id` FOREIGN KEY (`news_id`) REFERENCES `news` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `notice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `foreign_table` varchar(20) NOT NULL COMMENT 'Reference table name',
  `foreign_id` int(11) NOT NULL COMMENT 'The id of reference table',
  `type` tinyint(2) NOT NULL DEFAULT '0',
  `body` text NULL,
  `parent_table` varchar(20) NULL COMMENT 'Use for open page url.',
  `parent_id` int(11) NULL COMMENT 'Use for open page url.',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `foreign_table_foreign_id_type_created_at_idx` (`foreign_table`,`foreign_id`,`type`,`created_at`),
  KEY `parent_table_parent_id_type_idx` (`parent_table`,`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `notice_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `notice_id` int(11) NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `sort_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notice_id_member_id_UNIQUE_idx` (`notice_id`,`member_id`),
  KEY `member_id_is_read_sort_datetime_idx` (`member_id`,`is_read`,`sort_datetime`),
  CONSTRAINT `notice_status_notice_id_notice_id` FOREIGN KEY (`notice_id`) REFERENCES `notice` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notice_status_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `notice_member_from` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notice_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notice_id_member_id_UNIQUE_idx` (`notice_id`,`member_id`),
  CONSTRAINT `notice_member_from_notice_id_notice_id` FOREIGN KEY (`notice_id`) REFERENCES `notice` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notice_member_from_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `notice_mail_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notice_status_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `status` tinyint(2) NOT NULL DEFAULT 0 COMMENT '0:unexecuted, 1:successed and Greater than these are errors',
  `result_message` text NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `notice_status_id_idx` (`notice_status_id`),
  KEY `member_id_idx` (`member_id`),
  CONSTRAINT `notice_mail_queue_notice_status_id` FOREIGN KEY (`notice_status_id`) REFERENCES `notice_status` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notice_mail_queue_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `member_watch_content` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `foreign_table` varchar(20) NULL COMMENT 'Reference table name',
  `foreign_id` int(11) NULL COMMENT 'The id of reference table',
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `foreign_table_foreign_id_member_id_UNIQUE_idx` (`foreign_table`,`foreign_id`,`member_id`),
  CONSTRAINT `member_watch_content_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT 'Identified profile name (ASCII)',
  `caption` text NOT NULL,
  `display_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: display at detail, 1:display at summary, 2:always',
  `information` text NULL,
  `placeholder` text NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'This is a required',
  `is_unique` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Cannot select duplicate item',
  `is_edit_public_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Settable public flag',
  `default_public_flag` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Default of public flag',
  `is_disp_regist` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Shows when registeration',
  `is_disp_config` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Shows when edit',
  `is_disp_search` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Shows when searching',
  `form_type` varchar(32) NOT NULL DEFAULT '' COMMENT 'Form type to input/select',
  `value_type` varchar(32) NOT NULL DEFAULT '' COMMENT 'Type of input value',
  `value_regexp` text COMMENT 'Regular expression',
  `value_min` varchar(32) DEFAULT NULL COMMENT 'Minimum value',
  `value_max` varchar(32) DEFAULT NULL COMMENT 'Maximum value',
  `sort_order` int(11) DEFAULT NULL COMMENT 'Order to sort',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`),
  KEY `display_type_id` (`display_type`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves input/select items for the member profile';

CREATE TABLE `profile_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `label` text NOT NULL COMMENT 'Choice',
  `profile_id` int(11) NOT NULL COMMENT 'Profile id',
  `sort_order` int(11) DEFAULT NULL COMMENT 'Order to sort',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id_idx` (`profile_id`),
  CONSTRAINT `profile_option_profile_id_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves options of profile items';

CREATE TABLE `member_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id` int(11) NOT NULL COMMENT 'Member id',
  `profile_id` int(11) NOT NULL COMMENT 'Profile id',
  `profile_option_id` int(11) DEFAULT NULL COMMENT 'Profile option id',
  `value` text COLLATE utf8_unicode_ci NOT NULL COMMENT 'Text content for this profile item',
  `public_flag` tinyint(4) DEFAULT NULL COMMENT 'Public flag',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `member_id_idx` (`member_id`),
  KEY `profile_id_idx` (`profile_id`),
  KEY `profile_option_id_idx` (`profile_option_id`),
  CONSTRAINT `member_profile_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_profile_profile_id_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_profile_profile_option_id_profile_option_id` FOREIGN KEY (`profile_option_id`) REFERENCES `profile_option` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves informations of every member''''s profile';

CREATE TABLE `member_profile_cache` (
  `member_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `sex` varchar(16) DEFAULT NULL,
  `sex_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `birthyear` int(4) DEFAULT NULL,
  `birthyear_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `birthdate` varchar(5) DEFAULT NULL,
  `birthdate_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `birthday` date DEFAULT NULL,
  `birthday_public_flag` tinyint(2) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`),
  CONSTRAINT `mpc_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;


CREATE TABLE `timeline` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NULL,
  `member_id_to` int(11) NULL,
  `group_id` int(11) NULL,
  `page_id` int(11) NULL,
  `type` tinyint(2) NOT NULL DEFAULT '0',
  `body` text COLLATE utf8_unicode_ci NULL,
  `foreign_table` varchar(20) NULL COMMENT 'Reference table name',
  `foreign_id` int(11) NULL COMMENT 'The id of reference table',
  `source` varchar(64) NULL COMMENT 'The source caption',
  `source_uri` text NULL COMMENT 'The source URI',
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `comment_count` int(11) NOT NULL DEFAULT '0',
  `like_count` int(11) NOT NULL DEFAULT '0',
  `importance_level` tinyint(2) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `member_id_type_idx` (`member_id`,`type`),
  KEY `group_id_idx` (`group_id`),
  KEY `page_id_idx` (`page_id`),
  KEY `foreign_table_foreign_id_type_idx` (`foreign_table`,`foreign_id`,`type`)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;


CREATE TABLE `timeline_cache` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timeline_id` int(11) NOT NULL,
  `member_id` int(11) NULL,
  `member_id_to` int(11) NULL,
  `group_id` int(11) NULL,
  `page_id` int(11) NULL,
  `is_follow` tinyint(1) NOT NULL DEFAULT '0',
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `type` tinyint(2) NOT NULL DEFAULT '0',
  `comment_count` int(11) NOT NULL DEFAULT '0',
  `like_count` int(11) NOT NULL DEFAULT '0',
  `importance_level` tinyint(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `timeline_id_idx` (`timeline_id`),
  UNIQUE KEY `timeline_id_is_follow_UNIQUE_idx` (`timeline_id`,`is_follow`),
  CONSTRAINT `timeline_cache_timeline_id_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `timeline` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `timeline_child_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timeline_id` int(11) NOT NULL,
  `foreign_table` varchar(20) NULL COMMENT 'Reference table name',
  `foreign_id` int(11) NULL COMMENT 'The id of reference table',
  PRIMARY KEY (`id`),
  KEY `timeline_id_idx` (`timeline_id`),
  KEY `foreign_table_foreign_id_timeline_id_idx` (`foreign_table`,`foreign_id`,`timeline_id`),
  CONSTRAINT `timeline_child_data_timeline_id_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `timeline` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `timeline_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timeline_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_timeline_id_UNIQUE_idx` (`member_id`,`timeline_id`),
  KEY `timeline_id_id_idx` (`timeline_id`,`id`),
  CONSTRAINT `timeline_like_timeline_id_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `timeline` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `timeline_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timeline_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `like_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `timeline_id_id_idx` (`timeline_id`,`id`),
  CONSTRAINT `timeline_comment_timeline_id_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `timeline` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;


CREATE TABLE `timeline_comment_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timeline_comment_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_timeline_comment_id_UNIQUE_idx` (`member_id`,`timeline_comment_id`),
  KEY `timeline_comment_id_id_idx` (`timeline_comment_id`,`id`),
  CONSTRAINT `timeline_comment_like_timeline_comment_id_timeline_comment_id` FOREIGN KEY (`timeline_comment_id`) REFERENCES `timeline_comment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `member_follow_timeline` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `timeline_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_timeline_id_UNIQUE_idx` (`member_id`,`timeline_id`),
  CONSTRAINT `member_follow_timeline_member_id_timeline_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_follow_timeline_timeline_id_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `timeline` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `thread` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `member_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL DEFAULT '0',
  `comment_count` int(11) NOT NULL DEFAULT '0',
  `like_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `public_flag_srot_datetime_category_id_idx` (`public_flag`,`sort_datetime`,`category_id`)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;

CREATE TABLE `thread_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_thread_id_UNIQUE_idx` (`member_id`,`thread_id`),
  KEY `thread_id_id_idx` (`thread_id`,`id`),
  CONSTRAINT `thread_like_thread_id_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `thread` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `thread_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `like_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `thread_id_id_idx` (`thread_id`,`id`),
  KEY `member_id_idx` (`member_id`),
  CONSTRAINT `thread_comment_thread_id_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `thread` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4;

CREATE TABLE `thread_comment_like` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_comment_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_thread_comment_id_UNIQUE_idx` (`member_id`,`thread_comment_id`),
  KEY `thread_comment_id_id_idx` (`thread_comment_id`,`id`),
  CONSTRAINT `thread_comment_like_thread_comment_id_thread_comment_id` FOREIGN KEY (`thread_comment_id`) REFERENCES `thread_comment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `thread_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) NOT NULL,
  `file_name` varchar(128) NOT NULL,
  `name` text NULL,
  `shot_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `thread_id_created_at` (`thread_id`,`created_at`),
  KEY `thread_id_idx` (`thread_id`),
  KEY `file_name_idx` (`file_name`),
  CONSTRAINT `thread_image_thread_id_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `thread` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `member_relation_unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id_lower` int(11) NOT NULL COMMENT 'Lower member id',
  `member_id_upper` int(11) NOT NULL COMMENT 'Upper member id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_lower_upper_UNIQUE_idx` (`member_id_lower`,`member_id_upper`),
  KEY `member_id_upper_idx` (`member_id_upper`),
  CONSTRAINT `member_relation_unit_member_id_lower_member_id` FOREIGN KEY (`member_id_lower`) REFERENCES `member` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_relation_unit_member_id_upper_member_id` FOREIGN KEY (`member_id_upper`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Member one-to-one unit';

CREATE TABLE `group` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` text COLLATE utf8_unicode_ci NULL,
  `type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:use for system only, 1:normal',
  `public_flag` tinyint(2) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `group_member` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `group_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `role_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:normal, 1:admin',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id_member_id_UNIQUE_idx` (`group_id`,`member_id`),
  KEY `member_id_idx` (`member_id`),
  CONSTRAINT `group_member_group_id_group_id` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE CASCADE,
  CONSTRAINT `group_member_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `message` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id` int(11) NOT NULL COMMENT 'Sent member id',
  `subject` text COLLATE utf8_unicode_ci NULL,
  `body` text COLLATE utf8_unicode_ci NULL,
  `type` tinyint(2) NOT NULL DEFAULT '1' COMMENT '1:one to one relation message, 2:group massage, 8:site information, 9:system information',
  `foreign_table` varchar(20) NULL COMMENT 'Reference table name',
  `foreign_id` int(11) NULL COMMENT 'The id of reference table',
  `is_sent` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:unsent, 1:sent',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:undeleted, 1:deleted',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sent_at` datetime NULL,
  PRIMARY KEY (`id`),
  KEY `type` (`type`),
  KEY `member_id_sent_at_idx` (`member_id`,`sent_at`),
  KEY `member_id_updated_at_idx` (`member_id`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Use for message master';

CREATE TABLE `message_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) NOT NULL,
  `file_name` varchar(128) NOT NULL,
  `name` text COLLATE utf8_unicode_ci NULL,
  `shot_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `message_id_created_at` (`message_id`,`created_at`),
  KEY `message_id_idx` (`message_id`),
  KEY `file_name_idx` (`file_name`),
  CONSTRAINT `mi_message_id_message_id` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `message_sent_member_relation_unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_relation_unit_id` int(11) NOT NULL,
  `message_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `message_id_member_relation_unit_id_UNIQUE_idx` (`message_id`,`member_relation_unit_id`),
  KEY `member_relation_unit_id_id_idx` (`member_relation_unit_id`,`id`),
  CONSTRAINT `mrmru_mru_id_member_relation_unit_id` FOREIGN KEY (`member_relation_unit_id`) REFERENCES `member_relation_unit` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mrmru_mru_message_id_message_id` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Use for sent message list for one to one members';

CREATE TABLE `message_sent_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `group_id` int(11) NOT NULL,
  `message_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `message_id_group_id_UNIQUE_idx` (`message_id`,`group_id`),
  KEY `group_id_id_idx` (`group_id`,`id`),
  CONSTRAINT `message_group_group_group_id_group_id` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE CASCADE,
  CONSTRAINT `message_group_group_message_id_message_id` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Use for sent message list for groups';

CREATE TABLE `message_sent_admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `message_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `admin_user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `message_id_member_id_UNIQUE_idx` (`message_id`,`member_id`),
  KEY `member_id_idx` (`member_id`),
  CONSTRAINT `message_sent_admin_message_id_message_id` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`) ON DELETE CASCADE,
  CONSTRAINT `message_sent_admin_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Use for sent message list from admin_user';

CREATE TABLE `message_recieved` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id` int(11) NOT NULL COMMENT 'Recieved member id',
  `message_id` int(11) NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:unread, 1:already read',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:undeleted, 1:deleted',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_message_id_UNIQUE_idx` (`member_id`,`message_id`),
  KEY `member_id_id_idx` (`member_id`,`id`),
  KEY `message_id_idx` (`message_id`),
  CONSTRAINT `message_recieved_message_id_message_id` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`) ON DELETE CASCADE,
  CONSTRAINT `message_recieved_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Use for recieved message list for member';

CREATE TABLE `message_recieved_summary` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `member_id` int(11) NOT NULL COMMENT 'Recieved member id',
  `type` tinyint(2) NOT NULL DEFAULT '1' COMMENT '1:one to one relation message, 2:group massage, 8:info message from admin, 9:info message from system',
  `type_related_id` int(11) NOT NULL COMMENT 'The id of reference table. Set id based on type value',
  `last_message_id` int(11) NOT NULL COMMENT 'Last message id for each message type',
  `is_read` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:unread, 1:already read',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `last_sent_at` datetime NOT NULL COMMENT 'Last message sent time for each message type',
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_id_type_type_related_id_UNIQUE_idx` (`member_id`,`type`,`type_related_id`),
  KEY `member_id_last_sent_at_idx` (`member_id`,`last_sent_at`),
  CONSTRAINT `message_recieved_summary_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Use for recieved message list integrated member_relation_unit and group';

CREATE TABLE `message_recieved_mail_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_recieved_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `status` tinyint(2) NOT NULL DEFAULT 0 COMMENT '0:unexecuted, 1:successed and Greater than these are errors',
  `result_message` text NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `status_id_idx` (`status`,`id`),
  KEY `message_recieved_id_idx` (`message_recieved_id`,`id`),
  KEY `member_id_idx` (`member_id`),
  CONSTRAINT `mrmq_message_recieved_id_message_recieved_id` FOREIGN KEY (`message_recieved_id`) REFERENCES `message_recieved` (`id`) ON DELETE CASCADE,
  CONSTRAINT `message_recieved_mail_queue_member_id_member_id` FOREIGN KEY (`member_id`) REFERENCES `member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `site_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT 'Configuration name',
  `value` text COMMENT 'Configuration value',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves configurations of this site';


CREATE TABLE `template` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Serial number',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT 'Configuration name',
  `format` varchar(25) NOT NULL DEFAULT '' COMMENT 'format of template',
  `title` varchar(255) NULL,
  `body` text NULL COMMENT 'Configuration value',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Saves configurations of this site';


CREATE TABLE `site_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_user_id` int(11) NOT NULL,
  `file_name` varchar(128) NOT NULL,
  `name` text NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `file_name_UNIQUE_idx` (`file_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `content_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slug` varchar(64) NOT NULL DEFAULT '' COMMENT 'Identified news (ASCII)',
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `body` text COLLATE utf8_unicode_ci NULL,
  `format` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:text, 1:raw(html_editor), 2:markdown',
  `admin_user_id` int(11) NOT NULL,
  `is_secure` tinyint(2) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug_UNIQUE_idx` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `admin_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `group` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `last_login` datetime NOT NULL,
  `login_hash` varchar(255) NOT NULL,
  `profile_fields` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE_idx` (`username`),
  UNIQUE KEY `email_UNIQUE_idx` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
