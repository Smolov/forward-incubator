REM   Script: ponomarev_dz4
REM   dsaq2

create or replace   function Valiable_IP (IP_ADDRESS in varchar2) 
RETURN NUMBER  
IS 
ip_left VARCHAR2(255):= IP_ADDRESS; 
fist number; 
secnd number; 
third number; 
fourth number; 
BEGIN 
fist:=to_number(substr(ip_left,1,instr(ip_left,'.')-1)); 
ip_left:=SUBSTR(ip_left,length(to_CHAR(fist))+2,length(ip_left)); 
secnd:=to_number(substr(ip_left,1,instr(ip_left,'.')-1)); 
ip_left:=SUBSTR(ip_left,length(to_CHAR(secnd))+2,length(ip_left)); 
third:=to_number(substr(ip_left,1,instr(ip_left,'.')-1)); 
ip_left:=SUBSTR(ip_left,length(to_CHAR(third))+2,length(ip_left)); 
fourth:=to_number(substr(ip_left,1,length(ip_left))); 
ip_left:=SUBSTR(ip_left,length(to_CHAR(fourth))+1,length(ip_left)); 
 
IF ip_left is NULL  
and fist>=0 and fist<=255  
and secnd>=0 and secnd<=255 
and third>=0 and third<=255 
--Значение последнего байта не могут быть приняты за 0 и 255 (т.к. они являются адресом сети и широковещательным адресом соответственно) 
and fourth>0 and fourth<255  
THEN RETURN 1; 
ELSE RETURN 0; 
END IF; 
END; 
 
 
create or replace PROCEDURE getCOMMUTATOR (dwr OUT sys_refcursor, pID_commutator in incb_commutator.ID_commutator%type default null) IS 
BEGIN 
OPEN dwr FOR  
  select com.ID_commutator,com.IP_ADDRESS, com.V_MAC_ADDRESS, comt.V_VENDOR, comt.V_MODEL, com.V_DESCRIPTION,  
  case  
  WHEN com.B_NEED_CONVERT_HEX=0 
  THEN com.REMOTE_ID 
  ELSE com.REMOTE_ID_HEX 
  end 
  from incb_commutator com 
  join incb_commutator_type comt 
		on comt.ID_COMMUTATOR_TYPE=com.ID_COMMUTATOR_TYPE and com.b_deleted=0 
		WHERE  
          com.b_deleted=0  
          and com.ID_COMMUTATOR=pID_COMMUTATOR 
          and com.V_COMMUNITY_READ=1; 
  END; 
   
 
--ДЛЯ getCOMMUTATOR 
var r refcursor 
set autoprint on 
exec getCOMMUTATOR(:r,1) 
 
               
create or replace PROCEDURE saveCOMMUTATOR (pID_COMMUTATOR in incb_commutator.id_commutator%type, 
pIP_ADDRESS IN incb_commutator.IP_ADDRESS%TYPE, 
pID_COMMUTATOR_TYPE IN incb_commutator.ID_COMMUTATOR_TYPE%TYPE default null, 
pV_DESCRIPTION IN incb_commutator.V_DESCRIPTION%TYPE default null, 
pV_MAC_ADDRESS    IN incb_commutator.V_MAC_ADDRESS%TYPE, 
pV_COMMUNITY_READ IN incb_commutator.V_COMMUNITY_READ%TYPE, 
pV_COMMUNITY_WRITE IN incb_commutator.V_COMMUNITY_WRITE%TYPE, 
pREMOTE_ID IN incb_commutator.REMOTE_ID%TYPE, 
pB_NEED_CONVERT_HEX IN incb_commutator.B_NEED_CONVERT_HEX%TYPE default 0, 
pREMOTE_ID_HEX IN incb_commutator.REMOTE_ID_HEX%TYPE default null, 
pACTION in number) 
IS 
ip_creative NUMBER; 
mac_creative NUMBER; 
deleted_or  NUMBER; 
input_hex exception; 
invaliable_ip exception;     
zanyato_ip exception;   
zanyato_mac exception;   
net_commutator_type exception; 
BEGIN 
 
