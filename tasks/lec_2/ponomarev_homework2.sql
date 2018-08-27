-- 1 задача 


select dep.V_NAME,sum(tra.F_SUM) sam,count_tra.conut_tra,count_con.conut_con from FW_DEPARTMENTS dep
LEFT JOIN FW_CONTRACTS con
on
con.ID_DEPARTMENT=dep.ID_DEPARTMENT and
con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp and 
con.V_STATUS='A' 

LEFT JOIN TRANS_EXTERNAL tra
on
tra.ID_CONTRACT=con.ID_CONTRACT_INST and
tra.V_STATUS='A' and 
tra.DT_EVENT>=ADD_MONTHS( current_timestamp, -1 )   ---здесь дата

LEFT JOIN 
(select ID_DEPARTMENT,count(1) conut_con from FW_CONTRACTS con
WHERE
con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp  and 
con.V_STATUS='A' 
GROUP BY ID_DEPARTMENT
) count_con
on
count_con.ID_DEPARTMENT=dep.ID_DEPARTMENT 

LEFT JOIN 
(select con.ID_DEPARTMENT ID_DEPART,count(1) conut_tra from TRANS_EXTERNAL tra
JOIN FW_CONTRACTS con
on
con.ID_CONTRACT_INST=tra.ID_CONTRACT and
con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp

WHERE 
tra.V_STATUS='A' and 
tra.DT_EVENT>=ADD_MONTHS( current_timestamp, -1 )     ---здесь дата
GROUP BY con.ID_DEPARTMENT
) count_tra
on
count_tra.ID_DEPART=con.ID_DEPARTMENT 

WHERE
dep.B_DELETED=0 
group by dep.V_NAME,con.ID_CURRENCY,count_con.conut_con,count_tra.conut_tra
ORDER BY dep.V_NAME


-- 2 задача 


select con.V_EXT_IDENT, con.V_STATUS, cont_tra.trap  from FW_CONTRACTS con
JOIN 
(select con.ID_CONTRACT_INST,tra.ID_CONTRACT,count(1) trap from FW_CONTRACTS con
JOIN TRANS_EXTERNAL tra on 
tra.ID_CONTRACT=con.ID_CONTRACT_INST and
tra.V_STATUS='A'

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp and
DT_EVENT>=to_date('01-01-2017','dd-mm-yyyy') and
DT_EVENT<to_date('01-01-2018','dd-mm-yyyy')
GROUP BY con.ID_CONTRACT_INST, con.V_STATUS,tra.ID_CONTRACT
) cont_tra on 
cont_tra.ID_CONTRACT_INST=con.ID_CONTRACT_INST

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp  and
cont_tra.trap>3 
ORDER BY con.V_EXT_IDENT


-- 3 задача


select dep.V_NAME  from FW_DEPARTMENTS dep
LEFT JOIN FW_CONTRACTS con on con.ID_DEPARTMENT=dep.ID_DEPARTMENT
WHERE dep.B_DELETED=0 and con.ID_DEPARTMENT is NULL


-- 4 задача


select  joiner.cont,joiner.maxi,con.V_EXT_IDENT,ci.V_DESCRIPTION from FW_CONTRACTS con
JOIN 
(select con.ID_CONTRACT_INST ,count(1) cont,max(tra.DT_EVENT) maxi  from FW_CONTRACTS con

JOIN TRANS_EXTERNAL tra 
on tra.ID_CONTRACT=con.ID_CONTRACT_INST and
tra.V_STATUS= 'A'

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp and
con.V_STATUS='A'
GROUP BY con.ID_CONTRACT_INST,tra.ID_CONTRACT) joiner
on joiner.ID_CONTRACT_INST=con.ID_CONTRACT_INST

JOIN TRANS_EXTERNAL tra on  
joiner.ID_CONTRACT_INST=tra.ID_CONTRACT and 
tra.DT_EVENT=joiner.maxi and
tra.V_STATUS= 'A' and 
joiner.ID_CONTRACT_INST=tra.ID_CONTRACT

left JOIN CI_USERS ci on tra.id_manager=ci.ID_USER

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp 


-- 5 задача


select distinct con.ID_CONTRACT_INST,con.V_EXT_IDENT,con.V_STATUS,cur.V_NAME from FW_CONTRACTS con

JOIN (select ID_CONTRACT_INST,ID_CURRENCY, count(1) conut from FW_CONTRACTS
GROUP BY ID_CONTRACT_INST,ID_CURRENCY ) conut_val on
conut_val.ID_CONTRACT_INST=con.ID_CONTRACT_INST 

JOIN (select ID_CONTRACT_INST, count(1) conut from FW_CONTRACTS
GROUP BY ID_CONTRACT_INST) conut_real on
conut_real.ID_CONTRACT_INST=con.ID_CONTRACT_INST

LEFT JOIN FW_CURRENCY cur on con.ID_CURRENCY=cur.ID_CURRENCY

WHERE conut_real.conut<>conut_val.conut and con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp 
ORDER BY con.ID_CONTRACT_INST


-- 6 задача


select sum(tra.F_SUM),cur.V_CODE,con.V_EXT_IDENT,dep.V_NAME,extract(year from DT_EVENT) from FW_CONTRACTS con
JOIN TRANS_EXTERNAL tra
on
tra.ID_CONTRACT=con.ID_CONTRACT_INST and
tra.V_STATUS='A'

JOIN FW_DEPARTMENTS dep
on
dep.ID_DEPARTMENT=con.ID_DEPARTMENT and 
dep.B_DELETED=0

LEFT JOIN FW_CURRENCY cur
on
cur.ID_CURRENCY=con.ID_CURRENCY and 
cur.B_DELETED=0

WHERE con.V_STATUS='A'
GROUP BY con.ID_CURRENCY,con.V_EXT_IDENT,extract(year from DT_EVENT),cur.V_CODE,dep.V_NAME
ORDER BY con.V_EXT_IDENT
