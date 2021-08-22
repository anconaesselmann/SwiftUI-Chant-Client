#sqlite3 prod.db < tables.sql

-- DROP TABLE hashes;
-- DROP TABLE salts;

CREATE TABLE IF NOT EXISTS users (
	user_id CHAR(32) NOT NULL PRIMARY KEY,
	email VARCHAR(254) NOT NULL UNIQUE,
	user_name VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS hashes (
	user_id CHAR(32) NOT NULL PRIMARY KEY,
	hash BLOB NOT NULL,
	FOREIGN KEY (user_id)
       REFERENCES users (user_id)
       ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS salts (
	user_id CHAR(32) NOT NULL PRIMARY KEY,
	salt BLOB NOT NULL,
	FOREIGN KEY (user_id)
       REFERENCES users (user_id)
       ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tokens (
	user_id CHAR(32) NOT NULL PRIMARY KEY,
	token CHAR(32) NOT NULL,
	expires timestamp,
	FOREIGN KEY (user_id)
       REFERENCES users (user_id)
);
