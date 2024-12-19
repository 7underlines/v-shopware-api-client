module shopwareac

const accept_all = '*/*'
const default_content_type = 'application/json'

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
	api_url     string = 'localhost'
	inheritance bool
	language_id string
	version_id  string
	currency_id string
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
	errors   []ErrorDetail
	data     []ShopResponseData
	d        ShopResponseData @[json: data]
	meta     ShopResponseMeta
	included []ShopResponseData
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
pub mut:
	id         string
	type_      string @[json: 'type'] // type is a reserved word
	attributes Attributes
}

type Any = []Any | bool | f64 | map[string]Any | string

pub struct Attributes {
pub mut:
	media_id               ?string @[json: mediaId]
	cover_id               string  @[json: coverId]
	child_count            int     @[json: childCount]
	stock                  int
	custom_fields          map[string]Any @[json: customFields]
	active                 bool
	product_number         string   @[json: productNumber]
	custom_search_keywords []string @[json: customSearchKeywords]
	payment_method_id      string   @[json: paymentMethodId]
	name                   string
	parent_id              ?string @[json: parentId]
	cms_page_id            string  @[json: cmsPageId]
	price                  []Price
	tax_id                 string @[json: taxId]
	breadcrumb             []string
	meta_description       ?string @[json: metaDescription]
	meta_title             ?string @[json: metaTitle]
	is_closeout            bool    @[json: isCloseout]
	is_closeout_raw        Any     @[json: isCloseout]
	delivery_time_id       string  @[json: deliveryTimeId]
	delivery_time_id_raw   Any     @[json: deliveryTimeId]
	order_number           string  @[json: orderNumber]
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
pub mut:
	id          string
	name        string @[omitempty]
	parent_id   string @[json: parentId; omitempty]
	cms_page_id string @[json: cmsPageId; omitempty]
	active      ?bool
}

pub struct Manufacturer {
pub mut:
	id          string
	name        string @[omitempty]
	link        string @[omitempty]
	description string @[omitempty]
	media       Media  @[omitempty]
}

pub struct Unit {
pub mut:
	id         string
	name       string @[omitempty]
	short_code string @[json: 'shortCode'; omitempty]
}

pub struct Product {
pub mut:
	id                     string
	name                   string                @[omitempty]
	stock                  ?int                  @[omitempty]
	product_number         string                @[json: 'productNumber'; omitempty]
	description            string                @[omitempty]
	manufacturer           Id                    @[omitempty]
	categories             []Id                  @[omitempty]
	visibilities           []Visibility          @[omitempty]
	tax_id                 string                @[json: 'taxId'; omitempty]
	keywords               string                @[omitempty]
	custom_search_keywords []string              @[json: 'customSearchKeywords'; omitempty]
	options                []Option_             @[omitempty]
	weight                 int                   @[omitempty]
	price                  []Price               @[omitempty]
	cover_id               string                @[json: 'coverId'; omitempty]
	unit_id                string                @[json: 'unitId'; omitempty]
	media                  []ProductMedia        @[omitempty]
	custom_fields          ?CustomField          @[json: 'customFields'; omitempty]
	ean                    string                @[omitempty]
	meta_title             string                @[json: 'metaTitle'; omitempty]
	meta_description       string                @[json: 'metaDescription'; omitempty]
	parent_id              string                @[json: 'parentId'; omitempty]
	reference_unit         f64                   @[json: 'referenceUnit'; omitempty]
	purchase_unit          f64                   @[json: 'purchaseUnit'; omitempty]
	max_purchase           int                   @[json: 'maxPurchase'; omitempty]
	configurator_settings  []ConfiguratorSetting @[json: 'configuratorSettings'; omitempty]
	is_closeout            ?bool                 @[json: 'isCloseout'; omitempty]
	delivery_time_id       string                @[json: 'deliveryTimeId'; omitempty]
	variant_listing_config VariantListingConfig  @[json: 'variantListingConfig'; omitempty]
	active                 ?bool                 @[omitempty]
}

pub struct ConfiguratorSetting {
pub mut:
	id        string @[omitempty]
	option_id string @[json: 'optionId'; omitempty]
}

pub struct VariantListingConfig {
pub mut:
	display_parent ?bool @[json: 'displayParent'; omitempty]
}

pub struct ProductMedia {
pub mut:
	id       string
	position int
	media    Media
}

pub struct Id {
pub mut:
	id string @[omitempty]
}

pub struct Visibility {
pub mut:
	id               string @[omitempty]
	sales_channel_id string @[json: 'salesChannelId'; omitempty]
	visibility       int = 30    @[omitempty]
}

pub struct Option_ { // Option is a reserved word
pub mut:
	id       string @[omitempty]
	name     string @[omitempty]
	group_id string @[json: 'groupId'; omitempty]
}

pub struct Price {
pub mut:
	net         f64
	gross       f64
	currency_id string = 'b7d2554b0ce847cd82f3ac9bd1c0dfca' @[json: 'currencyId']
	linked      bool   = true
}

pub struct Media {
pub:
	id              string @[omitempty]
	media_folder_id string @[json: 'mediaFolderId'; omitempty]
}

pub struct Tax {
pub mut:
	id       string @[omitempty]
	name     string @[omitempty]
	tax_rate ?f64   @[json: 'taxRate'; omitempty]
}

pub struct PropertyGroup {
pub mut:
	id   string @[omitempty]
	name string @[omitempty]
}

pub struct CustomField {
pub mut:
	custom_import_field1 ?string @[omitempty]
	custom_import_field2 ?string @[omitempty]
	custom_import_field3 ?string @[omitempty]
	custom_import_field4 ?string @[omitempty]
	custom_import_field5 ?string @[omitempty]
	custom_import_field6 ?string @[omitempty]
	custom_import_field7 ?string @[omitempty]
	custom_import_field8 ?string @[omitempty]
	custom_import_field9 ?string @[omitempty]
}
