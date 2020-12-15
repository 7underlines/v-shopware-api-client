# V Shopware API client

This is a pure V module that can be used to communicate with the [Shopware 6 API](https://github.com/shopware/platform).

Shopware API credentials can be generated in the shopware backend (Settings->System->Integrations).

[Shopware 6 API Docs](https://docs.shopware.com/en/shopware-platform-dev-en/api)

## Usage:
```shell
v install logtom.shopware
```
... then in your v source:
```v
module main

import logtom.shopware

struct ShopResponse {
	data []ShopResponseData
}
struct ShopResponseData {
	id string
}

fn main(){
    mut conn := shopware.Login{
		api_url: 'http://localhost:8000/api/'
		client_id: 'xxx'
		client_secret: 'xxxxxx'
	}
	response := conn.get('product')}
	response_data := json.decode(ShopResponse,response) or {
		println("can't decode shop response")
		exit(1)
	}
	for product in response_data.data {
		println(product.id)
	}
}
```

## License
[GPL-3.0](LICENSE)
