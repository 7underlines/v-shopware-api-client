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
- [encode](#encode)
- [strip](#strip)
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
- [ShopResponseData](#ShopResponseData)

## date_time
```v
fn date_time() string
```

current time formatted for Shopware date time custom fields eg. "2022-01-16T12:00:00+00:00"

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

## ShopResponseData
```v
struct ShopResponseData {
pub:
	id         string
	attributes Attributes
}
```


[[Return to contents]](#Contents)

#### Powered by vdoc. Generated on: 14 Mar 2023 12:37:36



```bash
v doc -f md .
```

## License
[AGPL-3.0](LICENSE)
