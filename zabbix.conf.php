<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '0.0.0.0';
$DB['PORT']     = '3306';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = '123456';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = '0.0.0.0';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'Zabbix';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
