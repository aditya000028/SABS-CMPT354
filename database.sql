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
    CHECK(salary BETWEEN 60000 AND 120000)
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
    employee_password text NOT NULL,
    FOREIGN KEY (managerID) REFERENCES manager(managerID)
        ON DELETE SET DEFAULT
  		ON UPDATE CASCADE,
    CHECK(wage BETWEEN 15.50 AND 40.50),
  	CHECK(managerID > 0)
);

CREATE TRIGGER validate_startDate_before_insert_employee
	BEFORE INSERT ON employee
BEGIN 
SELECT
	CASE 
    	WHEN NEW.startDate NOT LIKE '____-__-__' THEN RAISE(ABORT, 'Invalid start date')
      WHEN NEW.wage < 15.20 THEN RAISE(ABORT, 'Employee wage cannot be less than minimum wage!')
      WHEN NEW.email NOT LIKE '%_@__%.__%' THEN RAISE (ABORT,'Invalid email address')
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
    member_password text NOT NULL,
    points INTEGER NOT NULL,
    registeredDate varchar(255) NOT NULL,
    companyName varchar(255) NOT NULL,
    address_street varchar(255),
    address_city char(2),
    address_zip char(6),
    address_province varchar(255),
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
		WHEN NEW.email NOT LIKE '%_@_%.__%' AND length(NEW.email) > 0 THEN RAISE (ABORT,'Invalid email address')
		WHEN NEW.birthdate NOT LIKE '____-__-__' AND length(NEW.birthdate) > 0 THEN RAISE (ABORT,'Invalid birth date')
    WHEN NEW.registeredDate NOT LIKE '____-__-__' THEN RAISE (ABORT,'Invalid registry date')
    WHEN NEW.address_zip NOT LIKE '______' AND length(NEW.address_zip) > 0 THEN RAISE (ABORT,'Invalid zip code length')
    WHEN NEW.address_province NOT LIKE '__' AND length(NEW.address_province) > 0 THEN RAISE (ABORT, 'Invalid province')
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
    objectID INTEGER NOT NULL,
    objectName varchar(255),
    objectPrice float NOT NULL,
  	CHECK(cartID > 0),
    FOREIGN KEY(cartID) REFERENCES member(memberID),
    FOREIGN KEY(objectID) REFERENCES item(itemID),
    FOREIGN KEY(objectName) REFERENCES item(itemName),
    FOREIGN KEY(objectPrice) REFERENCES item(price)
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
    	WHEN NEW.startDate NOT LIKE '____-__-__' THEN RAISE(ABORT, 'Invalid start date')
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
    CHECK(rating BETWEEN 1 AND 5),
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
    CHECK(date_of_purchase > 0),
    FOREIGN KEY(itemID) REFERENCES item(itemID),
    FOREIGN KEY(itemName) REFERENCES item(itemName),
    FOREIGN KEY(brand) REFERENCES item(brand),
    FOREIGN KEY(size) REFERENCES item(size),
    FOREIGN KEY(price) REFERENCES item(price),
    FOREIGN KEY(discountPercent) REFERENCES item(discountPercent),
    FOREIGN KEY(memberID) REFERENCES member(memberID),
    FOREIGN KEY(cartID) REFERENCES cart(cartID)
);

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
Insert into member values (1, 'Bruce', 'Wayne', 'Batman@gmail.com', 'Batman', 0, '1950-05-12', 'SABS General Store', '1234 ABC place', 'Surrey', 'V9Y3Q1', 'BC', '1950-05-12');
Insert into member values (2, 'Peter', 'Parker', 'Spiderman@gmail.com', 'Spidey', 0, '1950-05-12', 'SABS General Store', '1234 ABC place', 'Vancouver', 'V9Y3Q1', 'BC', '1950-05-12');
Insert into member values (3, 'Aubrey', 'Graham', 'Drake@gmail.com', 'Drake', 0, '1950-05-12', 'SABS General Store', '1234 ABC place', 'Burnaby', 'V9Y3Q1', 'BC', '1950-05-12');
Insert into member values (4, 'Steph', 'Curry', 'splash@gmail.com', 'Chef', 0, '1950-05-12', 'SABS General Store', '1234 ABC place', 'Richmond', 'V9Y3Q1', 'BC', '1950-05-12');
Insert into member values (5, 'Elias', 'Pettersson', 'Petey@gmail.com', 'Petey', 0, '1950-05-12', 'SABS General Store', '1234 ABC place', 'Toronto', 'V9Y3Q1', 'TO', '1950-05-12');

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
Insert into employee values (1, 20.50, 1, 'Emmanuel', 'Okafor', '1999-12-12', 'emmanuel@gmail.com', '1234');
Insert into employee values (2, 20.50, 2, 'Dion', 'Sanders', '1999-12-12', 'dion@gmail.com', '1234');
Insert into employee values (3, 20.50, 3, 'Ray', 'Allen', '1999-12-12', 'ray@gmail.com', '1234');
Insert into employee values (4, 20.50, 4, 'Wayne', 'Gretzky', '1999-12-12', 'wayne@gmail.com', '1234');
Insert into employee values (5, 20.50, 5, 'Brett', 'Hull', '1999-12-12', 'brett@gmail.com', '1234');

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
Insert into department values ('Home');
Insert into department values ('Miscellaneous');

