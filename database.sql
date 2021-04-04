/*
Create triggers template 

CREATE TRIGGER [name]
	BEFORE INSERT ON [table name]
BEGIN 
SELECT
	CASE 
    	WHEN NEW.[attribute] NOT LIKE '[condition]' THEN RAISE(ABORT, '[message]')
    END;
END;
*/


/*If tables already exist, then delete them.*/
drop table if exists item;
drop table if exists manager;
drop table if exists employee;
drop table if exists warehouse;
drop table if exists company;
drop table if exists member;
drop table if exists store;
drop table if exists review;
drop table if exists manages;
drop table if exists buys;
drop table if exists delivers;
drop table if exists writes;
drop table if exists empWorks;
drop table if exists storeHas;
drop table if exists department;
drop table if exists cart;

CREATE TABLE manager 
(
    managerID INTEGER PRIMARY KEY,
    firstName varchar(255) NOT NULL,
    lastName varchar(255) NOT NULL,
    salary int NOT NULL,
    CHECK(salary >= 60000 AND salary <= 120000)
);

CREATE TABLE employee
(
    employeeID INTEGER PRIMARY KEY,
    wage float NOT NULL,
    managerID INTEGER NOT NULL DEFAULT 1,
    firstName varchar(255) NOT NULL,
    lastName varchar(255) NOT NULL,
    startDate char(10) NOT NULL,
    email varchar(255) NOT NULL,
    password varchar(255) NOT NULL,
    FOREIGN KEY (managerID) REFERENCES manager(managerID)
        ON DELETE SET DEFAULT
  		ON UPDATE CASCADE,
    CHECK(wage >= 15.50 AND wage <= 40.50),
  	CHECK(managerID > 0)
);

CREATE TRIGGER validate_startDate_before_insert_employee
	BEFORE INSERT ON employee
BEGIN 
SELECT
	CASE 
    	WHEN NEW.startDate NOT LIKE '__-__-____' THEN RAISE(ABORT, 'Invalid start date')
    END;
END;

CREATE TABLE warehouse
(
    warehouseNumber INTEGER PRIMARY KEY,
    warehouseAddress varchar(255) NOT NULL,
  	CHECK(warehouseNumber > 0)
);

CREATE TABLE company (companyName varchar(255) NOT NULL);

CREATE TABLE store
( 
    storeNumber INTEGER NOT NULL,
    companyName varchar(255) NOT NULL,
    profit INTEGER,
  	CHECK(storeNumber > 0),
  	CHECK(profit >= 0),
    FOREIGN KEY(companyName) REFERENCES company(companyName)
  		ON DELETE CASCADE
  		ON UPDATE CASCADE
);

CREATE TABLE department (name varchar(255) PRIMARY KEY);

/*Create the 'member' table*/
CREATE TABLE member
( 
    memberID INTEGER PRIMARY KEY,
    fname varchar(255) NOT NULL,
    lname varchar(255) NOT NULL,
    email varchar(255),
    password varchar(255) NOT NULL,
    points INTEGER NOT NULL,
    registeredDate varchar(255) NOT NULL,
    companyName varchar(255) NOT NULL,
    memberAddress varchar(255),
    birthdate char(10),
  	CHECK(points >= 0),
    FOREIGN KEY(companyName) REFERENCES company(companyName)
  		ON DELETE CASCADE
  		ON UPDATE CASCADE
);

CREATE TRIGGER validate_member_before_insert_member 
   BEFORE INSERT ON member
BEGIN
   SELECT
      CASE
		WHEN NEW.email NOT LIKE '%_@__%.__%' THEN RAISE (ABORT,'Invalid email address')
		WHEN NEW.birthdate NOT LIKE '__-__-____' THEN RAISE (ABORT,'Invalid birth date')
        WHEN NEW.registeredDate NOT LIKE '__-__-____' THEN RAISE (ABORT,'Invalid registry date')
      END;
END;

