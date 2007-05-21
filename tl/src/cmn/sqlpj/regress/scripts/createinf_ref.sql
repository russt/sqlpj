-- DROP TABLE IF EXISTS `branch`;
CREATE TABLE `branch` (
    `branchid` bigint(11) NOT NULL auto_increment,
    `reposid` bigint(10) NOT NULL default 0,
    `name` varchar(50) NULL,
    `cvsbranchname` varchar(50) NULL,
    `noticerelease` varchar(5) NOT NULL default '0',
    `resistance` varchar(5) NULL,
    `activeflag` varchar(5) NULL,
    `createdby` varchar(20) NOT NULL,
    `createdate` datetime NULL,
    `updatedby` varchar(20) NOT NULL,
    `updatedate` datetime NULL,
    `productid` bigint(10) NOT NULL,
    `status` varchar(50) NULL,
    `status_url` varchar(100) NULL,
    `show_in_in` varchar(2) NULL,
    UNIQUE INDEX `branch_unq_idx` (`productid`, `reposid`, `name`),
    INDEX `branch_idx` (`branchid`, `productid`, `reposid`, `name`),
    INDEX `BRANCH_CVS_REPOS_FK` (`reposid`)
);

-- DROP TABLE IF EXISTS `branch_modules`;
CREATE TABLE `branch_modules` (
    `branchid` bigint(11) NOT NULL default 0,
    `moduleid` bigint(11) NOT NULL default 0,
    `resistance` varchar(5) NULL,
    PRIMARY KEY (`branchid`, `moduleid`)
);

-- DROP TABLE IF EXISTS `buglist`;
CREATE TABLE `buglist` (
    `noticeid` bigint(11) NOT NULL default 0,
    `bug` varchar(20) NULL,
    `bugtype` char(1) NULL,
    INDEX `buglist_idx` (`noticeid`)
);

-- DROP TABLE IF EXISTS `cvs2inf_error_defs`;
CREATE TABLE `cvs2inf_error_defs` (
    `err_num` bigint(10) NOT NULL default 0,
    `err_text` varchar(20) NULL,
    PRIMARY KEY (`err_num`)
);

-- DROP TABLE IF EXISTS `cvs_diff_prefs`;
CREATE TABLE `cvs_diff_prefs` (
    `diffid` char(2) NULL,
    `name` varchar(20) NULL
);

-- DROP TABLE IF EXISTS `cvs_email_prefs`;
CREATE TABLE `cvs_email_prefs` (
    `userid` varchar(20) NOT NULL,
    `reposid` bigint(10) NOT NULL default 0,
    `file_filter` varchar(2000) NULL,
    `diff_pref` varchar(10) NULL,
    `want_diffs` varchar(5) NULL,
    `last_transid` bigint(11) NULL,
    `repeat_interval` bigint(10) NULL,
    `last_run_time` decimal(20,0) NULL,
    `reset_date` datetime NULL,
    `suspend` bigint(10) NULL,
    `createdby` varchar(20) NOT NULL,
    `createdate` datetime NULL,
    `updatedby` varchar(20) NOT NULL,
    `updatedate` datetime NULL,
    INDEX `cvs_email_1_idx` (`userid`, `reposid`)
);

-- DROP TABLE IF EXISTS `cvs_email_prefs_branch`;
CREATE TABLE `cvs_email_prefs_branch` (
    `userid` varchar(20) NOT NULL,
    `reposid` bigint(10) NOT NULL default 0,
    `branchid` bigint(11) NOT NULL default 0,
    UNIQUE INDEX `cvs_email_prefs_3_idx` (`userid`, `reposid`, `branchid`)
);

