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

pub struct Attributes {
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
	name                   string
	parent_id              string            [json: parentId]
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
	id          string
	name        string [omitempty]
	parent_id   string [json: parentId; omitempty]
	cms_page_id string [json: cmsPageId]
}

pub struct Manufacturer {
	id   string
	name string [omitempty]
	link string [omitempty]
}

pub struct Product {
pub:
	id                     string
	name                   string         [omitempty]
	stock                  int            [omitempty]
	product_number         string         [json: 'productNumber'; omitempty]
	description            string         [omitempty]
	manufacturer           Id             [omitempty]
	categories             []Id           [omitempty]
	visibilities           []Visibilities [omitempty]
	tax_id                 string         [json: 'taxId'; omitempty]
	keywords               string         [omitempty]
	custom_search_keywords []string       [json: 'customSearchKeywords'; omitempty]
	options                []Options      [omitempty]
	weight                 int            [omitempty]
	price                  []Price        [omitempty]
	cover_id               string         [json: 'coverId'; omitempty]
	media                  []Media        [omitempty]
	custom_fields          CustomFields   [json: 'customFields'; omitempty]
	ean                    string         [omitempty]
	max_purchase           int            [json: 'maxPurchase'; omitempty]
}

pub struct Id {
	id string [omitempty]
}

struct Visibilities {
	id               string [omitempty]
	sales_channel_id string [json: 'salesChannelId'; omitempty]
	visibility       int    [omitempty]
}

struct Options {
	id       string [omitempty]
	name     string [omitempty]
	group_id string [json: 'groupId'; omitempty]
}

pub struct Price {
	net         f64
	gross       f64
	currency_id string [json: 'currencyId'] = 'b7d2554b0ce847cd82f3ac9bd1c0dfca'
	linked      bool = true
}

struct Media {
	id              string [omitempty]
	media_folder_id string [json: 'mediaFolderId'; omitempty]
}

struct CustomFields {
	customfields_import string [omitempty]
}
