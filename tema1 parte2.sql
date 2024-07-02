/*
### Consulta 1
- Informar aquellos barrios y sus respectivas localidades, en las cuales no se encuentran registros del 
domicilio de cada uno de los clientes que est�n dados de alta en la presente base de datos. 
Para la resoluci�n de este ejercicio no debe emplear la palabra reservada JOIN, en sus distintas 
variantes. Los encabezados deben ser los siguientes:
Localidad, Barrio, seg�n la columna que corresponda. Debe emplear un procedimiento almacenado. 
Finalmente, deje la instrucci�n correspondiente para ejecutarlo. 
*/
select *,(select descripcion_Barr from BARRIOS where codBarrio_Barr=codBarrio_Cl) as barrio, (select descripcion_Loc from LOCALIDADES where codPostal_Loc=codLocalidad_Cl) as localidad from clientes

/*
### Consulta 2
- Informar nombre completo, domicilio, barrio, localidad, g�nero y edad al momento de efectuar la consulta de 
aquellos clientes que tengan registrados el mayor n�mero de tel�fonos. Debe emplear un procedimiento 
almacenado. Como sugerencia para la resoluci�n de este punto, es conveniente a�adir un campo adicional en la 
tabla que le resulte m�s apropiada a modo de poder llevar adelante la consulta. Ejecute el procedimiento 
almacenado y posterior a dicha ejecuci�n, la tabla que haya elegido debe quedar con la misma cantidad de campos 
que al principio. Los encabezados deben ser los siguientes: Cliente, Domicilio, Barrio, Localidad, G�nero, 
Edad. NO EMPLEAR FUNCIONES que no se han visto en las clases o encuentros. 
*/

create proc consulta2Tema1
as
select (nombre_Cl+' '+apellido_Cl)as Cliente,direccion_Cl as Domicilio, (select descripcion_Barr from BARRIOS where codBarrio_Barr=codBarrio_Cl)as Barrio,(select descripcion_Loc from LOCALIDADES where codPostal_Loc=codLocalidad_Cl)as Localidad, (select descripcion_Gen from GENEROS where cod_Gen=codGen_Cl)as Genero,dbo.F_ObtenerEdad(fechaNacimiento_Cl) as Edad from clientes where dni_Cl in (select top 3 dniCliente_TxC from TELEFONOSxCLIENTES group by dniCliente_TxC order by count(*) desc);
exec consulta2Tema1

/*
### Consulta 3
Mostrar un listado por medio de un procedimiento almacenado que informe el nombre completo, tiempo trabajo 
en la empresa y edad de aquellos vendedores que est�n por entrar al estado pasivo, dado que se encuentran en 
edad jubilatoria. Tenga en cuenta que para las mujeres es una edad mayor o igual a los 60 a�os, mientras que 
para los hombres es a partir de los 65 a�os. Los encabezados que deben aparecer en la consulta son los 
siguientes: Vendedor/a, A�os Trabajados, Edad en la columna que corresponda. Si le resulta de utilidad a�adir 
alg�n campo o campos a la tabla que considere pertinente, para resolver este ejercicio, puede hacerlo. 
Luego de ejecutar el procedimiento almacenado elimine los campos a�adidos. NO EMPLEAR funciones que no se han
visto en las clases o encuentros. 

*/
create or alter proc VendedoresXJubilarse
as
select 
	(nombre_Vd+' '+apellido_Vd)as Vendedor, 
	dbo.F_ObtenerEdad(fechaNacimiento_Vd) as edad, 
	dbo.F_ObtenerEdad(fechaIngreso_Vd) as "Anios trabajados" 
		from VENDEDORES 
			where codGen_Vd=(select cod_Gen from GENEROS where 
			(descripcion_Gen='Femenino') and dbo.F_ObtenerEdad(fechaNacimiento_Vd) >58) 
			or dbo.F_ObtenerEdad(fechaNacimiento_Vd) >63
exec VendedoresXJubilarse


/*
### Consulta 4
Crear un procedimiento almacenado que informe el nombre completo, dni, direcci�n, barrio, localidad, y el 
mayor n�mero de compras realizadas entre todas las compras, de aquellos hombres que tienen una edad que es 
igual o superior a la edad promedio de las mujeres. Los hombres y mujeres que se toman en consideraci�n son los
clientes que est�n registrados en la base de datos. Realice cambios a la tabla pertinente a modo de a�adir 
alg�n campo, si lo considera necesario. Luego de ejecutar el procedimiento almacenado elimine el campo o campos 
a�adidos a la tabla. Los encabezados en el resultado de la consulta, deben ser los siguientes: Cliente, Dni, 
Direcci�n, Barrio, Localidad, Total de Compras Realizadas. No EMPLEAR funciones que no fueron dadas en los 
encuentros.
*/
create proc clientesvaronesviejos
as
select  
	(
	select top 1 
		sum(cantidadArt_DV) 
	from DETALLE_VENTAS 
	where idVenta_DV in (select id_Venta from VENTAS where dniCliente_Venta=dni_Cl) 
	group by idVenta_DV 
	order by  sum(cantidadArt_DV) desc),
	*,
	dbo.F_ObtenerEdad(fechaNacimiento_Cl) as edad 
	from clientes 
	where (codGen_Cl=(
		select cod_Gen 
		from GENEROS 
		where descripcion_Gen='Masculino')) 
	and 
	dbo.F_ObtenerEdad(fechaNacimiento_Cl) > (
		select 
			avg(dbo.F_ObtenerEdad(fechaNacimiento_Cl)) 
		from CLIENTES 
		where codGen_Cl=(
			select cod_Gen 
			from GENEROS 
			where descripcion_Gen= 'Femenino'))
