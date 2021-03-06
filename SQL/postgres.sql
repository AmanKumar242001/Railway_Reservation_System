PGDMP         4                z            postgres    14.4    14.4 6    .           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            /           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            0           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            1           1262    13754    postgres    DATABASE     d   CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_India.1252';
    DROP DATABASE postgres;
                postgres    false            2           0    0    DATABASE postgres    COMMENT     N   COMMENT ON DATABASE postgres IS 'default administrative connection database';
                   postgres    false    3377            3           0    0    DATABASE postgres    ACL     Z   GRANT CONNECT ON DATABASE postgres TO helper;
GRANT CONNECT ON DATABASE postgres TO help;
                   postgres    false    3377            4           0    0    SCHEMA public    ACL     N   GRANT USAGE ON SCHEMA public TO helper;
GRANT USAGE ON SCHEMA public TO help;
                   postgres    false    4                        3079    16384 	   adminpack 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;
    DROP EXTENSION adminpack;
                   false            5           0    0    EXTENSION adminpack    COMMENT     M   COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';
                        false    2            ?            1255    16688 D   assign_berth(character varying, integer, character varying, integer) 	   PROCEDURE     E  CREATE PROCEDURE public.assign_berth(IN name character varying, IN age integer, IN gender character varying, IN _pnr_no integer)
    LANGUAGE plpgsql
    AS $$
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
 ?   DROP PROCEDURE public.assign_berth(IN name character varying, IN age integer, IN gender character varying, IN _pnr_no integer);
       public          postgres    false            ?            1255    16707    create_admin()    FUNCTION       CREATE FUNCTION public.create_admin() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    execute(concat('CREATE USER ',NEW.username,' WITH PASSWORD ', E'\'',NEW.password,E'\'',';'));
    execute(concat('GRANT help TO ',NEW.username,';'));
    RETURN NEW;
END;
$$;
 %   DROP FUNCTION public.create_admin();
       public          postgres    false            ?            1255    16702    create_user()    FUNCTION       CREATE FUNCTION public.create_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    execute(concat('CREATE USER ',NEW.username,' WITH PASSWORD ', E'\'',NEW.password,E'\'',';'));
    execute(concat('GRANT helper TO ',NEW.username,';'));
    RETURN NEW;
