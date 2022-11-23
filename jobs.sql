CREATE TABLE `phone_jobs` (
  `citizenid` varchar(100) NOT NULL,
  `job` varchar(100) NOT NULL,
  `grade` int(11) NOT NULL,
  `removeable` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;