module shopwareac

import net.http
import time
import json
import os
import arrays

// auth get's called automatic and renews the oauth token if needed
pub fn (mut l Login) auth() {
	t := time.now()
	tu := t.unix_time()
	if l.token.valid_until > tu { // token is still valid, no need to get a new one
		return
	}

	url := l.api_url + 'oauth/token'

	config := http.FetchConfig{
		header: http.new_header(http.HeaderConfig{
			key: .content_type
			value: default_content_type
		})
		method: .post
		url: url
		data: json.encode(LoginShop{
			client_id: l.client_id
			client_secret: l.client_secret
		})
	}

	resp := http.fetch(config) or {
		println('HTTP POST request to auth at shop failed - url: $url - error:')
		println(err)
		exit(1)
	}
	if resp.status_code != 200 {
		println('Shop auth failed - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		exit(1)
	}
	token := json.decode(AuthToken, resp.text) or {
		println("Can't json decode shop auth token - response from shop:")
		println(resp.text)
		exit(1)
	}
	l.token = token
	l.token.request_at = tu
	l.token.valid_until = tu + token.expires_in - 50 // -50 is a buffer just to be safe
}

pub fn (mut l Login) get(endpoint string) string {
	resp := l.fetch(.get, endpoint, '')
	if resp.status_code != 200 {
		println('Problem at fetching data from shop at $endpoint - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		exit(1)
	}
	return resp.text
}

pub fn (mut l Login) get_raw(endpoint string) http.Response {
	return l.fetch(.get, endpoint, '')
}

// post returns the id of the created content on success
pub fn (mut l Login) post(endpoint string, data string) string {
	resp := l.fetch(.post, endpoint, data)
	if resp.status_code != 204 && resp.status_code != 200 {
		println('Error response from shop at POST - endpoint: $endpoint - statuscode: $resp.status_code - response from shop:')
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

pub fn (mut l Login) patch(endpoint string, data string) {
	resp := l.fetch(.patch, endpoint, data)
	if resp.status_code != 204 {
		println('Error response from shop at PATCH - endpoint: $endpoint - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		println('Data send to shop:')
		println(data)
		if resp.status_code == 500 {
			// if resp.text.contains('FRAMEWORK__WRITE_TYPE_INTEND_ERROR') { // try again on this error
			// 	println('trying again ...')
			// 	time.sleep_ms(2000)
			// 	resp2 := http.fetch(url, config) or {
			// 		println('HTTP PATCH request to shop failed - url: $url - error:')
			// 		println(err)
			// 		exit(1)
			// 	}
			// 	if resp2.status_code != 204 {
			println('Error response from shop at PATCH - endpoint: $endpoint - statuscode: $resp.status_code - response from shop:')
			println(resp.text)
			println('Data send to shop:')
			println(data)
			exit(1)
			// 	}
			// } else {
			// 	exit(1)
			// }
		}
	}
}

pub fn (mut l Login) delete(endpoint string, id string) {
	url := endpoint + '/' + id
	resp := l.fetch(.delete, url, '')
	if resp.status_code != 204 {
		println('Error response from shop at DELETE - url: $url - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		exit(1)
	}
}

fn (mut l Login) fetch(method http.Method, url string, data string) http.Response {
	l.auth()
	config := http.FetchConfig{
		header: http.new_header(http.HeaderConfig{
			key: .content_type
			value: default_content_type
		}, http.HeaderConfig{
			key: .accept
			value: accept_all
		}, http.HeaderConfig{
			key: .authorization
			value: 'Bearer $l.token.access_token'
		})
		method: method
		url: l.api_url + url
		data: data
	} // http.fetch(http.FetchConfig{ ...config, url: '' })
	resp := http.fetch(config) or {
		println('HTTP $method request to shop failed - url: $l.api_url$url - error:')
		println(err)
		exit(1)
	}
	return resp
}

// sync API is an add-on to the Admin API that allows you to perform multiple write operations (creating/updating and deleting) simultaneously
pub fn (mut l Login) sync(data string) string {
	l.auth()
	mut h := http.new_header(http.HeaderConfig{
		key: .content_type
		value: default_content_type
	}, http.HeaderConfig{
		key: .accept
		value: accept_all
	}, http.HeaderConfig{
		key: .authorization
		value: 'Bearer $l.token.access_token'
	})
	h.add_custom('single-operation', '1') or {
		println('add single-operation sync header failed')
		exit(1)
	}
	// h.add_custom('indexing-behavior', 'use-queue-indexing') or {
	// 	println('add indexing-behavior sync header failed')
	// 	exit(1)
	// }
	config := http.FetchConfig{
		header: h
		method: .post
		url: l.api_url + '_action/sync'
		data: data
	}
	os.write_file(@FILE + '_api_retry_cache.json', data) or {
		println('unable to create last sync log file - reason: ' + err.str())
	}
	resp := http.fetch(config) or {
		println('Unable to make HTTP sync request to shop')
		println(err)
		exit(1)
	}
	if resp.status_code != 204 && resp.status_code != 200 {
		println('Error response from shop at sync - statuscode: $resp.status_code - response from shop:')
		if resp.text.contains('"source":{"pointer":') {
			e := json.decode(ShopResponseSyncError, resp.text) or {
				println("Can't json decode shop error response: " + resp.text)
				println('Data send to shop: $data')
				exit(1)
			}
			println(e)
			pos := data[1..].index('{') or { -1 }
			if pos > -1 {
				payload := json.decode(SyncPayload, data[pos + 1..data.len - 1]) or {
					// println("Can't json decode sync payload")
					SyncPayload{}
				}
				error_source_array := e.errors[0].source.pointer.split('/')
				if error_source_array.len > 1 && payload.payload.len > 0 {
					error_item_nr := error_source_array[2]
					println('Error record:')
					println(payload.payload[error_item_nr.int()]) // todo - figure out why this doesn't print nested vars
				} else {
					println('Data send to shop: $data')
				}
			}
		} else {
			println(resp.text)
			println('Data send to shop: $data')
		}
		exit(1)
	}
	return resp.text
}

// sync_upsert is a shorthand function for sync with data chunking for large arrays
pub fn (mut l Login) sync_upsert(entity string, data []string) string {
	mut responses := ''
	chunks := arrays.chunk(data, 500) // split into chunks
	for chunk in chunks {
		c := chunk.filter(it != '')
		sync_data := '{"v-sync-$entity":{"entity":"$entity","action":"upsert","payload":[' +
			c.join(',') + ']}}'
		responses += l.sync(sync_data)
	}
	return responses
}

// get_last_sync returns the last sync payload
pub fn (mut l Login) get_last_sync() string {
	data := os.read_file(@FILE + '_api_retry_cache.json') or { return '' }
	return data
}

// resend_sync sends the last sync operation (sync saves data into a file) again to the shop api - useful for debugging or temporary errors
pub fn (mut l Login) resend_sync() {
	data := os.read_file(@FILE + '_api_retry_cache.json') or { return }
	l.auth()
	l.sync(data)
}
