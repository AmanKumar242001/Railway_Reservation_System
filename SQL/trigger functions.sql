CREATE OR REPLACE FUNCTION released_seats()
RETURNS TRIGGER 
AS
$$
DECLARE
    avail_a int;
    avail_s int;
BEGIN
    SELECT ac_num,sleeper_num
    FROM train
    where NEW.train_no=train_no AND NEW.date=date
    INTO avail_a,avail_s;
  
  IF NEW.ac_available>avail_a OR NEW.ac_available<=0 OR NEW.sleeper_available>avail_s OR NEW.sleeper_available<=0 THEN
  RAISE EXCEPTION 'SEATS NOT AVAILABLE';
  END IF;
  RETURN NEW;
  END;
  $$
  LANGUAGE plpgsql;
  
  CREATE TRIGGER check_released_seats
  AFTER INSERT ON train_released
  FOR EACH ROW
  EXECUTE FUNCTION released_seats();
  
  

  
  
  CREATE OR REPLACE FUNCTION revised_seats()
RETURNS TRIGGER 
AS
$$
DECLARE
        curr_ac int;
        curr_sleeper int;
BEGIN
    SELECT ac_available,sleeper_available
    FROM train_released
    where NEW.train_no=train_no AND NEW.date=date AND NEW.source=source AND NEW.destination=destination
    INTO curr_ac,curr_sleeper;
    
    IF NEW.coach='ac' THEN
    UPDATE train_released set ac_available=curr_ac-NEW.p_no where NEW.train_no=train_no AND NEW.date=date AND NEW.source=source AND NEW.destination=destination;
    ELSEIF NEW.coach='sleeper' THEN
    UPDATE train_released set sleeper_available=curr_sleeper-NEW.p_no where NEW.train_no=train_no AND NEW.date=date AND NEW.source=source AND NEW.destination=destination;
    END IF;
    
    RETURN NULL;
    END;
    $$
    LANGUAGE plpgsql;
  
  CREATE TRIGGER revising_seats
  AFTER INSERT ON ticket
  FOR EACH ROW
  EXECUTE FUNCTION revised_seats();





CREATE OR REPLACE FUNCTION get_seats()
RETURNS TRIGGER 
AS
$$
DECLARE
        curr_ac int;
        curr_sleeper int;
        person_num int;
BEGIN
    
    SELECT COUNT(*)
    FROM passenger
    WHERE pnr_no=OLD.pnr_no
    INTO person_num;
    
    DELETE FROM passenger
    WHERE pnr_no=OLD.pnr_no;

    SELECT ac_available,sleeper_available
    FROM train_released
    where OLD.train_no=train_no AND OLD.date=date AND OLD.source=source AND OLD.destination=destination
    INTO curr_ac,curr_sleeper;
    
    IF OLD.coach='ac' THEN
    UPDATE train_released set ac_available=curr_ac+person_num where OLD.train_no=train_no AND OLD.date=date AND OLD.source=source AND OLD.destination=destination;
    ELSEIF OLD.coach='sleeper' THEN
    UPDATE train_released set sleeper_available=curr_sleeper+person_num where OLD.train_no=train_no AND OLD.date=date AND OLD.source=source AND OLD.destination=destination;
    END IF;
    
    RETURN NULL;
    END;
    $$
    LANGUAGE plpgsql;
  
  CREATE OR REPLACE TRIGGER getting_seats
  AFTER DELETE ON ticket
  FOR EACH ROW
  EXECUTE FUNCTION get_seats();





CREATE OR REPLACE FUNCTION create_user()
RETURNS Trigger
language plpgsql
AS
$$
BEGIN
    execute(concat('CREATE USER ',NEW.username,' WITH PASSWORD ', E'\'',NEW.password,E'\'',';'));
    execute(concat('GRANT helper TO ',NEW.username,';'));
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER creating_user
AFTER INSERT ON user_
FOR EACH ROW
EXECUTE FUNCTION create_user();





CREATE OR REPLACE FUNCTION create_admin()
RETURNS Trigger
language plpgsql
AS
$$
BEGIN
    execute(concat('CREATE USER ',NEW.username,' WITH PASSWORD ', E'\'',NEW.password,E'\'',';'));
    execute(concat('GRANT help TO ',NEW.username,';'));
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER creating_admin
AFTER INSERT ON admin
FOR EACH ROW
EXECUTE FUNCTION create_admin();




