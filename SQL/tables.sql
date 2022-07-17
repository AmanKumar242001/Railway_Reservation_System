CREATE TABLE admin (
    username varchar(50) not null,
    password varchar(20) not null CHECK(char_length(password) > 4),
    PRIMARY KEY(username)
);




CREATE TABLE user_ (
    username varchar(50) not null,
    name varchar(50) not null,
    email varchar(50) not null CHECK (
        email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'
    ),
    address varchar(70) not null,
    password varchar(20) not null CHECK (char_length(password) > 4),
    PRIMARY KEY(username)
);

ALTER TABLE user_
ADD UNIQUE(email);




CREATE TABLE train (
    train_no int not null,
    date DATE not null,
    ac_num int not null CHECK (ac_num > 0),
    sleeper_num int not null CHECK (sleeper_num > 0),
    PRIMARY KEY (train_no, date)
);





CREATE TABLE train_released (
    train_no int not null,
    date DATE not null,
    source varchar(50) not null,
    destination varchar(50) not null,
    ac_available int not null,
    sleeper_available int not null,
    PRIMARY KEY (train_no, date, source, destination),
    FOREIGN KEY (train_no, date) REFERENCES train(train_no, date)
);

ALTER TABLE train_released
ADD CHECK(
        ac_available >= 0
        AND sleeper_available >= 0
    );




CREATE TABLE ticket (
    pnr_no serial,
    train_no int not null,
    date DATE not null,
    coach varchar(20) not null,
    username varchar(50) not null UNIQUE,
    source varchar(50) not null,
    destination varchar(50) not null,
    PRIMARY KEY (pnr_no),
    FOREIGN KEY (username) REFERENCES user_(username)
);

ALTER TABLE ticket
ADD CONSTRAINT fkp FOREIGN KEY(train_no, date, source, destination) REFERENCES train_released(train_no, date, source, destination);




CREATE TABLE passenger (
    pnr_no int not null,
    name varchar(50) not null,
    age int not null,
    gender varchar(20) not null,
    berth_no int not null,
    berth_type varchar(10) not null,
    coach_no int not null,
    PRIMARY KEY (pnr_no, berth_no, coach_no),
    FOREIGN KEY (pnr_no) REFERENCES ticket(pnr_no)
);




CREATE TABLE seating_plan (
    coach_no int,
    berth_no int,
    berth_type varchar(10),
    name varchar(30),
    pn_no int,
    source varchar(50),
    destination varchar(50)
);

ALTER TABLE seating_plan
    RENAME COLUMN pn_no TO pnr_no;