-- DROP TABLE IF EXISTS `cvs_filelist`;
CREATE TABLE `cvs_filelist` (
    `fileid` bigint(11) NOT NULL auto_increment,
    `userid` varchar(20) NULL,
    `noticeid` bigint(11) NOT NULL,
    `branch` varchar(100) NULL,
    `useruid` bigint(11) NULL default -1,
    `login` varchar(25) NULL,
    `reposid` bigint(10) NULL,
    `transtime` bigint(14) NULL,
    `cvsdir` varchar(255) NULL,
    `cvsfile` varchar(255) NULL,
    `old_rev` varchar(255) NULL,
    `new_rev` varchar(20) NULL,
    `opt_type` varchar(10) NULL,
    `cvstype` varchar(2) NULL,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    PRIMARY KEY (`fileid`),
    UNIQUE INDEX `CVS_FILELIST_UNQ` (`reposid`, `cvsdir`, `cvsfile`, `transtime`, `old_rev`, `new_rev`),
    INDEX `cvs_filelist_1_idx` (`cvsdir`),
    INDEX `cvs_filelist_file_idx` (`cvsfile`),
    INDEX `cvs_filelist_idx` (`noticeid`, `userid`, `fileid`, `useruid`, `login`, `transtime`, `old_rev`, `new_rev`, `reposid`)
);

-- DROP TABLE IF EXISTS `cvs_modules`;
CREATE TABLE `cvs_modules` (
    `id` bigint(11) NOT NULL auto_increment,
    `moduleid` bigint(11) NOT NULL default 0,
    `reposid` bigint(10) NOT NULL default 0,
    `name` varchar(50) NOT NULL,
    `activeflag` bigint(10) NULL default 0,
    `createdby` bigint(11) NULL,
    `createdate` datetime NULL,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `cvs_modules_reposid_idx` (`reposid`, `moduleid`, `name`),
    INDEX `cvs_modules_idx` (`reposid`, `moduleid`, `name`, `activeflag`)
);

-- DROP TABLE IF EXISTS `cvs_repos`;
CREATE TABLE `cvs_repos` (
    `reposid` bigint(10) NOT NULL auto_increment,
    `repos` varchar(128) NULL,
    `last_transid` bigint(11) NULL,
    `signature` varchar(14) NULL,
    `createdby` varchar(20) NULL,
    `created` datetime NULL,
    `updatedby` varchar(20) NULL,
    `updated` datetime NULL,
    `productid` bigint(10) NULL,
    UNIQUE INDEX `CVS_REPOS_UNQ_IDX` (`repos`),
    INDEX `cvs_repos_idx` (`reposid`, `last_transid`, `repos`, `signature`)
);

-- DROP TABLE IF EXISTS `cvs_repos_admin`;
CREATE TABLE `cvs_repos_admin` (
    `reposid` bigint(10) NOT NULL default 0,
    `cvsroot` varchar(100) NULL,
    `cvsweburl` varchar(100) NULL,
    `commit_log` varchar(250) NULL,
    `out_file` varchar(250) NULL,
    `cvsloop` bigint(10) NULL,
    `activeflag` int(1) NULL,
    `createdby` bigint(11) NULL,
    `created` datetime NULL,
    `updatedby` varchar(20) NULL,
    `updated` datetime NULL,
    `repostype` varchar(10) NULL,
    PRIMARY KEY (`reposid`)
);

-- DROP TABLE IF EXISTS `cvs_translog`;
CREATE TABLE `cvs_translog` (
    `reposid` bigint(10) NULL,
    `fileid` bigint(11) NULL,
    `transid` bigint(11) NULL,
    `signature` varchar(14) NULL,
    INDEX `cvs_translog_idx` (`transid`, `fileid`, `reposid`, `signature`)
);

-- DROP TABLE IF EXISTS `impact`;
CREATE TABLE `impact` (
    `impactid` bigint(10) NOT NULL auto_increment,
    `name` varchar(50) NULL,
    `createdby` varchar(20) NULL,
    `createdate` datetime NULL,
    PRIMARY KEY (`impactid`)
);