/* Add items to table */
Insert into item values (1, 'Blue pens 8-pack', 'BIC', '8x8x2', 24.99, 10, 0, 'Stationery', 'SABS General Store');
Insert into item values (2, 'Red pens 8-pack', 'BIC', '8x8x2', 24.99, 10, 0, 'Stationery', 'SABS General Store');
Insert into item values (3, 'Bubblegum', 'Excel', '4x4x2', 9.99, 50, 0, 'Miscellaneous', 'SABS General Store');
Insert into item values (4, 'Call of Duty - Modern Warfare', 'Activision', '6x62', 79.99, 5, 0, 'Electronics', 'SABS General Store');
Insert into item values (5, 'PS5', 'Sony', '20x20x20', 699.99, 2, 0, 'Electronics', 'SABS General Store');
Insert into item values (6, 'Water Bottle', 'Kindle', '5x5x10', 10.99, 50, 0, 'Home', 'SABS General Store');
Insert into item values (7, 'Hand Lotion', 'Glysomed', '2x2x7', 7.50, 100, 0, 'Home', 'SABS General Store');
Insert into item values (8, 'Deodarant', 'Old Spice', '1x3x4', 5.99, 100, 10, 'Home', 'SABS General Store');
Insert into item values (9, 'Pencil Sharpener', 'Burklin', '2x2x2', 2.99, 200, 0, 'Stationery', 'SABS General Store');
Insert into item values (11, '60 inch flatscreen TV', 'Samsung', '30x10x30', 1999.99, 50, 0, 'Electronics', 'SABS General Store');
Insert into item values (12, '35 inch monitor', 'Sony', '20x5x20', 699.99, 95, 15, 'Electronics', 'SABS General Store');
Insert into item values (13, 'Airpods', 'Apple', '5x2x5', 249.99, 45, 0, 'Electronics', 'SABS General Store');
Insert into item values (14, 'Body Spray - Aqua', 'Axe', '2x2x5', 2.99, 250, 0, 'Home', 'SABS General Store');
Insert into item values (15, 'Hole Puncher', 'Burklin', '10x5x5', 9.99, 100, 12, 'Stationery', 'SABS General Store');
Insert into item values (16, 'Ruler', 'Burklin', '1x10x1', 2.99, 200, 15, 'Stationery', 'SABS General Store');
Insert into item values (17, 'Coffee Pot', 'HolyCoffee', '20x30x20', 250.00, 50, 50, 'Appliance', 'SABS General Store');
Insert into item values (18, 'Hammer', 'Tougher', '2x15x5', 12.99, 75, 0, 'Hardware', 'SABS General Store');
Insert into item values (19, 'Hockey Stick - Men Large', 'Bauer', '56x5x5', 94.99, 300, 0, 'Sporting', 'SABS General Store');
Insert into item values (20, '20-pack Mini Bites', 'Entainment', '10x20x5', 15.99, 250, 0, 'Miscellaneous', 'SABS General Store');
Insert into item values (21, 'Clipboard', 'Ready', '15x1x1', 5.99, 100, 0, 'Stationery', 'SABS General Store');
Insert into item values (22, 'Dryer - Large Metallic', 'GG', '256x256x256', 1599.99, 25, 10, 'Appliances', 'SABS General Store');
Insert into item values (23, 'Stove - Gas', 'GG', '300x300x300', 1899.99, 25, 10, 'Appliances', 'SABS General Store');
Insert into item values (24, 'Professional Size Basketball', 'Wilson', '20x20x20', 20.99, 100, 0, 'Sporting', 'SABS General Store');
Insert into item values (25, 'Basketball Air Pump', 'Sony', '5x10x20', 15.99, 65, 0, 'Sporting', 'SABS General Store');

/* Add cart to table */
Insert into cart values (1, 25, 'Basketball Air Pump', 15.99);
Insert into cart values(1, 9, 'Pencil Sharpener', 2.99);

