
--sa_race is the Ireland Small Area shapefiles merged with 2016 Small Area Population Statistics. I joined them in QGIS and imported a postgres db, but I'm sure there are other ways
﻿select * from sa_race LIMIT 10;

--clear out Not Stated responses to maintain accurate population density. Assume Not Stated reponses were evenly distributed across races
ALTER TABLE sa_race
	ADD COLUMN wi_est int,
	ADD COLUMN wit_est int,
	ADD COLUMN ow_est int,
	ADD COLUMN bbi_est int,
	ADD COLUMN aai_est int,
	ADD COLUMN oth_est int;

UPDATE sa_race	
	SET wi_est = t2_2wi + ((cast(t2_2wi as float) / t2_2t) * t2_2ns),
	    wit_est = t2_2wit + ((cast(t2_2wit as float) / t2_2t) * t2_2ns),
	    ow_est = t2_2ow + ((cast(t2_2ow as float) / t2_2t) * t2_2ns),
	    bbi_est = t2_2bbi + ((cast(t2_2bbi as float) / t2_2t) * t2_2ns),
	    aai_est = t2_2aai + ((cast(t2_2aai as float) / t2_2t) * t2_2ns),
	    oth_est = t2_2oth + ((cast(t2_2oth as float) / t2_2t) * t2_2ns);

--New table with just randomly generated points in small area
drop table if exists race_points_full;
create table race_points_full (
	guid varchar(80) NOT NULL,
	white_irish geometry,
	traveller geography,
	other_white geography,
	black geography,
	asian geography,
	other geography,
	CONSTRAINT sa primary key (guid)
	);

	
insert into race_points_full (guid, white_irish, traveller, other_white, black, asian, other) 
	select guid,
		st_generatepoints(geom,wi_est),
		st_generatepoints(geom,wit_est),
		st_generatepoints(geom,ow_est),
		st_generatepoints(geom,bbi_est),
		st_generatepoints(geom,aai_est),
		st_generatepoints(geom,oth_est) from sa_race;


--Now the random points are in Multipoint geography objects. We want to separate each point into individual rows, randomly sorted
drop table if exists individuals;
create table individuals (
	point geometry NOT NULL,
	ethnicity varchar(80) NOT NULL,
	rand_sort float NOT NULL
	);
	
insert into individuals (point, ethnicity, rand_sort)
	select ((st_dump(cast(traveller as geometry))).geom), 'Traveller', random() from race_points_full;

insert into individuals (point, ethnicity, rand_sort)
	select ((st_dump(cast(white_irish as geometry))).geom), 'White Irish', random() from race_points_full;

insert into individuals (point, ethnicity, rand_sort)
	select ((st_dump(cast(other_white as geometry))).geom), 'Other White', random() from race_points_full;

insert into individuals (point, ethnicity, rand_sort)
	select ((st_dump(cast(black as geometry))).geom), 'Black', random() from race_points_full;

insert into individuals (point, ethnicity, rand_sort)
	select ((st_dump(cast(other as geometry))).geom), 'Other', random() from race_points_full;

insert into individuals (point, ethnicity, rand_sort)
	select ((st_dump(cast(asian as geometry))).geom), 'Asian', random() from race_points_full;

drop table if exists individuals_sorted;
create table individuals_sorted (
	point geometry NOT NULL,
	ethnicity varchar(80) NOT NULL
	);

insert into individuals_sorted (point, ethnicity)
	select point, ethnicity from individuals order by rand_sort;

drop table individuals;
drop table race_points_full;

--for medium zoom range reduce to 1/3 points to prevent over dense areas
create table race_points3 (
	guid varchar(80) NOT NULL,
	white_irish geography,
	traveller geography,
	other_white geography,
	black geography,
	asian geography,
	other geography,
	CONSTRAINT sa3 primary key (guid)
	);

	
