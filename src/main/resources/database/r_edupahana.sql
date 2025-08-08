-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 08, 2025 at 01:37 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `r_edupahana`
--

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

CREATE TABLE `bills` (
  `bill_id` int(11) NOT NULL,
  `bill_number` varchar(20) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `cashier_id` int(11) DEFAULT NULL,
  `bill_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `sub_total` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) DEFAULT 0.00,
  `tax` decimal(10,2) DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_status` enum('PAID','PENDING','CANCELLED') DEFAULT 'PAID',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bills`
--

INSERT INTO `bills` (`bill_id`, `bill_number`, `customer_id`, `cashier_id`, `bill_date`, `sub_total`, `discount`, `tax`, `total_amount`, `payment_status`, `is_active`, `created_date`, `updated_date`) VALUES
(36, 'BILL20250806191530', 14, 1, '2025-08-06 13:45:30', 1500.00, 20.00, 0.00, 1480.00, 'PAID', 1, '2025-08-06 13:45:30', '2025-08-06 13:45:30'),
(37, 'BILL20250806192052', 5, 1, '2025-08-06 13:50:52', 2736.00, 0.00, 0.00, 2736.00, 'PAID', 1, '2025-08-06 13:50:52', '2025-08-06 13:50:52'),
(38, 'BILL20250807010451', 16, 13, '2025-08-06 19:34:51', 400.00, 0.00, 0.00, 400.00, 'PAID', 1, '2025-08-06 19:34:51', '2025-08-06 19:34:51'),
(39, 'BILL20250807135137', 44, 1, '2025-08-07 08:21:37', 900.00, 26.00, 0.00, 874.00, 'PAID', 1, '2025-08-07 08:21:37', '2025-08-07 08:21:37'),
(40, 'BILL20250807135551', 45, 13, '2025-08-07 08:25:51', 906.00, 0.00, 0.00, 906.00, 'PAID', 1, '2025-08-07 08:25:51', '2025-08-07 08:25:51'),
(41, 'BILL20250807140406', 45, 13, '2025-08-07 08:34:06', 850.00, 0.00, 0.00, 850.00, 'PAID', 1, '2025-08-07 08:34:06', '2025-08-07 08:34:06');

-- --------------------------------------------------------

--
-- Table structure for table `bill_items`
--

CREATE TABLE `bill_items` (
  `bill_item_id` int(11) NOT NULL,
  `bill_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bill_items`
--

INSERT INTO `bill_items` (`bill_item_id`, `bill_id`, `item_id`, `quantity`, `unit_price`, `total_price`, `created_date`, `updated_date`) VALUES
(27, 36, 54, 3, 500.00, 1500.00, '2025-08-06 13:45:30', '2025-08-06 13:45:30'),
(28, 37, 55, 6, 456.00, 2736.00, '2025-08-06 13:50:52', '2025-08-06 13:50:52'),
(29, 38, 57, 1, 400.00, 400.00, '2025-08-06 19:34:51', '2025-08-06 19:34:51'),
(30, 39, 56, 2, 450.00, 900.00, '2025-08-07 08:21:37', '2025-08-07 08:21:37'),
(31, 40, 55, 1, 456.00, 456.00, '2025-08-07 08:25:51', '2025-08-07 08:25:51'),
(32, 40, 56, 1, 450.00, 450.00, '2025-08-07 08:25:51', '2025-08-07 08:25:51'),
(33, 41, 57, 1, 400.00, 400.00, '2025-08-07 08:34:06', '2025-08-07 08:34:06'),
(34, 41, 56, 1, 450.00, 450.00, '2025-08-07 08:34:06', '2025-08-07 08:34:06');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `customer_id` int(11) NOT NULL,
  `account_number` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`customer_id`, `account_number`, `name`, `address`, `phone`, `email`, `created_date`, `updated_date`, `is_active`) VALUES
(1, 'ACC001', 'Sunil Perera', 'No.123, Galle Road, Colombo', '0771234567', 'sunil@email.com', '2025-08-02 17:43:38', '2025-08-03 11:57:37', 0),
(2, 'ACC002', 'Kamala Silva', 'No.45, Kandy Road, Kandy', '0777654321', 'kamala@email.com', '2025-08-02 17:43:38', '2025-08-07 07:42:41', 0),
(3, 'ACC202508001', 'maleesha', 'sasas', '0771717599', 'ravindu@gmail.com', '2025-08-03 12:21:55', '2025-08-06 14:53:33', 0),
(5, 'ACC202508002', 'asasas', 'wewewe', '0771717599', 'rashmikadinal599@gmail.com', '2025-08-04 14:53:27', '2025-08-04 14:53:27', 1),
(6, 'ACC202508003', 'horo movie', 'rrrrrrrrrrrrr', '0771717599', 'wewewewe@gmail.com', '2025-08-04 14:53:48', '2025-08-04 14:54:16', 0),
(10, 'ACC202508004', 'loku sdfpoth', 'sdfsdf', '0112345682', 'kasunsdf@gmail.com', '2025-08-05 19:07:46', '2025-08-06 14:53:36', 0),
(13, 'ACC202508397B48', 'maleesha123', 'cccccccccccccc', '0771717599', 'raashmka@gmail.com', '2025-08-06 07:47:15', '2025-08-06 08:16:17', 0),
(14, 'ACC202508E2B50A', 'asas', 'rr', '0771717599', 'kasqweun@gmail.com', '2025-08-06 07:47:34', '2025-08-06 08:40:49', 1),
(15, 'ACC202508E5C5B2', 'ass', 'assssssssssssssssssssssssssss', '0771717599', 'kasuasasn@gmail.com', '2025-08-06 07:53:21', '2025-08-06 08:39:13', 0),
(16, 'ACC202508EA86AD', 'horo asmovie', 'aaa', '0771717599', 'asssssssdmin@pahanaedu.lk', '2025-08-06 07:55:21', '2025-08-07 07:42:39', 0),
(17, 'ACC202508043384', 'à¶»à·à·', 'âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·âà¶»à·', '0771717599', 'ravindu@gmail.com', '2025-08-06 08:25:51', '2025-08-06 14:53:39', 0),
(18, 'ACC2025088E0AB3', 'maheesha', 'rashmika', '0771717599', 'mal@gmail.com', '2025-08-06 08:40:37', '2025-08-06 14:53:35', 0),
(19, 'ACC2025082DC513', 'maheeshaeee', NULL, '0771414566', 'kasun@gmail.com', '2025-08-06 11:01:26', '2025-08-06 13:05:44', 0),
(20, 'ACC2025085D08CC', 'maleesha', 'rfh', '0771717599', 'ravindu@gmail.com', '2025-08-06 13:46:40', '2025-08-06 14:53:31', 0),
(21, 'ACC20250895F5FE', 'maleesha123', 'sdfsdfsdfsdf', '0771717599', 'kasuddfsdfn@gmail.com', '2025-08-06 13:53:38', '2025-08-06 14:52:55', 0),
(22, 'ACC202508BF8697', 'rashmika', 'No.45, Kandy Road, Kandy', '0703020319', 'rashmika@gmail.com', '2025-08-06 16:07:38', '2025-08-07 07:42:35', 0),
(23, 'ACC2025083B755E', 'maheesha', 'hhhhh', '0771717599', 'asdadf@gmail.com', '2025-08-06 16:08:22', '2025-08-07 07:42:43', 0),
(24, 'ACC202508A9435B', 'dsad', 'sadsadasd', '0112345684', 'manager1@gmail.com', '2025-08-06 19:05:43', '2025-08-06 19:05:43', 1),
(32, 'ACC202508BC30B1', 'maheeshadsf', 'à·à·à¶»à·à·à·âà¶»à·', '0771717599', 'jaskdSn@pahanaedu.lk', '2025-08-06 19:13:17', '2025-08-07 07:42:26', 0),
(33, 'ACC202508200774', 'roshani', 'à¶à·à·à·à·', '0771717599', 'rosj@gmail.com', '2025-08-06 20:27:12', '2025-08-07 07:42:33', 0),
(34, 'ACC202508EF2578', 'roshani', 'à¶à·à·à·à·', '0771717599', 'rosj@gmail.com', '2025-08-06 20:27:14', '2025-08-07 07:42:31', 0),
(35, 'ACC202508FB5913', 'roshani', 'à¶à·à·à·à·', '0771717599', 'rosj@gmail.com', '2025-08-06 20:27:16', '2025-08-07 07:42:30', 0),
(36, 'ACC2025082DA7B2', 'roshani', 'asas', '0112345682', 'rosasaj@gmail.com', '2025-08-06 20:52:12', '2025-08-07 07:42:16', 0),
(37, 'ACC20250850FC12', 'roshani', 'asas', '0771717599', 'rosj@gmail.com', '2025-08-06 21:12:13', '2025-08-07 07:42:28', 0),
(38, 'ACC202508A5299A', 'roshani', 'asas', '0771717599', 'ass@gmail.com', '2025-08-06 21:12:54', '2025-08-07 07:42:20', 0),
(39, 'ACC202508981BBE', 'maheesha', 'asas', '0771717599', 'malsadu@pahanaedu.lk', '2025-08-06 21:15:05', '2025-08-07 07:42:45', 0),
(40, 'ACC20250816FE34', 'huththo', 'asas', '0771717599', 'rosj@gmail.com', '2025-08-06 21:16:10', '2025-08-06 21:16:10', 1),
(41, 'ACC202508AF514C', 'mn hanuma', 'sasasas', '0771717599', 'hanumantf@gmail.com', '2025-08-07 07:47:28', '2025-08-07 07:47:28', 1),
(42, 'ACC20250834B39A', 'roshani', 'assssssssssssss', '0771717599', 'rosj@gmail.com', '2025-08-07 08:02:15', '2025-08-07 08:02:15', 1),
(43, 'ACC20250889173A', 'maheesha', 'fdfdf', '0771717594', 'nhee@pahanaedu.lk', '2025-08-07 08:19:08', '2025-08-07 08:19:08', 1),
(44, 'ACC20250884F4FC', 'roshani', 'asasas', '0115959687', 'rosh@gmail.com', '2025-08-07 08:21:09', '2025-08-07 08:21:09', 1),
(45, 'ACC202508A75F86', 'rashmika', 'asasas', '0787879556', 'rash123@gmail.com', '2025-08-07 08:25:12', '2025-08-07 08:25:12', 1);

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `item_id` int(11) NOT NULL,
  `item_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) DEFAULT 0,
  `category` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `author` varchar(255) DEFAULT NULL,
  `isbn` varchar(50) DEFAULT NULL,
  `publisher` varchar(255) DEFAULT NULL,
  `publication_year` int(11) DEFAULT NULL,
  `pages` int(11) DEFAULT NULL,
  `language` varchar(100) DEFAULT 'Sinhala'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`item_id`, `item_code`, `name`, `description`, `price`, `stock_quantity`, `category`, `is_active`, `created_date`, `updated_date`, `author`, `isbn`, `publisher`, `publication_year`, `pages`, `language`) VALUES