END;
$$;
 $   DROP FUNCTION public.create_user();
       public          postgres    false            ?            1255    16712    get_seats()    FUNCTION     ?  CREATE FUNCTION public.get_seats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
    $$;
 "   DROP FUNCTION public.get_seats();
       public          postgres    false            ?            1255    16497    released_seats()    FUNCTION     ?  CREATE FUNCTION public.released_seats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
  $$;
 '   DROP FUNCTION public.released_seats();
       public          postgres    false            ?            1255    16722    seating_plan(integer, date) 	   PROCEDURE       CREATE PROCEDURE public.seating_plan(IN _train_no integer, IN _date date)
    LANGUAGE plpgsql
    AS $$
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
 I   DROP PROCEDURE public.seating_plan(IN _train_no integer, IN _date date);
       public          postgres    false            ?            1259    16526    admin    TABLE     ?   CREATE TABLE public.admin (
    username character varying(50) NOT NULL,
    password character varying(20) NOT NULL,
    CONSTRAINT admin_password_check CHECK ((char_length((password)::text) > 4))
);
    DROP TABLE public.admin;
       public         heap    postgres    false            6           0    0    TABLE admin    ACL     A   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin TO help;
          public          postgres    false    211            ?            1259    16566 	   passenger    TABLE       CREATE TABLE public.passenger (
    pnr_no integer NOT NULL,
    name character varying(50) NOT NULL,
    age integer NOT NULL,
    gender character varying(20) NOT NULL,
    berth_no integer NOT NULL,
    berth_type character varying(10) NOT NULL,
    coach_no integer NOT NULL
);
    DROP TABLE public.passenger;
       public         heap    postgres    false            7           0    0    TABLE passenger    ACL     @   GRANT SELECT,INSERT,DELETE ON TABLE public.passenger TO helper;
          public          postgres    false    214            ?            1259    16716    seating_plan    TABLE     ?   CREATE TABLE public.seating_plan (
    coach_no integer,
    berth_no integer,
    berth_type character varying(10),
    name character varying(30),
    pnr_no integer,
    source character varying(50),
    destination character varying(50)
);
     DROP TABLE public.seating_plan;
       public         heap    postgres    false            ?            1259    16644    ticket    TABLE     %  CREATE TABLE public.ticket (
    pnr_no integer NOT NULL,
    train_no integer NOT NULL,
    date date NOT NULL,
    coach character varying(20) NOT NULL,
    username character varying(50) NOT NULL,
    source character varying(50) NOT NULL,
    destination character varying(50) NOT NULL
);
    DROP TABLE public.ticket;
       public         heap    postgres    false            8           0    0    TABLE ticket    ACL     =   GRANT SELECT,INSERT,DELETE ON TABLE public.ticket TO helper;
          public          postgres    false    216            ?            1259    16643    ticket_pnr_no_seq    SEQUENCE     ?   CREATE SEQUENCE public.ticket_pnr_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.ticket_pnr_no_seq;
       public          postgres    false    216            9           0    0    ticket_pnr_no_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.ticket_pnr_no_seq OWNED BY public.ticket.pnr_no;
          public          postgres    false    215            ?            1259    16534    train    TABLE       CREATE TABLE public.train (
    train_no integer NOT NULL,
    date date NOT NULL,
    ac_num integer NOT NULL,
    sleeper_num integer NOT NULL,
    CONSTRAINT train_ac_num_check CHECK ((ac_num > 0)),
    CONSTRAINT train_sleeper_num_check CHECK ((sleeper_num > 0))
);
    DROP TABLE public.train;
       public         heap    postgres    false            :           0    0    TABLE train    ACL     o   GRANT SELECT ON TABLE public.train TO helper;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.train TO help;
          public          postgres    false    212            ?            1259    16541    train_released    TABLE     d  CREATE TABLE public.train_released (
    train_no integer NOT NULL,
    date date NOT NULL,
    source character varying(50) NOT NULL,
    destination character varying(50) NOT NULL,
    ac_available integer NOT NULL,
    sleeper_available integer NOT NULL,
    CONSTRAINT train_released_check CHECK (((ac_available >= 0) AND (sleeper_available >= 0)))
);
 "   DROP TABLE public.train_released;
       public         heap    postgres    false            ;           0    0    TABLE train_released    ACL     ?   GRANT SELECT,UPDATE ON TABLE public.train_released TO helper;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.train_released TO help;
          public          postgres    false    213            ?            1259    16519    user_    TABLE     ?  CREATE TABLE public.user_ (
    username character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    address character varying(70) NOT NULL,
    password character varying(20) NOT NULL,
    CONSTRAINT user__email_check CHECK (((email)::text ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)),
    CONSTRAINT user__password_check CHECK ((char_length((password)::text) > 4))
);
    DROP TABLE public.user_;
       public         heap    postgres    false            <           0    0    TABLE user_    ACL     .   GRANT INSERT ON TABLE public.user_ TO helper;
          public          postgres    false    210            ?           2604    16647    ticket pnr_no    DEFAULT     n   ALTER TABLE ONLY public.ticket ALTER COLUMN pnr_no SET DEFAULT nextval('public.ticket_pnr_no_seq'::regclass);
 <   ALTER TABLE public.ticket ALTER COLUMN pnr_no DROP DEFAULT;
       public          postgres    false    215    216    216            %          0    16526    admin 
   TABLE DATA           3   COPY public.admin (username, password) FROM stdin;
    public          postgres    false    211   \T       (          0    16566 	   passenger 
   TABLE DATA           ^   COPY public.passenger (pnr_no, name, age, gender, berth_no, berth_type, coach_no) FROM stdin;
    public          postgres    false    214   ?T       +          0    16716    seating_plan 
   TABLE DATA           i   COPY public.seating_plan (coach_no, berth_no, berth_type, name, pnr_no, source, destination) FROM stdin;
    public          postgres    false    217   nU       *          0    16644    ticket 
   TABLE DATA           ^   COPY public.ticket (pnr_no, train_no, date, coach, username, source, destination) FROM stdin;
    public          postgres    false    216   V       &          0    16534    train 
   TABLE DATA           D   COPY public.train (train_no, date, ac_num, sleeper_num) FROM stdin;
    public          postgres    false    212   ?V       '          0    16541    train_released 
   TABLE DATA           n   COPY public.train_released (train_no, date, source, destination, ac_available, sleeper_available) FROM stdin;
    public          postgres    false    213   ?W       $          0    16519    user_ 
   TABLE DATA           I   COPY public.user_ (username, name, email, address, password) FROM stdin;
    public          postgres    false    210   +Z       =           0    0    ticket_pnr_no_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.ticket_pnr_no_seq', 23, true);
          public          postgres    false    215            ?           2606    16531    admin admin_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (username);
 :   ALTER TABLE ONLY public.admin DROP CONSTRAINT admin_pkey;
       public            postgres    false    211            ?           2606    16570    passenger passenger_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.passenger
    ADD CONSTRAINT passenger_pkey PRIMARY KEY (pnr_no, berth_no, coach_no);
 B   ALTER TABLE ONLY public.passenger DROP CONSTRAINT passenger_pkey;
       public            postgres    false    214    214    214            ?           2606    16649    ticket ticket_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (pnr_no);
 <   ALTER TABLE ONLY public.ticket DROP CONSTRAINT ticket_pkey;
       public            postgres    false    216            ?           2606    16651    ticket ticket_username_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_username_key UNIQUE (username);
 D   ALTER TABLE ONLY public.ticket DROP CONSTRAINT ticket_username_key;
       public            postgres    false    216            ?           2606    16540    train train_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.train
    ADD CONSTRAINT train_pkey PRIMARY KEY (train_no, date);
 :   ALTER TABLE ONLY public.train DROP CONSTRAINT train_pkey;
       public            postgres    false    212    212            ?           2606    16545 "   train_released train_released_pkey 
   CONSTRAINT     ?   ALTER TABLE ONLY public.train_released
    ADD CONSTRAINT train_released_pkey PRIMARY KEY (train_no, date, source, destination);
 L   ALTER TABLE ONLY public.train_released DROP CONSTRAINT train_released_pkey;
       public            postgres    false    213    213    213    213            ?           2606    16533    user_ user__email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.user_
    ADD CONSTRAINT user__email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.user_ DROP CONSTRAINT user__email_key;
       public            postgres    false    210            ?           2606    16525    user_ user__pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.user_
    ADD CONSTRAINT user__pkey PRIMARY KEY (username);
 :   ALTER TABLE ONLY public.user_ DROP CONSTRAINT user__pkey;
       public            postgres    false    210            ?           2620    16576 #   train_released check_released_seats    TRIGGER     ?   CREATE TRIGGER check_released_seats AFTER INSERT ON public.train_released FOR EACH ROW EXECUTE FUNCTION public.released_seats();
 <   DROP TRIGGER check_released_seats ON public.train_released;
       public          postgres    false    218    213            ?           2620    16708    admin creating_admin    TRIGGER     p   CREATE TRIGGER creating_admin AFTER INSERT ON public.admin FOR EACH ROW EXECUTE FUNCTION public.create_admin();
 -   DROP TRIGGER creating_admin ON public.admin;
       public          postgres    false    211    231            ?           2620    16703    user_ creating_user    TRIGGER     n   CREATE TRIGGER creating_user AFTER INSERT ON public.user_ FOR EACH ROW EXECUTE FUNCTION public.create_user();
 ,   DROP TRIGGER creating_user ON public.user_;
       public          postgres    false    210    232            ?           2620    16713    ticket getting_seats    TRIGGER     m   CREATE TRIGGER getting_seats AFTER DELETE ON public.ticket FOR EACH ROW EXECUTE FUNCTION public.get_seats();
 -   DROP TRIGGER getting_seats ON public.ticket;
       public          postgres    false    233    216            ?           2606    16680 
   ticket fkp    FK CONSTRAINT     ?   ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT fkp FOREIGN KEY (train_no, date, source, destination) REFERENCES public.train_released(train_no, date, source, destination);
 4   ALTER TABLE ONLY public.ticket DROP CONSTRAINT fkp;
       public          postgres    false    213    213    213    213    3211    216    216    216    216            ?           2606    16657    ticket ticket_username_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_username_fkey FOREIGN KEY (username) REFERENCES public.user_(username);
 E   ALTER TABLE ONLY public.ticket DROP CONSTRAINT ticket_username_fkey;
       public          postgres    false    216    210    3205            ?           2606    16546 0   train_released train_released_train_no_date_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.train_released
    ADD CONSTRAINT train_released_train_no_date_fkey FOREIGN KEY (train_no, date) REFERENCES public.train(train_no, date);
 Z   ALTER TABLE ONLY public.train_released DROP CONSTRAINT train_released_train_no_date_fkey;
       public          postgres    false    213    212    212    3209    213            %      x?K?M??.?M,?L??b???? SaF      (   ?   x?e???0?g?a?8???0!?.??"t??7?U????1?u??P???0???H??H?Ƞ7??9?~?fU	?ںI?T?S4??Ӂ*H?д???3(??sb
??????o???)@?֦?2???B??A????5?.e?K
?R*$Aͺ????CP|???{ ??k?G`?
??}?=S??e7??2??????"?Z^Y1??7!????      +   ?   x???;? ?????n?V?:5?\NSh
1P??e?Kt?9?=(?=???]?8???H=c#90U??6?4?d?mW??͏??????*??&yW??G???d|?=?r????oQ?t?4???5,?F?;\A?????c?=?Iu      *   y   x?u?A? @???]j?I?f?Ҁ?H@?x{u????????0???@?-(??gav????}?}???\?˲??>Z?s???T?d?H-???Z??_???7Mɿe?5???C???I      &   (  x?m??m?0ѳ݋???K??#?Ed???`???ʒ???D???+Z?Cq|?;?8?o?????w?q????y'AIP?%A??JP%?T	j'f9??8??<??z ??@??NP'??	?A??A?T?F??EmdQY?F??E?"h??m?6A??MP?S?F???N]O	?Y??Gk?J??@-P??D-QK???ڤY?ҬiV?4?KZC???Pk?5?:j??ZG??6T?4?(Ҭ?nVm7???Dm?6Q??M?j???Bm??Um7???U?ͪ?fU???|?nVSw????????~?]      '   I  x????j1????????X??]z??BR?P
~??i???????A??|??????????,/?~??-??????b?.?x?[????||???ɽ?:?\>?,K[~???????Lw???!???????g?
???Cb?Mj??ϩXS???G(?ڄS???P?X???ɸp???t??'??f2?]7???Oƅ?8N?i2!<??????8ޠ??0????7??H ?@	8^??j?̰f?ح1?ưƨƅ???jk?j?B?k?Ú"(H??"(H??"(H??"(H??"(H??*?H??*?H??*?H??*?H??*?H???-0??̰f?ح??]?jƻ?]`?t??w??.?e?f????@????.?	4"?	4"?	4"?	4"?	4"??DIR ?H ?@
	$H?@"?$)H$?D??k"??@?/???7M??>?M????hO+7}????G????G¦??q???}????"?X??SD?0a?c?"La,?P?)"?E?pE??G??p?(??"E?"?Y??WD8?p????p??)?|      $   ?   x?m???0Eg?+????JL]??,n ?<?@ߤ?hZ1????(???c?҃?/?V?
a?w??Og??|??'M?j拮#~P?%?&kly?hԨd?k&?????Y?Ok?x?CF??5
(?tl?B?/ٺp\`??뭺W`伛?dP,F?̴ۡ$?u??o?Vy?     