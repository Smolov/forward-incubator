---1


--�������� ������ � ���������� id_contract_inst �� �������


 cursor cur_con is
      select con.id_contract_inst
        from fw_contracts con
       where con.id_contract_inst != pID_CONTRACT_INST
         and con.v_ext_ident = l_ext_ident
--����� �������� ������ ��� ������� � ������
and con.DT_START<=current_timestamp  and con.DT_STOP>current_timestamp




--2

--����������� ���� (������ ��������) �������, �������� � B_DELETED=1

UPDATE filestorage
SET B_DELETED=0
WHERE V_SHORT_NAME='rpt_change.rpt' ;






---3

--����������� ������� fw_service, �.�.

INSERT INTO fw_service ....




---4


/*
���� � ��� ��� ���� �������� ��������������� ����� �����, � ��������� �������������� ����� � ����� ����������� (170033,191817,174491,191849).
�������: �������� ������ �������������� � ����,
� ������ ��������. 
P.S. ��� ���
*/