insert into race_points3 (guid, white_irish, traveller, other_white, black, asian, other) 
	select guid,
		st_generatepoints(geom,wi_est/3),
		st_generatepoints(geom,wit_est/3),
		st_generatepoints(geom,ow_est/3),
		st_generatepoints(geom,bbi_est/3),
		st_generatepoints(geom,aai_est/3),
		st_generatepoints(geom,oth_est/3) from sa_race;


drop table if exists individuals3;
create table individuals3 (
	point geometry NOT NULL,
	ethnicity varchar(80) NOT NULL,
	rand_sort float NOT NULL
	);
	
insert into individuals3 (point, ethnicity, rand_sort)
	select ((st_dump(cast(traveller as geometry))).geom), 'Traveller', random() from race_points3;

insert into individuals3 (point, ethnicity, rand_sort)
	select ((st_dump(cast(white_irish as geometry))).geom), 'White Irish', random() from race_points3;

insert into individuals3 (point, ethnicity, rand_sort)
	select ((st_dump(cast(other_white as geometry))).geom), 'Other White', random() from race_points3;

insert into individuals3 (point, ethnicity, rand_sort)
	select ((st_dump(cast(black as geometry))).geom), 'Black', random() from race_points3;

insert into individuals3 (point, ethnicity, rand_sort)
	select ((st_dump(cast(other as geometry))).geom), 'Other', random() from race_points3;

insert into individuals3 (point, ethnicity, rand_sort)
	select ((st_dump(cast(asian as geometry))).geom), 'Asian', random() from race_points3;

drop table if exists individuals3_sorted;
create table individuals3_sorted (
	point geometry NOT NULL,
	ethnicity varchar(80) NOT NULL
	);

insert into individuals3_sorted (point, ethnicity)
	select point, ethnicity from individuals3 order by rand_sort;

drop table individuals3;
drop table race_points3;



--for wide zoom range reduce to 1/10 points to prevent over dense areas
drop table if exists race_points10;
create table race_points10 (
	guid varchar(80) NOT NULL,
	white_irish geography,
	traveller geography,
	other_white geography,
	black geography,
	asian geography,
	other geography,
	CONSTRAINT sa10 primary key (guid)
	);

	
insert into race_points10 (guid, white_irish, traveller, other_white, black, asian, other) 
	select guid,
		st_generatepoints(geom,wi_est/10),
		st_generatepoints(geom,wit_est/10),
		st_generatepoints(geom,ow_est/10),
		st_generatepoints(geom,bbi_est/10),
		st_generatepoints(geom,aai_est/10),
		st_generatepoints(geom,oth_est/10) from sa_race;


drop table if exists individuals10;
create table individuals10 (
	point geometry NOT NULL,
	ethnicity varchar(80) NOT NULL,
	rand_sort float NOT NULL
	);
	
insert into individuals10 (point, ethnicity, rand_sort)
	select ((st_dump(cast(traveller as geometry))).geom), 'Traveller', random() from race_points10;

insert into individuals10 (point, ethnicity, rand_sort)
	select ((st_dump(cast(white_irish as geometry))).geom), 'White Irish', random() from race_points10;

insert into individuals10 (point, ethnicity, rand_sort)
	select ((st_dump(cast(other_white as geometry))).geom), 'Other White', random() from race_points10;

insert into individuals10 (point, ethnicity, rand_sort)
	select ((st_dump(cast(black as geometry))).geom), 'Black', random() from race_points10;

insert into individuals10 (point, ethnicity, rand_sort)
	select ((st_dump(cast(other as geometry))).geom), 'Other', random() from race_points10;

insert into individuals10 (point, ethnicity, rand_sort)
	select ((st_dump(cast(asian as geometry))).geom), 'Asian', random() from race_points10;

drop table if exists individuals10_sorted;
create table individuals10_sorted (
	point geometry NOT NULL,
	ethnicity varchar(80) NOT NULL
	);

insert into individuals10_sorted (point, ethnicity)
	select point, ethnicity from individuals10 order by rand_sort;

drop table individuals10;
drop table race_points10;

--individuals[,3,10]_sorted are now manually imported into QGIS, styles applied, then converted to thousands png tiles using QTiles.
		
