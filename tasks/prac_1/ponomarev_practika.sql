-- 1 задача (проверено)


select con.v_ext_ident,sum(serc.N_COST_PERIOD),dep.V_NAME from FW_contracts con
JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

JOIN FW_DEPARTMENTS dep 
on dep.ID_DEPARTMENT=con.ID_DEPARTMENT and
dep.B_DELETED=0

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp
group by con.ID_CONTRACT_INST,v_ext_ident, dep.V_NAME


-- 2 задача (проверено)


select AVG(serc.sot) sot,dep.V_NAME from FW_DEPARTMENTS dep
JOIN
(select con.v_ext_ident,sum(serc.N_COST_PERIOD) sot,dep.ID_DEPARTMENT from FW_contracts con
JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

JOIN FW_DEPARTMENTS dep 
on dep.ID_DEPARTMENT=con.ID_DEPARTMENT and
dep.B_DELETED=0

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp
group by con.ID_CONTRACT_INST,v_ext_ident, dep.ID_DEPARTMENT) serc
on serc.ID_DEPARTMENT=dep.ID_DEPARTMENT
GROUP BY dep.V_NAME


-- 3 задача 


select distinct con.v_ext_ident,joiner1.sot from FW_contracts con
JOIN FW_DEPARTMENTS dep
on dep.ID_DEPARTMENT=con.ID_DEPARTMENT

JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

JOIN (select AVG(serc.sot) sot,dep.V_NAME from FW_DEPARTMENTS dep
JOIN
(select con.v_ext_ident,sum(serc.N_COST_PERIOD) sot,dep.ID_DEPARTMENT from FW_contracts con
JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp
JOIN FW_DEPARTMENTS dep 
on dep.ID_DEPARTMENT=con.ID_DEPARTMENT and
dep.B_DELETED=0

WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp
group by con.ID_CONTRACT_INST,v_ext_ident, dep.ID_DEPARTMENT) serc
on serc.ID_DEPARTMENT=dep.ID_DEPARTMENT
GROUP BY dep.V_NAME) joiner on dep.V_NAME=joiner.V_NAME

JOIN (select con.ID_CONTRACT_INST,con.v_ext_ident,sum(serc.N_COST_PERIOD-serc.N_DISCOUNT_PERIOD) sot from FW_contracts con
JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp
group by con.ID_CONTRACT_INST,v_ext_ident,con.ID_CONTRACT_INST) joiner1 on joiner1.v_ext_ident=con.v_ext_ident

WHERE joiner.sot<joiner1.sot
ORDER BY con.v_ext_ident


-- 4 задача


select  ser.V_NAME,dep.V_NAME,(serc.N_COST_PERIOD-serc.N_DISCOUNT_PERIOD) AP from FW_contracts con
JOIN FW_DEPARTMENTS dep 
on dep.ID_DEPARTMENT=con.ID_DEPARTMENT

JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

JOIN FW_SERVICES sers 
on sers.ID_SERVICE_INST=serc.ID_SERVICE_INST and
sers.B_DELETED=0 and
sers.V_STATUS='A' and
sers.DT_STOP>current_timestamp and
sers.DT_START<=current_timestamp 

JOIN FW_SERVICE ser 
on ser.ID_SERVICE=sers.ID_SERVICE and
ser.B_DELETED=0

JOIN (select AVG(serc.sot) sot,dep.V_NAME from FW_DEPARTMENTS dep
JOIN
(select con.v_ext_ident,sum(serc.N_COST_PERIOD) sot,dep.ID_DEPARTMENT from FW_contracts con
JOIN FW_SERVICES_COST serc
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

JOIN FW_DEPARTMENTS dep 
on dep.ID_DEPARTMENT=con.ID_DEPARTMENT and
dep.B_DELETED=0
WHERE con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp
group by con.ID_CONTRACT_INST,v_ext_ident, dep.ID_DEPARTMENT) serc
on serc.ID_DEPARTMENT=dep.ID_DEPARTMENT
GROUP BY dep.V_NAME) joiner on dep.V_NAME=joiner.V_NAME

WHERE serc.N_COST_PERIOD>joiner.sot
ORDER BY con.V_EXT_IDENT


-- 5 задача


select distinct con.V_EXT_IDENT,(joiner1.colvo_vs-joiner2.colvo_vs) zna4 from FW_SERVICES_COST serc
JOIN FW_CONTRACTS con 
on con.ID_CONTRACT_INST=serc.ID_CONTRACT_INST

JOIN (select distinct serc.ID_CONTRACT_INST,count(1) colvo_vs from FW_SERVICES_COST serc
JOIN FW_SERVICES ser 
on ser.ID_SERVICE_INST=serc.ID_SERVICE_INST and
ser.DT_STOP>TO_DATE('01-12-2017', 'dd-mm-yyyy') and
ser.DT_START<=TO_DATE('01-11-2017', 'dd-mm-yyyy')

LEFT JOIN FW_CONTRACTS con 
on con.ID_CONTRACT_INST=serc.ID_CONTRACT_INST and
con.DT_STOP>TO_DATE('01-12-2017', 'dd-mm-yyyy') and
con.DT_START<=TO_DATE('01-11-2017', 'dd-mm-yyyy')
GROUP BY serc.ID_CONTRACT_INST,ser.ID_SERVICE,serc.N_COST_PERIOD,serc.N_DISCOUNT_PERIOD) joiner1 
on joiner1.ID_CONTRACT_INST=serc.ID_CONTRACT_INST

