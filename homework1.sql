REM   Script: home_fork1
REM   dz

SELECT count(1)  
FROM FW_PROCESS_LOG  
WHERE  
V_MESSAGE like '%2520123%'  
AND N_STATUS=500 
 
 
--Задача 2 
 
SELECT to_char(DT_TIMESTAMP,'dd-mm-yyyy hh24:mi:ss'),'2520123' as nomer_zak  
FROM FW_PROCESS_LOG  
WHERE  
V_MESSAGE like '%2520123%'  
AND N_STATUS=500 
 
 
--Задача 3 
 
SELECT REPLACE (V_MESSAGE,'Загрузка порции заказов начиная с','') as nomer_zak  
FROM FW_PROCESS_LOG  
WHERE  
V_MESSAGE like 'Загрузка порции заказов начиная с %'  
 
 
--Задача 4 
 
SELECT count(1)  
FROM  
(SELECT distinct REPLACE (V_MESSAGE,'Загрузка порции заказов начиная с ','') as kontract 
FROM FW_PROCESS_LOG  
WHERE  
V_MESSAGE like 'Загрузка порции заказов начиная с %' )   
 
 
--Задача 5 
 
SELECT SUM(SUBSTR(V_MESSAGE,141,20)) as sum FROM fw_process_log 
WHERE V_MESSAGE like 'Процесс продвижения заказов завершен.%' 
 
 
--Задача 6 
 
SELECT count(*) as koli4estvo FROM fw_process_log 
WHERE DT_TIMESTAMP>='2018-03-1' AND DT_TIMESTAMP<'2018-04-1'  
 
 
--Задача 7 
 
select SUM(count(*)) from FW_PROCESS_LOG 
GROUP BY SID 
HAVING COUNT(*)>1 
 
 
--Задача 8 
 
select to_char(DT_TIMESTAMP,'dd-mm-yyyy hh24:mi:ss'), OS_USERNAME from FW_PROCESS_LOG 
WHERE ID_USER=11136 and DT_TIMESTAMP=(SELECT max(DT_TIMESTAMP) from FW_PROCESS_LOG WHERE ID_USER=11136)  
 
 
--Задача 9 
 
SELECT month, Count(*) 
    FROM (SELECT  
 CASE  
    WHEN DT_TIMESTAMP>='2018-01-1' AND DT_TIMESTAMP<'2018-02-1' THEN 'Январь' 
    WHEN DT_TIMESTAMP>='2018-02-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Февраль' 
    WHEN DT_TIMESTAMP>='2018-03-1' AND DT_TIMESTAMP<'2018-04-1' THEN 'Март' 
    WHEN DT_TIMESTAMP>='2018-04-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Апрель' 
    WHEN DT_TIMESTAMP>='2018-05-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Май' 
    WHEN DT_TIMESTAMP>='2018-06-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Июнь' 
    WHEN DT_TIMESTAMP>='2018-07-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Июль' 
    WHEN DT_TIMESTAMP>='2018-08-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Август' 
    WHEN DT_TIMESTAMP>='2018-09-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Сентябрь' 
    WHEN DT_TIMESTAMP>='2018-10-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Октябрь' 
   WHEN DT_TIMESTAMP>='2018-11-1' AND DT_TIMESTAMP<'2018-03-1' THEN 'Ноября' 
    ELse 'Декабрь' 
    END as month 
FROM fw_process_log) 
GROUP BY month  
 
 
--Задача 10 
 
SELECT sum(count(*)),count(*) FROM FW_PROCESS_LOG 
WHERE ID_PROCESS=5 and N_STATUS=500 and DT_TIMESTAMP>'2018-02-22' and DT_TIMESTAMP<'2018-03-02'  
GROUP BY V_MESSAGE 
 
 
--Задача 11 
 
SELECT MIN(N_SUM) 
FROM fw_transfers  
WHERE DT_INCOMING>='2017-02-14 10:00:0.000000' AND DT_INCOMING<='2017-02-14 12:00:0.000000' AND ID_CONTRACT_FROM<>ID_CONTRACT_TO 
 
 
--Задача 12 
 
SELECT ID_CONTRACT_TO,DT_REAL,(LENGTH(V_DESCRIPTION)-20) AS perebor 
FROM fw_transfers  
WHERE LENGTH(V_DESCRIPTION)>22 
ORDER BY perebor DESC 
 
 
--Задача 13 
 
SELECT DT_REAL, count(*) as kol_vo 
FROM (SELECT to_char(DT_REAL,'dd-mm-yyyy') AS DT_REAL FROM fw_transfers WHERE ID_CONTRACT_TO=ID_CONTRACT_FROM)  
GROUP BY DT_REAL 
ORDER BY DT_REAL ;

