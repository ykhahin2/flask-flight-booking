-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 27, 2025 at 05:38 PM
-- Server version: 8.0.43-0ubuntu0.22.04.1
-- PHP Version: 8.1.2-1ubuntu2.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `booking`
--

-- --------------------------------------------------------

--
-- Table structure for table `air_journeys`
--

CREATE TABLE `air_journeys` (
  `journey_id` int NOT NULL,
  `origin` varchar(255) NOT NULL,
  `destination` varchar(255) NOT NULL,
  `departure_time` time NOT NULL,
  `arrival_time` time NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `available_seats` int NOT NULL,
  `business_seats` int DEFAULT '26',
  `economy_seats` int DEFAULT '104'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `air_journeys`
--

INSERT INTO `air_journeys` (`journey_id`, `origin`, `destination`, `departure_time`, `arrival_time`, `price`, `available_seats`, `business_seats`, `economy_seats`) VALUES
(1, 'Newcastle', 'Bristol', '17:45:00', '19:00:00', '90.00', 130, 29, 105),
(2, 'Bristol', 'Newcastle', '09:00:00', '10:15:00', '90.00', 130, 26, 108),
(3, 'Cardiff', 'Edinburgh', '07:00:00', '08:30:00', '90.00', 130, 26, 104),
(4, 'Bristol', 'Manchester', '12:30:00', '13:30:00', '80.00', 130, 26, 104),
(5, 'Manchester', 'Bristol', '13:20:00', '14:20:00', '80.00', 130, 26, 103),
(6, 'Bristol', 'London', '07:40:00', '08:20:00', '80.00', 130, 26, 104),
(7, 'London', 'Manchester', '13:00:00', '14:00:00', '100.00', 130, 26, 104),
(8, 'Manchester', 'Glasgow', '12:20:00', '13:30:00', '100.00', 130, 26, 104),
(9, 'Bristol', 'Glasgow', '08:40:00', '09:45:00', '110.00', 130, 26, 104),
(10, 'Glasgow', 'Newcastle', '14:30:00', '15:45:00', '100.00', 130, 26, 104),
(11, 'Newcastle', 'Manchester', '16:15:00', '17:05:00', '100.00', 130, 26, 104),
(12, 'Manchester', 'Bristol', '18:25:00', '19:30:00', '80.00', 130, 26, 104),
(13, 'Bristol', 'Manchester', '06:20:00', '07:20:00', '80.00', 130, 26, 104),
(14, 'Portsmouth', 'Dundee', '12:00:00', '14:00:00', '120.00', 130, 26, 104),
(16, 'Edinburgh', 'Cardiff', '18:30:00', '20:00:00', '90.00', 130, 26, 104),
(17, 'Southampton', 'Manchester', '12:00:00', '13:30:00', '90.00', 130, 26, 104),
(18, 'Manchester', 'Southampton', '19:00:00', '20:30:00', '90.00', 130, 26, 104),
(19, 'Birmingham', 'Newcastle', '17:00:00', '17:45:00', '100.00', 130, 26, 104),
(20, 'Newcastle', 'Birmingham', '07:00:00', '07:45:00', '100.00', 130, 26, 104),
(24, 'Liverpool', 'London', '12:00:00', '14:00:00', '100.00', 50, 10, -16),
(26, 'Manchester', 'Brighton', '12:00:00', '14:00:00', '50.00', 150, 30, 120);

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int NOT NULL,
  `journey_type` varchar(255) DEFAULT 'Air',
  `journey_date` date DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `journey_id` int DEFAULT NULL,
  `seats` int NOT NULL DEFAULT '1',
  `total_price` decimal(10,2) DEFAULT NULL,
  `seat_type` enum('business','economy') NOT NULL,
  `status` enum('active','cancelled','completed') DEFAULT 'active',
  `cancellation_charge` decimal(10,2) DEFAULT '0.00',
  `refund_amount` decimal(10,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `journey_type`, `journey_date`, `user_id`, `journey_id`, `seats`, `total_price`, `seat_type`, `status`, `cancellation_charge`, `refund_amount`) VALUES
(22, 'Air', '2025-06-20', 7, 6, 1, '80.00', 'economy', 'cancelled', '32.00', '48.00'),
(23, 'Air', '2025-05-30', 3, 5, 1, '80.00', 'economy', 'active', '0.00', '0.00'),
(24, 'Air', '2025-06-14', 8, 6, 1, '80.00', 'economy', 'cancelled', '32.00', '48.00'),
(25, 'Air', '2025-06-07', 3, 24, 1, '100.00', 'economy', 'active', '0.00', '0.00'),
(26, 'Air', '2025-06-22', 3, 24, 55, '5500.00', 'economy', 'active', '0.00', '0.00'),
(27, 'Air', '2025-06-15', 9, 5, 1, '80.00', 'economy', 'cancelled', '32.00', '48.00'),
(28, 'Air', '2025-06-12', 10, 14, 1, '120.00', 'economy', 'cancelled', '48.00', '72.00');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int NOT NULL,
  `booking_id` int NOT NULL,
  `payment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_amount` decimal(10,2) NOT NULL,
  `payment_status` enum('paid','refunded','partial_refund') DEFAULT 'paid'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `role` enum('admin','customer') DEFAULT 'customer',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`, `role`, `created_at`, `name`) VALUES
(3, 'admin3', 'scrypt:32768:8:1$7JSnIwE4rkgbVqdL$1a0614c3836d68f89410a8a5edf9686398ed68201cfc94b7b1d455dbf8f175d7d5a452b511c7635016117333590573299dbdb4dbc78ba35dc4997fbbac6a7e6b', 'test@test.com', 'admin', '2025-04-02 19:40:01', 'admin3'),
(7, 'test', 'scrypt:32768:8:1$BTWLw0bg8EPybkyP$5fb4d510736c5d264ba32b91dfd52362646e34e3c7f8550d4ffd10b04be8257857c77bb77a60bf5373a9f90cf624fc5a1f2e7e11a16b850b6bfbc8e862bb4e6d', 'test@test.com', 'customer', '2025-05-03 10:50:31', 'john doe'),
(8, 'test2', 'scrypt:32768:8:1$JL7EyWIB9DH68Vq2$3b5e22690fbed1517ea789f9dea448d893d558c559e36973735a13de3abe723d8986b3129b430825ca2053a7d61d978c31ba248765873b77dc2dd683ae4a4767', 'test@test.com', 'customer', '2025-05-03 10:55:30', 'john doe'),
(9, 'test3', 'scrypt:32768:8:1$EQMlGm9L27bauayP$0d6a47f231953adb947c8e2977044715b215d4adae8449c67b37b7eb58b4ea84b1ad13b659b5465f7b3e6de850c8ebd90377a60aa4d68905029a4fe5db9b7209', 'test@test.com', 'customer', '2025-05-03 11:01:03', 'john doe'),
(10, 'test4', 'scrypt:32768:8:1$WVVcoDGWFgoz5AgR$983d3bde8dc0e4b8ebb0094c905ae17d0129708e3b1f9a683b5e7aab0be209b9498328008b4285b76663468474fc6f5525201de1be2c0dc767b8125ed7a9767c', 'test@test.com', 'customer', '2025-05-03 11:08:14', 'john doe');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `air_journeys`
--
ALTER TABLE `air_journeys`
  ADD PRIMARY KEY (`journey_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `journey_id` (`journey_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `payments_ibfk_1` (`booking_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `air_journeys`
--
ALTER TABLE `air_journeys`
  MODIFY `journey_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`journey_id`) REFERENCES `air_journeys` (`journey_id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
