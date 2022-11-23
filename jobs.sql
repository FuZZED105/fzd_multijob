CREATE TABLE IF NOT EXISTS `phone_jobs` (
  `name` varchar(50) NOT NULL,
  `employees` longtext NOT NULL DEFAULT '[]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;