IF pB_NEED_CONVERT_HEX=1 and pREMOTE_ID_HEX is null 
then raise input_hex; 
elsif Valiable_IP(pIP_ADDRESS) = 0 
then raise invaliable_ip; 
end if; 
 
 
select count(1)  
into ip_creative 
from  incb_commutator com 
WHERE com.B_DELETED=0 
AND com.IP_ADDRESS=pIP_ADDRESS 
AND com.ID_COMMUTATOR<>pID_COMMUTATOR; 
 
 select count(1)  
into mac_creative 
from  incb_commutator com 
WHERE com.B_DELETED=0 
AND com.V_MAC_ADDRESS=pV_MAC_ADDRESS 
AND com.ID_COMMUTATOR<>pID_COMMUTATOR;  
 
IF  ip_creative>0  
then raise zanyato_ip; 
elsif mac_creative>0  
then raise zanyato_mac; 
end if; 
 
 select comt.B_DELETED  
into deleted_or  
from  incb_commutator_type comt 
WHERE pID_COMMUTATOR_TYPE=comt.ID_COMMUTATOR_TYPE; 
 
IF  deleted_or=1  
then raise net_commutator_type; 
END IF; 
 
CASE 
 WHEN pACTION = 1 THEN      --Создание записи в справочнике 
   INSERT INTO incb_commutator 
 (ID_COMMUTATOR, IP_ADDRESS, ID_COMMUTATOR_TYPE, V_DESCRIPTION, V_MAC_ADDRESS, V_COMMUNITY_READ, V_COMMUNITY_WRITE, REMOTE_ID, B_NEED_CONVERT_HEX, REMOTE_ID_HEX) 
   VALUES 
 (pID_COMMUTATOR, pIP_ADDRESS, pID_COMMUTATOR_TYPE, pV_DESCRIPTION, pV_MAC_ADDRESS, pV_COMMUNITY_READ, pV_COMMUNITY_WRITE, pREMOTE_ID, pB_NEED_CONVERT_HEX, pREMOTE_ID_HEX); 
 WHEN pACTION = 2 THEN      --Изменение записи в справочнике 
   UPDATE incb_commutator    
   SET IP_ADDRESS=pIP_ADDRESS, ID_COMMUTATOR_TYPE = pID_COMMUTATOR_TYPE, V_DESCRIPTION=pV_DESCRIPTION, V_MAC_ADDRESS =pV_MAC_ADDRESS , 
   V_COMMUNITY_READ=pV_COMMUNITY_READ, REMOTE_ID=pREMOTE_ID, B_NEED_CONVERT_HEX=pB_NEED_CONVERT_HEX, REMOTE_ID_HEX=pREMOTE_ID_HEX 
   WHERE ID_COMMUTATOR=pID_COMMUTATOR ; 
  END CASE; 
EXCEPTION 
WHEN no_data_found THEN 
   raise_application_error (-20021,'Ничего не выходит'); 
WHEN input_hex THEN   
		raise_application_error (-20022, 'Необходимо дополнить поле REMOTE_ID_HEX' ); 
WHEN invaliable_ip THEN   
		raise_application_error (-20023, 'Ошибочный ввод IP-адресса' );   
WHEN zanyato_ip THEN   
		raise_application_error (-20024, 'Данный IP-адресс, занят другим устройством' ); 
WHEN zanyato_mac THEN 
    raise_application_error (-20025, 'Данный MAC-адресс, занят другим устройством' ); 
WHEN net_commutator_type THEN 
    raise_application_error (-20026, 'Данный тип коммутатора удален из базы!' ); 
WHEN OTHERS THEN 
    raise_application_error(-20027, 'Сторонняя ошибка, обратитесь в службу поддержки');     
 
END; 
 
 
create or replace PROCEDURE deleteCOMMUTATOR (pID_commutator in incb_commutator.ID_commutator%type default null) IS 
BEGIN 
UPDATE incb_commutator    
   SET B_DELETED=1 
   WHERE ID_COMMUTATOR=pID_COMMUTATOR ; 
END; 
   
 
 