-- DROP TABLE IF EXISTS `module`;
CREATE TABLE `module` (
    `moduleid` bigint(11) NOT NULL auto_increment,
    `productid` bigint(10) NOT NULL default 0,
    `name` varchar(32) NULL,
    `alias` varchar(50) NULL,
    `description` varchar(255) NULL,
    `activeflag` varchar(5) NULL,
    `createdby` bigint(11) NULL,
    `createdate` datetime NULL,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    `approvers` varchar(100) NULL,
    `show_in_in` varchar(2) NULL,
    `resistance` varchar(5) NULL,
    INDEX `module_idx` (`moduleid`, `productid`, `name`)
);

-- DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
    `noticeid` bigint(11) NOT NULL auto_increment,
    `statusid` char(1) NOT NULL,
    `branchid` bigint(11) NOT NULL default 0,
    `productid` bigint(11) NOT NULL default 0,
    `noticerelease` varchar(50) NULL,
    `moduleid` bigint(11) NOT NULL default 0,
    `userid` varchar(20) NOT NULL default '0',
    `reviewer` varchar(255) NULL,
    `originationdate` datetime NULL,
    `planneddate` datetime NULL,
    `integrateddate` datetime NULL,
    `subject` varchar(150) NULL,
    `description` longtext NULL,
    `gui` bigint(10) NULL default 0,
    `docs` bigint(10) NULL default 0,
    `l10n` bigint(10) NULL default 0,
    `i18n` bigint(10) NULL default 0,
    `impactid` bigint(10) NULL,
    `multi_user` bigint(10) NULL default 0,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    `build` int(1) NULL,
    INDEX `notice_2_idx` (`branchid`, `noticerelease`),
    INDEX `notice_idx` (`noticeid`, `statusid`, `productid`, `moduleid`, `branchid`, `userid`)
);

-- DROP TABLE IF EXISTS `notice_approval`;
CREATE TABLE `notice_approval` (
    `noticeid` decimal(20,0) NOT NULL default 0,
    `status` varchar(15) NULL,
    `noticecomment` varchar(2000) NULL,
    `approver` varchar(20) NULL,
    `approvaldate` varchar(14) NULL,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    INDEX `approval_idx` (`noticeid`, `status`)
);

-- DROP TABLE IF EXISTS `notice_approval_history`;
CREATE TABLE `notice_approval_history` (
    `id` bigint(11) NOT NULL auto_increment,
    `noticeid` decimal(20,0) NOT NULL default 0,
    `status` varchar(15) NULL,
    `noticecomment` varchar(2000) NULL,
    `approver` varchar(20) NULL,
    `approvaldate` varchar(14) NULL,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    PRIMARY KEY (`id`),
    INDEX `noticeid_idx` (`noticeid`)
);

-- DROP TABLE IF EXISTS `notice_history`;
CREATE TABLE `notice_history` (
    `id` bigint(11) NOT NULL auto_increment,
    `noticeid` bigint(11) NOT NULL default 0,
    `statusid` char(1) NOT NULL,
    `branchid` bigint(11) NOT NULL default 0,
    `productid` bigint(11) NOT NULL default 0,
    `noticerelease` varchar(50) NULL,
    `moduleid` bigint(11) NOT NULL default 0,
    `userid` varchar(20) NOT NULL default '0',
    `reviewer` varchar(255) NULL,
    `originationdate` datetime NULL,
    `planneddate` datetime NULL,
    `integrateddate` datetime NULL,
    `subject` varchar(150) NULL,
    `description` longtext NULL,
    `gui` bigint(10) NULL default 0,
    `docs` bigint(10) NULL default 0,
    `l10n` bigint(10) NULL default 0,
    `i18n` bigint(10) NULL default 0,
    `impactid` bigint(10) NULL,
    `multi_user` bigint(10) NULL default 0,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    `build` int(1) NULL,
    PRIMARY KEY (`id`),
    INDEX `notice_1_idx` (`noticeid`)
);

