DROP DATABASE IF EXISTS cinema_film_rental;

CREATE DATABASE cinema_film_rental
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE cinema_film_rental;

CREATE TABLE distributor (
    distributor_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    distributor_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(150) NULL,
    phone VARCHAR(50) NULL,
    email VARCHAR(150) NULL,
    website VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_distributor
        PRIMARY KEY (distributor_id),

    CONSTRAINT uq_distributor_name
        UNIQUE (distributor_name)
) ENGINE = InnoDB;

CREATE TABLE genre (
    genre_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(100) NOT NULL,
    genre_code VARCHAR(20) NOT NULL,
    description VARCHAR(255) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_genre
        PRIMARY KEY (genre_id),

    CONSTRAINT uq_genre_name
        UNIQUE (genre_name),

    CONSTRAINT uq_genre_code
        UNIQUE (genre_code)
) ENGINE = InnoDB;


CREATE TABLE cinema (
    cinema_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cinema_name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NULL,
    email VARCHAR(150) NULL,
    opening_date DATE NULL,
    hall_count TINYINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_cinema
        PRIMARY KEY (cinema_id),

    CONSTRAINT chk_cinema_hall_count
        CHECK (hall_count IS NULL OR hall_count > 0)
) ENGINE = InnoDB;

CREATE TABLE film (
    film_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    distributor_id INT UNSIGNED NULL,
    title VARCHAR(200) NOT NULL,
    original_title VARCHAR(200) NULL,
    release_date DATE NULL,
    duration_minutes SMALLINT UNSIGNED NULL,
    age_rating VARCHAR(10) NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_film
        PRIMARY KEY (film_id),

    KEY idx_film_distributor (distributor_id),

    CONSTRAINT fk_film_distributor
        FOREIGN KEY (distributor_id)
        REFERENCES distributor (distributor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT chk_film_duration
        CHECK (duration_minutes IS NULL OR duration_minutes > 0),

    CONSTRAINT chk_film_age_rating
        CHECK (
            age_rating IS NULL
            OR age_rating IN ('0+', '6+', '12+', '16+', '18+')
        )
) ENGINE = InnoDB;


CREATE TABLE film_genre (
    film_genre_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    film_id INT UNSIGNED NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_film_genre
        PRIMARY KEY (film_genre_id),

    CONSTRAINT uq_film_genre
        UNIQUE (film_id, genre_id),

    KEY idx_film_genre_genre (genre_id),

    CONSTRAINT fk_film_genre_film
        FOREIGN KEY (film_id)
        REFERENCES film (film_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_film_genre_genre
        FOREIGN KEY (genre_id)
        REFERENCES genre (genre_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE film_rental (
    film_rental_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cinema_id INT UNSIGNED NOT NULL,
    film_id INT UNSIGNED NOT NULL,
    rental_start_date DATE NOT NULL,
    rental_end_date DATE NOT NULL,
    format VARCHAR(20) NOT NULL DEFAULT '2D',
    rental_price DECIMAL(12, 2) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'planned',
    note VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_film_rental
        PRIMARY KEY (film_rental_id),

    CONSTRAINT uq_film_rental_cinema_film_start
        UNIQUE (cinema_id, film_id, rental_start_date),

    KEY idx_film_rental_film (film_id),

    CONSTRAINT fk_film_rental_cinema
        FOREIGN KEY (cinema_id)
        REFERENCES cinema (cinema_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_film_rental_film
        FOREIGN KEY (film_id)
        REFERENCES film (film_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_film_rental_dates
        CHECK (rental_end_date >= rental_start_date),

    CONSTRAINT chk_film_rental_format
        CHECK (format IN ('2D', '3D', 'IMAX', '4DX')),

    CONSTRAINT chk_film_rental_status
        CHECK (status IN ('planned', 'active', 'finished')),

    CONSTRAINT chk_film_rental_price
        CHECK (rental_price IS NULL OR rental_price >= 0)
) ENGINE = InnoDB;