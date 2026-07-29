# Cliente de la API de administración de Shopware 6 para V

Este es un módulo puro de [V](https://vlang.io) que puede utilizarse para comunicarse con [Shopware 6](https://github.com/shopware/platform).

**Importante**: Funciones como `sync_upsert()` realizarán varias llamadas a la API. V incluye una versión de mbedtls que lanzará errores como `response does not start with HTTP/` si la API no responde inmediatamente. Para solucionar esto, compile siempre utilizando `-d use_openssl`. [V OpenSSL](https://github.com/vlang/v?tab=readme-ov-file#v-nethttp-netwebsocket-v-install)

```sh
v -d use_openssl run .
v -d use_openssl .
```

Requiere al menos la versión 6.4 de Shopware.

Las credenciales de la Admin API de Shopware se pueden generar en el backend de Shopware (Settings->System->Integrations).

[Referencia del Endpoint de la Admin API de Shopware 6](https://shopware.stoplight.io/docs/admin-api/adminapi.json)

[Documentación para desarrolladores de Shopware 6](http://developer.shopware.com/)

Recomiendo configurar las credenciales de la API a través de .env; eche un vistazo a mi [módulo dotenv](https://github.com/thomaspeissl/vdotenv).

## Características

+ Renovación integrada de tokens oauth
+ Funciones auxiliares útiles para la carga de archivos y búsquedas

## Por qué V

+ Puede manejar importaciones grandes que pueden tardar varias horas
+ Procesamiento paralelo
+ Errores durante el tiempo de compilación

## Instalación

### Instalar y usar este módulo como dependencia vía v.mod (recomendado)

Ejecute "v init" para generar automáticamente su archivo v.mod.
```shell
v init
```
Luego, edite las dependencias en su archivo v.mod para que se vean así: 
```v
dependencies: ['thomaspeissl.shopwareac']
```
E instale con:
```shell
v install
```
Para actualizar sus dependencias más tarde, simplemente ejecute "v install" nuevamente.

### O vía VPM:
```shell
v install thomaspeissl.shopwareac
```

### O a través de Git:
```shell
git clone https://github.com/thomaspeissl/v-shopware-api-client.git ~/.vmodules/thomaspeissl/shopwareac
```

## Ejecución de los ejemplos
Complete sus credenciales de API en los marcadores de posición del código y luego ejecute.
```shell
cd examples
v run simple.v
v run search.v
```

## Ejemplo
Este ejemplo obtiene productos de la API de administración e imprime sus IDs de producto.
```v
module main

import thomaspeissl.shopwareac
import json

struct ShopResponse {
	data []ShopResponseData
}
struct ShopResponseData {
	id string
}

fn main() {
	mut sw_api := shopwareac.Login{ // se requiere mut para la renovación automática del token oauth2
		api_url: 'http://localhost:8000/api/'
		client_id: 'XXXXXXXXXXXXXXXXXXXXXXXXXX' // obtenga esto del backend de Shopware 6 Settings->System->Integrations
		client_secret: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
	}
	response := sw_api.get('product?limit=1')
	response_data := json.decode(ShopResponse, response) or { ShopResponse{} }
	for product in response_data.data {
		println(product.id)
	}
}
```

# Documentación del módulo

## Contenido
- [date_time](#date_time)
- [decode](#decode)
- [encode](#encode)
- [strip](#strip)
- [Attributes](#Attributes)
- [Category](#Category)
- [ConfiguratorSetting](#ConfiguratorSetting)
- [CustomField](#CustomField)
- [Id](#Id)
- [Login](#Login)
  - [add_media_to_product](#add_media_to_product)
  - [auth](#auth)
  - [delete](#delete)
  - [find_category_by_customfield](#find_category_by_customfield)
  - [find_media_by_name](#find_media_by_name)
  - [find_product_by_customfield](#find_product_by_customfield)
  - [find_product_by_productnumber](#find_product_by_productnumber)
  - [find_property_by_name](#find_property_by_name)
  - [find_subcategory_by_name](#find_subcategory_by_name)
  - [get](#get)
  - [get_default_category](#get_default_category)
  - [get_default_cms_page](#get_default_cms_page)
  - [get_default_media_folder](#get_default_media_folder)
  - [get_default_payment_method](#get_default_payment_method)
  - [get_default_sales_channel](#get_default_sales_channel)
  - [get_default_tax](#get_default_tax)
  - [get_last_sync](#get_last_sync)
  - [get_raw](#get_raw)
  - [patch](#patch)
  - [post](#post)
  - [resend_sync](#resend_sync)
  - [search](#search)
  - [sync](#sync)
  - [sync_delete](#sync_delete)
  - [sync_upsert](#sync_upsert)
  - [update_media_from_url](#update_media_from_url)
  - [upload](#upload)
  - [upload_file](#upload_file)
- [Manufacturer](#Manufacturer)
- [Media](#Media)
- [Option_](#Option_)
- [Price](#Price)
- [Product](#Product)
- [ProductMedia](#ProductMedia)
- [PropertyGroup](#PropertyGroup)
- [ShopResponseData](#ShopResponseData)
- [Tax](#Tax)
- [Unit](#Unit)
- [Visibility](#Visibility)

## date_time
```v
fn date_time() string
```
Hora actual formateada para los campos personalizados de fecha y hora de Shopware, ej. "2022-01-16T12:00:00+00:00"

[[Volver al contenido]](#Contenido)

## decode
```v
fn decode(data string) map[string]json2.Any
```


[[Volver al contenido]](#Contenido)

## encode
```v
fn encode(s string) string
```
Codificación percentual de caracteres reservados, ej. para parámetros de filtro

[[Volver al contenido]](#Contenido)

## strip
```v
fn strip(s string) string
```
Elimina caracteres no permitidos

[[Volver al contenido]](#Contenido)

## Attributes
```v
struct Attributes {
pub:
	media_id               string            @[json: mediaId]
	cover_id               string            @[json: coverId]
	child_count            int               @[json: childCount]
	stock                  int
	custom_fields          map[string]string @[json: customFields]
	active                 bool
	product_number         string            @[json: productNumber]
	custom_search_keywords []string          @[json: customSearchKeywords]
	payment_method_id      string            @[json: paymentMethodId]
	name                   string
	parent_id              string            @[json: parentId]
	cms_page_id            string            @[json: cmsPageId]
}
```


[[Volver al contenido]](#Contenido)

## Category
```v
struct Category {
pub mut:
	id          string
	name        string @[omitempty]
	parent_id   string @[json: parentId; omitempty]
	cms_page_id string @[json: cmsPageId]
}
```


[[Volver al contenido]](#Contenido)

## ConfiguratorSetting
```v
struct ConfiguratorSetting {
pub mut:
	id        string @[omitempty]
	option_id string @[json: 'optionId'; omitempty]
}
```


[[Volver al contenido]](#Contenido)

## CustomField
```v
struct CustomField {
pub mut:
	custom_import_field1 string @[omitempty]
	custom_import_field2 string @[omitempty]
	custom_import_field3 string @[omitempty]
	custom_import_field4 string @[omitempty]
	custom_import_field5 string @[omitempty]
	custom_import_field6 string @[omitempty]
	custom_import_field7 string @[omitempty]
	custom_import_field8 string @[omitempty]
	custom_import_field9 string @[omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Id
```v
struct Id {
pub mut:
	id string @[omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Login
```v
struct Login {
mut:
	token AuthToken
pub:
	client_id     string
	client_secret string
pub mut:
	api_url string
}
```


[[Volver al contenido]](#Contenido)

## add_media_to_product
```v
fn (mut l Login) add_media_to_product(media_id string, product_id string, set_as_cover bool, position int)
```
La posición de `add_media_to_product` debe comenzar con 0

[[Volver al contenido]](#Contenido)

## auth
```v
fn (mut l Login) auth() bool
```
`auth` se llama automáticamente y renueva el token oauth si es necesario

[[Volver al contenido]](#Contenido)

## delete
```v
fn (mut l Login) delete(endpoint string, id string)
```


[[Volver al contenido]](#Contenido)

## find_category_by_customfield
```v
fn (mut l Login) find_category_by_customfield(field string, value string) !ShopResponseData
```


[[Volver al contenido]](#Contenido)

## find_media_by_name
```v
fn (mut l Login) find_media_by_name(name string) !ShopResponseData
```


[[Volver al contenido]](#Contenido)

## find_product_by_customfield
```v
fn (mut l Login) find_product_by_customfield(field string, value string) !ShopResponseData
```


[[Volver al contenido]](#Contenido)

## find_product_by_productnumber
```v
fn (mut l Login) find_product_by_productnumber(productnumber string) !ShopResponseData
```


[[Volver al contenido]](#Contenido)

## find_property_by_name
```v
fn (mut l Login) find_property_by_name(name string, group string) !ShopResponseData
```


[[Volver al contenido]](#Contenido)

## find_subcategory_by_name
```v
fn (mut l Login) find_subcategory_by_name(name string, parent string) !ShopResponseData
```


[[Volver al contenido]](#Contenido)

## get
```v
fn (mut l Login) get(endpoint string) string
```


[[Volver al contenido]](#Contenido)

## get_default_category
```v
fn (mut l Login) get_default_category() string
```


[[Volver al contenido]](#Contenido)

## get_default_cms_page
```v
fn (mut l Login) get_default_cms_page() string
```


[[Volver al contenido]](#Contenido)

## get_default_media_folder
```v
fn (mut l Login) get_default_media_folder() string
```


[[Volver al contenido]](#Contenido)

## get_default_payment_method
```v
fn (mut l Login) get_default_payment_method() string
```


[[Volver al contenido]](#Contenido)

## get_default_sales_channel
```v
fn (mut l Login) get_default_sales_channel() string
```


[[Volver al contenido]](#Contenido)

## get_default_tax
```v
fn (mut l Login) get_default_tax() string
```


[[Volver al contenido]](#Contenido)

## get_last_sync
```v
fn (mut l Login) get_last_sync() string
```
`get_last_sync` devuelve el payload de la última sincronización

[[Volver al contenido]](#Contenido)

## get_raw
```v
fn (mut l Login) get_raw(endpoint string) http.Response
```


[[Volver al contenido]](#Contenido)

## patch
```v
fn (mut l Login) patch(endpoint string, data string)
```


[[Volver al contenido]](#Contenido)

## post
```v
fn (mut l Login) post(endpoint string, data string) string
```
`post` devuelve el ID del contenido creado en caso de éxito

[[Volver al contenido]](#Contenido)

## resend_sync
```v
fn (mut l Login) resend_sync()
```
`resend_sync` envía nuevamente la última operación de sincronización (sync guarda los datos en un archivo) a la API de la tienda; útil para depuración o errores temporales

[[Volver al contenido]](#Contenido)

## search
```v
fn (mut l Login) search(entity string, data string) string
```


[[Volver al contenido]](#Contenido)

## sync
```v
fn (mut l Login) sync(data string) !string
```
La API `sync` es un complemento de la Admin API que permite realizar múltiples operaciones de escritura (creación/actualización y eliminación) simultáneamente

[[Volver al contenido]](#Contenido)

## sync_delete
```v
fn (mut l Login) sync_delete(entity string, data []string)
```
`sync_delete` es una función abreviada para sync con fragmentación de datos para matrices grandes

[[Volver al contenido]](#Contenido)

## sync_upsert
```v
fn (mut l Login) sync_upsert(entity string, data []string)
```
`sync_upsert` es una función abreviada para sync con fragmentación de datos para matrices grandes

[[Volver al contenido]](#Contenido)

## update_media_from_url
```v
fn (mut l Login) update_media_from_url(media_id string, url string)
```
Adjunta los datos del recurso al objeto de medios desde la URL proporcionada

[[Volver al contenido]](#Contenido)

## upload
```v
fn (mut l Login) upload(file_url string, name string, media_folder_id string) !string
```
`upload` devuelve el mediaId del archivo cargado en caso de éxito

[[Volver al contenido]](#Contenido)

## upload_file
```v
fn (mut l Login) upload_file(media_id string, name string, _ext string, data string) !
```
`upload_file` mediante un blob binario

[[Volver al contenido]](#Contenido)

## Manufacturer
```v
struct Manufacturer {
pub mut:
	id          string
	name        string @[omitempty]
	link        string @[omitempty]
	description string @[omitempty]
	media       Media  @[omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Media
```v
struct Media {
pub:
	id              string @[omitempty]
	media_folder_id string @[json: 'mediaFolderId'; omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Option_
```v
struct Option_ { // Option es una palabra reservada
pub mut:
	id       string @[omitempty]
	name     string @[omitempty]
	group_id string @[json: 'groupId'; omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Price
```v
struct Price {
pub mut:
	net         f64
	gross       f64
	currency_id string = 'b7d2554b0ce847cd82f3ac9bd1c0dfca' @[json: 'currencyId']
	linked      bool = true
}
```


[[Volver al contenido]](#Contenido)

## Product
```v
struct Product {
pub mut:
	id                     string
	name                   string                @[omitempty]
	stock                  ?int                  @[omitempty]
	product_number         string                @[json: 'productNumber'; omitempty]
	description            string                @[omitempty]
	manufacturer           Id                    @[omitempty]
	categories             []Id                  @[omitempty]
	visibilities           []Visibility          @[omitempty]
	tax_id                 string                @[json: 'taxId'; omitempty]
	keywords               string                @[omitempty]
	custom_search_keywords []string              @[json: 'customSearchKeywords'; omitempty]
	options                []Option_             @[omitempty]
	weight                 int                   @[omitempty]
	price                  []Price               @[omitempty]
	cover_id               string                @[json: 'coverId'; omitempty]
	unit_id                string                @[json: 'unitId'; omitempty]
	media                  []ProductMedia        @[omitempty]
	custom_fields          CustomField           @[json: 'customFields'; omitempty]
	ean                    string                @[omitempty]
	meta_title             string                @[json: 'metaTitle'; omitempty]
	meta_description       string                @[json: 'metaDescription'; omitempty]
	parent_id              string                @[json: 'parentId'; omitempty]
	reference_unit         f64                   @[json: 'referenceUnit'; omitempty]
	purchase_unit          f64                   @[json: 'purchaseUnit'; omitempty]
	max_purchase           int                   @[json: 'maxPurchase'; omitempty]
	configurator_settings  []ConfiguratorSetting @[json: 'configuratorSettings'; omitempty]
}
```


[[Volver al contenido]](#Contenido)

## ProductMedia
```v
struct ProductMedia {
pub mut:
	id       string
	position int
	media    Media
}
```


[[Volver al contenido]](#Contenido)

## PropertyGroup
```v
struct PropertyGroup {
pub mut:
	id   string @[omitempty]
	name string @[omitempty]
}
```


[[Volver al contenido]](#Contenido)

## ShopResponseData
```v
struct ShopResponseData {
pub:
	id         string
	attributes Attributes
}
```


[[Volver al contenido]](#Contenido)

## Tax
```v
struct Tax {
pub mut:
	id       string @[omitempty]
	name     string @[omitempty]
	tax_rate ?f64   @[json: 'taxRate'; omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Unit
```v
struct Unit {
pub mut:
	id         string
	name       string @[omitempty]
	short_code string @[json: 'shortCode'; omitempty]
}
```


[[Volver al contenido]](#Contenido)

## Visibility
```v
struct Visibility {
pub mut:
	id               string @[omitempty]
	sales_channel_id string @[json: 'salesChannelId'; omitempty]
	visibility       int = 30    @[omitempty]
}
```


[[Volver al contenido]](#Contenido)

#### Impulsado por vdoc. Generado el: 28 Nov 2023 11:52:49



```bash
v doc -f md .
```

## Licencia
[AGPL-3.0](LICENSE)
