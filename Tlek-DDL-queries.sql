create table interactions(
    user_id int not null, 
    item_id int NOT null,
    progress int8 not null,
    rating float, 
    isFavorite BOOLEAN NULL ,
    start_date date not null,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(id),
    CHECK (isFavorite IN (0,1))
    );

create table items(
    id int NOT null,
    title varchar(255) not null,
    genres varchar(255),
    authors varchar(255),
    year varchar(255),
    PRIMARY KEY (id)
);

create table users(
    user_id int not null, 
    age varchar(255),
    sex FLOAT,
    PRIMARY KEY (user_id)
);


create table wishlist(
    user_id int not null, 
    item_id int NOT null,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(id)
);

create table rating(
    user_id int not null, 
    item_id int NOT null,
    user_rating int not null,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(id)
);


create table comments(
    user_id int not null,
    item_id int not null, 
    context varchar(255) not null, 
    created_date date not null,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(id)
);