/*Create the 'item' table*/
CREATE TABLE item
(
    itemID INTEGER PRIMARY KEY, 
    itemName varchar(255) NOT NULL,
    brand varchar(255) NOT NULL,
    size varchar(255),
    price float NOT NULL,
    stock int NOT NULL,
    discountPercent INTEGER,
    depName varchar(255) NOT NULL,
    companyName varchar(255) NOT NULL,
  	CHECK(price > 0),
  	CHECK(stock >= 0),
  	CHECK(discountPercent >= 0),
    FOREIGN KEY(companyName) REFERENCES company(companyName)
  		on delete cascade
  		ON UPDATE CASCADE,
    FOREIGN KEY(depName) REFERENCES department(name)
  		on delete cascade
  		ON UPDATE CASCADE
);

CREATE TABLE cart
( 
    cartID INTEGER NOT NULL,
    memberID INTEGER NOT NULL,
  	CHECK(cartID > 0),
  	CHECK(memberID > 0),
    FOREIGN KEY(memberID) REFERENCES member(memberID)
  		on delete CASCADE
);

CREATE TABLE empWorks
(
    empID INTEGER NOT NULL,
    storeNum INTEGER NOT NULL,
    startDate char(10) NOT NULL,
  	CHECK(empID > 0),
  	CHECK(storeNum > 0),
    FOREIGN KEY(empID) REFERENCES employee(employeeID)
  		on delete CASCADE
  		on UPDATE CASCADE,
    FOREIGN KEY(storeNum) REFERENCES store(storeNumber)
  		on delete CASCADE
  		on UPDATE CASCADE
);

CREATE TRIGGER startDate_validate_before_insert_empWorks
	BEFORE INSERT ON empWorks
BEGIN 
SELECT
	CASE 
    	WHEN NEW.startDate NOT LIKE '__-__-____' THEN RAISE(ABORT, 'Invalid start date')
    END;
END;

CREATE TABLE storeHas
(
    storeNum INTEGER NOT NULL,
    depName varchar(255) NOT NULL,
  	CHECK(storeNum > 0)
    FOREIGN KEY(storeNum) REFERENCES store(storeNumber)
  		on delete CASCADE
  		on UPDATE CASCADE,
    FOREIGN KEY(depName) REFERENCES department(name)
  		on DELETE CASCADE
  		on UPDATE CASCADE
);

CREATE TABLE review
(
    reviewNumber INTEGER NOT NULL,
    itemID INTEGER NOT NULL,
    memberID INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    content text,
  	CHECK(reviewnumber > 0),
  	CHECK(itemID > 0),
    CHECK(memberid > 0),
    CHECK(rating >= 1 and rating <= 5),
    FOREIGN KEY(itemID) REFERENCES item(itemID)
        ON DELETE CASCADE,
    FOREIGN KEY(memberID) REFERENCES member(memberID)
        ON DELETE CASCADE
);

CREATE TABLE manages
(
    empID INTEGER NOT NULL,
    managerID INTEGER NOT NULL,
  	CHECK(empID > 0),
  	CHECK(managerID > 0),
    FOREIGN KEY(empID) REFERENCES employee(employeeID)
  		on DELETE CASCADE
  		on UPDATE CASCADE,
    FOREIGN KEY(managerID) REFERENCES manager(managerID)
  		on DELETE CASCADE
  		on UPDATE CASCADE
);

CREATE TABLE buys
(
    itemID INTEGER,
    itemName varchar(255) NOT NULL,
    brand varchar(255) NOT NULL,
    size vachar(255),
    price FLOAT NOT NULL,
    discountPercent INTEGER NOT NULL,
    memberID INTEGER NOT NULL, 
    receipt text NOT NULL,
    date_of_purchase INTEGER NOT NULL, 
    cartID INTEGER NOT NULL,
  	CHECK(itemID > 0),
    CHECK(memberID > 0),
    CHECK(cartID > 0),
    FOREIGN KEY(itemID) REFERENCES item(itemID),
    FOREIGN KEY(itemName) REFERENCES item(itemName),
    FOREIGN KEY(brand) REFERENCES item(brand),
    FOREIGN KEY(size) REFERENCES item(size),
    FOREIGN KEY(price) REFERENCES item(price),
    FOREIGN KEY(discountPercent) REFERENCES item(discountPercent),
    FOREIGN KEY(memberID) REFERENCES member(memberID),
    FOREIGN KEY(cartID) REFERENCES cart(cartID)
);

