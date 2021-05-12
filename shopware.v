module shopwareac

import net.http
import time
import json

// auth get's called automatic and renews the oauth token if needed
pub fn (mut l Login) auth() {
	t := time.now()
	tu := t.unix_time()
	if l.token.valid_until > tu { // token is still valid, no need to get a new one
		return
	}
	config := http.FetchConfig{
		method: .post
		header: http.new_header(
			key: .content_type
			value: default_content_type
		)
		data: json.encode(LoginShop{
			client_id: l.client_id
			client_secret: l.client_secret
		})
	}
	url := l.api_url + 'oauth/token'
	resp := http.fetch(url, config) or {
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
	l.auth()
	config := http.FetchConfig{
		header: http.new_header(
			{key: .content_type, value: default_content_type},
			{key: .accept, value: accept_all},
			{key: .authorization, value: 'Bearer $l.token.access_token'}
		)
		method: .get
	}
	url := l.api_url + endpoint
	resp := http.fetch(url, config) or {
		println('HTTP GET request to shop failed - url: $url - error:')
		println(err)
		exit(1)
	}
	if resp.status_code != 200 {
		println('Problem at fetching data from shop at $url - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		exit(1)
	}
	return resp.text
}

pub fn (mut l Login) get_raw(endpoint string) http.Response {
	l.auth()
	config := http.FetchConfig{
		header: http.new_header(
			{key: .content_type, value: default_content_type},
			{key: .accept, value: accept_all},
			{key: .authorization, value: 'Bearer $l.token.access_token'}
		)
		method: .get
	}
	url := l.api_url + endpoint
	resp := http.fetch(url, config) or {
		println('HTTP GET request to shop failed - url: $url - error:')
		println(err)
		exit(1)
	}
	return resp
}

// post returns the id of the created content on success
pub fn (mut l Login) post(endpoint string, data string) string {
	l.auth()
	config := http.FetchConfig{
		header: http.new_header(
			{key: .content_type, value: default_content_type},
			{key: .accept, value: accept_all},
			{key: .authorization, value: 'Bearer $l.token.access_token'}
		)
		data: data
		method: .post
	}
	url := l.api_url + endpoint
	resp := http.fetch(url, config) or {
		println('HTTP POST request to shop failed - url: $url - error:')
		println(err)
		exit(1)
	}
	if resp.status_code != 204 && resp.status_code != 200 {
		println('Error response from shop at POST - url: $url - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		println('Data send to shop:')
		println(data)
		exit(1)
	}
	if resp.status_code == 204 {
		location := resp.header.get(.location) or {
			''
		}
		if location != '' {
			pos := location.last_index('/') or {
				-1
			}
			return location[pos + 1..]
		} else {
			return resp.text
		}
	} else {
		return resp.text
	}
}

pub fn (mut l Login) patch(endpoint string, data string) {
	l.auth()
	config := http.FetchConfig{
		header: http.new_header(
			{key: .content_type, value: default_content_type},
			{key: .accept, value: accept_all},
			{key: .authorization, value: 'Bearer $l.token.access_token'}
		)
		data: data
		method: .patch
	}
	url := l.api_url + endpoint
	resp := http.fetch(url, config) or {
		println('HTTP PATCH request to shop failed - url: $url - error:')
		println(err)
		exit(1)
	}
	if resp.status_code != 204 {
		println('Error response from shop at PATCH - url: $url - statuscode: $resp.status_code - response from shop:')
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
					println('Error response from shop at PATCH - url: $url - statuscode: $resp.status_code - response from shop:')
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
	l.auth()
	config := http.FetchConfig{
		header: http.new_header(
			{key: .content_type, value: default_content_type},
			{key: .accept, value: accept_all},
			{key: .authorization, value: 'Bearer $l.token.access_token'}
		)
		method: .delete
	}
	url := l.api_url + endpoint + '/' + id
	resp := http.fetch(url, config) or {
		println('HTTP DELETE request to shop failed - url: $url - error:')
		println(err)
		exit(1)
	}
	if resp.status_code != 204 {
		println('Error response from shop at DELETE - url: $url - statuscode: $resp.status_code - response from shop:')
		println(resp.text)
		exit(1)
	}
}