/* Add empWorks to table */
Insert into empWorks values (1, 1, '2016-12-12');
Insert into empWorks values (2, 2, '2016-12-12');
Insert into empWorks values (3, 3, '2016-12-12');
Insert into empWorks values (4, 4, '2016-12-12');
Insert into empWorks values (5, 5, '2016-12-12');

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
Insert into buys values (1, 'Blue pens 8-pack', 'BIC', '8x8x2', 24.99, 0, 1, 'You have bought "Blue pens 8-pack"', 1615978318, 1);
Insert into buys values (2, 'Red pens 8-pack', 'BIC', '8x8x2', 24.99, 0, 2, 'You have bought "Red pens 8-pack"', 1612428228, 2);
Insert into buys values (3, 'Bubblegum', 'Excel', '4x4x2', 9.99, 0, 3, 'You have bought "Bubblegum"', 1614217428, 3);
Insert into buys values (4, 'Call of Duty - Modern Warfare', 'Activision', '6x62', 79.99, 0, 4, 'You have bought "Call of Duty - Modern Warfare"', 	1617295720, 4);
Insert into buys values (5, 'PS5', 'Sony', '20x20x20', 699.99, 0, 5, 'You have bought PS5', 1617364120, 6);
Insert into buys values (6, 'Water Bottle', 'Kindle', '5x5x10', 10.99, 0, 1, 'You have bought "Water Bottle"', 1615978318, 1);
Insert into buys values (9, 'Pencil Sharpener', 'Burklin', '2x2x2', 2.99, 0, 1, 'You have bought "Pencil Sharpener"', 1615978318, 1);
Insert into buys values (13, 'Airpods', 'Apple', '5x2x5', 249.99, 0, 1, 'You have bought "Airpods"', 1617364120, 5);
Insert into buys values (14, 'Body Spray - Aqua', 'Axe', '2x2x5', 2.99, 0, 5, 'You have bought "Body Spray - Aqua"', 1617364120, 6);
Insert into buys values (18, 'Hammer', 'Tougher', '2x15x5', 12.99, 0, 5, 'You have bought "Hammer"', 1617364120, 6);
Insert into buys values (7, 'Hand Lotion', 'Glysomed', '2x2x7', 7.50, 0, 1, 'You have bought "Hand Lotion"', 1617364120, 5);
Insert into buys values (6, 'Water Bottle', 'Kindle', '5x5x10', 10.99, 0, 1, 'You have bought "Water Bottle"', 1617364120, 5);
Insert into buys values (17, 'Coffee Pot', 'HolyCoffee', '20x30x20', 250.00, 50, 1, 'You have bought "Coffee Pot"', 1617364120, 5);
Insert into buys values (11, '60 inch flatscreen TV', 'Samsung', '30x10x30', 1999.99, 0, 1, 'You have bought "60 inch flatscreen TV"', 1617364120, 5);
Insert into buys values (14, 'Body Spray - Aqua', 'Axe', '2x2x5', 2.99, 0, 1, 'You have bought "Body Spra - Aqua"', 1617354120, 7);
Insert into buys values (6, 'Water Bottle', 'Kindle', '5x5x10', 10.99, 0, 1, 'You have bought "Water Bottle"', 1617354120, 7);
Insert into buys values (15, 'Hole Puncher', 'Burklin', '10x5x5', 9.99, 12, 1, 'You have bought "Hole Puncher"', 1617154120, 8);
Insert into buys values (12, '35 inch monitor', 'Sony', '20x5x20', 699.99, 15, 1, 'You have bought "35 inch monitor"', 1617154120, 8);
Insert into buys values (9, 'Hockey Stick - Men Large', 'Bauer', '2x2x2', 2.99, 0, 1, 'You have bought "Hockey Stick - Men Large"', 1617154120, 8);
Insert into buys values (9, 'Hockey Stick - Men Large', 'Bauer', '2x2x2', 2.99, 0, 1, 'You have bought "Hockey Stick - Men Large"', 1617154120, 8);
Insert into buys values (13, 'Airpods', 'Apple', '5x2x5', 249.99, 0, 1, 'You have bought "Airpods"', 1617154120, 8);
Insert into buys values (22, 'Dryer - Large Metallic', 'GG', '256x256x256', 1599.99, 10, 1, 'You have bought "Dryer - Large Metallic"', 1617154120, 8);
Insert into buys values (23, 'Stove - Gas', 'GG', '300x300x300', 1899.99, 10, 1, 'You have bought "Stove - Gas"', 1617154120, 8);
Insert into buys values (24, 'Professional Size Basketball', 'Wilson', '5x10x20', 15.99, 0, 1, 'You have bought "Professional Size Basketball"', 1617154120, 8);

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