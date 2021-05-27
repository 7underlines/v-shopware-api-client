module shopwareac

import json
import os

pub fn (mut l Login) find_product_by_productnumber(productnumber string) ?ShopResponseData {
	response_raw := l.get('product/?filter[productNumber]=${encode(productnumber)}')
	response := json.decode(ShopResponseFind, response_raw) or {
		println('Failed to decode product json')
		exit(1)
	}
	if response.meta.total == 0 {
		return error('Found none')
	} else if response.meta.total > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_product_by_customfield(field string, value string) ?ShopResponseData {
	response_raw := l.get('product/?filter[customFields.$field]=${encode(value)}')
	response := json.decode(ShopResponseFind, response_raw) or {
		println('Failed to decode product json')
		exit(1)
	}
	if response.meta.total == 0 {
		return error('Found none')
	} else if response.meta.total > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_category_by_customfield(field string, value string) ?ShopResponseData {
	response_raw := l.get('category/?filter[customFields.$field]=${encode(value)}')
	response := json.decode(ShopResponseFind, response_raw) or {
		println('Failed to decode category json')
		exit(1)
	}
	if response.meta.total == 0 {
		return error('Found none')
	} else if response.meta.total > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_subcategory_by_name(name string, parent string) ?ShopResponseData {
	response_raw := l.get('category/?filter[name]=${encode(name)}&filter[parentId]=$parent')
	response := json.decode(ShopResponseFind, response_raw) or {
		println('Failed to decode category json')
		exit(1)
	}
	if response.meta.total == 0 {
		return error('Found none')
	} else if response.meta.total > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_property_by_name(name string, group string) ?ShopResponseData {
	response_raw := l.get('property-group-option/?filter[name]=${encode(name)}&filter[groupId]=$group')
	response := json.decode(ShopResponseFind, response_raw) or {
		println('Failed to decode property json')
		exit(1)
	}
	if response.meta.total == 0 {
		return error('Found none')
	} else if response.meta.total > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}

pub fn (mut l Login) find_media_by_name(name string) ?ShopResponseData {
	mut ext := os.file_ext(name)
	name_without_ext := name.substr(0, name.len - ext.len)
	if ext.len > 0 {
		ext = ext[1..]
	}
	response_raw := l.get('media/?filter[fileName]=${encode(strip(name_without_ext))}&filter[fileExtension]=$ext')
	response := json.decode(ShopResponseFind, response_raw) or {
		println('Failed to decode media json')
		exit(1)
	}
	if response.meta.total == 0 {
		return error('Found none')
	} else if response.meta.total > 1 {
		return error('Found multiple')
	}
	return response.data[0]
}
