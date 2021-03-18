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
    firstName varchar(255),
    lastName varchar(255),
    wage float
);

CREATE TABLE employee
(
    employeeID INTEGER PRIMARY KEY,
    wage float NOT NULL,
    managerID INTEGER,
    firstName varchar(255),
    lastName varchar(255),
    startDate char(10),
    FOREIGN KEY (managerID) REFERENCES manager(managerID)
);

CREATE TABLE warehouse
(
    warehouseNumber INTEGER PRIMARY KEY,
    warehouseAddress varchar(255)
);

CREATE TABLE company (comapanyName varchar(255));

CREATE TABLE store
( 
    storeNumber INTEGER,
    companyName varchar(255),
    profit INTEGER,
    FOREIGN KEY(companyName) REFERENCES company(companyName)
);

CREATE TABLE department (name varchar(255) PRIMARY KEY);

/*Create the 'member' table*/
CREATE TABLE member
( 
    memberID INTEGER PRIMARY KEY,
    fname varchar(255),
    lname varchar(255),
    email varchar(255),
    password varchar(255),
    points INTEGER NOT NULL,
    registeredDate varchar(255),
    companyName varchar(255),
    memberAddress varchar(255),
    birthdate char(10),
    FOREIGN KEY(companyName) REFERENCES company(companyName)
);

/*Create the 'item' table*/
CREATE TABLE item
(
    itemID INTEGER PRIMARY KEY, 
    itemName varchar(255),
    brand varchar(255),
    size varchar(255),
    price float,
    stock int,
    discountPercent INTEGER,
    depName varchar(255),
    companyName varchar(255),
    FOREIGN KEY(companyName) REFERENCES company(companyName),
    FOREIGN KEY(depName) REFERENCES department(name)
);

CREATE TABLE cart
( 
    cartID INTEGER,
    memberID INTEGER NOT NULL,
    FOREIGN KEY(memberID) REFERENCES member(memberID)
);

CREATE TABLE empWorks
(
    empID INTEGER,
    storeNum INTEGER,
    startDate char(10),
    FOREIGN KEY(empID) REFERENCES employee(employeeID),
    FOREIGN KEY(storeNum) REFERENCES store(storeNumber)
);

CREATE TABLE storeHas
(
    storeNum INTEGER,
    depName varchar(255),
    FOREIGN KEY(storeNum) REFERENCES store(storeNumber),
    FOREIGN KEY(depName) REFERENCES department(name)
);

CREATE TABLE review
(
    reviewNumber INTEGER,
    itemID INTEGER NOT NULL,
    memberID INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    content text,
    FOREIGN KEY(itemID) REFERENCES item(itemID),
    FOREIGN KEY(memberID) REFERENCES member(memberID)
);

CREATE TABLE manages
(
    empID INTEGER,
    managerID INTEGER,
    FOREIGN KEY(empID) REFERENCES employee(employeeID),
    FOREIGN KEY(managerID) REFERENCES manager(managerID)
);

CREATE TABLE buys
(
    itemID INTEGER,
    memberID INTEGER, 
    receipt text,
    cartID INTEGER,
    FOREIGN KEY(itemID) REFERENCES item(itemID),
    FOREIGN KEY(memberID) REFERENCES member(memberID),
    FOREIGN KEY(cartID) REFERENCES cart(cartID)
);

CREATE TABLE delivers
(
    storeNum INTEGER,
    warehouseNum INTEGER,
    itemID INTEGER,
    FOREIGN KEY(storeNum) REFERENCES store(storeNumber),
    FOREIGN KEY(warehouseNum) REFERENCES warehouse(warehouseNumber),
    FOREIGN KEY(itemID) REFERENCES item(itemID)
);

CREATE TABLE writes
(
    itemID INTEGER,
    memberID INTEGER,
    reviewNumber INTEGER,
    FOREIGN KEY(itemID) REFERENCES item(itemID),
    FOREIGN KEY(memberID) REFERENCES member(memberID)
);

/* Add members to database */
Insert into member values (1, 'Bruce', 'Wayne', 'Batman@gmail.com', 'Batman', 0, '04-12-2021', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (2, 'Peter', 'Parker', 'Spiderman@gmail.com', 'Spidey', 0, '07-12-2021', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (3, 'Aubrey', 'Graham', 'Drake@gmail.com', 'Drake', 0, '24-11-1998', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (4, 'Steph', 'Curry', 'splash@gmail.com', 'Chef', 0, '17-09-1987', 'SABS General Store', '1234 ABC place', '12-05-1950');
Insert into member values (5, 'Elias', 'Pettersson', 'Petey@gmail.com', 'Petey', 0, '23-05-2001', 'SABS General Store', '1234 ABC place', '12-05-1950');

/* Add managers into table */
Insert into manager values (1, 'John', 'Smith', 45.50);
Insert into manager values (2, 'Kelly', 'Gurana', 45.50);
Insert into manager values (3, 'Samuel', 'Demers', 45.50);
Insert into manager values (4, 'Kennedy', 'Lorace', 45.50);
Insert into manager values (5, 'Matthew', 'Parker', 45.50);

/* Add company to table (since we are only modelling one company, there will only be one entry*/
Insert into company values ('SABS General Store');

/* Add store to table */
Insert into store values (1, 'SABS General Store', 300000);
Insert into store values (2, 'SABS General Store', 400000);
Insert into store values (3, 'SABS General Store', 350000);
Insert into store values (4, 'SABS General Store', 550000);
Insert into store values (5, 'SABS General Store', 450000);

/* Add employee to table */
Insert into employee values (1, 20.50, 1, 'Emmanuel', 'Okafor', '12-12-1999');
Insert into employee values (2, 20.50, 2, 'Dion', 'Sanders', '10-11-1998');
Insert into employee values (3, 20.50, 3, 'Ray', 'Allen', '12-12-1999');
Insert into employee values (4, 20.50, 4, 'Wayne', 'Gretzky', '12-12-1999');
Insert into employee values (5, 20.50, 5, 'Brett', 'Hull', '12-12-1999');

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

/* Add items to table */
Insert into item(itemID, itemName, brand, size, price, stock) values (1, 'Blue pens 8-pack', 'BIC', '8x8x2', 24.99, 10);
Insert into item(itemID, itemName, brand, size, price, stock) values (2, 'Red pens 8-pack', 'BIC', '8x8x2', 24.99, 10);
Insert into item(itemID, itemName, brand, size, price, stock) values (3, 'Bubblegum', 'Excel', '4x4x2', 9.99, 50);
Insert into item(itemID, itemName, brand, size, price, stock) values (4, 'Call of Duty: Modern Warfare', 'Activision', '6x62', 79.99, 5);
Insert into item(itemID, itemName, brand, size, price, stock) values (5, 'PS5', 'Sony', '20x20x20', 699.99, 2);

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
Insert into buys values (1, 1, 'You have bought Blue pens 8-pack', 1);
Insert into buys values (2, 2, 'You have bought Red pens 8-pack', 2);
Insert into buys values (3, 3, 'You have bought Bubblegum', 3);
Insert into buys values (4, 4, 'You have bought COD: Modern Warfare', 4);
Insert into buys values (5, 5, 'You have bought PS5', 5);

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