-- CREATE TRIGGER date_and_time_validate_buys
-- 	BEFORE INSERT ON buys
-- BEGIN 
-- SELECT
-- 	CASE 
--     	WHEN NEW.date_of_purchase NOT LIKE '__-__-____' THEN RAISE(ABORT, 'Invalid purchase date')
--       WHEN NEW.time_of_purchase NOT LIKE '__:__:__' THEN RAISE(ABORT, 'Invalid purchase time')
--     END;
-- END;

CREATE TABLE delivers
(
    storeNum INTEGER NOT NULL,
    warehouseNum INTEGER NOT NULL,
    itemID INTEGER,
  	check(storeNum > 0),
  	check(warehouseNum > 0),
  	check(itemID > 0),
    FOREIGN KEY(storeNum) REFERENCES store(storeNumber)
  		on DELETE CASCADE
  		on UPDATE CASCADE,
    FOREIGN KEY(warehouseNum) REFERENCES warehouse(warehouseNumber)
  		on DELETE CASCADE
  		on UPDATE CASCADE,
    FOREIGN KEY(itemID) REFERENCES item(itemID)
);

CREATE TABLE writes
(
    itemID INTEGER NOT NULL,
    memberID INTEGER NOT NULL,
    reviewNumber INTEGER NOT NULL,
  	check(itemID > 0),
  	check(memberID > 0),
  	check(reviewNumber > 0),
    FOREIGN KEY(itemID) REFERENCES item(itemID)
  		on DELETE CASCADE,
    FOREIGN KEY(memberID) REFERENCES member(memberID)
  		on DELETE CASCADE
);

