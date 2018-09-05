---1


--Конфликт связан с изменением id_contract_inst во времени


 cursor cur_con is
      select con.id_contract_inst
        from fw_contracts con
       where con.id_contract_inst != pID_CONTRACT_INST
         and con.v_ext_ident = l_ext_ident
--Нужно добавить именно эту строчку в курсор
and con.DT_START<=current_timestamp  and con.DT_STOP>current_timestamp




--2

--Необходимый файл (видимо случайно) удалили, поставив в B_DELETED=1

UPDATE filestorage
SET B_DELETED=0
WHERE V_SHORT_NAME='rpt_change.rpt' ;






---3

--Отсутствует таблица fw_service, т.е.

INSERT INTO fw_service ....




---4


/*
Дело в том что срок действия идентификаторов услуг истек, а некоторые идентификаторы услуг и вовсе отсутствуют (170033,191817,174491,191849).
Решение: добавить пустые идентификаторы в базу,
а старые обновить. 
P.S. или нет
*/
