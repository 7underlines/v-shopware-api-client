module shopware

const (
	accept_all           = '*/*'
	default_content_type = 'application/json'
)

struct LoginShop {
	grant_type    string = 'client_credentials'
	client_id     string
	client_secret string
}

pub struct Login {
mut:
	token         AuthToken
pub:
	api_url       string
	client_id     string
	client_secret string
}

struct AuthToken {
mut:
	access_token string
	expires_in   int
	request_at   int
	valid_until  int
}

struct ShopResponseFind {
	meta ShopResponseMeta
pub:
	data []ShopResponseData
}

struct ShopResponse {
	errors []ErrorDetail
	data   []ShopResponseData
	d      ShopResponseData   [json: data]
	meta   ShopResponseMeta
}

struct ShopResponseSingle {
	data ShopResponseData
}

struct ShopResponseError {
	errors []ErrorDetail
}

pub struct ShopResponseData {
pub:
	id         string
	attributes Attributes
}

struct Attributes {
	media_id    string [json: mediaId]
pub:
	child_count int    [json: childCount]
	stock       int
}

struct ErrorDetail {
	status string
	code   string
	detail string
	title  string
}

struct ShopResponseMeta {
	total int
}