-- DROP TABLE IF EXISTS `notice_related_in`;
CREATE TABLE `notice_related_in` (
    `noticeid` bigint(11) NOT NULL,
    `related_in` bigint(11) NULL,
    INDEX `notice_related_in_idx` (`noticeid`, `related_in`)
);

-- DROP TABLE IF EXISTS `preferences`;
CREATE TABLE `preferences` (
    `userid` varchar(20) NOT NULL default '0',
    `productid` bigint(11) NOT NULL default 0,
    `branchid` bigint(11) NOT NULL default 0,
    `moduleid` bigint(11) NOT NULL default 0,
    `reviewer` varchar(255) NULL,
    `diff_pref` varchar(10) NULL,
    `want_diffs` bigint(10) NULL,
    `emailgui` bigint(10) NULL,
    `activeflag` bigint(10) NULL,
    `createdby` varchar(20) NULL,
    `createdate` datetime NULL,
    `updatedby` varchar(20) NULL,
    `updatedate` datetime NULL,
    PRIMARY KEY (`userid`)
);

-- DROP TABLE IF EXISTS `preferences_email_branch`;
CREATE TABLE `preferences_email_branch` (
    `userid` varchar(20) NOT NULL default '0',
    `branchid` bigint(11) NOT NULL default 0,
    UNIQUE INDEX `userid_2_idx` (`userid`, `branchid`)
);

-- DROP TABLE IF EXISTS `preferences_email_module`;
CREATE TABLE `preferences_email_module` (
    `userid` varchar(20) NOT NULL default '0',
    `moduleid` bigint(11) NOT NULL default 0,
    UNIQUE INDEX `preferences_email_3_idx` (`userid`, `moduleid`)
);

-- DROP TABLE IF EXISTS `preferences_email_product`;
CREATE TABLE `preferences_email_product` (
    `userid` varchar(20) NOT NULL default '0',
    `productid` bigint(11) NOT NULL default 0,
    UNIQUE INDEX `userid_4_idx` (`userid`, `productid`)
);

-- DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
    `productid` bigint(10) NOT NULL auto_increment,
    `name` varchar(64) NULL,
    `description` varchar(255) NULL,
    `notification` varchar(255) NULL,
    `activeflag` varchar(5) NULL,
    `createdby` bigint(11) NULL,
    `created` datetime NULL,
    `updatedby` varchar(11) NULL,
    `updated` datetime NULL,
    `highimpactalias` varchar(100) NULL,
    `allintegrationsalias` varchar(100) NULL,
    `guiintegrationalias` varchar(100) NULL,
    `docsalias` varchar(100) NULL,
    `l10nalias` varchar(100) NULL,
    `i18nalias` varchar(100) NULL,
    `owner` varchar(100) NULL,
    `director` varchar(100) NULL,
    `lists` varchar(256) NULL,
    `buildalias` varchar(100) NULL,
    `role_name` varchar(50) NULL,
    PRIMARY KEY (`productid`),
    UNIQUE INDEX `productid_idx` (`productid`, `name`)
);

-- DROP TABLE IF EXISTS `status`;
CREATE TABLE `status` (
    `statusid` char(1) NOT NULL,
    `name` varchar(16) NULL,
    INDEX `status_idx` (`statusid`, `name`)
);

-- DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile` (
    `userid` varchar(20) NOT NULL default '0',
    `name` varchar(50) NULL,
    `emailaddr` varchar(100) NULL,
    `login` varchar(20) NULL,
    `employeetype` varchar(20) NULL default 'Employee',
    `createdate` datetime NULL,
    INDEX `user_profile_idx` (`userid`, `name`, `emailaddr`, `login`, `employeetype`)
);

-- DROP TABLE IF EXISTS `validation_table`;
CREATE TABLE `validation_table` (
    `column_1` varchar(10) NOT NULL
);

