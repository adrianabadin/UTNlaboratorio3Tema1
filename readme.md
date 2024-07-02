# UTN Examen Laboratorio3 SQL 
## Tema 1

## Parte 1

1.- Realizar el Diagrama Entidad-Relación, y el Diccionario de Datos del siguiente ejercicio. Se debe normalizar la base de datos de modo que no haya ningún tipo de redundancia de datos.
En la provincia de Salta, la Municipalidad de Cerillos, se encarga de efectuar el cobro correspondiente a la tasa inmobiliaria de las propiedades pertenecientes a los propietarios o contribuyentes que se encuentran en la jurisdicción de dicha Municipalidad.
Cada contribuyente tiene asignado un código alfanumérico el cual es de índole identificatorio, a su vez, se toman otros datos como los siguientes: dni, nombre, apellido, dirección (la que aparece en el dni), localidad, barrio, correo electrónico, y al menos un teléfono para ponerse en contacto por cuestiones referentes al pago del inmueble.
Para los inmuebles, los mismos se identifican por su número catastral (código alfanumérico), y se guardan otros datos identificatorios a saber: dirección, barrio, localidad, zona (urbana, rural nucleada, rural dispersa), tipo de inmueble (edificado, baldío, en obra), superficie (en m2). En la Municipalidad se tienen registros de que un propietario puede tener más de un inmueble registrado a su nombre, y que no existen más de un propietario como titular por terreno o propiedad.
El departamento de Cerillos, cuenta con distintas localidades, y cada una de ellas está conformada por múltiples barrios. Los códigos postales de cada localidad son únicos e irrepetibles dentro de lo que son los límites del mencionado departamento.
La Municipalidad, emite las facturas para todos los contribuyentes con las mismas fechas de vencimiento; existen una primera y una segunda fecha de vencimiento. El pago es mensual, es decir, se emiten 12 facturas por año. El monto de cada factura está relacionado a las características propias de cada inmueble, es decir, queda determinado por el inmueble y dicho monto asciende en un 25% a partir de la segunda fecha de vencimiento. Una vez que los montos han sido establecidos por cada inmueble, los mismos no sufren modificación con el paso de los años. Las fechas correspondientes a los pagos de cada factura no tienen que coincidir necesariamente con las fechas de vencimiento. A su vez, se tienen registros de todos los pagos tanto de los años anteriores como del corriente año.
Al momento de realizar el pago de la/s facturas, se puede cobrar por sistema el total que alcanza la suma de los montos respectivos a cada una de ellas. Sin embargo, la Municipalidad escoge la modalidad de guardar en registros la información correspondiente al pago de cada factura por separado, así como el tipo de pago, que puede ser en efectivo, débito o crédito. Para el pago con tarjeta, solamente se puede realizar en un sólo pago. En situaciones de pago, fuera de término, a modo de disminuir las deudas por mora, la Municipalidad optó por cobrar según el monto correspondiente a la segunda fecha de vencimiento. En el caso de que la factura se abone entre la primera y segunda fecha, el monto a pagar es el correspondiente a la primera fecha.

2.- Creación de una base de datos y tablas
Debe crear una base de datos cuyo nombre será SEGUNDO_PARCIAL_25_06_2024_TEMAX (donde X es el número de tema que le corresponde en su parcial). La mencionada base de datos debe cumplir con los siguientes requisitos:
- Debe crear tres tablas, de las cuales una de ellas debe ser la correspondiente a los propietarios.
- Antes de crear cada tabla, compruebe que éstas no existen en la base de datos.
- En caso de que alguna exista, debe mostrar el siguiente mensaje: “La tabla que quiere crear ya existe” (sin las comillas) con un encabezado llamado Error.
- Por cada tabla debe ingresar dos registros.

![Diagrama entidad relacion](./examen%20parte%201%20tema%201.drawio.png)

## Parte 2

### Consulta 1
- Informar aquellos barrios y sus respectivas localidades, en las cuales no se encuentran registros del domicilio de cada uno de los clientes que están dados de alta en la presente base de datos. Para la resolución de este ejercicio no debe emplear la palabra reservada JOIN, en sus distintas variantes. Los encabezados deben ser los siguientes: Localidad, Barrio, según la columna que corresponda. Debe emplear un procedimiento almacenado. Finalmente, deje la instrucción correspondiente para ejecutarlo. 

