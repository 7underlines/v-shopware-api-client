module shopwareac

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
	token AuthToken
pub:
	client_id     string
	client_secret string
pub mut:
	api_url string
}

struct AuthToken {
mut:
	access_token string
	expires_in   int
	request_at   i64
	valid_until  i64
}

struct ShopResponseFind {
	meta ShopResponseMeta
pub:
	data []ShopResponseData
}

struct ShopResponse {
pub:
	errors []ErrorDetail
	data   []ShopResponseData
	d      ShopResponseData   [json: data]
	meta   ShopResponseMeta
}

struct ShopResponseSingle {
pub:
	data ShopResponseData
}

struct ShopResponseError {
	errors []ErrorDetail
}

struct ShopResponseSyncError {
	errors []SyncErrorDetail
}

pub struct ShopResponseData {
pub:
	id         string
	attributes Attributes
}

struct Attributes {
pub:
	media_id               string            [json: mediaId]
	cover_id               string            [json: coverId]
	child_count            int               [json: childCount]
	stock                  int
	custom_fields          map[string]string [json: customFields]
	active                 bool
	product_number         string            [json: productNumber]
	custom_search_keywords []string          [json: customSearchKeywords]
	payment_method_id      string            [json: paymentMethodId]
}

struct ErrorDetail {
	status string
	code   string
	detail string
	title  string
}

struct SyncErrorDetail {
	status string
	code   string
	detail string
	title  string
	// source map[string]string
	source ErrorDetailSource
	meta   SyncErrorDetailMeta
}

struct SyncErrorDetailMeta {
	parameters map[string]string
}

struct ErrorDetailSource {
	pointer string
}

struct ShopResponseMeta {
	total int
}

struct SyncPayload {
	payload []map[string]string
}

pub struct Category {
	id string
	name string
	parent_id string [json: parentId]
	cms_page_id string [json: cmsPageId]
}
