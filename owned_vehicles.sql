SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `owned_vehicles` (
  `ID` int(11) NOT NULL,
  `owner` varchar(40) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `nk_garage` varchar(255) NOT NULL DEFAULT 'Pillbox Hill',
  `nk_nametag` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `owned_vehicles`
ADD PRIMARY KEY (`ID`);

ALTER TABLE `owned_vehicles`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;