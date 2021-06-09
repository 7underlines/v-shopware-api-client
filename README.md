# V Shopware 6 admin API client

This is a pure [V](https://vlang.io) module that can be used to communicate with [Shopware 6](https://github.com/shopware/platform).

Requires at least shopware 6.4.

Shopware Admin API credentials can be generated in the shopware backend (Settings->System->Integrations).

[Shopware 6 Admin API Docs](https://developer.shopware.com/docs/guides/integrations-api/admin-api)

I recommend to configure the api credentials via .env - take a look at my [dotenv module](https://github.com/treffner/vdotenv).

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
dependencies: ['treffner.shopwareac']
```
And install with:
```shell
v install
```
To update your dependencies later just run "v install" again.

### Or via VPM:
```shell
v install treffner.shopwareac
```

### Or through Git:
```shell
git clone https://github.com/treffner/v-shopware-api-client.git ~/.vmodules/treffner/shopwareac
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

import treffner.shopwareac
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
	response := sw_api.get('product')
	response_data := json.decode(ShopResponse, response) or {
		println('Failed decode shop response')
		exit(1)
	}
	for product in response_data.data {
		println(product.id)
	}
}
```

# Module documentation

## Contents
- [encode](#encode)
- [strip](#strip)
- [Login](#Login)
  - [add_media_to_product](#add_media_to_product)
  - [auth](#auth)
  - [delete](#delete)
  - [find_media_by_name](#find_media_by_name)
  - [find_product_by_customfield](#find_product_by_customfield)
  - [find_product_by_productnumber](#find_product_by_productnumber)
  - [find_property_by_name](#find_property_by_name)
  - [find_subcategory_by_name](#find_subcategory_by_name)
  - [get](#get)
  - [get_raw](#get_raw)
  - [patch](#patch)
  - [post](#post)
  - [upload](#upload)
- [ShopResponseData](#ShopResponseData)

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
	api_url       string
	client_id     string
	client_secret string
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
fn (mut l Login) auth()
```
 auth get's called automatic and renews the oauth token if needed 

[[Return to contents]](#Contents)

## delete
```v
fn (mut l Login) delete(endpoint string, id string)
```


[[Return to contents]](#Contents)

## find_media_by_name
```v
fn (mut l Login) find_media_by_name(name string) ?ShopResponseData
```


[[Return to contents]](#Contents)

## find_product_by_customfield
```v
fn (mut l Login) find_product_by_customfield(field string, value string) ?ShopResponseData
```


[[Return to contents]](#Contents)

## find_product_by_productnumber
```v
fn (mut l Login) find_product_by_productnumber(productnumber string) ?ShopResponseData
```


[[Return to contents]](#Contents)

## find_property_by_name
```v
fn (mut l Login) find_property_by_name(name string, group string) ?ShopResponseData
```


[[Return to contents]](#Contents)

## find_subcategory_by_name
```v
fn (mut l Login) find_subcategory_by_name(name string, parent string) ?ShopResponseData
```


[[Return to contents]](#Contents)

## get
```v
fn (mut l Login) get(endpoint string) string
```


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

## upload
```v
fn (mut l Login) upload(file_url string, name string, media_folder_id string) ?string
```
 upload returns the mediaId of the uploaded file on success 

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

#### Powered by vdoc. Generated on: 12 May 2021 10:49:16


## License
[AGPL-3.0](LICENSE)
