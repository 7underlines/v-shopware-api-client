# module shopwareac

## Contents
- [encode](#encode)
- [strip](#strip)
- [Login](#Login)
  - [upload](#upload)
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
  - [add_media_to_product](#add_media_to_product)
- [ShopResponseData](#ShopResponseData)

## encode
```v
fn encode(s string) string
```


[[Return to contents]](#Contents)

## strip
```v
fn strip(s string) string
```


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

## upload
```v
fn (mut l Login) upload(file_url string, name string, media_folder_id string) ?string
```


[[Return to contents]](#Contents)

## auth
```v
fn (mut l Login) auth()
```


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


[[Return to contents]](#Contents)

## add_media_to_product
```v
fn (mut l Login) add_media_to_product(media_id string, product_id string, set_as_cover bool, position int)
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

#### Powered by vdoc. Generated on: 11 May 2021 20:48:49