--ДЛЯ getCOMMUTATOR 
var r refcursor 
set autoprint on 
exec getCOMMUTATOR(:r,1) 
 
--ДЛЯ saveCOMMUTATOR  
declare  
  begin 
saveCOMMUTATOR(5,'98.108.35.56',2002,'Isprav','42:91:4f','1','1','32',0, NULL, 1); 
end; 
 
  --ДЛЯ deleteCOMMUTATOR  
declare  
  begin 
deleteCOMMUTATOR(4); 
end; 
 
--Задача 2 
 
 
CREATE OR REPLACE function check_access_comm (pIP_ADDRESS IN incb_commutator.IP_ADDRESS%TYPE, 
V_COMMUNITY OUT incb_commutator.V_COMMUNITY_READ%TYPE, 
B_MODE_WRITE in number)  
RETURN NUMBER  
IS 
answer0 NUMBER; 
answer1 NUMBER; 
BEGIN 
select com.V_COMMUNITY_READ,com.V_COMMUNITY_WRITE INTO answer0,answer1 from incb_commutator com 
WHERE  
com.IP_ADDRESS=pIP_ADDRESS and com.B_DELETED=0; 
CASE  
WHEN B_MODE_WRITE=0 AND  answer0=1 
THEN RETURN 1; 
WHEN B_MODE_WRITE=1 AND  answer1=1 
THEN RETURN 1; 
else  
RETURN 0; 
END CASE; 
EXCEPTION  
  WHEN no_data_found THEN  
   raise_application_error (-20021, 'Пустошь' ); 
  WHEN OTHERS THEN  
    raise_application_error(-20020, 'Непреодолимые ошибки, обратитесь в службу поддержки');  
END; 
 
 
 
--Задача 3  
 
CREATE OR REPLACE FUNCTION get_remote_id(pID_COMMUTATOR in incb_commutator.id_commutator%type) 
return varchar2  
IS 
hex_id varchar2(255); 
hex_key NUMBER; 
rem_id varchar2(255); 
emptys exception; 
 
BEGIN 
 select REMOTE_ID_HEX, B_NEED_CONVERT_HEX, REMOTE_ID into hex_id, hex_key,rem_id from incb_commutator 
  where ID_COMMUTATOR=pID_COMMUTATOR 
  and b_deleted=0; 
   
  case  
  when  hex_key=1 and hex_id is not null 
  then return hex_id; 
  when  hex_key=1 and hex_id is null 
  then raise emptys; 
  when hex_key=0  
  then return rem_id; 
  end case;  
 
 
 EXCEPTION  
	WHEN no_data_found THEN  
   raise_application_error (-20025, 'NO SUCH AN ID' );  
  WHEN emptys THEN  
    raise_application_error(-20026, 'Хекс ID не найден'); 
  WHEN OTHERS THEN  
    raise_application_error(-20027, 'Неизвестная ошибка');  
 end; 
 
 
 
---Задача 4  
 
CREATE TYPE table_of_integer1 IS TABLE OF integer; 
create or replace PROCEDURE check_and_del_data (B_FORCE_DELETE in number, vrong_table out table_of_integer1) 
is 
  type table_of_integer is table of integer; 
  vrong_table table_of_integer; 
begin 
  vrong_table := table_of_integer(); -- initialize 
  select com.id_commutator bulk collect into vrong_table from incb_commutator com 
  WHERE  
  Valiable_IP(com.IP_ADDRESS)=0  
   or (select count(1)  
       from  incb_commutator com1 
       WHERE com.B_DELETED=0 
       AND com1.IP_ADDRESS=com.IP_ADDRESS)>1 
   or (select count(1)  
       from  incb_commutator com1 
       WHERE com.B_DELETED=0 
       AND com1.V_MAC_ADDRESS=com.V_MAC_ADDRESS)>1 
   or (com.B_NEED_CONVERT_HEX=1 and REMOTE_ID_HEX is NULL); 
   if B_FORCE_DELETE = 1 
then 
  for i in 1 .. vrong_table.count loop 
    deleteCOMMUTATOR(i); 
  end loop; 
  END IF; 
end; 

/

