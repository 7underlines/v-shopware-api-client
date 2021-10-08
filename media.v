module shopwareac

import json
import os

// upload returns the mediaId of the uploaded file on success
pub fn (mut l Login) upload(file_url string, name string, media_folder_id string) ?string {
	data := '{"mediaFolderId": "$media_folder_id"}'
	resp2 := l.post('media?_response=true', data)
	shopres := json.decode(ShopResponseSingle, resp2) or {
		println("Can't json decode shop media response - response from shop:")
		println(resp2)
		exit(1)
	}
	ext := os.file_ext(file_url)
	ext2 := ext[1..]
	data2 := '{"url":"$file_url"}'
	url := '_action/media/$shopres.data.id/upload?extension=$ext2&fileName=${strip(name)}'
	resp := l.fetch(.post, url, data2)
	if resp.status_code == 500 {
		shopr := json.decode(ShopResponseError, resp.text) or {
			println("Can't json decode shop response - response from shop:")
			println(resp.text)
			exit(1)
		}
		for e in shopr.errors {
			if e.code == 'CONTENT__MEDIA_DUPLICATED_FILE_NAME' {
				l.delete('media', shopres.data.id) // clean the placeholder media
				return error('Error duplicate file name')
			}
		}
	}
	if resp.status_code != 204 && resp.status_code != 200 {
		println('Error response from shop at POST - url: $url - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
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
			return resp.text
		}
	} else {
		return resp.text
	}
}

// add_media_to_product position should begin with 0
pub fn (mut l Login) add_media_to_product(media_id string, product_id string, set_as_cover bool, position int) { // position should begin with 0
	mut product_media_id := ''
	data_product := '{"media":[{"mediaId":"$media_id", "position": $position}]}'
	l.patch('product/$product_id', data_product)
	if !set_as_cover {
		return
	}
	r := l.get('product/$product_id/media')
	pm := json.decode(ShopResponseFind, r) or {
		println("Can't json decode shop product media response - response from shop:")
		println(r)
		exit(1)
	}
	if pm.meta.total == 0 {
		println('No product_media entries found for product id $product_id')
		exit(1)
	}
	for p in pm.data {
		if p.attributes.media_id == media_id {
			product_media_id = p.id
		}
	}
	if product_media_id == '' {
		println("Couldn't get product_media_id for product id $product_id")
		exit(1)
	}
	data_cover := '{"coverId": "$product_media_id"}'
	l.patch('product/$product_id', data_cover)
}

// upload_file via binary blob
pub fn (mut l Login) upload_file(media_id string, name string, _ext string, data string) {
	l.auth()
	ext := _ext.replace('.', '')
	config := http.FetchConfig{
		header: http.new_header(http.HeaderConfig{
			key: .content_type
			value: 'image/$ext'
		}, http.HeaderConfig{
			key: .accept
			value: accept_all
		}, http.HeaderConfig{
			key: .authorization
			value: 'Bearer $l.token.access_token'
		})
		method: .post
		url: l.api_url + '_action/media/$media_id/upload?extension=$ext&fileName=${strip(name)}'
		data: data
	}
	resp := http.fetch(config) or {
		println('HTTP POST request for file_upload for mediaId $media_id to shop failed - error:')
		println(err)
		exit(1)
	}
	if resp.status_code != 204 {
		println('Error response from shop at file_upload for mediaId $media_id statuscode: $resp.status_code - response from shop:')
		println(resp.text)
	}
}