/* Add members to database */
Insert into member values (1, 'Bruce', 'Wayne', 'Batman@gmail.com', 'Batman', 0, '04-12-2021', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (2, 'Peter', 'Parker', 'Spiderman@gmail.com', 'Spidey', 0, '07-12-2021', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (3, 'Aubrey', 'Graham', 'Drake@gmail.com', 'Drake', 0, '24-11-1998', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (4, 'Steph', 'Curry', 'splash@gmail.com', 'Chef', 0, '17-09-1987', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (5, 'Elias', 'Pettersson', 'Petey@gmail.com', 'Petey', 0, '23-05-2001', 'SABS General Store', '1234 ABC place', '12-05-1950');

/* Add managers into table */
Insert into manager values (1, 'TempFirst', 'TempLast', 60000);
Insert into manager values (2, 'John', 'Smith', 75000);
Insert into manager values (3, 'Kelly', 'Gurana', 80000);
Insert into manager values (4, 'Samuel', 'Demers', 72000);
Insert into manager values (5, 'Kennedy', 'Lorace', 65000);
Insert into manager values (6, 'Matthew', 'Parker', 90000);

/* Add company to table (since we are only modelling one company, there will only be one entry*/
Insert into company values ('SABS General Store');

/* Add store to table */
Insert into store values (1, 'SABS General Store', 300000);
Insert into store values (2, 'SABS General Store', 400000);
Insert into store values (3, 'SABS General Store', 350000);
Insert into store values (4, 'SABS General Store', 550000);
Insert into store values (5, 'SABS General Store', 450000);

/* Add employee to table */
Insert into employee values (1, 20.50, 1, 'Emmanuel', 'Okafor', '12-12-1999', 'emmanuel@gmail.com', '1234');
Insert into employee values (2, 20.50, 2, 'Dion', 'Sanders', '10-11-1998', 'dion@gmail.com', '1234');
Insert into employee values (3, 20.50, 3, 'Ray', 'Allen', '12-12-1999', 'ray@gmail.com', '1234');
Insert into employee values (4, 20.50, 4, 'Wayne', 'Gretzky', '12-12-1999', 'wayne@gmail.com', '1234');
Insert into employee values (5, 20.50, 5, 'Brett', 'Hull', '12-12-1999', 'brett@gmail.com', '1234');

/* Add warehouse to table */
Insert into warehouse values (1, '1234 Hoot St.');
Insert into warehouse values (2, '6764 Burrard St.');
Insert into warehouse values (3, '2983 Granville St.');
Insert into warehouse values (4, '9999 Main Way');
Insert into warehouse values (5, '2022 Pine St.');

/* Add department to table */
Insert into department values ('Sporting');
Insert into department values ('Appliances');
Insert into department values ('Electronics');
Insert into department values ('Hardware');
Insert into department values ('Stationery');
Insert into department values ('Miscellaneous');

/* Add items to table */
Insert into item(itemID, itemName, brand, size, price, stock, discountPercent, depName, companyName) values (1, 'Blue pens 8-pack', 'BIC', '8x8x2', 24.99, 10, 0, 'Stationery', 'SABS General Store');
Insert into item(itemID, itemName, brand, size, price, stock, discountPercent, depName, companyName) values (2, 'Red pens 8-pack', 'BIC', '8x8x2', 24.99, 10, 0, 'Stationery', 'SABS General Store');
Insert into item(itemID, itemName, brand, size, price, stock, discountPercent, depName, companyName) values (3, 'Bubblegum', 'Excel', '4x4x2', 9.99, 50, 0, 'Miscellaneous', 'SABS General Store');
Insert into item(itemID, itemName, brand, size, price, stock, discountPercent, depName, companyName) values (4, 'Call of Duty - Modern Warfare', 'Activision', '6x62', 79.99, 5, 0, 'Electronics', 'SABS General Store');
Insert into item(itemID, itemName, brand, size, price, stock, discountPercent, depName, companyName) values (5, 'PS5', 'Sony', '20x20x20', 699.99, 2, 0, 'Electronics', 'SABS General Store');

/* Add cart to table */
Insert into cart values (1, 1);
Insert into cart values (2, 2);
Insert into cart values (3, 3);
Insert into cart values (4, 4);
Insert into cart values (5, 5);

/* Add empWorks to table */
Insert into empWorks values (1, 1, '12-12-2016');
Insert into empWorks values (2, 2, '12-12-2017');
Insert into empWorks values (3, 3, '12-12-2018');
Insert into empWorks values (4, 4, '12-12-2019');
Insert into empWorks values (5, 5, '12-12-2020');

/* Add storeHas to table */
Insert into storeHas values (1, 'Sporting');
Insert into storeHas values (1, 'Electronics');
Insert into storeHas values (1, 'Hardware');
Insert into storeHas values (1, 'Appliances');
Insert into storeHas values (1, 'Stationery');

/* Add reviews to table */
Insert into review values (1, 1, 1, 4, 'Yeah Blue pens 8-pack writes pretty good. Just runs out kind of quick');
Insert into review values (2, 2, 2, 5, 'The Red pens 8-pack writes pretty good. I like red so its good for me');
Insert into review values (3, 3, 3, 3, 'This bubblegum tastes disgusting');
Insert into review values (4, 4, 4, 4, 'COD really picked it up this year');
Insert into review values (5, 5, 5, 5, 'Best console ever');

/* Add manages to table */
Insert into manages values (1, 1);
Insert into manages values (2, 2);
Insert into manages values (3, 3);
Insert into manages values (4, 4);
Insert into manages values (5, 5);

/* Add buys to table */
Insert into buys values (1, 'Blue pens 8-pack', 'BIC', '8x8x2', 24.99, 0, 1, 'You have bought Blue pens 8-pack', 1615978318, 1);
Insert into buys values (2, 'Red pens 8-pack', 'BIC', '8x8x2', 24.99, 0, 2, 'You have bought Red pens 8-pack', 1612428228, 2);
Insert into buys values (3, 'Bubblegum', 'Excel', '4x4x2', 9.99, 0, 3, 'You have bought Bubblegum', 1614217428, 3);
Insert into buys values (4, 'Call of Duty - Modern Warfare', 'Activision', '6x62', 79.99, 0, 4, 'You have bought Call of Duty - Modern Warfare', 	1617295720, 4);
Insert into buys values (5, 'PS5', 'Sony', '20x20x20', 699.99, 0, 5, 'You have bought PS5', 1617364120, 5);

/* Add delivers to table */
Insert into delivers values (1, 1, 1);
Insert into delivers values (2, 2, 2);
Insert into delivers values (3, 3, 3);
Insert into delivers values (4, 4, 4);
Insert into delivers values (5, 5, 5);

/* Add writes to table */
Insert into writes values (1, 1, 1);
Insert into writes values (2, 2, 2);
Insert into writes values (3, 3, 3);
Insert into writes values (4, 4, 4);
Insert into writes values (5, 5, 5);