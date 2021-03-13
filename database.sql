/*If tables with the name 'users' and 'blogs' already exist, then delete them.*/
drop table if exists items;
drop table if exists members;

/*Create the 'members' table*/
CREATE TABLE members
( id INTEGER PRIMARY KEY,
fname varchar(255),
lname varchar(255),
email varchar(255),
password varchar(255),
points int NOT NULL,
registeredDate varchar(255),
phoneNumber char(12)
);

/*Create the 'items' table*/
CREATE TABLE items
(itemid INTEGER PRIMARY KEY, 
itemName varchar(255),
brand varchar(255),
size varchar(255),
price float,
stock int
);

/*Add users and blogs to database*/
Insert into members values (1, 'Bruce', 'Wayne', 'Batman@gmail.com', 'Batman', 0, '04-12-2021', '222-333-4444');
Insert into members values (2, 'Peter', 'Parker', 'Spiderman@gmail.com', 'Spidey', 0, '07-12-2021', '604-783-9876');
Insert into items(itemid, itemName, brand, size, price, stock) values (1, 'Blue pens 8-pack', 'BIC', '8x8x2', 24.99, 10);
Insert into items(itemid, itemName, brand, size, price, stock) values (2, 'Red pens 8-pack', 'BIC', '8x8x2', 24.99, 10);
Insert into items(itemid, itemName, brand, size, price, stock) values (3, 'Bubblegum', 'Excel', '4x4x2', 9.99, 50);
Insert into items(itemid, itemName, brand, size, price, stock) values (4, 'Call of Duty: Modern Warfare', 'Activision', '6x62', 79.99, 5);
Insert into items(itemid, itemName, brand, size, price, stock) values (5, 'PS5', 'Sony', '20x20x20', 699.99, 2);