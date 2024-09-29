--1
alter view VACCINE_VIEW(medicine_Name, germ_name, date_Found_medicine) as
select  [medicine_name], [germ_name], [tast_date]
from [dbo].[tbl_archiv] where [reaction_type] = 'dead'
with check option
delete from tbl_archiv


select * from vaccine_view

--2
alter procedure COPY_TO_ARCHIV @id smallint as
begin
	insert into [dbo].[tbl_archiv]
		select g.[name],[germ_id],[test_date],m.[name], t.[reaction_type]
		from [dbo].[tbl_germs]g join [dbo].[tbl_test]t
		on g.ID = t.germ_id
		join [dbo].[tbl_medicine]m
		on t.MEDICINE_ID = m.ID
		where t.germ_id = @id
end


begin try
	exec COPY_TO_ARCHIV 12
end try
begin catch
	insert into [dbo].[tbl_exception] values(error_message())
end catch

select * from [dbo].tbl_archiv

--3
alter procedure ADD_TEST_SQL @germ_name varchar(10),@medicine_name varchar(20),@test_date date,@reaction_type varchar(10)as
begin
	declare @id_germ smallint
	set @id_germ = (select  g.id
	from  [dbo].tbl_germs g
	where g.[name] = @germ_name)
	declare @id_medicin smallint 
	set @id_medicin = (select m.id
	from  [dbo].tbl_medicine m
	where m.[NAME] like @medicine_name)
	if @id_germ is null
			begin
				insert into [dbo].[tbl_exception] values('germ does not exist')
				print 'germ does not exist.';
				return;
			end
	if @id_medicin is null
			begin
				insert into [dbo].[tbl_exception] values(' medicine does not exist')
				print ' medicine does not exist.';
				return;
			end	
	if exists (SELECT * FROM [dbo].[tbl_test] WHERE germ_id = @id_germ
						AND [MEDICINE_ID] = @id_medicin)
				begin
					insert into [dbo].[tbl_exception] values('Medicine already tested on the germ.')
					print 'Medicine already tested on the germ.';
					return;
				end 
	insert into [dbo].[tbl_test] values(@id_germ,@id_medicin,@test_date,@reaction_type)
	if @reaction_type = 'dead'
		begin try
			exec COPY_TO_ARCHIV @id_germ
			update [dbo].[tbl_germs]
			set medicin_date = @test_date
			where [ID] = @id_germ
		end try
		begin catch
		print(error_message())
			insert into [dbo].tbl_exception values(error_message())
		end catch
end

begin try
   exec ADD_TEST_SQL 'sinusitus','ebofen','2004-12-01','dead'
end try
begin catch
   insert into [dbo].tbl_exception values(ERROR_MESSAGE())
end catch
--
 select * from [dbo].tbl_test
 select * from [dbo].tbl_archiv
 select * from tbl_exception
 delete from [dbo].tbl_archiv
 where reaction_type = 'alive'

--4
alter procedure UPDATE_STATUS @germ_id smallint, @medicine_id smallint, @status varchar(5)as
begin 
	update [dbo].[tbl_test]
	set [reaction_type] = @status
	where [medicine_id] = @medicine_id and  germ_id = @germ_id
	if @status = 'dead'
		begin try
			exec COPY_TO_ARCHIV @germ_id
			update [dbo].tbl_germs
			set medicin_date = GETDATE()
			where id= @germ_id
		end try
		begin catch
			print error_message()
			insert into [dbo].tbl_exception values(error_message())
		end catch
end

begin try
	exec UPDATE_STATUS 13, 200, 'dead'
end try
begin catch
	print error_message()
	insert into [dbo].tbl_exception values(error_message())
end catch

select * from tbl_germs
select * from [dbo].tbl_test
select * from [dbo].tbl_archiv
select * from tbl_exception

--delete from [dbo].tbl_archiv
--where germ_id = 15

--delete from tbl_exception

 
--5
alter procedure STAYING_ALIVE @germ_id smallint, @medicine_id smallint as
begin 
print('stying alive')
	if (select DATEDIFF(MM ,[test_date], GETDATE()) from  [dbo].[tbl_test]where germ_id = @germ_id
		and medicine_id = @medicine_id and reaction_type = 'dying') > 2
		begin try
		print('dying')
			exec UPDATE_STATUS @germ_id, @medicine_id, 'alive'
		end try
		begin catch
			insert into [dbo].tbl_exception values(error_message())
		end catch 
end

begin try
	exec STAYING_ALIVE 14, 14
end try
begin catch
	insert into [dbo].tbl_exception values(error_message())
end catch 



--6
alter trigger Dead_germ on [dbo].[tbl_test]
FOR INSERT, update as
begin
declare @id smallint
print('enter trigger')
set @id = (select [germ_id] from inserted where[reaction_type] = 'dead')
    if @id is not null
	begin try
		exec COPY_TO_ARCHIV @id
		--if Exists(select test_date from inserted) begin
			update [dbo].[tbl_germs]
			set medicin_date = (select test_date from inserted)
			where id = @id
	--		end
	--	else begin
		--print ('update in trigger')
		--	update [dbo].[tbl_germs]
		--	set medicin_date = GETDATE()
	--	end
	end try
	begin catch
		insert into [dbo].tbl_exception values(error_message())
	end catch
	print('go out trigger')
end


insert into [dbo].tbl_test values(15,100,'10/10/2024','dead')
select * from [dbo].tbl_test
delete from [dbo].tbl_test
where germ_id = 15
 	
--7

alter function TEST_TO_GERM (@germ_id int)
returns int as
begin
		declare @count_germ int
		set @count_germ = (select count([germ_id]) from[dbo].[tbl_test] where [germ_id] = @germ_id)
		return @count_germ
end

print [dbo].[TEST_TO_GERM](15)


--8
alter function GERM_FOR_VACCINE (@medicine_name varchar(20))
returns table as

return (select distinct[germ_id], germ_name 
		from tbl_archiv a
		where a.medicine_name = @medicine_name and a.reaction_type = 'dead')

select * from [dbo].[GERM_FOR_VACCINE]('akamol')

--9
alter procedure GERM_PRENSISTENT_MOST @germ_max varchar(20) output
as begin
	declare  @current_id int, @max_id int, @max_test int= 0 , @germ_name varchar(20)
	declare my_crs cursor
	for select [id] from [dbo].[tbl_germs]
	open my_crs
	fetch next from my_crs into @current_id
	while @@FETCH_STATUS = 0
	begin 
		if(([dbo].[TEST_TO_GERM] (@current_id)) > @max_test)
		begin
			set @max_test = ([dbo].[TEST_TO_GERM] (@current_id)) 
			set @max_id =@current_id
			set @germ_name = (select [name]from [dbo].[tbl_germs] where [id] = @max_id)
			
		end
		fetch next from my_crs into @current_id
	end
	print @max_test
	print @germ_name
	close my_crs
	deallocate my_crs
	
	set @germ_max = (select [name] from [dbo].[tbl_germs] where [id] = @max_id)

end


declare @max varchar(20)
exec [dbo].[GERM_PRENSISTENT_MOST] @max
