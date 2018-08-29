--задание 1
CREATE OR REPLACE PROCEDURE saveSIGNERS(pV_FIO       IN scd_signers.v_fio%TYPE,
                          pID_MANAGER       IN scd_signers.id_manager%TYPE,
                          pACTION       IN NUMBER) IS
  ID_POLZ NUMBER;
BEGIN
 SELECT ci.ID_USER INTO ID_POLZ FROM CI_USERS ci
 WHERE ci.ID_USER=pID_MANAGER;
 CASE pACTION
 WHEN 1 THEN 
 INSERT INTO scd_signers (v_fio,id_manager)
 VALUES (pV_FIO,pID_MANAGER);
 WHEN 2 THEN
 UPDATE scd_signers
 SET v_fio=pV_FIO
 WHERE id_manager=pID_MANAGER;
 WHEN 3 THEN
 DELETE FROM scd_signers
 WHERE id_manager=pID_MANAGER;
 END CASE;
EXCEPTION
WHEN no_data_found THEN 
raise_application_error(-20020,'"Пользователь не найден"');
WHEN OTHERS THEN
    raise_application_error(-20020,
                            'Неизвестная ошибка. Обратитесь в службу поддержки.');
END;


--задание 2 

CREATE OR REPLACE FUNCTION getDecoder(id_equp IN scd_equip_kits.v_cas_id%TYPE) return  varchar2 IS
  VERNUL varchar2(255);
  agency NUMBER;
BEGIN
SELECT con.b_agency INTO agency FROM scd_equip_kits eq
JOIN scd_contracts con on 
con.id_contract_inst = eq.id_contract_inst 
WHERE eq.id_equip_kits_inst=id_equp and eq.DT_STOP>current_timestamp and eq.DT_START<=current_timestamp; 
IF agency = 1 THEN SELECT eq.V_CAS_ID INTO VERNUL FROM scd_equip_kits eq
          WHERE eq.id_equip_kits_inst=id_equp and eq.DT_STOP>current_timestamp and eq.DT_START<=current_timestamp;
else SELECT eq.v_ext_ident INTO VERNUL FROM scd_equip_kits eq
          WHERE eq.id_equip_kits_inst=id_equp and eq.DT_STOP>current_timestamp and eq.DT_START<=current_timestamp;    

END IF;
return VERNUL; 
EXCEPTION
WHEN no_data_found THEN 
   raise_application_error (-20020,'Оборудование не найдено'); 
  WHEN OTHERS THEN 
    raise_application_error(-20020, 'Неизвестная ошибка. Обратитесь в службу поддержки.'); 
END;



---задание 3


CREATE OR REPLACE PROCEDURE getEquip(pID_EQUIP_KITS_INST IN NUMBER default null, dwr OUT sys_refcursor) IS

BEGIN
 IF pID_EQUIP_KITS_INST is not null THEN 
    OPEN dwr FOR
    select cl.V_LONG_TITLE, ci.V_USERNAME, eqt.V_NAME, getDecoder(pID_EQUIP_KITS_INST) from fw_clients cl   
     JOIN ci_users ci on 
    ci.ID_CLIENT_INST=cl.ID_CLIENT_INST and ci.v_status='A'
     JOIN fw_contracts con on
    con.ID_CLIENT_INST=cl.ID_CLIENT_INST and con.DT_STOP>current_timestamp and con.DT_START<=current_timestamp
     JOIN scd_equip_kits eq on
    eq.ID_CONTRACT_INST=con.ID_CONTRACT_INST and eq.DT_STOP>current_timestamp and eq.DT_START<=current_timestamp 
     JOIN scd_equipment_kits_type eqt on
    eqt.id_equip_kits_type=eq.id_equip_kits_type and eqt.DT_STOP>current_timestamp and eqt.DT_START<=current_timestamp 
     WHERE 
    cl.DT_STOP>current_timestamp and cl.DT_START<=current_timestamp and pID_EQUIP_KITS_INST=eq.ID_EQUIP_KITS_INST;
  
    ELSE
    OPEN dwr FOR
    select cl.V_LONG_TITLE, ci.V_USERNAME, eqt.V_NAME, getDecoder(eq.ID_EQUIP_KITS_INST) from fw_clients cl
     JOIN ci_users ci on 
    ci.ID_CLIENT_INST=cl.ID_CLIENT_INST and ci.v_status='A'
     JOIN fw_contracts con on
    con.ID_CLIENT_INST=cl.ID_CLIENT_INST and con.DT_STOP>current_timestamp and con.DT_START<=current_timestamp
     JOIN scd_equip_kits eq on
    eq.ID_CONTRACT_INST=con.ID_CONTRACT_INST and eq.DT_STOP>current_timestamp and eq.DT_START<=current_timestamp 
     JOIN scd_equipment_kits_type eqt on
    eqt.id_equip_kits_type=eq.id_equip_kits_type and eqt.DT_STOP>current_timestamp and eqt.DT_START<=current_timestamp 
     WHERE 
    cl.DT_STOP>current_timestamp and cl.DT_START<=current_timestamp; 
    END IF;
 
 
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20020,'Неизвестная ошибка. Обратитесь в службу поддержки.');
END;



----задание 4


CREATE OR REPLACE PROCEDURE checkstatus IS 
  
BEGIN
  FOR i IN (select distinct ek.id_equip_kits_inst, cl.V_LONG_TITLE, c.b_agency,  fc.v_ext_ident  from scd_equip_kits ek
  JOIN scd_equipment_status ses
                ON ses.id_equipment_status = ek.id_status
               AND ses.b_deleted = 0
              and ses.v_name <>'Продано'
			join fw_contracts fc
			on fc.id_contract_inst=ek.id_contract_inst
			and fc.dt_start <= current_timestamp AND fc.dt_stop > current_timestamp
			and fc.v_status='A'
				join fw_clients cl
				on cl.ID_CLIENT_INST=fc.ID_CLIENT_INST
				and cl.dt_start <= current_timestamp AND cl.dt_stop > current_timestamp
					JOIN scd_contracts c ON c.id_contract_inst = ek.id_contract_inst
						join scd_equipment_kits_type ekt
						on ekt.id_equip_kits_type=ek.id_equip_kits_type
						and ekt.dt_start <= current_timestamp AND ekt.dt_stop > current_timestamp
		where ek.dt_start <= current_timestamp AND ek.dt_stop > current_timestamp) LOOP
  
    
    update scd_equipment_status
      set v_name='Продано';
    update scd_equipment_status
      set id_equipment_status=22;
  
  if i.b_agency=1	then
  dbms_output.put_line ('Для оборудования '||i.id_equip_kits_inst||' дилера '||i.V_LONG_TITLE||' с контрактом '||i.v_ext_ident||',являющегося агентской сетью был проставлен статус Продано.'); 
                  else
	dbms_output.put_line ('Для оборудования '||i.id_equip_kits_inst||' дилера '||i.V_LONG_TITLE||' с контрактом '||i.v_ext_ident||',не являющегося агентской сетью был проставлен статус Продано.');
	end if;
  END LOOP;
  end;

