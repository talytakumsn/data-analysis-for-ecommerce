-- create database
CREATE DATABASE dqlab-store;


-- use the database
USE dqlab-store;


-- create users table
CREATE TABLE IF NOT EXISTS `dqlab-store`.`users` (
  `user_id` INT NOT NULL,
  `nama_user` VARCHAR(500) NULL DEFAULT NULL,
  `kodepos` INT NULL DEFAULT NULL,
  `email` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci


-- create products table
CREATE TABLE IF NOT EXISTS `dqlab-store`.`products` (
  `product_id` INT NOT NULL,
  `desc_product` VARCHAR(500) NULL DEFAULT NULL,
  `category` VARCHAR(500) NULL DEFAULT NULL,
  `base_price` INT NULL DEFAULT NULL,
  PRIMARY KEY (`product_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci


-- create orders table
CREATE TABLE IF NOT EXISTS `dqlab-store`.`orders` (
  `order_id` INT NOT NULL,
  `seller_id` INT NULL DEFAULT NULL,
  `buyer_id` INT NULL DEFAULT NULL,
  `kodepos` INT NULL DEFAULT NULL,
  `subtotal` INT NULL DEFAULT NULL,
  `discount` INT NULL DEFAULT NULL,
  `total` INT NULL DEFAULT NULL,
  `created_at` DATE NULL DEFAULT NULL,
  `paid_at` DATE NULL DEFAULT NULL,
  `delivery_at` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `seller_idx` (`seller_id` ASC) VISIBLE,
  INDEX `buyer_idx` (`buyer_id` ASC) VISIBLE,
  CONSTRAINT `seller`
    FOREIGN KEY (`seller_id`)
    REFERENCES `dqlab-store`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `buyer`
    FOREIGN KEY (`buyer_id`)
    REFERENCES `dqlab-store`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci


-- create order details table
CREATE TABLE IF NOT EXISTS `dqlab-store`.`order_details` (
  `order_detail_id` INT NOT NULL,
  `order_id` INT NULL DEFAULT NULL,
  `product_id` INT NULL DEFAULT NULL,
  `price` INT NULL DEFAULT NULL,
  `quantity` INT NULL DEFAULT NULL,
  PRIMARY KEY (`order_detail_id`),
  INDEX `productid_idx` (`product_id` ASC) VISIBLE,
  INDEX `orderid_idx` (`order_id` ASC) VISIBLE,
  CONSTRAINT `orderid`
    FOREIGN KEY (`order_id`)
    REFERENCES `dqlab-store`.`orders` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `productid`
    FOREIGN KEY (`product_id`)
    REFERENCES `dqlab-store`.`products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci
