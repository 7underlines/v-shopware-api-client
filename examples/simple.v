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
	products_response_raw := sw_api.get('product?limit=1')
	products_response := json.decode(ShopResponse, products_response_raw) or {
		println('Failed to decode products json')
		exit(1)
	}
	for product in products_response.data {
		println(product.id)
	}
}
