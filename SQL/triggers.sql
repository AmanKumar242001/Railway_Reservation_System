CREATE TRIGGER check_released_seats
  AFTER INSERT ON train_released
  FOR EACH ROW
  EXECUTE FUNCTION released_seats();
  


  
   CREATE TRIGGER revising_seats
  AFTER INSERT ON ticket
  FOR EACH ROW
  EXECUTE FUNCTION revised_seats();
  
  
  
  
  CREATE OR REPLACE TRIGGER getting_seats
  AFTER DELETE ON ticket
  FOR EACH ROW
  EXECUTE FUNCTION get_seats();
  
  
  
  
  CREATE OR REPLACE TRIGGER creating_user
AFTER INSERT ON user_
FOR EACH ROW
EXECUTE FUNCTION create_user();
  



CREATE OR REPLACE TRIGGER creating_admin
AFTER INSERT ON admin
FOR EACH ROW
EXECUTE FUNCTION create_admin();