```sql
select 
    *,
    (select descripcion_Barr from BARRIOS where codBarrio_Barr=codBarrio_Cl) as barrio, 
    (select descripcion_Loc from LOCALIDADES where codPostal_Loc=codLocalidad_Cl) as localidad 
    from clientes
```


### Consulta 2
- Informar nombre completo, domicilio, barrio, localidad, género y edad al momento de efectuar la consulta de aquellos clientes que tengan registrados el mayor número de teléfonos. Debe emplear un procedimiento almacenado. Como sugerencia para la resolución de este punto, es conveniente añadir un campo adicional en la tabla que le resulte más apropiada a modo de poder llevar adelante la consulta. Ejecute el procedimiento almacenado y posterior a dicha ejecución, la tabla que haya elegido debe quedar con la misma cantidad de campos que al principio. Los encabezados deben ser los siguientes: Cliente, Domicilio, Barrio, Localidad, Género, Edad. NO EMPLEAR FUNCIONES que no se han visto en las clases o encuentros. 

#### Funcion que devuelve la edad a partir de una fecha 
```sql 
create or alter function F_ObtenerEdad
(@fecha date)
returns int
as 
begin
declare 
	@dia int = datepart(day,@fecha),
	@mes int = datepart(MONTH,@fecha), 
	@respuesta int;
set @respuesta = case 
						when datepart(month,getdate()) -@mes =0  and DATEPART(day,getdate()) -@dia <=0 then datepart(year,getdate()) - DATEPART(year,@fecha)
						when datepart(month,getdate()) -@mes >0 then  datepart(year,getdate()) - DATEPART(year,@fecha) -1
						else datepart(year,getdate()) - DATEPART(year,@fecha)
					end
return @respuesta;
end

```
#### Procedimiento almacenado que realiza lo solicitado
```sql
create proc consulta2Tema1
as
select 
    (nombre_Cl+' '+apellido_Cl)as Cliente,
    direccion_Cl as Domicilio, 
    (select descripcion_Barr from BARRIOS where codBarrio_Barr=codBarrio_Cl)as Barrio,
    (select descripcion_Loc from LOCALIDADES where codPostal_Loc=codLocalidad_Cl)as Localidad, 
    (select descripcion_Gen from GENEROS where cod_Gen=codGen_Cl)as Genero,
    dbo.F_ObtenerEdad(fechaNacimiento_Cl) as Edad 
from clientes 
    where dni_Cl in (select top 3 dniCliente_TxC from TELEFONOSxCLIENTES 
    group by dniCliente_TxC 
    order by count(*) desc);
```
### Consulta 3
- Mostrar un listado por medio de un procedimiento almacenado que informe el nombre completo, tiempo trabajo en la empresa y edad de aquellos vendedores que están por entrar al estado pasivo, dado que se encuentran en edad jubilatoria. Tenga en cuenta que para las mujeres es una edad mayor o igual a los 60 años, mientras que para los hombres es a partir de los 65 años. Los encabezados que deben aparecer en la consulta son los siguientes: Vendedor/a, Años Trabajados, Edad en la columna que corresponda. Si le resulta de utilidad añadir algún campo o campos a la tabla que considere pertinente, para resolver este ejercicio, puede hacerlo. Luego de ejecutar el procedimiento almacenado elimine los campos añadidos. NO EMPLEAR funciones que no se han visto en las clases o encuentros. 

```sql
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

```

### Consulta 4
- Crear un procedimiento almacenado que informe el nombre completo, dni, dirección, barrio, localidad, y el mayor número de compras realizadas entre todas las compras, de aquellos hombres que tienen una edad que es igual o superior a la edad promedio de las mujeres. Los hombres y mujeres que se toman en consideración son los clientes que están registrados en la base de datos. Realice cambios a la tabla pertinente a modo de añadir algún campo, si lo considera necesario. Luego de ejecutar el procedimiento almacenado elimine el campo o campos añadidos a la tabla. Los encabezados en el resultado de la consulta, deben ser los siguientes: Cliente, Dni, Dirección, Barrio, Localidad, Total de Compras Realizadas. No EMPLEAR funciones que no fueron dadas en los encuentros.

```sql
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

```

