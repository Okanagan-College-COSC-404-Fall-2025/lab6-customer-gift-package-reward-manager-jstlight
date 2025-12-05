-- Connor Elechko (300332258), COSC-404. Dec. 4
-- Part A
CREATE TYPE T_GIFT_ITEMS IS TABLE OF VARCHAR2(30);
/
CREATE TABLE GIFT_CATALOG(GIFT_ID NUMBER PRIMARY KEY, MIN_PURCHASE NUMBER, GIFT_ITEMS T_GIFT_ITEMS)
NESTED TABLE GIFT_ITEMS STORE AS gift_tab;
/

INSERT INTO GIFT_CATALOG VALUES(1, 100, T_GIFT_ITEMS('Stickers', 'Pen Set'));
INSERT INTO GIFT_CATALOG VALUES(2, 1000, T_GIFT_ITEMS('Teddy Bear', 'Mug', 'Perfume Sample'));
INSERT INTO GIFT_CATALOG VALUES(3, 10000, T_GIFT_ITEMS('Backpack', 'Thermos Bottle', 'Chocolate Collection'));
/

-- Part B
CREATE TABLE CUSTOMER_REWARDS (
    reward_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_email VARCHAR2(255),
    gift_id NUMBER REFERENCES GIFT_CATALOG(GIFT_ID),
    REWARD_DATE DATE DEFAULT SYSDATE
);
/

-- Part C
CREATE OR REPLACE PACKAGE CUSTOMER_MANAGER AS
    FUNCTION GET_TOTAL_PURCHASE(p_cID IN NUMBER) RETURN NUMBER;
    PROCEDURE ASSIGN_GIFTS_TO_ALL();
END CUSTOMER_MANAGER;
/

CREATE OR REPLACE PACKAGE BODY CUSTOMER_MANAGER AS
    FUNCTION GET_TOTAL_PURCHASE(p_cID IN NUMBER) RETURN NUMBER IS
        total_val NUMBER := 0;
    BEGIN   
        SELECT SUM(oi.unit_price * oi.quantity) INTO total_val 
        FROM Orders o, OrderItems oi
        WHERE o.customer_id = p_cID AND o.order_id = oi.order_id;
        RETURN total_val;
    END GET_TOTAL_PURCHASE;

    FUNCTION CHOOSE_GIFT_PACKAGE(p_total_purchase IN NUMBER) RETURN NUMBER IS
        gift_num NUMBER;
    BEGIN
        gift_num := CASE
            WHEN p_total_purchase >= 10000 THEN 3
            WHEN p_total_purchase >= 1000 THEN 2
            WHEN p_total_purchase >= 100 THEN 1
            ELSE NULL
        END;
        return gift_num;
    END CHOOSE_GIFT_PACKAGE;

    PROCEDURE ASSINGN_GIFTS_TO_ALL() IS
        v_cust_total NUMBER;
        v_gift_id NUMBER;
    BEGIN
        FOR cust IN (SELECT customer_id, email_address FROM Customers)
        LOOP
            v_cust_total := GET_TOTAL_PURCHASE(cust.customer_id);
            v_gift_id := CHOOSE_GIFT_PACKAGE(v_cust_total);
            INSERT INTO CUSTOMER_REWARDS VALUES(cust.email_address, v_gift_id, SYSDATE);
        END LOOP;
    END;
END CUSTOMER_MANAGER;