JOIN (select distinct serc.ID_CONTRACT_INST,count(1) colvo_vs from FW_SERVICES_COST serc
JOIN FW_SERVICES ser 
on ser.ID_SERVICE_INST=serc.ID_SERVICE_INST and
ser.DT_STOP>TO_DATE('01-12-2017', 'dd-mm-yyyy') and
ser.DT_START<=TO_DATE('01-11-2017', 'dd-mm-yyyy')

LEFT JOIN FW_CONTRACTS con 
on con.ID_CONTRACT_INST=serc.ID_CONTRACT_INST and
con.DT_STOP>TO_DATE('01-12-2017', 'dd-mm-yyyy') and
con.DT_START<=TO_DATE('01-11-2017', 'dd-mm-yyyy')
GROUP BY serc.ID_CONTRACT_INST,ser.ID_SERVICE,serc.N_COST_PERIOD) joiner2 
on joiner1.ID_CONTRACT_INST=serc.ID_CONTRACT_INST

WHERE  (joiner1.colvo_vs-joiner2.colvo_vs)>1 and serc.DT_STOP>TO_DATE('01-12-2017', 'dd-mm-yyyy') and serc.DT_START<=TO_DATE('01-11-2017', 'dd-mm-yyyy')
ORDER BY con.V_EXT_IDENT


-- 6 задача


select distinct dep.V_NAME, joiner2.maxi, tp.V_NAME from FW_DEPARTMENTS dep
LEFT JOIN FW_CONTRACTS con 
on con.ID_DEPARTMENT=dep.ID_DEPARTMENT and
con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp and
con.V_STATUS='A'

LEFT JOIN FW_SERVICES_COST serc 
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

LEFT JOIN FW_SERVICES ser 
on ser.ID_SERVICE_INST=serc.ID_SERVICE_INST  and
ser.DT_STOP>current_timestamp and
ser.DT_START<=current_timestamp and
ser.V_STATUS='A'

LEFT JOIN FW_TARIFF_PLAN tp 
on tp.ID_TARIFF_PLAN=ser.ID_TARIFF_PLAN and
tp.DT_STOP>current_timestamp and
tp.DT_START<=current_timestamp and
tp.B_DELETED=0


LEFT JOIN
(select distinct dep.V_NAME,max(joiner.sam) maxi from FW_DEPARTMENTS dep
JOIN FW_CONTRACTS con 
on con.ID_DEPARTMENT=dep.ID_DEPARTMENT and
con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp and
con.V_STATUS='A'

JOIN FW_SERVICES_COST serc 
on serc.ID_CONTRACT_INST=con.ID_CONTRACT_INST and
serc.DT_STOP>current_timestamp and
serc.DT_START<=current_timestamp

JOIN FW_SERVICES ser
on ser.ID_SERVICE_INST=serc.ID_SERVICE_INST and
ser.DT_STOP>current_timestamp and
ser.DT_START<=current_timestamp and
ser.V_STATUS='A'

JOIN FW_TARIFF_PLAN tp 
on tp.ID_TARIFF_PLAN=tp.ID_TARIFF_PLAN and
tp.DT_STOP>current_timestamp and
tp.DT_START<=current_timestamp and tp.B_DELETED=0


JOIN (select sum(N_COST_PERIOD-N_DISCOUNT_PERIOD) sam,tp.ID_TARIFF_PLAN,con.ID_DEPARTMENT from FW_SERVICES_COST serc
JOIN FW_SERVICES ser 
on ser.ID_SERVICE_INST=serc.ID_SERVICE_INST and
ser.DT_STOP>current_timestamp and
ser.DT_START<=current_timestamp and ser.V_STATUS='A'

JOIN FW_TARIFF_PLAN tp 
on tp.ID_TARIFF_PLAN=tp.ID_TARIFF_PLAN and
tp.DT_STOP>current_timestamp and
tp.DT_START<=current_timestamp and
tp.B_DELETED=0

JOIN FW_CONTRACTS con 
on con.ID_CONTRACT_INST=serc.ID_CONTRACT_INST and
con.DT_STOP>current_timestamp and
con.DT_START<=current_timestamp and
con.V_STATUS='A'
GROUP BY serc.ID_CONTRACT_INST,tp.ID_TARIFF_PLAN,con.ID_DEPARTMENT) joiner on joiner.ID_TARIFF_PLAN=tp.ID_TARIFF_PLAN and joiner.ID_DEPARTMENT=con.ID_DEPARTMENT

WHERE dep.B_DELETED=0
GROUP BY dep.V_NAME,joiner.ID_DEPARTMENT) joiner2 on joiner2.V_NAME=dep.V_NAME
ORDER BY dep.V_NAME
