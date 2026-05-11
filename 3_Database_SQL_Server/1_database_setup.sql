--database setup
create database companies_startups;
go

use companies_startups;
go

--data inspection
select * from cleaned_objects;
select * from cleaned_acquisitions;
select * from cleaned_degrees;
select * from cleaned_funding_rounds;
select * from cleaned_funds;
select * from cleaned_investments;
select * from cleaned_ipos;
select * from cleaned_milestones;
select * from cleaned_offices;
select * from cleaned_people;
select * from cleaned_relationships;

--checking table structures
exec sp_help cleaned_objects;
exec sp_help cleaned_acquisitions;
exec sp_help cleaned_funding_rounds;
exec sp_help cleaned_degrees;
exec sp_help cleaned_funds;
exec sp_help cleaned_investments;
exec sp_help cleaned_ipos;
exec sp_help cleaned_milestones;
exec sp_help cleaned_offices;
exec sp_help cleaned_people;
exec sp_help cleaned_relationships;

--data cleaning: removing orphan records 
--delete records that do not have a matching id in the primary objects table
delete from cleaned_people 
where object_id not in (select id from cleaned_objects);

delete from cleaned_acquisitions 
where acquiring_object_id not in (select id from cleaned_objects);

delete from cleaned_acquisitions 
where acquired_object_id not in (select id from cleaned_objects);

delete from cleaned_funding_rounds 
where object_id not in (select id from cleaned_objects);

delete from cleaned_investments 
where funded_object_id not in (select id from cleaned_objects);

delete from cleaned_investments 
where investor_object_id not in (select id from cleaned_objects);

delete from cleaned_relationships 
where person_object_id not in (select id from cleaned_objects);

delete from cleaned_relationships 
where relationship_object_id not in (select id from cleaned_objects);

delete from cleaned_degrees 
where object_id not in (select id from cleaned_objects);

delete from cleaned_ipos 
where object_id not in (select id from cleaned_objects);

delete from cleaned_milestones 
where object_id not in (select id from cleaned_objects);

delete from cleaned_funds 
where object_id not in (select id from cleaned_objects);

--preparing specific keys for relationships 
-- ensure funding_round_id is unique to allow foreign key referencing
alter table cleaned_funding_rounds 
alter column funding_round_id int not null;

alter table cleaned_funding_rounds 
add constraint uq_fundingroundid unique (funding_round_id);

-- clean investments from invalid round ids
delete from cleaned_investments 
where funding_round_id not in (select funding_round_id from cleaned_funding_rounds);

--establishing foreign key constraints 

-- linking acquisitions
alter table cleaned_acquisitions 
add constraint fk_cleaned_acquisitions_acquiring 
foreign key (acquiring_object_id) 
references cleaned_objects(id);

alter table cleaned_acquisitions 
add constraint fk_cleaned_acquisitions_acquired 
foreign key (acquired_object_id) 
references cleaned_objects(id);

-- linking degrees, funding, and funds
alter table cleaned_degrees 
add constraint fk_cleaned_degrees_object 
foreign key (object_id) 
references cleaned_objects(id);

alter table cleaned_funding_rounds 
add constraint fk_cleaned_fundingrounds_object 
foreign key (object_id) 
references cleaned_objects(id);

alter table cleaned_funds 
add constraint fk_cleaned_funds_object 
foreign key (object_id) 
references cleaned_objects(id);

-- linking investments
alter table cleaned_investments 
add constraint fk_final_investments_round 
foreign key (funding_round_id) 
references cleaned_funding_rounds(funding_round_id);

alter table cleaned_investments 
add constraint fk_cleaned_investments_fundedobject 
foreign key (funded_object_id) 
references cleaned_objects(id);

alter table cleaned_investments 
add constraint fk_cleaned_investments_investorobject 
foreign key (investor_object_id) 
references cleaned_objects(id);

-- linking other dimensions
alter table cleaned_ipos 
add constraint fk_cleaned_ipos_object 
foreign key (object_id) 
references cleaned_objects(id);

alter table cleaned_milestones 
add constraint fk_cleaned_milestones_object 
foreign key (object_id) 
references cleaned_objects(id);

alter table cleaned_offices 
add constraint fk_cleaned_offices_object 
foreign key (object_id) 
references cleaned_objects(id);

alter table cleaned_people 
add constraint fk_cleaned_people_object 
foreign key (object_id) 
references cleaned_objects(id);

-- linking relationships
alter table cleaned_relationships 
add constraint fk_cleaned_relationships_person 
foreign key (person_object_id) 
references cleaned_objects(id);

alter table cleaned_relationships 
add constraint fk_cleaned_relationships_entity 
foreign key (relationship_object_id) 
references cleaned_objects(id);

--handling self-join for parent companies 
--check if column exists, then clean and link
--add parent_id column to handle hierarchical relationships between companies
alter table cleaned_objects add parent_id nvarchar(100);
update cleaned_objects 
set parent_id = null where parent_id not in (select id from cleaned_objects);

alter table cleaned_objects 
add constraint fk_cleaned_objects_parent 
foreign key (parent_id) 
references cleaned_objects(id);