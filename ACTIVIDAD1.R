
# El siguiente origen de datos es Open Data o Big Data --------------------
'''
https://geoportalgasolineras.es/geoportal-instalaciones/DescargarFicheros
Este origen de datos es Open datas ya que tienes permisos expresos del dueño, 
en este caso, el gobierno. Nos cede datos para su descarga y uso. Especifica que 
se permite su uso, citando al autor de los datos.
'''

# Obtenga los datos de forma remota y léalos en el estudio ----------------
#através de una petición mediante la API accedemos (tidyverse y json)

#1.Instalar API
install.packages('tidyverse', 'jsonlite', 'janitor')
install.packages('janitor')

#2.Cargar librerias
library(tidyverse)
library(jsonlite)
library(dplyr)
library(janitor)

#3.Extraer datos de fuente
fromJSON("https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/")
?fromJson
ds <- fromJSON("https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/")

#4.EDA ---------------------------------------------------------------------
view(ds)
ds %>% view()

ds_chicha <- ds$ListaEESSPrecio %>% view
'''
Los datos contienen espacios, acentos, símbolos y carácteres extraños, 
los numericos deberian ser reales o integer y no char
Por ello se procede a limpiar los datos
'''

#5. Limpieza de datos -------------------------------------------------------

ds_cleaned <- ds_chicha %>% janitor::clean_names() %>% as_tibble() %>% glimpse()


#6. Comprobar que esta haciendo nuestro ordenador ---------------------------
'''
Hay algo raro, todas las variables salen como CHAR y otras cosas nos hacen sospechar
que algo va mal. Utilizamos "locale()" para acceder a info al respecto
'''
locale()
'''
Nos da información como numbers, formatos, timezone y tipos de codificación. 
Tenemos que comprobar que tipo de codificación u otros parámetros utiliza el dataset

Por ejemplo, utiliza , para los digitos y . para los decimales que no coincide con nuestro 
formato en España
'''
locale(decimal_mark=",")
ds_cleaned_num <- type.convert(ds_cleaned, locale = locale(decimal_mark)=",")) %>% glimpse()

ds_cleaned_num %>% select(precio_gasoleo_a, rotulo, direccion, localidad) %>%
  filter(localidad =="ALCOBENDAS") %>% arrange(precio_gasoleo_a) %>% arrange(precio_gasoleo_a) %>% View

#8. Actualizar Datos cada 30 minutos -------------------------------------------------------------------------


install.packages("cronR")
library(cronR)

update_data <- function() {
  # Aquí colocas el código para actualizar la fuente de datos externa
  # Por ejemplo, podrías leer la fuente de datos, procesarla y guardarla en un objeto en R.
  # replace_this_with_actual_code()
  print("https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/")
}

# La tarea se programará para ejecutarse cada 30 minutos
task <- cronR::cron_r("* */30 * * *", update_data)

#Iniciar servidor
cronR::cron_start()

#si te sale codigo 400 es que algo estas haciendo mal o tu entorno, si es 200 es que ha cogido tu comanda, si es 500 es que su servidor esta caido