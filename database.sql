

CREATE DATABASE ELECTION_DB;
USE ELECTION_DB;

CREATE TABLE ADMIN (
    STATUS INT DEFAULT 0,
    AADHAR VARCHAR(12) PRIMARY KEY,
    NAME VARCHAR(50),
    DOB DATE,
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    WALLETADDRESS VARCHAR(50) UNIQUE,
    PHONE VARCHAR(10),
    MAIL VARCHAR(50),
)

CREATE TABLE MODERATOR (
    AADHAR VARCHAR(12) PRIMARY KEY,
    STATUS INT DEFAULT 0,
    VERIFIED_BY VARCHAR(12),
    NAME VARCHAR(50),
    DOB DATE,
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    WALLETADDRESS VARCHAR(50) UNIQUE,
    PHONE VARCHAR(10),
    MAIL VARCHAR(50),
    FOREIGN KEY (VERIFIED_BY) REFERENCES ADMIN(AADHAR)
)

CREATE TABLE VOTER (
    AADHAR VARCHAR(12) PRIMARY KEY,
    STATUS INT DEFAULT 0,
    VERIFIED_BY VARCHAR(12),
    NAME VARCHAR(50),
    DOB DATE,
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    WALLETADDRESS VARCHAR(50) UNIQUE,
    PHONE VARCHAR(10),
    MAIL VARCHAR(50),
    FOREIGN KEY (VERIFIED_BY) REFERENCES MODERATOR(AADHAR)
)