CREATE PROCEDURE book_ticket
(
    OUT pnr_no VARCHAR(15),
    IN train_no int,
    IN date DATE,
    IN coach VARCHAR(50), 
    IN booker VARCHAR(50),
    IN source VARCHAR(50),
    IN destination VARCHAR(50),
    IN p_no int
)
language plpgsql
as
$$
BEGIN
    select (left(regexp_replace(coalesce('<booker>', '0') || '', '[^0-9]', '', 'g'), 8) || '0')::integer
    INTO pnr_no;
 	INSERT INTO ticket
    VALUES(pnr_no, train_no,date,coach,booker,source,destination,p_no);
END;
$$;




CREATE OR REPLACE PROCEDURE assign_berth (
    IN name VARCHAR(50), 
    IN age INT, 
    IN gender VARCHAR(50), 
    IN _pnr_no INT
)
LANGUAGE plpgsql
AS 
$$
DECLARE
     tnum INT;
     tdate DATE;
     tcoach VARCHAR(50);
     tsource varchar(50);
     tdestination varchar(50);
     tot_ac int;
     tot_sleeper int;
     bseats INT;
     tseats INT;
     berth_no INT;
     coach_no INT;
     berth_type VARCHAR(10);
     ac_avail int;
     sleeper_avail int;
BEGIN
     SELECT train_no,date,coach,source,destination
     FROM ticket
     WHERE _pnr_no=pnr_no
     INTO tnum,tdate,tcoach,tsource,tdestination;
    
    IF tcoach='ac' THEN
        UPDATE train_released
        SET ac_available = ac_available - 1
        WHERE train_no=tnum AND date=tdate AND source=tsource AND destination=tdestination;
    ELSE
        UPDATE train_released
        SET sleeper_available = sleeper_available - 1
        WHERE train_no=tnum AND date=tdate AND source=tsource AND destination=tdestination;
    END IF;
    
     SELECT ac_num,sleeper_num
     FROM train
     WHERE train_no=tnum AND date=tdate 
     INTO tot_ac,tot_sleeper;
     
     SELECT ac_available,sleeper_available
     FROM train_released
     WHERE train_no=tnum AND date=tdate AND source=tsource AND destination=tdestination
     INTO ac_avail,sleeper_avail;
    
    IF tcoach = 'ac' THEN
          tseats:=18;
          bseats := tot_ac - ac_avail;   
    ELSE 
        tseats:=24;
        bseats := tot_sleeper-sleeper_avail;
    END IF;

    IF bseats % tseats = 0 THEN
        coach_no := bseats/tseats;
    ELSE
        coach_no := floor(bseats/tseats) + 1;
    END IF;
	
    berth_no := bseats%tseats;

    IF tcoach = 'ac' THEN
            IF berth_no % 6=1 THEN
                berth_type := 'LB';
            ELSEIF
               berth_no % 6=2 THEN
                berth_type := 'LB';
            ELSEIF
                berth_no % 6=3 THEN
                berth_type := 'UB';
            ELSEIF
                berth_no % 6=4 THEN
                berth_type := 'UB';
            ELSEIF
                berth_no % 6=5 THEN
               berth_type := 'SL';
            ELSEIF
                berth_no % 6=0 THEN
               berth_type := 'SU';
		END IF;
    ELSE
            IF berth_no % 8= 1 THEN
               berth_type := 'LB';
            ELSEIF
                berth_no % 8=2 THEN
                berth_type := 'MB';
            ELSEIF
                berth_no % 8=3 THEN
                berth_type := 'UB';
            ELSEIF
                berth_no % 8=4 THEN
                berth_type := 'LB';
            ELSEIF
                berth_no % 8=5 THEN
                berth_type := 'MB';
            ELSEIF
                berth_no % 8=6 THEN
                berth_type := 'UB';
            ELSEIF
            berth_no % 8=7 THEN
               berth_type := 'SL';
            ELSEIF
                berth_no % 8 =0 THEN
                berth_type := 'SU';
		END IF;
    END IF;
   
    INSERT INTO passenger(pnr_no,name,age,gender,berth_no,berth_type,coach_no)
    VALUES(_pnr_no,name, age, gender, berth_no, berth_type, coach_no);
    
END;
$$;





CREATE OR REPLACE PROCEDURE seating_plan
(
    _train_no int,
    _date DATE
)
language plpgsql
AS
$$
DECLARE
    rec1 RECORD;
    rec2 RECORD;
    last_row INT DEFAULT 0;
    finished INT DEFAULT 0;
    c1 CURSOR  	
    FOR SELECT pnr_no,source ,destination
        from ticket
        where train_no=_train_no AND date=_date;
 
    c2 refcursor;
  BEGIN 
  
  DELETE FROM seating_plan;
   
    OPEN c1;

	 LOOP
		FETCH c1 INTO rec1;
		exit when not found;
 
            OPEN c2 FOR 
                    SELECT coach_no,berth_no,berth_type,name
                    from passenger
                    where pnr_no=rec1.pnr_no;
                    
             LOOP
		        FETCH c2 INTO rec2 ;
		        exit when not found;
                
                INSERT INTO seating_plan VALUES(rec2.coach_no,rec2.berth_no,rec2.berth_type,rec2.name,rec1.pnr_no,rec1.source ,rec1.destination);
                
            END LOOP ;
	        CLOSE c2;
            
	END LOOP ;
	CLOSE c1;

END;
$$;




