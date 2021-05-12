# V Shopware API client

This is a pure [V](https://vlang.io) module that can be used to communicate with the [Shopware 6 API](https://github.com/shopware/platform).

Requires at least shopware 6.4.

Shopware API credentials can be generated in the shopware backend (Settings->System->Integrations).

[Shopware 6 API Docs](https://docs.shopware.com/en/shopware-platform-dev-en/api)

## Features

+ built-in oauth token renewal
+ useful helper functions for file upload and search

## Why V and not PHP

+ big imports can take several days
+ parallel processing
+ easy to learn
+ errors during compile time

## Installation
```shell
v install treffner.shopwareac
```

## Running the example
```shell
cd examples
v run simple.v
```

## Usage:
In your v source:
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

## License
[GPL-3.0](LICENSE)