(52, 'BOO001', 'ddd', 'ser', 100.00, 10, 'Books', 0, '2025-08-06 13:39:21', '2025-08-06 13:39:55', 'frwer', '345', '345', 0, 0, 'Sinhala'),
(53, 'BOO002', 'sdfd', NULL, 100.00, 10, 'Books', 0, '2025-08-06 13:39:40', '2025-08-06 13:40:57', 'sdf', NULL, NULL, 0, 0, 'Sinhala'),
(54, 'BOO003', 'asdsad', NULL, 500.00, 47, 'Books', 0, '2025-08-06 13:40:36', '2025-08-06 13:49:54', 'sadsadsadsa', NULL, NULL, 0, 0, 'Sinhala'),
(55, 'BOO004', 'enter', NULL, 456.00, 33, 'Books', 1, '2025-08-06 13:46:04', '2025-08-07 08:25:51', 'ere', NULL, NULL, 0, 0, 'English'),
(56, 'BOO005', 'asasas', NULL, 450.00, 6, 'Books', 1, '2025-08-06 13:49:08', '2025-08-07 08:34:06', 'asasasas', NULL, NULL, NULL, NULL, 'English'),
(57, 'BOO006', 'sadasdwe', NULL, 400.00, 8, 'Books', 1, '2025-08-06 13:51:25', '2025-08-07 08:34:06', 'sd', NULL, NULL, NULL, NULL, 'Tamil');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('ADMIN','CASHIER') NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `role`, `full_name`, `email`, `phone`, `is_active`, `created_date`) VALUES
(1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'ADMIN', 'System Administrator', 'admin@redupahana.com', NULL, 1, '2025-08-02 17:43:38'),
(3, 'admin50', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'CASHIER', 'asdas', 'asdadf@gmail.com', '0771717599', 1, '2025-08-04 15:17:59'),
(4, 'harthik123', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'CASHIER', 'asd', 'asdadf@gmail.com', '0771717599', 0, '2025-08-04 15:26:36'),
(5, 'asdsadasdasdqwe', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'CASHIER', 'sadasdasd', 'qweqweqwasd@gmail.com', '0665959887', 0, '2025-08-06 11:02:36'),
(6, 'rav!23', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'CASHIER', 'rashmika', 'ravindasasu@gmail.com', '0775689658', 0, '2025-08-06 12:57:16'),
(7, 'asasasqqe', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'CASHIER', 'qwwqewqe', 'qweqwe@gmail.com', '0771717599', 1, '2025-08-06 12:59:39'),
(8, 'admin123', '$2a$12$78.jVK0TTgd5ozV5GAqwt.QzQOVBESNn236vcSD1Tn9QNmDqCX2rW', 'ADMIN', '1qsaqs', 'admin@gmail.com', '0771717599', 1, '2025-08-06 13:00:22'),
(9, 'aaaa', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'CASHIER', 'aaaa', 'sadsad@gmail.com', '0112345684', 1, '2025-08-06 13:42:09'),
(10, 'admin11', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'ADMIN', 'tharindu', 'admin@pahanaedu.lk', '0771717599', 1, '2025-08-06 14:04:38'),
(11, 'rav123', 'admin123', 'ADMIN', 'tharindu', 'handsf@gmail.com', '0771717599', 1, '2025-08-06 14:15:16'),
(12, 'kasun', '0ee23550ffe538242f61e274bc6892c097bd052b0bb14a78b9412b0db4f9dc13', 'ADMIN', 'kanishka', 'admin@pahanaedu.lk', '0771717599', 1, '2025-08-06 14:39:56'),
(13, 'cashier1', 'c246650737293ddc18fc357393db78d1ecc9d1fd1af95469115e4a29f983359a', 'CASHIER', 'ravindu cash', 'cashier@redupahana.com', '0771717599', 1, '2025-08-06 14:50:19');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bills`
--
ALTER TABLE `bills`
  ADD PRIMARY KEY (`bill_id`),
  ADD UNIQUE KEY `bill_number` (`bill_number`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `cashier_id` (`cashier_id`),
  ADD KEY `idx_bills_is_active` (`is_active`),
  ADD KEY `idx_bills_created_date` (`created_date`),
  ADD KEY `idx_bills_payment_status` (`payment_status`),
  ADD KEY `idx_bills_bill_date` (`bill_date`);

--
-- Indexes for table `bill_items`
--
ALTER TABLE `bill_items`
  ADD PRIMARY KEY (`bill_item_id`),
  ADD KEY `bill_id` (`bill_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `idx_bill_items_created_date` (`created_date`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `account_number` (`account_number`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`item_id`),
  ADD UNIQUE KEY `item_code` (`item_code`),
  ADD KEY `idx_items_author` (`author`),
  ADD KEY `idx_items_isbn` (`isbn`),
  ADD KEY `idx_items_publisher` (`publisher`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bills`
--
ALTER TABLE `bills`
  MODIFY `bill_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `bill_items`
--
ALTER TABLE `bill_items`
  MODIFY `bill_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bills`
--
ALTER TABLE `bills`
  ADD CONSTRAINT `bills_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  ADD CONSTRAINT `bills_ibfk_2` FOREIGN KEY (`cashier_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `bill_items`
--
ALTER TABLE `bill_items`
  ADD CONSTRAINT `bill_items_ibfk_1` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`bill_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bill_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
