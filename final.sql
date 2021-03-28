CREATE TABLE books(
    bookid FLOAT PRIMARY KEY, 
    title VARCHAR2(1500),
    authors VARCHAR2(1500),
    average_rating FLOAT, 
    num_page NUMBER, 
    ratings_count NUMBER, 
    publication_date DATE,
    publisher VARCHAR2(255)
);
CREATE TABLE users(
    login VARCHAR2(255), 
    password VARCHAR2(255)
);
CREATE TABLE admin_books_log(
    action_author VARCHAR2(255),
    action_date DATE,
    title VARCHAR2(1500), 
    authors VARCHAR2(255)
);


CREATE OR REPLACE TRIGGER insert_into_admin_table
AFTER INSERT ON books FOR EACH ROW
BEGIN
    INSERT INTO admin_books_log(title, authors, action_author, action_date) VALUES(:NEW.title, :NEW.authors, USER, SYSDATE);
END insert_into_admin_table;

CREATE TYPE count_1 IS VARRAY(5) OF NUMBER;

CREATE OR REPLACE PROCEDURE admin_proc(v_text OUT SYS_REFCURSOR) IS
BEGIN
    OPEN v_text FOR
        SELECT b.title, a.action_date, b.authors, b.publisher FROM admin_books_log a INNER JOIN books b ON a.title= b.title AND a.authors = b.authors;
END admin_proc; 


CREATE OR REPLACE TRIGGER create_user_log_trigger 
AFTER INSERT ON users FOR EACH ROW
DECLARE
	v_dynamic_statement VARCHAR2(10000);
    v_name VARCHAR2(255) := :NEW.login;
    v_date DATE := SYSDATE;
BEGIN
   
    v_dynamic_statement := 'INSERT INTO users_log VALUES(:1, :2)';
    EXECUTE IMMEDIATE v_dynamic_statement USING v_name, v_date;
    
END create_user_log_trigger;


CREATE TABLE users_log(
    login VARCHAR2(255),
    date_creation DATE
);





--package for rating body
CREATE OR REPLACE PACKAGE books_rat_pkg IS
    PROCEDURE books_rating_proc(v_text OUT SYS_REFCURSOR);
    PROCEDURE books_5_rating_proc(v_text OUT SYS_REFCURSOR);
END books_rat_pkg;


CREATE OR REPLACE PACKAGE BODY books_rat_pkg IS
    PROCEDURE books_rating_proc(v_text OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN v_text FOR
            SELECT title, authors, average_rating, num_page, publication_date, publisher FROM books
            ORDER BY average_rating FETCH NEXT 10 ROWS ONLY;
    END books_rating_proc;
    
    
    PROCEDURE books_5_rating_proc(v_text OUT SYS_REFCURSOR) IS
    BEGIN
    OPEN v_text FOR
            SELECT title, authors, ratings_count FROM books WHERE ratings_count > 0
            ORDER BY ratings_count DESC FETCH NEXT 5 ROWS ONLY;
    END books_5_rating_proc;
END books_rat_pkg;


            
--functions on inserting 

CREATE OR REPLACE FUNCTION boosk_add_func(p_title IN VARCHAR2, p_authors IN VARCHAR2, p_date IN VARCHAR2, p_publisher IN VARCHAR2, p_date_char OUT DATE)
RETURN INTEGER IS
  v_text INTEGER := 0;
BEGIN
    p_date_char := TO_DATE(p_date, 'dd.mm.yyyy');
    INSERT INTO books(title, authors, publication_date, publisher) VALUES(p_title, p_authors, p_date_char, p_publisher);
    RETURN v_text;
END;

--function that adds user
CREATE OR REPLACE FUNCTION user_add_func(p_login IN VARCHAR2, p_password IN VARCHAR2)
RETURN INTEGER IS
  v_text INTEGER := 0;
BEGIN
    INSERT INTO users(login, password) VALUES(p_login, p_password);
    RETURN v_text;
END;

--function that check registered user
CREATE OR REPLACE FUNCTION user_check_func(p_login IN VARCHAR2, p_password IN VARCHAR2)
RETURN INTEGER IS
  v_text INTEGER := 0;
BEGIN
    SELECT count(login) INTO v_text FROM users WHERE password = p_password AND password IN (SELECT password FROM users WHERE login = p_login);
    IF v_text > 0 THEN v_text := 1;
    ELSE v_text := 0;
    END IF;
    RETURN v_text;
END;




--procedure that holds data in cursor to cab page
CREATE OR REPLACE PROCEDURE books_proc(p_login IN VARCHAR2, v_text OUT SYS_REFCURSOR) IS
BEGIN
    OPEN v_text FOR
            SELECT title, authors, average_rating, num_page, publication_date, publisher FROM books WHERE publisher = p_login
            FETCH NEXT 3 ROWS ONLY; 
END books_proc;


--procedure that returns number count of books of each user
CREATE OR REPLACE PROCEDURE books_count_func(p_login IN VARCHAR2, v_text OUT NUMBER) IS
BEGIN
    SELECT COUNT(title) INTO v_text FROM books WHERE publisher = p_login; 
END;


--similarity between text 
CREATE OR REPLACE PROCEDURE get_simil(p_query_title VARCHAR2, p_query_author VARCHAR2, v_text OUT SYS_REFCURSOR) IS
BEGIN
    OPEN v_text FOR 
        SELECT * FROM books WHERE compare_text(authors, p_query_author) = 1 AND compare_text(title, p_query_title) = 1 FETCH NEXT 9 ROWS ONLY;
END;

--comparing two strings
CREATE OR REPLACE FUNCTION compare_text(p_target VARCHAR2, p_query VARCHAR2)
RETURN INTEGER IS
    v_score INTEGER := 0;
BEGIN
    IF p_query IS NULL THEN
        RETURN 1;
    END IF;
    
    v_score := similarity(p_target, p_query);
    IF v_score >= 80 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;

--function for finding similarity
CREATE OR REPLACE FUNCTION similarity(STRING VARCHAR2, substring VARCHAR2)
RETURN NUMBER IS 
BEGIN
  RETURN UTL_MATCH.JARO_WINKLER_SIMILARITY(LOWER(STRING), LOWER(substring));
END;
