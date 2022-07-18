# Railway_Reservation_System

# Features :
1. Registeration as an user or as an admin.
2. Ticket booking.
3. Ticket Cancellation.
4. Print of entire seating plan of a train for a date can be seen in table "seating_plan".


# Steps :
1. Install PostgreSQL.
2. a.  Import the database file named as “postgres” (present 
       in SQL folder) in PostgreSQL(pgAdmin).
               OR
   b.  Copy all the scripts of tables, functions, triggers and 
       that of procedures too into PostgreSQL ,in a newly 
       created database, and run them once.
3. Register as an user by inserting values in "user_" table.
4. Look into the "train_released" table for the availability of train with the desired date and seats.
5. Insert values into the "ticket" table using your username and note the generated pnr_no from the "ticket" table.
6. Using the generated pnr_no, Call the procedure "assign_berth" for all those passengers who are to be booked on the same ticket.
7. See the details of all the passengers in the "passenger" table.
8. For ticket cancellation, delete the tupple with the respective pnr_no from the "ticket" table.
9.To see the train seating_plan for the whole day, Call procedure "seating_plan" and then select table "seating_plan".

