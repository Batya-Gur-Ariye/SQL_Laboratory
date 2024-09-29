create database DB_BATYA_GA
use DB_BATYA_GA
go
create table tbl_germs
(
	id smallint primary key,
	[name] varchar(20) unique not null,
	short_desc varchar(300) ,
	id_date date not null,
	medicin_date date
)

insert into tbl_germs values(12, 'strap', 'so weak', '12/01/2023','12/12/2025')
insert into tbl_germs values(13, 'covid-19', 'so week', '12/01/2023','12/12/2025')
insert into tbl_germs values(14, 'sinusitus', 'so week', '12/01/2023','12/12/2025')
insert into tbl_germs values(15, 'h-toref', 'so week', '12/01/2023','12/12/2025')
insert into tbl_germs values(16, 'mono', 'so week', '12/01/2023','12/12/2025')



create table tbl_medicine
(
	id smallint primary key,
	[name] varchar(20) unique not null
)
insert into tbl_medicine values(100, 'antibutiqe')
insert into tbl_medicine values(200, 'barzel')
insert into tbl_medicine values(300, 'vitamin e')
insert into tbl_medicine values(400, 'vitamin b')

select * from tbl_germs
select* from tbl_medicine


create table tbl_test
(
	germ_id smallint foreign key references tbl_germs(id),
	medicine_id smallint foreign key references tbl_medicine(id),
	test_date date,
	reaction_type varchar(10) check(reaction_type in('alive', 'dead', 'dying')),
	constraint pk_test primary key (germ_id, medicine_id)
)
select * from tbl_test
insert into tbl_test values(15, 100 ,'12/01/2004', 'alive') 
insert into tbl_test values(12, 14 ,'12/01/2004', 'alive') 
insert into tbl_test values(13, 200 ,'12/01/2004', 'alive') 
insert into tbl_test values(14, 14 ,'12/01/2004', 'dying') 
insert into tbl_test values(16, 400 ,'12/01/2004', 'dying') 
insert into tbl_test values(15, 200 ,'12/01/2004', 'alive') 
insert into tbl_test values(15, 12 ,'12/01/2004', 'alive') 
insert into tbl_test values(12, 100 ,'12/01/2004', 'alive') 


create table tbl_archiv
(
	germ_name varchar(20) ,
	germ_id smallint,
	tast_date date,
	medicine_name varchar(20),
	reaction_type varchar(10)
)

--insert into tbl_archiv values('abcde', 12, '12/02/1978', 'norofen', 'dead')
--insert into tbl_archiv values('bcdef', 13, '10/01/2004', 'ibofen', 'dead')
--insert into tbl_archiv values('cdefg', 14, '08/29/2001', 'barzel', 'dead')
--insert into tbl_archiv values('defgh', 15, '12/03/1978', 'vitamin e', 'dead')
--insert into tbl_archiv values('efghi', 16, '12/02/2008', 'vitamin b', 'dead')
--insert into tbl_archiv values('fghij', 17, '12/12/1978', 'norofen', 'dead')

select * from tbl_archiv

create table tbl_exception(
	[message] varchar(300)
) 

select * from tbl_exception


