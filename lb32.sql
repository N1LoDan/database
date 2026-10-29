DROP DATABASE IF EXISTS computer_configuration;

CREATE DATABASE computer_configuration
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE computer_configuration;

CREATE TABLE manufacturer (
    manufacturer_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    manufacturer_name VARCHAR(150) NOT NULL,
    country VARCHAR(100) NULL,
    website VARCHAR(255) NULL,
    support_email VARCHAR(150) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_manufacturer
        PRIMARY KEY (manufacturer_id),

    CONSTRAINT uq_manufacturer_name
        UNIQUE (manufacturer_name)
) ENGINE = InnoDB;

CREATE TABLE hardware_category (
    hardware_category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    category_code VARCHAR(20) NOT NULL,
    description VARCHAR(255) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_hardware_category
        PRIMARY KEY (hardware_category_id),

    CONSTRAINT uq_hardware_category_name
        UNIQUE (category_name),

    CONSTRAINT uq_hardware_category_code
        UNIQUE (category_code)
) ENGINE = InnoDB;


CREATE TABLE hardware (
    hardware_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    manufacturer_id INT UNSIGNED NOT NULL,
    hardware_category_id INT UNSIGNED NOT NULL,
    hardware_name VARCHAR(150) NOT NULL,
    model_number VARCHAR(100) NOT NULL,
    release_date DATE NULL,
    price DECIMAL(12, 2) NULL,
    description VARCHAR(255) NULL,

    CONSTRAINT pk_hardware
        PRIMARY KEY (hardware_id),

    CONSTRAINT uq_hardware_model
        UNIQUE (manufacturer_id, model_number),

    KEY idx_hardware_manufacturer (manufacturer_id),
    KEY idx_hardware_category (hardware_category_id),

    CONSTRAINT fk_hardware_manufacturer
        FOREIGN KEY (manufacturer_id)
        REFERENCES manufacturer (manufacturer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_hardware_category
        FOREIGN KEY (hardware_category_id)
        REFERENCES hardware_category (hardware_category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_hardware_price
        CHECK (price IS NULL OR price >= 0)
) ENGINE = InnoDB;


CREATE TABLE computer (
    computer_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    manufacturer_id INT UNSIGNED NOT NULL,
    computer_name VARCHAR(150) NOT NULL,
    serial_number VARCHAR(100) NOT NULL,
    production_date DATE NULL,
    price DECIMAL(12, 2) NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_computer
        PRIMARY KEY (computer_id),

    CONSTRAINT uq_computer_serial
        UNIQUE (serial_number),

    KEY idx_computer_manufacturer (manufacturer_id),

    CONSTRAINT fk_computer_manufacturer
        FOREIGN KEY (manufacturer_id)
        REFERENCES manufacturer (manufacturer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_computer_price
        CHECK (price IS NULL OR price >= 0)
) ENGINE = InnoDB;

CREATE TABLE configuration (
    configuration_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    computer_id INT UNSIGNED NOT NULL,
    configuration_name VARCHAR(150) NOT NULL,
    description VARCHAR(255) NULL,
    total_price DECIMAL(14, 2) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_configuration
        PRIMARY KEY (configuration_id),

    CONSTRAINT uq_configuration_computer_name
        UNIQUE (computer_id, configuration_name),

    KEY idx_configuration_computer (computer_id),

    CONSTRAINT fk_configuration_computer
        FOREIGN KEY (computer_id)
        REFERENCES computer (computer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_configuration_price
        CHECK (total_price IS NULL OR total_price >= 0)
) ENGINE = InnoDB;


CREATE TABLE configuration_hardware (
    configuration_hardware_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    configuration_id INT UNSIGNED NOT NULL,
    hardware_id INT UNSIGNED NOT NULL,
    quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    unit_price DECIMAL(12, 2) NULL,

    CONSTRAINT pk_configuration_hardware
        PRIMARY KEY (configuration_hardware_id),

    CONSTRAINT uq_configuration_hardware
        UNIQUE (configuration_id, hardware_id),

    KEY idx_configuration_hardware_hardware (hardware_id),

    CONSTRAINT fk_configuration_hardware_configuration
        FOREIGN KEY (configuration_id)
        REFERENCES configuration (configuration_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_configuration_hardware_hardware
        FOREIGN KEY (hardware_id)
        REFERENCES hardware (hardware_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_configuration_hardware_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_configuration_hardware_price
        CHECK (unit_price IS NULL OR unit_price >= 0)
) ENGINE = InnoDB;