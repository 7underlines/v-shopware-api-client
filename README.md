# V Shopware 6 admin API client

This is a pure [V](https://vlang.io) module that can be used to communicate with [Shopware 6](https://github.com/shopware/platform).

Requires at least Shopware version 6.4.

Shopware Admin API credentials can be generated in the shopware backend (Settings->System->Integrations).

[Shopware 6 Admin API Endpoint Reference](https://shopware.stoplight.io/docs/admin-api/adminapi.json)

[Shopware 6 Developer Documentation](http://developer.shopware.com/)

I recommend to configure the api credentials via .env - take a look at my [dotenv module](https://github.com/thomaspeissl/vdotenv).

## Features

+ built-in oauth token renewal
+ useful helper functions for file upload and search

## Why V

+ can handle big imports that may take several hours
+ parallel processing
+ errors during compile time

## Installation

### Install and use this module as a dependency via v.mod (recommended)

Run "v init" to auto-generate your v.mod file.
```shell
v init
```
Then edit the dependencies in your v.mod file to look like this: 
```v
dependencies: ['thomaspeissl.shopwareac']
```
And install with:
```shell
v install
```
To update your dependencies later just run "v install" again.

### Or via VPM:
```shell
v install thomaspeissl.shopwareac
```

### Or through Git:
```shell
git clone https://github.com/thomaspeissl/v-shopware-api-client.git ~/.vmodules/thomaspeissl/shopwareac
```

## Running the examples
Fill in your api credentials in the code placeholders an then run.
```shell
cd examples
v run simple.v
v run search.v
```

## Example
This example gets products from the admin api and prints out their product ids.
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
	mut sw_api := shopwareac.Login{ // mut is needed for the automated oauth2 token renewal
		api_url: 'http://localhost:8000/api/'
		client_id: 'XXXXXXXXXXXXXXXXXXXXXXXXXX' // get this from Shopware 6 backend Settings->System->Integrations
		client_secret: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
	}
	response := sw_api.get('product?limit=1')
	response_data := json.decode(ShopResponse, response) or { ShopResponse{} }
	for product in response_data.data {
		println(product.id)
	}
}
```

# Module documentation

## Contents
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
current time formatted for Shopware date time custom fields eg. "2022-01-16T12:00:00+00:00"

[[Return to contents]](#Contents)

## decode
```v
fn decode(data string) map[string]json2.Any
```


[[Return to contents]](#Contents)

## encode
```v
fn encode(s string) string
```
Percent-encoding reserved characters eg. for filter parameters

[[Return to contents]](#Contents)

## strip
```v
fn strip(s string) string
```
strip not allowed chars

[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

## ConfiguratorSetting
```v
struct ConfiguratorSetting {
pub mut:
	id        string @[omitempty]
	option_id string @[json: 'optionId'; omitempty]
}
```


[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

## Id
```v
struct Id {
pub mut:
	id string @[omitempty]
}
```


[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

## add_media_to_product
```v
fn (mut l Login) add_media_to_product(media_id string, product_id string, set_as_cover bool, position int)
```
add_media_to_product position should begin with 0

[[Return to contents]](#Contents)

## auth
```v
fn (mut l Login) auth() bool
```
auth get's called automatic and renews the oauth token if needed

[[Return to contents]](#Contents)

## delete
```v
fn (mut l Login) delete(endpoint string, id string)
```


[[Return to contents]](#Contents)

## find_category_by_customfield
```v
fn (mut l Login) find_category_by_customfield(field string, value string) !ShopResponseData
```


[[Return to contents]](#Contents)

## find_media_by_name
```v
fn (mut l Login) find_media_by_name(name string) !ShopResponseData
```


[[Return to contents]](#Contents)

## find_product_by_customfield
```v
fn (mut l Login) find_product_by_customfield(field string, value string) !ShopResponseData
```


[[Return to contents]](#Contents)

## find_product_by_productnumber
```v
fn (mut l Login) find_product_by_productnumber(productnumber string) !ShopResponseData
```


[[Return to contents]](#Contents)

## find_property_by_name
```v
fn (mut l Login) find_property_by_name(name string, group string) !ShopResponseData
```


[[Return to contents]](#Contents)

## find_subcategory_by_name
```v
fn (mut l Login) find_subcategory_by_name(name string, parent string) !ShopResponseData
```


[[Return to contents]](#Contents)

## get
```v
fn (mut l Login) get(endpoint string) string
```


[[Return to contents]](#Contents)

## get_default_category
```v
fn (mut l Login) get_default_category() string
```


[[Return to contents]](#Contents)

## get_default_cms_page
```v
fn (mut l Login) get_default_cms_page() string
```


[[Return to contents]](#Contents)

## get_default_media_folder
```v
fn (mut l Login) get_default_media_folder() string
```


[[Return to contents]](#Contents)

## get_default_payment_method
```v
fn (mut l Login) get_default_payment_method() string
```


[[Return to contents]](#Contents)

## get_default_sales_channel
```v
fn (mut l Login) get_default_sales_channel() string
```


[[Return to contents]](#Contents)

## get_default_tax
```v
fn (mut l Login) get_default_tax() string
```


[[Return to contents]](#Contents)

## get_last_sync
```v
fn (mut l Login) get_last_sync() string
```
get_last_sync returns the last sync payload

[[Return to contents]](#Contents)

## get_raw
```v
fn (mut l Login) get_raw(endpoint string) http.Response
```


[[Return to contents]](#Contents)

## patch
```v
fn (mut l Login) patch(endpoint string, data string)
```


[[Return to contents]](#Contents)

## post
```v
fn (mut l Login) post(endpoint string, data string) string
```
post returns the id of the created content on success

[[Return to contents]](#Contents)

## resend_sync
```v
fn (mut l Login) resend_sync()
```
resend_sync sends the last sync operation (sync saves data into a file) again to the shop api - useful for debugging or temporary errors

[[Return to contents]](#Contents)

## search
```v
fn (mut l Login) search(entity string, data string) string
```


[[Return to contents]](#Contents)

## sync
```v
fn (mut l Login) sync(data string) !string
```
sync API is an add-on to the Admin API that allows you to perform multiple write operations (creating/updating and deleting) simultaneously

[[Return to contents]](#Contents)

## sync_delete
```v
fn (mut l Login) sync_delete(entity string, data []string)
```
sync_delete is a shorthand function for sync with data chunking for large arrays

[[Return to contents]](#Contents)

## sync_upsert
```v
fn (mut l Login) sync_upsert(entity string, data []string)
```
sync_upsert is a shorthand function for sync with data chunking for large arrays

[[Return to contents]](#Contents)

## update_media_from_url
```v
fn (mut l Login) update_media_from_url(media_id string, url string)
```
Attach resource data to the media object from the given url

[[Return to contents]](#Contents)

## upload
```v
fn (mut l Login) upload(file_url string, name string, media_folder_id string) !string
```
upload returns the mediaId of the uploaded file on success

[[Return to contents]](#Contents)

## upload_file
```v
fn (mut l Login) upload_file(media_id string, name string, _ext string, data string) !
```
upload_file via binary blob

[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

## Media
```v
struct Media {
pub:
	id              string @[omitempty]
	media_folder_id string @[json: 'mediaFolderId'; omitempty]
}
```


[[Return to contents]](#Contents)

## Option_
```v
struct Option_ { // Option is a reserved word
pub mut:
	id       string @[omitempty]
	name     string @[omitempty]
	group_id string @[json: 'groupId'; omitempty]
}
```


[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

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


[[Return to contents]](#Contents)

## ProductMedia
```v
struct ProductMedia {
pub mut:
	id       string
	position int
	media    Media
}
```


[[Return to contents]](#Contents)

## PropertyGroup
```v
struct PropertyGroup {
pub mut:
	id   string @[omitempty]
	name string @[omitempty]
}
```


[[Return to contents]](#Contents)

## ShopResponseData
```v
struct ShopResponseData {
pub:
	id         string
	attributes Attributes
}
```


[[Return to contents]](#Contents)

## Tax
```v
struct Tax {
pub mut:
	id       string @[omitempty]
	name     string @[omitempty]
	tax_rate ?f64   @[json: 'taxRate'; omitempty]
}
```


[[Return to contents]](#Contents)

## Unit
```v
struct Unit {
pub mut:
	id         string
	name       string @[omitempty]
	short_code string @[json: 'shortCode'; omitempty]
}
```


[[Return to contents]](#Contents)

## Visibility
```v
struct Visibility {
pub mut:
	id               string @[omitempty]
	sales_channel_id string @[json: 'salesChannelId'; omitempty]
	visibility       int = 30    @[omitempty]
}
```


[[Return to contents]](#Contents)

#### Powered by vdoc. Generated on: 28 Nov 2023 11:52:49



```bash
v doc -f md .
```

## License
[AGPL-3.0](LICENSE)
