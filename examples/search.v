import thomaspeissl.shopwareac

fn main() {
	mut sw_api := shopwareac.Login{ // mut is needed for the automated oauth2 token renewal
		api_url:       'http://localhost:8000/api/'
		client_id:     'XXXXXXXXXXXXXXXXXXXXXXXXXX' // get this from Shopware 6 backend Settings->System->Integrations
		client_secret: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
	}
	response := sw_api.find_product_by_productnumber('SW10000') or { // SW10000 is the default shopware productnumber of the first manually created product
		shopwareac.ShopResponseData{}
	}
	println(response.id) // should print the product id eg. e1b77454d0174f438b3b4b9e01bd6164
}
