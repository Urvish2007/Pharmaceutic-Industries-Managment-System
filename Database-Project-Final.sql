CREATE SCHEMA IF NOT EXISTS PHARMA_MANUFACTURING;

SET SEARCH_PATH TO PHARMA_MANUFACTURING;


CREATE TABLE Material_Master (
    Material_ID          VARCHAR(20)   PRIMARY KEY,
    Material_Name        VARCHAR(30)   NOT NULL,
    Material_Type        VARCHAR(20)   NOT NULL,
    Storage_Condition    VARCHAR(100)  NOT NULL,
    Shelf_Life           NUMERIC(3)    NOT NULL CHECK (Shelf_Life > 0),
    Therapeutic_Category VARCHAR(30)   NOT NULL,
    Material_State       VARCHAR(10)   NOT NULL,
    isHazardous          BOOLEAN       NOT NULL,
    isInflammable        BOOLEAN       NOT NULL,
    UOM                  VARCHAR(3)    NOT NULL
);

CREATE TABLE Account_Master (
    Account_No   VARCHAR(11)  PRIMARY KEY,
    Account_Name VARCHAR(50)  NOT NULL,
    Phone_No     VARCHAR(13)  NOT NULL,
    Address      VARCHAR(100) NOT NULL
);

CREATE TABLE Transactions (
    Invoice_No       NUMERIC(10)  PRIMARY KEY,
    Transaction_Date DATE         NOT NULL,
    Currency         VARCHAR(3)   NOT NULL,
    Transaction_Type VARCHAR(4)   NOT NULL
        CHECK (Transaction_Type IN ('buy','sell')),
    Paid_Received    BOOLEAN      NOT NULL,
    Account_No       VARCHAR(11)  REFERENCES Account_Master(Account_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Total_Value      NUMERIC(10,2) NOT NULL CHECK (Total_Value > 0)
);

CREATE TABLE Warehouse (
    Item_ID     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Material_ID VARCHAR(20) NOT NULL
        REFERENCES Material_Master(Material_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Invoice_No  NUMERIC(10) NOT NULL
        REFERENCES Transactions(Invoice_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UT_Q_A      VARCHAR(2)  NOT NULL,
    Stock       NUMERIC(10) NOT NULL CHECK (Stock > 0),

    CONSTRAINT uq_warehouse_mat_inv UNIQUE (Material_ID, Invoice_No)
);


CREATE TABLE Material_Quality_Check (
    Report_ID     VARCHAR(20)  PRIMARY KEY,
    Item_ID       BIGINT       NOT NULL,
    Analysis_Date DATE         NOT NULL,
    Analyst_Name  VARCHAR(20)  NOT NULL,
    Sample_Size   NUMERIC(10)  NOT NULL CHECK (Sample_Size > 0),
    Test          VARCHAR(20)  NOT NULL,
    Limits        VARCHAR(20)  NOT NULL,
    Results       VARCHAR(30)  NOT NULL,

    CONSTRAINT fk_mqc_warehouse
        FOREIGN KEY (Item_ID)
        REFERENCES Warehouse(Item_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE RM_Transaction (
    Invoice_No NUMERIC(10) NOT NULL
        REFERENCES Transactions(Invoice_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Item_ID    BIGINT      NOT NULL
        REFERENCES Warehouse(Item_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    RM_Qty     NUMERIC(10)   NOT NULL CHECK (RM_Qty > 0),
    Val        NUMERIC(10,2) NOT NULL CHECK (Val > 0),

    CONSTRAINT pk_rm_transaction PRIMARY KEY (Invoice_No, Item_ID)
);

CREATE TABLE Product_Master (
    Product_ID       VARCHAR(20) PRIMARY KEY,
    Product_Name     VARCHAR(20) NOT NULL,
    Generic_Name     VARCHAR(100) NOT NULL,
    Product_Type     VARCHAR(20) NOT NULL,
    Packing_Type     VARCHAR(10) NOT NULL,
    Packing_Size     VARCHAR(5)  NOT NULL,
    SalableorSample  VARCHAR(1)  NOT NULL CHECK (SalableorSample IN ('M','S')),
    GenericorBranded VARCHAR(1)  NOT NULL CHECK (GenericorBranded IN ('G','B'))
);


CREATE TABLE Formula_Master (
    Product_ID        VARCHAR(20) NOT NULL
        REFERENCES Product_Master(Product_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Material_ID       VARCHAR(20) NOT NULL
        REFERENCES Material_Master(Material_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Weight_per_tablet NUMERIC(10) NOT NULL CHECK (Weight_per_tablet > 0),

    CONSTRAINT pk_formula_master PRIMARY KEY (Product_ID, Material_ID)
);


CREATE TABLE Batch (
    Batch_No   NUMERIC(10) PRIMARY KEY,
    Batch_Size NUMERIC(10) NOT NULL CHECK (Batch_Size > 0),
    Mfg_Date   DATE        NOT NULL,
    Exp_Date   DATE,
    Product_ID VARCHAR(20) REFERENCES Product_Master(Product_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Stock_Qty  NUMERIC(10) NOT NULL CHECK (Stock_Qty >= 0),
    UT_Q_A     VARCHAR(2)  NOT NULL
);


CREATE TABLE Material_Dispensing (
    Batch_No         NUMERIC(10) NOT NULL
        REFERENCES Batch(Batch_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Item_ID          BIGINT      NOT NULL
        REFERENCES Warehouse(Item_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Quantity_Issued  NUMERIC(10) NOT NULL CHECK (Quantity_Issued > 0),

    CONSTRAINT pk_material_dispensing PRIMARY KEY (Batch_No, Item_ID)
);

CREATE TABLE Product_Quality_Check (
    Report_ID     VARCHAR(20)  PRIMARY KEY,
    Batch_No      NUMERIC(10)  REFERENCES Batch(Batch_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Analysis_Date DATE         NOT NULL,
    Analyst_Name  VARCHAR(20)  NOT NULL,
    Sample_Size   NUMERIC(10)  NOT NULL CHECK (Sample_Size > 0),
    Process_State VARCHAR(20)  NOT NULL,
    Test          VARCHAR(20)  NOT NULL,
    Limits        VARCHAR(20)  NOT NULL,
    Results       VARCHAR(30)  NOT NULL
);


CREATE TABLE FG_Transaction (
    Invoice_No NUMERIC(10) NOT NULL
        REFERENCES Transactions(Invoice_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Batch_No   NUMERIC(10) NOT NULL
        REFERENCES Batch(Batch_No)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Sale_Qty   NUMERIC(10)   NOT NULL CHECK (Sale_Qty > 0),
    Val        NUMERIC(10,2) NOT NULL CHECK (Val > 0),

    CONSTRAINT pk_fg_transaction PRIMARY KEY (Invoice_No, Batch_No)
);


INSERT INTO Material_Master VALUES ('VT001','Vitamin A','Supplement','Store at room temperature not exceeding 30C','36','Oral Nutritional Supplement','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('VT002','Vitamin D3','Supplement','Store at room temperature not exceeding 30C','24','Oral Nutritional Supplement','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('PC001','Paracetamol','Drug','Store at room temperature not exceeding 30C. Protect from light.','24','Antipyretic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB001','Omeprazole','Drug','Store at room temperature not exceeding 25C','24','Anti-ulcer','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB002','Azithromycin Dihydrate','Drug','Store at room temperature not exceeding 25C. RH no more than 55%.','12','Antibiotic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('PR001','L-Leucine','Supplement','Store at room temperature not exceeding 30C','36','Essential Amino-Acids','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('PR002','L-Lysine Hydrochloride','Supplement','Store at room temperature not exceeding 30C','36','Essential Amino-Acids','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('PR003','L-Phenylalanine','Supplement','Store at room temperature not exceeding 30C','24','Essential Amino-Acids','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB003','Tinidazole','Drug','Store at room temperature not exceeding 30C. Protect from light.','18','Antibiotic','Solid',TRUE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB004','Atorvastatin','Drug','Store at room temperature not exceeding 30C. Protect from light.','18','Cardio-vascular','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB005','Glimepiride','Drug','Store below 25C in a well closed container protected from light.','12','Anti-diabetic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB006','Ciprofloxacin Hydrochloride','Drug','Store at room temperature not exceeding 25C','24','Antibiotic','Solid',TRUE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR001','Losartan Potassium','Drug','Store in cool and dry conditions. RH no more than 40%','24','Cardio-vascular','Solid',TRUE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR002','Sodium Chloride','Electrolyte','Store in cool and dry place.','48','Mineral Replenishment','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR003','Potassium Chloride','Electrolyte','Store in cool and dry place.','48','Mineral Replenishment','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR004','Sodium Citrate','Electrolyte','Store in cool and dry place.','24','Mineral Replenishment','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR005','Anhydrous Glucose','Sweetener','Store in cool and dry place.','48','Energy Supplement','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR006','Zinc Sulphate Monohydrate','Supplement','Store at room temperature not exceeding 30C. Store in dry conditions only.','24','Mineral Replenishment','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR007','Levocetirizine Hydrochloride','Drug','Store at room temperature not exceeding 25C','18','Anti-allergic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB007','Cetirizine Hydrochloride','Drug','Store at room temperature not exceeding 25C','18','Anti-allergic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR008','Diphenhydramine','Drug','Store at room temperature not exceeding 25C. RH no more than 55%.','12','Anti-cold','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OR009','Menthol','Drug','Store in cool and dry place.','36','Anti-cold','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB008','Amoxycillin Trihydrate','Drug','Store at room temperature not exceeding 30C. Store in dry conditions only.','18','Antibiotic','Solid',TRUE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB009','Albendazole','Drug','Store at room temperature not exceeding 30C','24','Anti-worms','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB010','Diclofenac Potassium','Drug','Store at room temperature not exceeding 25C','18','Analgesic','Solid',TRUE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB011','Montelukast Sodium','Drug','Store at room temperature not exceeding 25C','12','Anti-tussive','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB012','Norfloxacin','Drug','Store at room temperature not exceeding 30C. Protect from light.','8','Antibiotic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('OT001','Caffeine','Supplement','Store at room temperature not exceeding 25C. Protect from light.','8','Stimulant','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('NB013','Phenylephrine Hydrochloride','Drug','Store below 25C in a well closed container protected from light.','12','Vasoconstrictor','Liquid',TRUE,FALSE,'ltr');
INSERT INTO Material_Master VALUES ('NB014','Ibuprofen','Drug','Store at room temperature not exceeding 30C. Protect from light.','24','Analgesic','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('EX001','Sodium Starch Glycolate','Excipient','Store in cool and dry place.','36','Disintegrating Agent','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('EX002','Methyl Cellulose','Excipient','Store in cool and dry place.','48','Binder','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('EX003','Sucrose','Excipient','Store in cool and dry place.','36','Sweetener','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('EX004','Starch','Excipient','Store in cool and dry place.','48','Filler','Solid',FALSE,FALSE,'kg');
INSERT INTO Material_Master VALUES ('EX005','Isopropyl Alcohol','Excipient','Store at room temperature not exceeding 25C. Protect from light.','24','Solvent','Liquid',TRUE,TRUE,'ltr');
INSERT INTO Material_Master VALUES ('EX006','Propylene Glycol','Excipient','Store at room temperature not exceeding 25C','24','Solvent','Liquid',FALSE,TRUE,'ltr');

INSERT INTO Account_Master VALUES ('12334455566','AK Pharma','911023456789','B232 ABC Sector, Vatva, Ahmedabad, Gujarat');
INSERT INTO Account_Master VALUES ('12345678912','Stallion Pharma','919099234567','G371 Industrial Area, Changodar, Ahmedabad, Gujarat');
INSERT INTO Account_Master VALUES ('12345678913','West Coast Pharma','913243423342','M222 Bsafal Business Park, Prahaladnagar, Ahmedabad');
INSERT INTO Account_Master VALUES ('12345678914','Cipla Pharma','919676856858','K322 Industrial Area, Changodar, Ahmedabad, Gujarat');
INSERT INTO Account_Master VALUES ('23456789123','Zydus Pharma','915685685887','Zydus Head Office, Vaishnav Devi Circle, Ahmedabad');
INSERT INTO Account_Master VALUES ('23456789124','Torrent Pharma','918565655675','Torrent Head Office, IIMA Road, Ahmedabad, Gujarat');
INSERT INTO Account_Master VALUES ('23456789125','Soham Pharma','918556556757','Z33 Jalandhar Business Sector, PQR Road, Jalandhar');
INSERT INTO Account_Master VALUES ('30941324893','Silis Pharma','311312312312','TZ11 SMZ Corporate Park, Jaipur, Rajasthan');
INSERT INTO Account_Master VALUES ('34567891245','Sagar Laboratories','913891819333','M24 Pharma Business Hub, Borivali, Mumbai');
INSERT INTO Account_Master VALUES ('45678901234','Danadams Pharma','651308080809','Danadams Head Office, Oreleens Road, Lagos');
INSERT INTO Account_Master VALUES ('45678900234','Sehat-E-Zafran Labs','651231312312','P433 ADNEC Business Center, Abu Dhabi, UAE');
INSERT INTO Account_Master VALUES ('45678900034','Vatican Bells Pharma','221321321313','Bells Pharma Building, Querada Road, Lagos');
INSERT INTO Account_Master VALUES ('13579086421','Justeen Pharmaceuticals','233312311333','Justeen Pharma Head Office, Kosad Road, Nigeria');
INSERT INTO Account_Master VALUES ('99886778934','Saham Pharma','901232312312','D323 Mecall Business Hub, KB Road, Lahore, Pakistan');
INSERT INTO Account_Master VALUES ('42739230089','Sak Kam Pharma','863123131232','Tu Tue Hong, Philm Se Hat, Beijing, China');
INSERT INTO Account_Master VALUES ('13412342314','Swiss Pharmaceuticals','411232312333','100A Cordova, Senterzen Street, Geneva');
INSERT INTO Account_Master VALUES ('67132648713','KTZ Pharma Ltd','866868168687','Prot Hat Ne, Sim Te Lar Road, Myanmar');
INSERT INTO Account_Master VALUES ('71389479813','Hong Phat Pharma','543810899899','15 Procon Estate, Industrial District, Shanghai');
INSERT INTO Account_Master VALUES ('28402342389','Lupin Pharmaceuticals','919999139919','Lupin Head Office, DBS Road, Sector 8, New Delhi');

INSERT INTO Transactions VALUES (1, '01-09-2018','INR','buy',TRUE, '34567891245',2250000);
INSERT INTO Transactions VALUES (2, '02-09-2018','INR','buy',TRUE, '45678901234',2100000);
INSERT INTO Transactions VALUES (3, '03-09-2018','INR','buy',TRUE, '45678900234',1600000);
INSERT INTO Transactions VALUES (4, '04-09-2018','INR','buy',TRUE, '45678900034',150000);
INSERT INTO Transactions VALUES (5, '05-09-2018','INR','buy',TRUE, '13579086421',1600000);
INSERT INTO Transactions VALUES (6, '06-09-2018','INR','buy',TRUE, '99886778934',1500000);
INSERT INTO Transactions VALUES (7, '07-09-2018','INR','buy',FALSE,'42739230089',1500000);
INSERT INTO Transactions VALUES (8, '08-09-2018','INR','buy',TRUE, '13412342314',4100000);
INSERT INTO Transactions VALUES (9, '09-09-2018','INR','buy',TRUE, '67132648713',12000000);
INSERT INTO Transactions VALUES (10,'10-09-2018','INR','buy',TRUE, '71389479813',6500000);
INSERT INTO Transactions VALUES (11,'11-09-2018','INR','buy',TRUE, '28402342389',500000);
INSERT INTO Transactions VALUES (12,'12-09-2018','INR','buy',TRUE, '34567891245',200000);
INSERT INTO Transactions VALUES (13,'13-09-2018','INR','buy',FALSE,'45678901234',3000000);
INSERT INTO Transactions VALUES (14,'14-09-2018','INR','buy',TRUE, '45678900234',100000);
INSERT INTO Transactions VALUES (15,'15-09-2018','INR','buy',TRUE, '45678900034',750000);
INSERT INTO Transactions VALUES (16,'16-09-2018','INR','buy',TRUE, '13579086421',1800000);
INSERT INTO Transactions VALUES (17,'17-09-2018','INR','buy',TRUE, '99886778934',8185000);
INSERT INTO Transactions VALUES (18,'18-09-2018','INR','buy',TRUE, '42739230089',5000000);
INSERT INTO Transactions VALUES (19,'19-09-2018','INR','buy',FALSE,'13412342314',200000);
INSERT INTO Transactions VALUES (20,'20-09-2018','INR','buy',TRUE, '67132648713',100000);
INSERT INTO Transactions VALUES (21,'21-09-2018','INR','buy',TRUE, '71389479813',2300000);
INSERT INTO Transactions VALUES (22,'22-09-2018','INR','buy',TRUE, '28402342389',1050000);
INSERT INTO Transactions VALUES (23,'23-09-2018','INR','buy',TRUE, '34567891245',15000);
INSERT INTO Transactions VALUES (24,'24-09-2018','INR','buy',FALSE,'45678901234',75000);
INSERT INTO Transactions VALUES (25,'25-09-2018','INR','buy',TRUE, '45678900234',1000000);
INSERT INTO Transactions VALUES (26,'26-09-2018','INR','buy',TRUE, '45678900034',1200000);
INSERT INTO Transactions VALUES (1001,'01-12-2018','INR','sell',TRUE, '12334455566',50000);
INSERT INTO Transactions VALUES (1002,'02-12-2018','INR','sell',TRUE, '12345678912',336000);
INSERT INTO Transactions VALUES (1003,'03-12-2018','INR','sell',TRUE, '12345678913',540000);
INSERT INTO Transactions VALUES (1004,'04-12-2018','INR','sell',TRUE, '12345678914',195000);
INSERT INTO Transactions VALUES (1005,'05-12-2018','INR','sell',FALSE,'23456789123',76800);
INSERT INTO Transactions VALUES (1006,'06-12-2018','INR','sell',TRUE, '23456789124',270000);
INSERT INTO Transactions VALUES (1007,'07-12-2018','INR','sell',TRUE, '23456789125',45000);
INSERT INTO Transactions VALUES (1008,'08-12-2018','INR','sell',TRUE, '30941324893',342000);
INSERT INTO Transactions VALUES (1009,'09-12-2018','INR','sell',FALSE,'34567891245',28000);
INSERT INTO Transactions VALUES (1010,'10-12-2018','INR','sell',TRUE, '30941324893',72000);
INSERT INTO Transactions VALUES (1011,'11-12-2018','INR','sell',TRUE, '12345678913',70000);
INSERT INTO Transactions VALUES (4001,'01-03-2019','USD','buy',TRUE,'34567891245',30000);
INSERT INTO Transactions VALUES (4002,'02-03-2019','USD','buy',FALSE,'45678901234',25000);
INSERT INTO Transactions VALUES (4003,'03-03-2019','USD','buy',TRUE,'45678900234',20000);
INSERT INTO Transactions VALUES (4004,'04-03-2019','USD','sell',TRUE,'12334455566',8000);
INSERT INTO Transactions VALUES (4005,'05-03-2019','USD','sell',FALSE,'12345678912',9000);
INSERT INTO Transactions VALUES (4006,'06-03-2019','USD','buy',TRUE,'45678900034',18000);
INSERT INTO Transactions VALUES (4007,'07-03-2019','USD','buy',TRUE,'13579086421',27000);
INSERT INTO Transactions VALUES (4008,'08-03-2019','USD','sell',TRUE,'23456789123',11000);
INSERT INTO Transactions VALUES (4009,'09-03-2019','USD','sell',FALSE,'23456789124',7000);
INSERT INTO Transactions VALUES (4010,'10-03-2019','USD','buy',TRUE,'99886778934',35000);
INSERT INTO Transactions VALUES (4101,'01-04-2019','EUR','buy',TRUE,'34567891245',22000);
INSERT INTO Transactions VALUES (4102,'02-04-2019','EUR','buy',TRUE,'45678901234',24000);
INSERT INTO Transactions VALUES (4103,'03-04-2019','EUR','sell',FALSE,'12334455566',6000);
INSERT INTO Transactions VALUES (4104,'04-04-2019','EUR','sell',TRUE,'12345678912',8500);
INSERT INTO Transactions VALUES (4105,'05-04-2019','EUR','buy',TRUE,'45678900234',19000);
INSERT INTO Transactions VALUES (4106,'06-04-2019','EUR','buy',FALSE,'45678900034',21000);
INSERT INTO Transactions VALUES (4107,'07-04-2019','EUR','sell',TRUE,'23456789123',5000);
INSERT INTO Transactions VALUES (4108,'08-04-2019','EUR','sell',TRUE,'23456789124',7500);
INSERT INTO Transactions VALUES (4109,'09-04-2019','EUR','buy',TRUE,'99886778934',26000);
INSERT INTO Transactions VALUES (4110,'10-04-2019','EUR','buy',TRUE,'42739230089',23000);
INSERT INTO Transactions VALUES (4201,'01-05-2019','AED','buy',TRUE,'34567891245',50000);
INSERT INTO Transactions VALUES (4202,'02-05-2019','AED','buy',FALSE,'45678901234',42000);
INSERT INTO Transactions VALUES (4203,'03-05-2019','AED','sell',TRUE,'12334455566',15000);
INSERT INTO Transactions VALUES (4204,'04-05-2019','AED','sell',TRUE,'12345678912',18000);
INSERT INTO Transactions VALUES (4205,'05-05-2019','AED','buy',TRUE,'45678900234',47000);
INSERT INTO Transactions VALUES (4206,'06-05-2019','AED','buy',TRUE,'45678900034',39000);
INSERT INTO Transactions VALUES (4207,'07-05-2019','AED','sell',FALSE,'23456789123',12000);
INSERT INTO Transactions VALUES (4208,'08-05-2019','AED','sell',TRUE,'23456789124',14000);
INSERT INTO Transactions VALUES (4209,'09-05-2019','AED','buy',TRUE,'99886778934',55000);
INSERT INTO Transactions VALUES (4210,'10-05-2019','AED','buy',TRUE,'42739230089',60000);
INSERT INTO Transactions VALUES (4301,'01-06-2019','GBP','buy',TRUE,'34567891245',18000);
INSERT INTO Transactions VALUES (4302,'02-06-2019','GBP','buy',TRUE,'45678901234',20000);
INSERT INTO Transactions VALUES (4303,'03-06-2019','GBP','sell',TRUE,'12334455566',9000);
INSERT INTO Transactions VALUES (4304,'04-06-2019','GBP','sell',FALSE,'12345678912',7000);
INSERT INTO Transactions VALUES (4305,'05-06-2019','GBP','buy',TRUE,'45678900234',22000);
INSERT INTO Transactions VALUES (4306,'06-06-2019','GBP','buy',TRUE,'45678900034',25000);
INSERT INTO Transactions VALUES (4307,'07-06-2019','GBP','sell',TRUE,'23456789123',8000);
INSERT INTO Transactions VALUES (4308,'08-06-2019','GBP','sell',TRUE,'23456789124',10000);
INSERT INTO Transactions VALUES (4309,'09-06-2019','GBP','buy',FALSE,'99886778934',27000);
INSERT INTO Transactions VALUES (4310,'10-06-2019','GBP','buy',TRUE,'42739230089',30000);
INSERT INTO Transactions VALUES (4401,'01-07-2019','CNY','buy',TRUE,'34567891245',70000);
INSERT INTO Transactions VALUES (4402,'02-07-2019','CNY','buy',TRUE,'45678901234',65000);
INSERT INTO Transactions VALUES (4403,'03-07-2019','CNY','sell',TRUE,'12334455566',20000);
INSERT INTO Transactions VALUES (4404,'04-07-2019','CNY','sell',FALSE,'12345678912',18000);
INSERT INTO Transactions VALUES (4405,'05-07-2019','CNY','buy',TRUE,'45678900234',72000);
INSERT INTO Transactions VALUES (4406,'06-07-2019','CNY','buy',TRUE,'45678900034',69000);
INSERT INTO Transactions VALUES (4407,'07-07-2019','CNY','sell',TRUE,'23456789123',22000);
INSERT INTO Transactions VALUES (4408,'08-07-2019','CNY','sell',TRUE,'23456789124',25000);
INSERT INTO Transactions VALUES (4409,'09-07-2019','CNY','buy',TRUE,'99886778934',80000);
INSERT INTO Transactions VALUES (4410,'10-07-2019','CNY','buy',TRUE,'42739230089',85000);
INSERT INTO Transactions VALUES (4501,'01-08-2019','JPY','buy',TRUE,'34567891245',800000);
INSERT INTO Transactions VALUES (4502,'02-08-2019','JPY','buy',TRUE,'45678901234',750000);
INSERT INTO Transactions VALUES (4503,'03-08-2019','JPY','sell',TRUE,'12334455566',200000);
INSERT INTO Transactions VALUES (4504,'04-08-2019','JPY','sell',FALSE,'12345678912',180000);
INSERT INTO Transactions VALUES (4505,'05-08-2019','JPY','buy',TRUE,'45678900234',820000);
INSERT INTO Transactions VALUES (4506,'06-08-2019','JPY','buy',TRUE,'45678900034',790000);
INSERT INTO Transactions VALUES (4507,'07-08-2019','JPY','sell',TRUE,'23456789123',220000);
INSERT INTO Transactions VALUES (4508,'08-08-2019','JPY','sell',TRUE,'23456789124',250000);
INSERT INTO Transactions VALUES (4509,'09-08-2019','JPY','buy',TRUE,'99886778934',900000);
INSERT INTO Transactions VALUES (4510,'10-08-2019','JPY','buy',TRUE,'42739230089',950000);

INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (1, 'VT001',1,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (2, 'VT002',1,'UT',50000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (3, 'PC001',1,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (4, 'NB001',1,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (5, 'NB002',1,'UT',30000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (6, 'PR001',2,'UT',50000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (7, 'PR002',2,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (8, 'PR003',2,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (9, 'NB003',3,'UT',40000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (10,'NB004',4,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (11,'NB005',5,'UT',40000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (12,'NB006',6,'UT',30000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (13,'OR001',7,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (14,'OR002',8,'UT',11000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (15,'OR003',8,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (16,'OR004',8,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (17,'OR005',9,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (18,'OR006',9,'UT',30000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (19,'OR007',9,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (20,'NB007',10,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (21,'OR008',10,'UT',35000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (22,'OR009',11,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (23,'NB008',11,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (24,'NB009',11,'UT',25000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (25,'NB010',12,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (26,'NB011',13,'UT',30000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (27,'NB012',14,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (28,'OT001',15,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (29,'NB013',16,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (30,'NB014',16,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (31,'EX001',16,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (32,'EX002',16,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (33,'EX003',17,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (34,'EX004',17,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (35,'EX005',18,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (36,'EX006',18,'UT',30000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (37,'PR002',19,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (38,'NB014',20,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (39,'NB011',21,'UT',12000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (40,'OR008',21,'UT',11000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (41,'EX002',22,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (42,'VT002',23,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (43,'NB002',24,'UT',15000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (44,'OR002',25,'UT',10000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (45,'VT001',26,'UT',20000);
INSERT INTO Warehouse OVERRIDING SYSTEM VALUE VALUES (46,'OR004',26,'UT',10000);


INSERT INTO Material_Quality_Check VALUES ('1', 1, '01-09-2018','Ajay Sharma',  1,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('2', 2, '02-09-2018','Hitesh Patel', 2,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('3', 3, '03-09-2018','Ajay Sharma',  3,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('4', 4, '04-09-2018','Hitesh Patel', 1,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('5', 5, '05-09-2018','Ajay Sharma',  2,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('6', 6, '06-09-2018','Hitesh Patel', 1,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('7', 7, '07-09-2018','Ajay Sharma',  3,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('8', 8, '08-09-2018','Hitesh Patel', 1,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('9', 9, '09-09-2018','Ajay Sharma',  5,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('10',10,'10-09-2018','Hitesh Patel', 3,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('11',11,'11-09-2018','Ajay Sharma',  2,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('12',12,'12-09-2018','Hitesh Patel', 3,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('13',13,'13-09-2018','Ajay Sharma',  4,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('14',14,'14-09-2018','Hitesh Patel', 1,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('15',15,'15-09-2018','Hitesh Patel', 3,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('16',16,'16-09-2018','Hitesh Patel', 2,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('17',17,'17-09-2018','Ajay Sharma',  3,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('18',18,'18-09-2018','Hitesh Patel', 3,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('19',19,'19-09-2018','Ajay Sharma',  3,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('20',20,'20-09-2018','Hitesh Patel', 4,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('21',21,'21-09-2018','Ajay Sharma',  2,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('22',22,'22-09-2018','Hitesh Patel', 1,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('23',23,'23-09-2018','Ajay Sharma',  3,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('24',24,'24-09-2018','Hitesh Patel', 3,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('25',25,'25-09-2018','Ajay Sharma',  4,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('26',26,'26-09-2018','Hitesh Patel', 5,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('27',27,'27-09-2018','Ajay Sharma',  1,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('28',28,'28-09-2018','Hitesh Patel', 2,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('29',29,'29-09-2018','Ajay Sharma',  7,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('30',30,'30-09-2018','Hitesh Patel', 2,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('31',31,'01-10-2018','Ajay Sharma',  4,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('32',32,'02-10-2018','Hitesh Patel', 3,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('33',33,'03-10-2018','Ajay Sharma',  5,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('34',34,'04-10-2018','Hitesh Patel', 4,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('35',35,'05-10-2018','Ajay Sharma',  6,'Potency','>95% and <104%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('36',36,'06-10-2018','Hitesh Patel', 2,'Potency','>90% and <110%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('37',35,'07-10-2018','Ajay Sharma',  4,'Potency','>90% and <105%','PASSED');
INSERT INTO Material_Quality_Check VALUES ('38',37,'08-10-2018','Hitesh Patel', 1,'Potency','>95% and <104%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('39',38,'09-10-2018','Ajay Sharma',  2,'Potency','>90% and <110%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('40',39,'10-10-2018','Hitesh Patel', 5,'Potency','>90% and <105%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('41',40,'11-10-2018','Ajay Sharma',  3,'Potency','>95% and <115%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('42',41,'12-10-2018','Hitesh Patel', 2,'Potency','>80% and <110%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('43',42,'13-10-2018','Ajay Sharma',  1,'Potency','>80% and <115%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('44',43,'14-10-2018','Hitesh Patel', 4,'Potency','>65% and <115%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('45',44,'15-10-2018','Ajay Sharma',  2,'Potency','>70% and <110%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('46',45,'16-10-2018','Hitesh Patel', 4,'Potency','>80% and <105%','FAILED');
INSERT INTO Material_Quality_Check VALUES ('47',46,'17-10-2018','Ajay Sharma',  3,'Potency','>85% and <104%','FAILED');



INSERT INTO RM_Transaction VALUES (1, 1, 10000,100000);
INSERT INTO RM_Transaction VALUES (1, 2, 50000,500000);
INSERT INTO RM_Transaction VALUES (1, 3, 20000,1000000);
INSERT INTO RM_Transaction VALUES (1, 4, 20000,500000);
INSERT INTO RM_Transaction VALUES (1, 5, 30000,150000);
INSERT INTO RM_Transaction VALUES (2, 6, 50000,1000000);
INSERT INTO RM_Transaction VALUES (2, 7, 10000,1000000);
INSERT INTO RM_Transaction VALUES (2, 8, 10000,100000);
INSERT INTO RM_Transaction VALUES (3, 9, 40000,1600000);
INSERT INTO RM_Transaction VALUES (4, 10,10000,150000);
INSERT INTO RM_Transaction VALUES (5, 11,40000,1600000);
INSERT INTO RM_Transaction VALUES (6, 12,30000,1500000);
INSERT INTO RM_Transaction VALUES (7, 13,15000,1500000);
INSERT INTO RM_Transaction VALUES (8, 14,11000,1100000);
INSERT INTO RM_Transaction VALUES (8, 15,20000,2000000);
INSERT INTO RM_Transaction VALUES (8, 16,10000,1000000);
INSERT INTO RM_Transaction VALUES (9, 17,10000,2000000);
INSERT INTO RM_Transaction VALUES (9, 18,30000,6000000);
INSERT INTO RM_Transaction VALUES (9, 19,20000,4000000);
INSERT INTO RM_Transaction VALUES (10,20,15000,3000000);
INSERT INTO RM_Transaction VALUES (10,21,35000,3500000);
INSERT INTO RM_Transaction VALUES (11,22,15000,150000);
INSERT INTO RM_Transaction VALUES (11,23,10000,100000);
INSERT INTO RM_Transaction VALUES (11,24,25000,250000);
INSERT INTO RM_Transaction VALUES (12,25,20000,200000);
INSERT INTO RM_Transaction VALUES (13,26,30000,3000000);
INSERT INTO RM_Transaction VALUES (14,27,10000,100000);
INSERT INTO RM_Transaction VALUES (15,28,15000,750000);
INSERT INTO RM_Transaction VALUES (16,29,20000,800000);
INSERT INTO RM_Transaction VALUES (16,30,15000,150000);
INSERT INTO RM_Transaction VALUES (16,31,15000,150000);
INSERT INTO RM_Transaction VALUES (16,32,10000,700000);
INSERT INTO RM_Transaction VALUES (17,33,15000,150000);
INSERT INTO RM_Transaction VALUES (17,34,20000,8000000);
INSERT INTO RM_Transaction VALUES (18,35,20000,2000000);
INSERT INTO RM_Transaction VALUES (18,36,30000,3000000);
INSERT INTO RM_Transaction VALUES (19,37,10000,200000);
INSERT INTO RM_Transaction VALUES (20,38,10000,100000);
INSERT INTO RM_Transaction VALUES (21,39,12000,1200000);
INSERT INTO RM_Transaction VALUES (21,40,11000,1100000);
INSERT INTO RM_Transaction VALUES (22,41,15000,1050000);
INSERT INTO RM_Transaction VALUES (23,42,15000,150000);
INSERT INTO RM_Transaction VALUES (24,43,15000,75000);
INSERT INTO RM_Transaction VALUES (25,44,10000,1000000);
INSERT INTO RM_Transaction VALUES (26,45,20000,200000);
INSERT INTO RM_Transaction VALUES (26,46,10000,1000000);

INSERT INTO Product_Master VALUES ('SP0001PD','Vitarich','Multivitamin-Multimineral','Tablet','ALU','2x10','M','B');
INSERT INTO Product_Master VALUES ('SP0002PD','Vitarich','Multivitamin-Multimineral','Tablet','ALU','2x10','S','B');
INSERT INTO Product_Master VALUES ('SP0003PD','Finamin','Essential Amino Acids and Vitamins','Capsule','BLI','2x10','M','B');
INSERT INTO Product_Master VALUES ('SG0001PD','Omsergy','Omeprazole','Capsule','ALU','10x10','M','B');
INSERT INTO Product_Master VALUES ('SY0001PD','Exicof','Cough Syrup','Syrup','BOT','1x1','M','B');
INSERT INTO Product_Master VALUES ('SG0002PD','Parabufen','Paracetamol Ibuprofen','Tablet','BLI','3x10','M','B');
INSERT INTO Product_Master VALUES ('SG0003PD','Tinizoa','Tinidazole','Tablet','ALU','2x12','M','B');
INSERT INTO Product_Master VALUES ('SG0004PD','Norseptin 400','Norfloxacin','Tablet','BLI','3x10','M','B');
INSERT INTO Product_Master VALUES ('SP0005PD','Amoxyn','Amoxycillin Oral Suspension','Syrup','BOT','1x1','M','B');
INSERT INTO Product_Master VALUES ('SG0005PD','Rhinacet','Levocetirizine','Tablet','BLI','5x10','M','B');
INSERT INTO Product_Master VALUES ('SG0006PD','Desloratadine SP','Desloratadine','Tablet','ALU','3x7','M','G');
INSERT INTO Product_Master VALUES ('SG0007PD','Atorvastatin 20','Atorvastatin','Tablet','ALU','3x10','M','G');
INSERT INTO Product_Master VALUES ('SG0008PD','Montehist','Montelukast Sodium and Levocetirizine','Tablet','ALU','10x10','M','B');
INSERT INTO Product_Master VALUES ('SG0009PD','Omecid','Gastro Resistant Omeprazole','Capsule','ALU','3x10','M','B');
INSERT INTO Product_Master VALUES ('SG0010PD','Zetry','Cetirizine Hydrochloride','Tablet','ALU','10x10','M','B');
INSERT INTO Product_Master VALUES ('SG0011PD','Lotenz 100','Losartan Potassium','Tablet','ALU','3x10','M','B');
INSERT INTO Product_Master VALUES ('SG0012PD','Coldrest','Paracetamol Phenylephrine Caffeine','Tablet','BLI','2x10','M','B');
INSERT INTO Product_Master VALUES ('SG0013PD','Albex 400','Albendazole','Tablet','BLI','1x4','M','B');
INSERT INTO Product_Master VALUES ('SG0014PD','Ultramol 250','Paracetamol','Tablet','ALU','5x10','M','B');
INSERT INTO Product_Master VALUES ('SG0015PD','Ultramol 500','Paracetamol','Tablet','BLI','4x10','M','B');
INSERT INTO Product_Master VALUES ('SG0016PD','Q-Bact 250','Ciprofloxacin Hydrochloride','Tablet','BLI','3x10','M','B');
INSERT INTO Product_Master VALUES ('SG0017PD','Q-Bact 500','Ciprofloxacin Hydrochloride','Tablet','BLI','3x10','M','B');
INSERT INTO Product_Master VALUES ('SG0018PD','Diclobells 50','Diclofenac Potassium','Tablet','BLI','2x10','M','B');
INSERT INTO Product_Master VALUES ('SG0019PD','Tavon ORS Plus Zinc','Oral Rehydration Salts with Zinc','ORS','SCT','2x1','M','B');
INSERT INTO Product_Master VALUES ('SG0020PD','Gludip 3','Glimepiride 3mg','Tablet','BLU','1x10','M','B');
INSERT INTO Product_Master VALUES ('SP0004PD','Cafee 200','Caffeine','Tablet','ALU','3x10','M','B');
INSERT INTO Product_Master VALUES ('GN0001PD','Ibuprofen','Ibuprofen','Tablet','BLI','2x10','M','G');
INSERT INTO Product_Master VALUES ('GN0002PD','Vitamin A','Vitamin A','Capsule','ALU','3x10','S','G');
INSERT INTO Product_Master VALUES ('GN0003PD','L-Lysine','Lysine Hydrochloride','Capsule','ALU','3x10','M','G');
INSERT INTO Product_Master VALUES ('GN0004PD','Leucine','Leucine','Capsule','ALU','3x10','S','G');
INSERT INTO Product_Master VALUES ('GN0005PD','Caffeine','Caffeine','Tablet','BLI','3x10','S','G');
INSERT INTO Product_Master VALUES ('GN0006PD','Azithromycin 500','Azithromycin','Capsule','ALU','3x10','M','G');

INSERT INTO Formula_Master VALUES ('SP0001PD','VT001',100);
INSERT INTO Formula_Master VALUES ('SP0001PD','VT002',250);
INSERT INTO Formula_Master VALUES ('SP0001PD','EX002',650);
INSERT INTO Formula_Master VALUES ('SP0002PD','VT001',100);
INSERT INTO Formula_Master VALUES ('SP0002PD','VT002',250);
INSERT INTO Formula_Master VALUES ('SP0002PD','EX002',650);
INSERT INTO Formula_Master VALUES ('SP0003PD','PR001',150);
INSERT INTO Formula_Master VALUES ('SP0003PD','PR002',150);
INSERT INTO Formula_Master VALUES ('SP0003PD','PR003',300);
INSERT INTO Formula_Master VALUES ('SP0003PD','EX002',400);
INSERT INTO Formula_Master VALUES ('SG0001PD','NB001',200);
INSERT INTO Formula_Master VALUES ('SG0001PD','EX001',250);
INSERT INTO Formula_Master VALUES ('SG0001PD','EX003',100);
INSERT INTO Formula_Master VALUES ('SG0001PD','EX002',450);
INSERT INTO Formula_Master VALUES ('SG0002PD','NB014',200);
INSERT INTO Formula_Master VALUES ('SG0002PD','PC001',500);
INSERT INTO Formula_Master VALUES ('SG0002PD','EX002',300);
INSERT INTO Formula_Master VALUES ('SG0003PD','NB003',250);
INSERT INTO Formula_Master VALUES ('SG0003PD','EX002',200);
INSERT INTO Formula_Master VALUES ('SG0003PD','EX004',250);
INSERT INTO Formula_Master VALUES ('SG0003PD','EX003',300);
INSERT INTO Formula_Master VALUES ('SG0004PD','NB012',400);
INSERT INTO Formula_Master VALUES ('SG0004PD','EX002',300);
INSERT INTO Formula_Master VALUES ('SG0004PD','EX003',300);
INSERT INTO Formula_Master VALUES ('SG0005PD','OR007',300);
INSERT INTO Formula_Master VALUES ('SG0005PD','EX004',700);
INSERT INTO Formula_Master VALUES ('SG0006PD','NB007',500);
INSERT INTO Formula_Master VALUES ('SG0006PD','EX003',300);
INSERT INTO Formula_Master VALUES ('SG0006PD','EX004',200);
INSERT INTO Formula_Master VALUES ('SG0007PD','NB004',250);
INSERT INTO Formula_Master VALUES ('SG0007PD','EX001',750);
INSERT INTO Formula_Master VALUES ('SG0008PD','NB011',250);
INSERT INTO Formula_Master VALUES ('SG0008PD','OR007',250);
INSERT INTO Formula_Master VALUES ('SG0008PD','EX003',500);
INSERT INTO Formula_Master VALUES ('SG0009PD','NB001',500);
INSERT INTO Formula_Master VALUES ('SG0009PD','EX002',500);
INSERT INTO Formula_Master VALUES ('SG0010PD','NB007',500);
INSERT INTO Formula_Master VALUES ('SG0010PD','EX001',500);
INSERT INTO Formula_Master VALUES ('SG0011PD','OR001',300);
INSERT INTO Formula_Master VALUES ('SG0011PD','EX001',300);
INSERT INTO Formula_Master VALUES ('SG0011PD','EX002',400);
INSERT INTO Formula_Master VALUES ('SG0012PD','PC001',250);
INSERT INTO Formula_Master VALUES ('SG0012PD','NB013',250);
INSERT INTO Formula_Master VALUES ('SG0012PD','OT001',250);
INSERT INTO Formula_Master VALUES ('SG0012PD','EX001',250);
INSERT INTO Formula_Master VALUES ('SG0013PD','NB009',300);
INSERT INTO Formula_Master VALUES ('SG0013PD','EX004',700);
INSERT INTO Formula_Master VALUES ('SG0014PD','PC001',250);
INSERT INTO Formula_Master VALUES ('SG0014PD','EX001',250);
INSERT INTO Formula_Master VALUES ('SG0014PD','EX002',500);
INSERT INTO Formula_Master VALUES ('SG0015PD','PC001',500);
INSERT INTO Formula_Master VALUES ('SG0015PD','EX001',250);
INSERT INTO Formula_Master VALUES ('SG0015PD','EX002',250);
INSERT INTO Formula_Master VALUES ('SG0016PD','NB006',250);
INSERT INTO Formula_Master VALUES ('SG0016PD','EX001',250);
INSERT INTO Formula_Master VALUES ('SG0016PD','EX002',500);
INSERT INTO Formula_Master VALUES ('SG0017PD','NB006',500);
INSERT INTO Formula_Master VALUES ('SG0017PD','EX001',250);
INSERT INTO Formula_Master VALUES ('SG0017PD','EX002',250);
INSERT INTO Formula_Master VALUES ('SG0018PD','NB010',50);
INSERT INTO Formula_Master VALUES ('SG0018PD','EX004',450);
INSERT INTO Formula_Master VALUES ('SG0019PD','OR002',2600);
INSERT INTO Formula_Master VALUES ('SG0019PD','OR003',1500);
INSERT INTO Formula_Master VALUES ('SG0019PD','OR004',2900);
INSERT INTO Formula_Master VALUES ('SG0019PD','OR005',13450);
INSERT INTO Formula_Master VALUES ('SG0019PD','OR006',50);
INSERT INTO Formula_Master VALUES ('SG0020PD','NB005',3);
INSERT INTO Formula_Master VALUES ('SG0020PD','EX001',27);
INSERT INTO Formula_Master VALUES ('SG0020PD','EX002',470);
INSERT INTO Formula_Master VALUES ('GN0001PD','NB014',200);
INSERT INTO Formula_Master VALUES ('GN0001PD','EX001',200);
INSERT INTO Formula_Master VALUES ('GN0001PD','EX002',600);
INSERT INTO Formula_Master VALUES ('GN0002PD','VT001',300);
INSERT INTO Formula_Master VALUES ('GN0002PD','EX002',700);
INSERT INTO Formula_Master VALUES ('GN0003PD','PR002',300);
INSERT INTO Formula_Master VALUES ('GN0003PD','EX001',300);
INSERT INTO Formula_Master VALUES ('GN0003PD','EX003',400);
INSERT INTO Formula_Master VALUES ('GN0004PD','PR001',300);
INSERT INTO Formula_Master VALUES ('GN0004PD','EX003',300);
INSERT INTO Formula_Master VALUES ('GN0004PD','EX004',400);
INSERT INTO Formula_Master VALUES ('GN0005PD','OT001',400);
INSERT INTO Formula_Master VALUES ('GN0005PD','EX001',300);
INSERT INTO Formula_Master VALUES ('GN0005PD','EX004',300);
INSERT INTO Formula_Master VALUES ('SP0004PD','OT001',800);
INSERT INTO Formula_Master VALUES ('SP0004PD','EX001',100);
INSERT INTO Formula_Master VALUES ('SP0004PD','EX002',100);
INSERT INTO Formula_Master VALUES ('GN0006PD','NB002',500);
INSERT INTO Formula_Master VALUES ('GN0006PD','EX002',250);
INSERT INTO Formula_Master VALUES ('GN0006PD','EX003',250);
INSERT INTO Formula_Master VALUES ('SY0001PD','OR008',1000);
INSERT INTO Formula_Master VALUES ('SY0001PD','OR009',250);
INSERT INTO Formula_Master VALUES ('SY0001PD','EX003',250);
INSERT INTO Formula_Master VALUES ('SP0005PD','NB008',2250);
INSERT INTO Formula_Master VALUES ('SP0005PD','EX003',250);

INSERT INTO Batch VALUES (1, 10000,'2018-10-18','2019-10-17','SP0001PD',10000,'UT');
INSERT INTO Batch VALUES (2,  8000,'2018-10-19','2019-10-18','SP0002PD', 8000,'UT');
INSERT INTO Batch VALUES (3, 20000,'2018-10-20','2019-10-19','SP0003PD',20000,'UT');
INSERT INTO Batch VALUES (4, 30000,'2018-10-21','2019-10-20','SG0001PD',30000,'UT');
INSERT INTO Batch VALUES (5,  5000,'2018-10-22','2019-10-21','SY0001PD', 5000,'UT');
INSERT INTO Batch VALUES (6,  2000,'2018-10-23','2019-10-22','SG0002PD', 2000,'UT');
INSERT INTO Batch VALUES (7, 10000,'2018-10-24','2019-10-23','SG0003PD',10000,'UT');
INSERT INTO Batch VALUES (8, 20000,'2018-10-25','2019-10-24','SG0004PD',20000,'UT');
INSERT INTO Batch VALUES (9,  5000,'2018-10-26','2019-05-25','SP0005PD', 5000,'UT');
INSERT INTO Batch VALUES (10,20000,'2018-10-27','2019-10-26','SG0005PD',20000,'UT');
INSERT INTO Batch VALUES (11, 5000,'2018-10-28','2019-10-27','SG0006PD', 5000,'UT');
INSERT INTO Batch VALUES (12, 5000,'2018-10-29','2019-10-28','SG0007PD', 5000,'UT');
INSERT INTO Batch VALUES (13, 8000,'2018-10-30','2019-06-29','SG0008PD', 8000,'UT');
INSERT INTO Batch VALUES (14, 9000,'2018-10-31','2019-10-30','SG0009PD', 9000,'UT');
INSERT INTO Batch VALUES (15, 6000,'2018-11-01','2019-08-31','SG0010PD', 6000,'UT');
INSERT INTO Batch VALUES (16, 7000,'2018-11-02','2019-11-01','SG0011PD', 7000,'UT');
INSERT INTO Batch VALUES (17, 4000,'2018-11-03','2019-11-02','SG0012PD', 4000,'UT');
INSERT INTO Batch VALUES (18, 3000,'2018-11-04','2019-11-03','SG0013PD', 3000,'UT');
INSERT INTO Batch VALUES (19,15000,'2018-11-05','2019-11-04','SG0014PD',15000,'UT');
INSERT INTO Batch VALUES (20,25000,'2018-11-06','2019-09-05','SG0015PD',25000,'UT');
INSERT INTO Batch VALUES (21, 5000,'2018-11-07','2019-11-06','SG0016PD', 5000,'UT');
INSERT INTO Batch VALUES (22,20000,'2018-11-08','2019-11-07','SG0017PD',20000,'UT');
INSERT INTO Batch VALUES (23,10000,'2018-11-09','2019-11-08','SG0018PD',10000,'UT');
INSERT INTO Batch VALUES (24,11000,'2018-11-10','2019-11-09','SG0019PD',11000,'UT');
INSERT INTO Batch VALUES (25, 5000,'2018-11-11','2019-09-10','SG0020PD', 5000,'UT');
INSERT INTO Batch VALUES (26,40000,'2018-11-12','2019-10-11','SP0004PD',40000,'UT');
INSERT INTO Batch VALUES (27,50000,'2018-11-13','2019-06-12','GN0001PD',50000,'UT');
INSERT INTO Batch VALUES (28,10000,'2018-11-14','2019-05-13','GN0002PD',10000,'UT');
INSERT INTO Batch VALUES (29, 4000,'2018-11-15','2019-09-14','GN0003PD', 4000,'UT');
INSERT INTO Batch VALUES (30, 5000,'2018-11-16','2019-07-15','GN0004PD', 5000,'UT');
INSERT INTO Batch VALUES (31, 5000,'2018-11-17','2019-10-16','GN0005PD', 5000,'UT');
INSERT INTO Batch VALUES (32,10000,'2018-11-18','2019-09-17','GN0006PD',10000,'UT');



INSERT INTO Material_Dispensing VALUES (1, 1, 1000);
INSERT INTO Material_Dispensing VALUES (1, 2, 2500);
INSERT INTO Material_Dispensing VALUES (1,32, 6500);
INSERT INTO Material_Dispensing VALUES (2, 1,  800);
INSERT INTO Material_Dispensing VALUES (2, 2, 2000);
INSERT INTO Material_Dispensing VALUES (2,32, 5200);
INSERT INTO Material_Dispensing VALUES (3, 6, 3000);
INSERT INTO Material_Dispensing VALUES (3, 7, 3000);
INSERT INTO Material_Dispensing VALUES (3, 8, 6000);
INSERT INTO Material_Dispensing VALUES (3,32, 8000);
INSERT INTO Material_Dispensing VALUES (4, 4, 6000);
INSERT INTO Material_Dispensing VALUES (4,31, 7500);
INSERT INTO Material_Dispensing VALUES (4,33, 3000);
INSERT INTO Material_Dispensing VALUES (4,32,13500);
INSERT INTO Material_Dispensing VALUES (5,21, 5000);
INSERT INTO Material_Dispensing VALUES (5,22, 1250);
INSERT INTO Material_Dispensing VALUES (5,33, 1250);
INSERT INTO Material_Dispensing VALUES (6,30,  400);
INSERT INTO Material_Dispensing VALUES (6, 3, 1000);
INSERT INTO Material_Dispensing VALUES (6,32,  600);
INSERT INTO Material_Dispensing VALUES (7, 9, 2500);
INSERT INTO Material_Dispensing VALUES (7,32, 2000);
INSERT INTO Material_Dispensing VALUES (7,34, 2500);
INSERT INTO Material_Dispensing VALUES (7,33, 3000);
INSERT INTO Material_Dispensing VALUES (8,27, 8000);
INSERT INTO Material_Dispensing VALUES (8,32, 6000);
INSERT INTO Material_Dispensing VALUES (8,33, 6000);
INSERT INTO Material_Dispensing VALUES (9,23,11250);
INSERT INTO Material_Dispensing VALUES (9,33, 1250);
INSERT INTO Material_Dispensing VALUES (10,19, 6000);
INSERT INTO Material_Dispensing VALUES (10,34,14000);
INSERT INTO Material_Dispensing VALUES (11,20, 2500);
INSERT INTO Material_Dispensing VALUES (11,33, 1500);
INSERT INTO Material_Dispensing VALUES (11,34, 1000);
INSERT INTO Material_Dispensing VALUES (12,10, 1250);
INSERT INTO Material_Dispensing VALUES (12,31, 3750);
INSERT INTO Material_Dispensing VALUES (13,26, 2000);
INSERT INTO Material_Dispensing VALUES (13,19, 2000);
INSERT INTO Material_Dispensing VALUES (13,33, 4000);
INSERT INTO Material_Dispensing VALUES (14, 4, 4500);
INSERT INTO Material_Dispensing VALUES (14,32, 4500);
INSERT INTO Material_Dispensing VALUES (15,20, 3000);
INSERT INTO Material_Dispensing VALUES (15,31, 3000);
INSERT INTO Material_Dispensing VALUES (16,13, 2100);
INSERT INTO Material_Dispensing VALUES (16,31, 2100);
INSERT INTO Material_Dispensing VALUES (16,32, 2800);
INSERT INTO Material_Dispensing VALUES (17,29, 1000);
INSERT INTO Material_Dispensing VALUES (17, 3, 1000);
INSERT INTO Material_Dispensing VALUES (17,28, 1000);
INSERT INTO Material_Dispensing VALUES (17,31, 1000);
INSERT INTO Material_Dispensing VALUES (18,24,  900);
INSERT INTO Material_Dispensing VALUES (18,34, 2100);
INSERT INTO Material_Dispensing VALUES (19, 3, 3750);
INSERT INTO Material_Dispensing VALUES (19,31, 3750);
INSERT INTO Material_Dispensing VALUES (19,32, 7500);
INSERT INTO Material_Dispensing VALUES (20, 3,12500);
INSERT INTO Material_Dispensing VALUES (20,31, 6250);
INSERT INTO Material_Dispensing VALUES (20,32, 6250);
INSERT INTO Material_Dispensing VALUES (21,12, 1250);
INSERT INTO Material_Dispensing VALUES (21,31, 1250);
INSERT INTO Material_Dispensing VALUES (21,32, 2500);
INSERT INTO Material_Dispensing VALUES (22,12,10000);
INSERT INTO Material_Dispensing VALUES (22,31, 5000);
INSERT INTO Material_Dispensing VALUES (22,32, 5000);
INSERT INTO Material_Dispensing VALUES (23,25,  500);
INSERT INTO Material_Dispensing VALUES (23,34, 4500);
INSERT INTO Material_Dispensing VALUES (24,14,28600);
INSERT INTO Material_Dispensing VALUES (24,15,16500);
INSERT INTO Material_Dispensing VALUES (24,16,31900);
INSERT INTO Material_Dispensing VALUES (24,17,147950);
INSERT INTO Material_Dispensing VALUES (24,18,   550);
INSERT INTO Material_Dispensing VALUES (25,11,    15);
INSERT INTO Material_Dispensing VALUES (25,31,   135);
INSERT INTO Material_Dispensing VALUES (25,32,  2350);
INSERT INTO Material_Dispensing VALUES (26,28,32000);
INSERT INTO Material_Dispensing VALUES (26,31, 4000);
INSERT INTO Material_Dispensing VALUES (26,32, 4000);
INSERT INTO Material_Dispensing VALUES (27,30,10000);
INSERT INTO Material_Dispensing VALUES (27,31,10000);
INSERT INTO Material_Dispensing VALUES (27,32,30000);
INSERT INTO Material_Dispensing VALUES (28, 1, 3000);
INSERT INTO Material_Dispensing VALUES (28,32, 7000);
INSERT INTO Material_Dispensing VALUES (29, 7, 1200);
INSERT INTO Material_Dispensing VALUES (29,31, 1200);
INSERT INTO Material_Dispensing VALUES (29,33, 1600);
INSERT INTO Material_Dispensing VALUES (30, 6, 1500);
INSERT INTO Material_Dispensing VALUES (30,33, 1500);
INSERT INTO Material_Dispensing VALUES (30,34, 2000);
INSERT INTO Material_Dispensing VALUES (31,28, 2000);
INSERT INTO Material_Dispensing VALUES (31,31, 1500);
INSERT INTO Material_Dispensing VALUES (31,34, 1500);
INSERT INTO Material_Dispensing VALUES (32, 5, 5000);
INSERT INTO Material_Dispensing VALUES (32,32, 2500);
INSERT INTO Material_Dispensing VALUES (32,33, 2500);


INSERT INTO Product_Quality_Check VALUES ('1', 1,'2018-10-19','Ajay Sharma', 10,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('2', 1,'2018-10-19','Hitesh Patel',20,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('3', 1,'2018-10-19','Ajay Sharma', 30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('4', 2,'2018-10-20','Hitesh Patel',10,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('5', 2,'2018-10-20','Ajay Sharma', 20,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('6', 2,'2018-10-20','Hitesh Patel',10,'Coating','Assay','>80% and <110%','FAILED');
INSERT INTO Product_Quality_Check VALUES ('7', 3,'2018-10-21','Ajay Sharma', 30,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('8', 3,'2018-10-21','Hitesh Patel',10,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('9', 3,'2018-10-21','Ajay Sharma', 50,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('10',4,'2018-10-22','Hitesh Patel',30,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('11',4,'2018-10-22','Ajay Sharma', 20,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('12',4,'2018-10-22','Hitesh Patel',30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('13',5,'2018-10-23','Ajay Sharma', 40,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('14',5,'2018-10-23','Hitesh Patel',10,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('15',5,'2018-10-23','Ajay Sharma', 30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('16',6,'2018-10-24','Hitesh Patel',20,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('17',6,'2018-10-24','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('18',6,'2018-10-24','Hitesh Patel',30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('19',7,'2018-10-25','Ajay Sharma', 30,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('20',7,'2018-10-25','Hitesh Patel',40,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('21',7,'2018-10-25','Ajay Sharma', 20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('22',8,'2018-10-26','Hitesh Patel',10,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('23',8,'2018-10-26','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('24',8,'2018-10-26','Hitesh Patel',30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('25',9,'2018-10-27','Ajay Sharma', 40,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('26',9,'2018-10-27','Hitesh Patel',50,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('27',9,'2018-10-27','Ajay Sharma', 10,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('28',10,'2018-10-28','Hitesh Patel',20,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('29',10,'2018-10-28','Ajay Sharma', 70,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('30',10,'2018-10-28','Hitesh Patel',20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('31',11,'2018-10-29','Ajay Sharma', 40,'Granulation','Disintegration time','>0 <20 min','FAILED');
INSERT INTO Product_Quality_Check VALUES ('32',12,'2018-10-30','Hitesh Patel',40,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('33',12,'2018-10-30','Ajay Sharma', 60,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('34',12,'2018-10-30','Hitesh Patel',20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('35',13,'2018-10-31','Ajay Sharma', 40,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('36',13,'2018-10-31','Hitesh Patel',10,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('37',13,'2018-10-31','Ajay Sharma', 20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('38',14,'2018-11-01','Hitesh Patel',50,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('39',14,'2018-11-01','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('40',14,'2018-11-01','Hitesh Patel',20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('41',15,'2018-11-02','Ajay Sharma', 10,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('42',15,'2018-11-02','Hitesh Patel',40,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('43',15,'2018-11-02','Ajay Sharma', 20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('44',16,'2018-11-03','Hitesh Patel',40,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('45',16,'2018-11-03','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('46',16,'2018-11-03','Hitesh Patel',10,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('47',17,'2018-11-04','Ajay Sharma', 20,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('48',17,'2018-11-04','Hitesh Patel',30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('49',17,'2018-11-04','Ajay Sharma', 10,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('50',18,'2018-11-05','Hitesh Patel',20,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('51',18,'2018-11-05','Ajay Sharma', 10,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('52',18,'2018-11-05','Hitesh Patel',30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('53',19,'2018-11-06','Ajay Sharma', 10,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('54',19,'2018-11-06','Hitesh Patel',50,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('55',19,'2018-11-06','Ajay Sharma', 30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('56',20,'2018-11-07','Hitesh Patel',20,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('57',20,'2018-11-07','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('58',20,'2018-11-07','Hitesh Patel',40,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('59',21,'2018-11-08','Ajay Sharma', 10,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('60',21,'2018-11-08','Hitesh Patel',30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('61',21,'2018-11-08','Ajay Sharma', 20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('62',22,'2018-11-09','Hitesh Patel',30,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('63',22,'2018-11-09','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('64',22,'2018-11-09','Hitesh Patel',30,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('65',23,'2018-11-10','Ajay Sharma', 40,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('66',23,'2018-11-10','Hitesh Patel',20,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('67',23,'2018-11-10','Ajay Sharma', 10,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('68',24,'2018-11-11','Hitesh Patel',30,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('69',24,'2018-11-11','Ajay Sharma', 30,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('70',24,'2018-11-11','Hitesh Patel',40,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('71',25,'2018-11-12','Ajay Sharma', 50,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('72',25,'2018-11-12','Hitesh Patel',10,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('73',25,'2018-11-12','Ajay Sharma', 20,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('74',26,'2018-11-13','Hitesh Patel',70,'Granulation','Disintegration time','>0 <10 min','PASSED');
INSERT INTO Product_Quality_Check VALUES ('75',26,'2018-11-13','Ajay Sharma', 20,'Compression','Hardness','>2 <15 kg/cm2','PASSED');
INSERT INTO Product_Quality_Check VALUES ('76',26,'2018-11-13','Hitesh Patel',40,'Coating','Assay','>90% and <110%','PASSED');
INSERT INTO Product_Quality_Check VALUES ('77',27,'2018-11-14','Ajay Sharma', 30,'Granulation','Disintegration time','>0 <20 min','FAILED');


INSERT INTO FG_Transaction VALUES (1001, 1, 5000, 50000);
INSERT INTO FG_Transaction VALUES (1002,10,15000,300000);
INSERT INTO FG_Transaction VALUES (1002, 9, 4500, 36000);
INSERT INTO FG_Transaction VALUES (1003, 8,18000,540000);
INSERT INTO FG_Transaction VALUES (1004, 3,15000,195000);
INSERT INTO FG_Transaction VALUES (1005, 5, 4800, 76800);
INSERT INTO FG_Transaction VALUES (1006, 4,25000,225000);
INSERT INTO FG_Transaction VALUES (1006, 7, 9000, 45000);
INSERT INTO FG_Transaction VALUES (1007, 6, 1000, 45000);
INSERT INTO FG_Transaction VALUES (1008,23, 4000, 60000);
INSERT INTO FG_Transaction VALUES (1008,22,18000,342000);
INSERT INTO FG_Transaction VALUES (1009,21, 1400, 28000);
INSERT INTO FG_Transaction VALUES (1010,19, 8000, 72000);
INSERT INTO FG_Transaction VALUES (1011,13, 7000, 70000);



SELECT * FROM Material_Master;

SELECT Product_Name, Generic_Name FROM Product_Master;

SELECT * FROM Transactions WHERE Transaction_Type = 'buy';

SELECT * FROM Batch WHERE Stock_Qty > 10000;

SELECT Material_ID, Stock FROM Warehouse WHERE Stock > 20000;

SELECT A.Account_Name, T.Invoice_No
FROM Account_Master A
JOIN Transactions T ON A.Account_No = T.Account_No;

SELECT Material_ID
FROM Formula_Master
WHERE Product_ID = 'SP0001PD';

SELECT B.Batch_No, P.Product_Name
FROM Batch B
JOIN Product_Master P ON B.Product_ID = P.Product_ID;

SELECT * FROM Material_Quality_Check WHERE Results = 'FAILED';

SELECT Product_ID, COUNT(Material_ID) AS Material_Count
FROM Formula_Master
GROUP BY Product_ID
HAVING COUNT(Material_ID) > 3;

SELECT Batch_No, SUM(Quantity_Issued) AS Total_Issued
FROM Material_Dispensing
GROUP BY Batch_No;

SELECT P.Product_Name, B.Batch_No, B.Stock_Qty
FROM Product_Master P
JOIN Batch B ON P.Product_ID = B.Product_ID;

SELECT P.Product_Name, M.Material_ID
FROM Product_Master P
JOIN Batch B ON P.Product_ID = B.Product_ID
JOIN Material_Dispensing MD ON B.Batch_No = MD.Batch_No
JOIN Warehouse W ON MD.Item_ID = W.Item_ID
JOIN Material_Master M ON W.Material_ID = M.Material_ID;

SELECT Batch_No, SUM(Sale_Qty)
FROM FG_Transaction
GROUP BY Batch_No;

SELECT DISTINCT A.Account_Name
FROM Account_Master A
JOIN Transactions T ON A.Account_No = T.Account_No
WHERE T.Transaction_Type = 'sell';

SELECT B.Batch_No
FROM Batch B
JOIN Material_Dispensing MD ON B.Batch_No = MD.Batch_No
GROUP BY B.Batch_No, B.Stock_Qty
HAVING SUM(MD.Quantity_Issued) > B.Stock_Qty;

SELECT DISTINCT P.Product_Name
FROM Product_Master P
JOIN Formula_Master F ON P.Product_ID = F.Product_ID
JOIN Material_Master M ON F.Material_ID = M.Material_ID
WHERE M.isHazardous = TRUE;

SELECT A.Account_Name, SUM(T.Total_Value)
FROM Account_Master A
JOIN Transactions T ON A.Account_No = T.Account_No
GROUP BY A.Account_Name;

SELECT DISTINCT P.Product_Name
FROM Product_Master P
JOIN Batch B ON P.Product_ID = B.Product_ID
WHERE NOT EXISTS (
    SELECT 1
    FROM Product_Quality_Check PQ
    WHERE PQ.Batch_No = B.Batch_No
    AND PQ.Results = 'FAILED'
);

SELECT * FROM Material_Master
WHERE isHazardous = TRUE AND isInflammable = TRUE;

SELECT * FROM Batch
WHERE Exp_Date < CURRENT_DATE;

SELECT * FROM Batch
WHERE Exp_Date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';

SELECT P.Product_Name, SUM(MD.Quantity_Issued) AS Total_Consumed
FROM Product_Master P
JOIN Batch B ON P.Product_ID = B.Product_ID
JOIN Material_Dispensing MD ON B.Batch_No = MD.Batch_No
GROUP BY P.Product_Name;

SELECT A.Account_Name, SUM(T.Total_Value) AS Total_Amount
FROM Account_Master A
JOIN Transactions T ON A.Account_No = T.Account_No
GROUP BY A.Account_Name
ORDER BY Total_Amount DESC;

SELECT Material_ID
FROM Material_Master
WHERE Material_ID NOT IN (
    SELECT Material_ID FROM Formula_Master
);

SELECT Product_ID
FROM Product_Master
WHERE Product_ID NOT IN (
    SELECT Product_ID FROM Batch
);

SELECT Item_ID
FROM Warehouse
WHERE Item_ID NOT IN (
    SELECT Item_ID FROM Material_Quality_Check
);

SELECT Batch_No
FROM Product_Quality_Check
WHERE Results = 'FAILED';

SELECT SUM(Total_Value) AS Total_Revenue
FROM Transactions
WHERE Transaction_Type = 'sell';

SELECT Material_ID, COUNT(Product_ID)
FROM Formula_Master
GROUP BY Material_ID
HAVING COUNT(Product_ID) > 2;

SELECT W.Material_ID, SUM(MD.Quantity_Issued) AS Total_Used
FROM Material_Dispensing MD
JOIN Warehouse W ON MD.Item_ID = W.Item_ID
GROUP BY W.Material_ID
ORDER BY Total_Used DESC
LIMIT 1;

SELECT *
FROM Batch
WHERE Stock_Qty = 0 AND Batch_Size > 0;

SELECT AVG(Sample_Size)
FROM Material_Quality_Check;

SELECT *
FROM Transactions
WHERE Paid_Received = FALSE;
