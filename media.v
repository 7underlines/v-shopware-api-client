module shopwareac

import json
import os
import net.http

// upload returns the mediaId of the uploaded file on success
pub fn (mut l Login) upload(file_url string, name string, media_folder_id string) !string {
	data := '{"mediaFolderId": "${media_folder_id}"}'
	resp2 := l.post('media?_response=true', data)
	shopres := json.decode(ShopResponseSingle, resp2)!
	ext := os.file_ext(file_url)
	ext2 := ext[1..]
	data2 := '{"url":"${file_url}"}'
	url := '_action/media/${shopres.data.id}/upload?extension=${ext2}&fileName=${strip(name)}'
	resp := l.fetch(.post, url, data2)
	if resp.status_code == 500 || // before shopware 6.5
		resp.status_code == 409 { // since shopware 6.5
		shopr := json.decode(ShopResponseError, resp.body)!
		for e in shopr.errors {
			if e.code == 'CONTENT__MEDIA_DUPLICATED_FILE_NAME' {
				l.delete('media', shopres.data.id) // clean the placeholder media
				return error('Error duplicate file name')
			}
		}
	}
	if resp.status_code != 204 && resp.status_code != 200 {
		eprintln('Error response from shop at POST - url: ${url} - statuscode: ${resp.status_code} - response from shop:')
		eprintln(resp.body)
		eprintln('Data send to shop:')
		eprintln(data)
		return error(resp.status_code.str())
	}
	if resp.status_code == 204 {
		location := resp.header.get(.location) or { '' }
		if location != '' {
			pos := location.last_index('/') or { -1 }
			return location[pos + 1..]
		} else {
			return resp.body
		}
	} else {
		return resp.body
	}
}

// add_media_to_product position should begin with 0
pub fn (mut l Login) add_media_to_product(media_id string, product_id string, set_as_cover bool, position int) { // position should begin with 0
	mut product_media_id := ''
	data_product := '{"media":[{"mediaId":"${media_id}", "position": ${position}}]}'
	l.patch('product/${product_id}', data_product)
	if !set_as_cover {
		return
	}
	r := l.get('product/${product_id}/media')
	pm := json.decode(ShopResponseFind, r) or {
		eprintln(err)
		return
	}
	if pm.meta.total == 0 {
		eprintln('No product_media entries found for product id ${product_id}')
		return
	}
	for p in pm.data {
		if p.attributes.media_id == media_id {
			product_media_id = p.id
		}
	}
	if product_media_id == '' {
		eprintln("Couldn't get product_media_id for product id ${product_id}")
		return
	}
	data_cover := '{"coverId": "${product_media_id}"}'
	l.patch('product/${product_id}', data_cover)
}

// upload_file via binary blob
pub fn (mut l Login) upload_file(media_id string, name string, _ext string, data string) ! {
	l.auth()
	ext := _ext.replace('.', '')
	config := http.FetchConfig{
		header: http.new_header(http.HeaderConfig{
			key: .content_type
			value: 'image/${ext}'
		}, http.HeaderConfig{
			key: .accept
			value: accept_all
		}, http.HeaderConfig{
			key: .authorization
			value: 'Bearer ${l.token.access_token}'
		})
		method: .post
		url: l.api_url + '_action/media/${media_id}/upload?extension=${ext}&fileName=${strip(name)}'
		data: data
	}
	resp := http.fetch(config) or {
		return error('HTTP POST request for file_upload for mediaId ${media_id} to shop failed - error: ${err}')
	}
	if resp.status_code != 204 {
		return error('Error response from shop at file_upload for mediaId ${media_id} - file extension ${ext} - filename ${name} - filename stripped ${strip(name)} - statuscode: ${resp.status_code} - response from shop: ${resp.body}')
	}
}

// Attach resource data to the media object from the given url
pub fn (mut l Login) update_media_from_url(media_id string, url string) {
	l.auth()
	name := os.file_name(url)
	ext := os.file_ext(name)
	filename_without_ext := name.substr(0, name.len - ext.len)
	resp := l.fetch(.post, '_action/media/${media_id}/upload?extension=${ext.replace('.',
		'')}&fileName=${strip(filename_without_ext)}', '{"url":"${url.replace(' ', '%20')}"}')
	if resp.status_code != 204 {
		println('Error response from shop at file_upload for mediaId ${media_id} - url ${url} - statuscode ${resp.status_code} - response from shop:')
		println(resp.body)
	}
}

pub fn (mut l Login) upload_replace(file_url string, name string, media_folder_id string, existing_media_id string) !string {
	data := '{"mediaFolderId": "${media_folder_id}"}'
	ext := os.file_ext(file_url)
	ext2 := ext[1..]
	data2 := '{"url":"${file_url}"}'

	l.auth()
	url := l.api_url +
		'_action/media/${existing_media_id}/upload?extension=${ext2}&fileName=${strip(name)}'

	config := http.FetchConfig{
		header: http.new_header(http.HeaderConfig{
			key: .content_type
			value: default_content_type
		}, http.HeaderConfig{
			key: .accept
			value: accept_all
		}, http.HeaderConfig{
			key: .authorization
			value: 'Bearer ${l.token.access_token}'
		})
		method: .post
		url: url
		data: data2
	}

	resp := http.fetch(config) or {
		println('HTTP POST request to shop failed - url: ${url} - error:')
		println(err)
		exit(1)
	}
	if resp.status_code == 500 {
		shopr := json.decode(ShopResponse, resp.body) or {
			println("Can't json decode shop response - response from shop:")
			println(resp.body)
			exit(1)
		}
		for e in shopr.errors {
			if e.code == 'CONTENT__MEDIA_DUPLICATED_FILE_NAME' {
				return error('Error duplicate file name')
			}
		}
	}
	if resp.status_code != 204 && resp.status_code != 200 {
		println('Error response from shop at POST - url: ${url} - statuscode: ${resp.status_code} - response from shop:')
		println(resp.body)
		println('Data send to shop:')
		println(data)
		exit(1)
	}
	if resp.status_code == 204 {
		location := resp.header.get(.location) or { '' }
		if location != '' {
			pos := location.last_index('/') or { -1 }
			return location[pos + 1..]
		} else {
			return resp.body
		}
	} else {
		return resp.body
	}
}
