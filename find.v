module shopwareac

import json
import os

pub fn (mut l Login) find_product_by_productnumber(productnumber string) !ShopResponseData {
	response_raw := l.get('product/?filter[productNumber]=${encode(productnumber)}')
	response := json.decode(ShopResponseFind, response_raw) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if response.data.len < 1 {
		return error('Found none')
	} else if response.data.len > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_product_by_customfield(field string, value string) !ShopResponseData {
	response_raw := l.get('product/?filter[customFields.${field}]=${encode(value)}')
	response := json.decode(ShopResponseFind, response_raw) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if response.data.len < 1 {
		return error('Found none')
	} else if response.data.len > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_category_by_customfield(field string, value string) !ShopResponseData {
	response_raw := l.get('category/?filter[customFields.${field}]=${encode(value)}')
	response := json.decode(ShopResponseFind, response_raw) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if response.data.len < 1 {
		return error('Found none')
	} else if response.data.len > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_subcategory_by_name(name string, parent string) !ShopResponseData {
	response_raw := l.get('category/?filter[name]=${encode(name)}&filter[parentId]=${parent}')
	response := json.decode(ShopResponseFind, response_raw) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if response.data.len < 1 {
		return error('Found none')
	} else if response.data.len > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_property_by_name(name string, group string) !ShopResponseData {
	response_raw := l.get('property-group-option/?filter[name]=${encode(name)}&filter[groupId]=${group}')
	response := json.decode(ShopResponseFind, response_raw) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if response.data.len < 1 {
		return error('Found none')
	} else if response.data.len > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_media_by_name(name string) !ShopResponseData {
	mut ext := os.file_ext(name)
	name_without_ext := name.substr(0, name.len - ext.len)
	if ext.len > 0 {
		ext = ext[1..]
	}
	response_raw := l.get('media/?filter[fileName]=${encode(strip(name_without_ext))}&filter[fileExtension]=${ext}')
	response := json.decode(ShopResponseFind, response_raw) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if response.data.len < 1 {
		return error('Found none')
	} else if response.data.len > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) get_default_tax() string {
	tax_response := l.get('tax?filter[position]=1')
	tax_data := json.decode(ShopResponseFind, tax_response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if tax_data.data.len < 1 {
		eprintln('No tax with position 1 found')
		return ''
	}
	// todo if pos 1 not found - get pos 0 or any other
	// if there are none - create default tax
	return tax_data.data[0].id
}

pub fn (mut l Login) get_default_sales_channel() string {
	sales_channel_type_response := l.get('sales-channel-type?filter[name]=Storefront&limit=1')
	sales_channel_type_data := json.decode(ShopResponseFind, sales_channel_type_response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if sales_channel_type_data.data.len < 1 {
		eprintln('No sales channel type with name "Storefront" found')
		return ''
	}
	sales_channel_response := l.get('sales-channel-type/${sales_channel_type_data.data[0].id}/salesChannels?limit=1&active=true&sort=createdAt')
	sales_channel_data := json.decode(ShopResponseFind, sales_channel_response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if sales_channel_data.data.len < 1 {
		eprintln('No active sales channel with type "Storefront" found')
		return ''
	}
	return sales_channel_data.data[0].id
}

pub fn (mut l Login) get_default_payment_method() string {
	sales_channel_type_response := l.get('sales-channel-type?filter[name]=Storefront')
	sales_channel_type_data := json.decode(ShopResponseFind, sales_channel_type_response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if sales_channel_type_data.data.len < 1 {
		eprintln('No sales channel type with name "Storefront" found')
		return ''
	}
	sales_channel_response := l.get('sales-channel-type/${sales_channel_type_data.data[0].id}/salesChannels')
	sales_channel_data := json.decode(ShopResponseFind, sales_channel_response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if sales_channel_data.data.len < 1 {
		eprintln('No sales channel with type "Storefront" found')
		return ''
	}
	return sales_channel_data.data[0].attributes.payment_method_id
}

pub fn (mut l Login) get_default_media_folder() string {
	response := l.get('media-folder?filter[name]=Imported Media')
	data := json.decode(ShopResponseFind, response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if data.data.len < 1 {
		eprintln('No media folder with name "Imported Media" found')
		return ''
	}
	return data.data[0].id
}

pub fn (mut l Login) get_default_cms_page() string {
	response := l.get('cms-page/?filter[type]=product_list&limit=1')
	data := json.decode(ShopResponseFind, response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if data.data.len < 1 {
		eprintln('No cms page with type "product_list" found')
		return ''
	}
	return data.data[0].id
}

pub fn (mut l Login) get_default_category() string {
	// should we get navigationCategoryId instead from default storefront instead?
	response := l.get('category?limit=1')
	data := json.decode(ShopResponseFind, response) or {
		eprintln(err)
		ShopResponseFind{}
	}
	if data.data.len < 1 {
		eprintln('No category found')
		return ''
	}
	return data.data[0].id
}
