module shopwareac

import net.http
import time
import json
import x.json2
import os
import arrays

// auth get's called automatic and renews the oauth token if needed
pub fn (mut l Login) auth() bool {
	t := time.now()
	tu := t.unix()
	if l.token.valid_until > tu { // token is still valid, no need to get a new one
		return true
	}
	if l.api_url.len < 2 {
		return false
	}
	if l.api_url[l.api_url.len - 1..] != '/' {
		l.api_url += '/'
	}
	if !l.api_url.contains('api') {
		l.api_url += 'api/'
	}
	if !l.api_url.contains('http') {
		l.api_url = 'https://' + l.api_url
	}
	url := l.api_url + 'oauth/token'

	config := http.FetchConfig{
		header: http.new_header(http.HeaderConfig{
			key:   .content_type
			value: default_content_type
		})
		method: .post
		url:    url
		data:   json.encode(LoginShop{
			client_id:     l.client_id
			client_secret: l.client_secret
		})
	}

	resp := http.fetch(config) or {
		eprintln('HTTP POST request to auth at shop failed - url: ${url} - error: ${err}')
		return false
	}
	if resp.status_code != 200 {
		eprintln('Shop auth failed - url: ${url} - statuscode: ${resp.status_code} - response from shop:')
		eprintln(resp.body)
		return false
	}
	token := json.decode(AuthToken, resp.body) or {
		eprintln("Can't json decode shop auth token - response from shop:")
		eprintln(resp.body)
		AuthToken{}
	}
	l.token = token
	l.token.request_at = tu
	l.token.valid_until = tu + token.expires_in - 50 // -50 is a buffer just to be safe
	if l.token.access_token != '' {
		return true
	}
	return false
}

pub fn (mut l Login) get(endpoint string) string {
	mut resp := l.fetch(.get, endpoint, '')
	if resp.status_code != 200 && resp.status_code != 404 {
		eprintln('Problem at fetching data from shop at ${endpoint} - statuscode: ${resp.status_code} - response from shop:')
		eprintln(resp.body)
		eprintln('Retry in 60 seconds ...')
		time.sleep(60 * time.second)
		resp = l.fetch(.get, endpoint, '')
		if resp.status_code != 200 {
			eprintln('Also error on retry')
		}
	}
	return resp.body
}

pub fn (mut l Login) get_raw(endpoint string) http.Response {
	return l.fetch(.get, endpoint, '')
}

// post returns the id of the created content on success
pub fn (mut l Login) post(endpoint string, data string) string {
	resp := l.fetch(.post, endpoint, data)
	if resp.status_code != 204 && resp.status_code != 200 {
		eprintln('Error response from shop at POST - endpoint: ${endpoint} - statuscode: ${resp.status_code} - response from shop:')
		eprintln(resp.body)
		eprintln('Data send to shop:')
		eprintln(data)
		// exit(1)
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

pub fn (mut l Login) search(entity string, data string) string {
	return l.post('search/${entity}', data)
}

pub fn (mut l Login) patch(endpoint string, data string) {
	resp := l.fetch(.patch, endpoint, data)
	if resp.status_code != 204 {
		eprintln('Error response from shop at PATCH - endpoint: ${endpoint} - statuscode: ${resp.status_code} - response from shop:')
		eprintln(resp.body)
		eprintln('Data send to shop:')
		eprintln(data)
		if resp.status_code == 500 {
			// if resp.body.contains('FRAMEWORK__WRITE_TYPE_INTEND_ERROR') { // try again on this error
			// 	eprintln('trying again ...')
			// 	time.sleep_ms(2000)
			// 	resp2 := http.fetch(url, config) or {
			// 		eprintln('HTTP PATCH request to shop failed - url: $url - error:')
			// 		eprintln(err)
			// 		exit(1)
			// 	}
			// 	if resp2.status_code != 204 {
			eprintln('Error response from shop at PATCH - endpoint: ${endpoint} - statuscode: ${resp.status_code} - response from shop:')
			eprintln(resp.body)
			eprintln('Data send to shop:')
			eprintln(data)
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
		eprintln('Error response from shop at DELETE - url: ${url} - statuscode: ${resp.status_code} - response from shop:')
		eprintln(resp.body)
	}
}

fn (mut l Login) fetch(method http.Method, url string, data string) http.Response {
	l.auth()
	if l.token.access_token == '' {
		return http.Response{}
	}
	mut request := http.Request{
		method:       method
		url:          l.api_url + url
		data:         data
		read_timeout: 120 * time.minute // -1 for no timeout somehow does not work
		header:       http.new_header(http.HeaderConfig{
			key:   .content_type
			value: default_content_type
		}, http.HeaderConfig{
			key:   .accept
			value: accept_all
		}, http.HeaderConfig{
			key:   .authorization
			value: 'Bearer ${l.token.access_token}'
		})
	}
	if l.inheritance {
		request.header.add_custom('sw-inheritance', '1') or {
			eprintln('sw-inheritance header contains invalid characters')
			exit(1)
		}
	}
	if l.language_id != '' {
		request.header.add_custom('sw-language-id', l.language_id) or {
			eprintln('sw-language-id header contains invalid characters')
			exit(1)
		}
	}
	if l.version_id != '' {
		request.header.add_custom('sw-version-id', l.version_id) or {
			eprintln('sw-version-id header contains invalid characters')
			exit(1)
		}
	}
	if l.currency_id != '' {
		request.header.add_custom('sw-currency-id', l.currency_id) or {
			eprintln('sw-currency-id header contains invalid characters')
			exit(1)
		}
	}
	resp := request.do() or {
		eprintln('HTTP ${method} request to shop failed - url: ${l.api_url}${url} - error: ${err}')
		http.Response{}
	}
	if resp.status_code != 0 {
		return resp
	}
	eprintln('Retry')
	time.sleep(1 * time.second)
	l.auth()
	resp2 := request.do() or {
		eprintln('Retry failed again')
		exit(1)
	}
	return resp2
}

// sync API is an add-on to the Admin API that allows you to perform multiple write operations (creating/updating and deleting) simultaneously
pub fn (mut l Login) sync(data string) !string {
	l.auth()
	mut h := http.new_header(http.HeaderConfig{
		key:   .content_type
		value: default_content_type
	}, http.HeaderConfig{
		key:   .accept
		value: accept_all
	}, http.HeaderConfig{
		key:   .authorization
		value: 'Bearer ${l.token.access_token}'
	})
	h.add_custom('single-operation', '1') or { return err } // hardcoded as of Shopware 6.5.1.0
	// https://github.com/shopware/shopware/blob/trunk/UPGRADE-6.5.md#sync-api-changes
	// h.add_custom('indexing-behavior', 'use-queue-indexing') or {
	// 	panic(err)
	// }
	request := http.Request{
		method:       .post
		url:          l.api_url + '_action/sync'
		data:         data
		read_timeout: 120 * time.minute // -1 for no timeout somehow does not work
		header:       h
	}
	os.write_file(@FILE + '_api_retry_cache.json', data) or {
		// eprintln('unable to create last sync log file - reason: ' + err.str())
	}
	resp := request.do() or {
		eprintln('Unable to make HTTP sync request to shop')
		eprintln(err)
		eprintln('Retrying ...')
		time.sleep(120 * time.second)
		l.auth()
		request.do() or {
			eprintln('sync request also failed on retry - error: ${err} - doing one last retry ...')
			time.sleep(300 * time.second)
			l.auth()
			request.do() or {
				eprintln('sync request also failed on second retry - error: ${err} - giving up')
				return err
			}
		}
	}
	if resp.status_code != 204 && resp.status_code != 200 {
		// eprintln('Error response from shop at sync - statuscode: ${resp.status_code}')
		if resp.body.contains('"source":{"pointer":') {
			e := json.decode(ShopResponseSyncError, resp.body) or { return error(resp.body) }
			pos := data[1..].index('{') or { -1 }
			if pos > -1 {
				payload := json.decode(SyncPayload, data[pos + 1..data.len - 1]) or {
					SyncPayload{}
				}
				error_source_array := e.errors[0].source.pointer.split('/')
				if error_source_array.len > 1 && payload.payload.len > 0 {
					error_item_nr := error_source_array[2]
					eprintln('Error record:')
					eprintln(payload.payload[error_item_nr.int()]) // todo - figure out why this doesn't print nested vars
				}
			}
		} else {
			eprintln('Error from Shop at sync/post - statuscode: ${resp.status_code} - response from shop:')
			eprintln(resp.body)
			eprintln('Retrying ...')
			time.sleep(60 * time.second)
			l.auth()
			resp2 := request.do() or {
				eprintln('Unable to make HTTP sync request to shop on retry')
				eprintln(err)
				eprintln('Retrying ...')
				time.sleep(60 * time.second)
				request.do() or {
					eprintln('sync retry request also failed on retry - error: ${err} - giving up')
					return err
				}
			}
			if resp2.status_code != 204 && resp2.status_code != 200 {
				eprintln('Error response from shop at sync retry - statuscode: ${resp2.status_code}')
				return error(resp2.body)
			}
			return resp2.body
		}
		return error(resp.body)
	}
	return resp.body
}

// sync_upsert is a shorthand function for sync with data chunking for large arrays
pub fn (mut l Login) sync_upsert(entity string, data []string, params ChunkParams) {
	chunks := arrays.chunk(data, params.size) // split into chunks
	for i, chunk in chunks {
		if i > 0 {
			time.sleep(params.sleep * time.millisecond)
		}
		c := chunk.filter(it != '')
		sync_data := '{"v-sync-${entity}":{"entity":"${entity}","action":"upsert","payload":[' +
			c.join(',') + ']}}'
		l.sync(sync_data) or {
			eprintln('${time.now()} sync upsert failed - error: ${err}')
			// {"errors":[{"code":"40001","status":"500","title":"Internal Server Error","detail":"SQLSTATE[40001]: Serialization failure: 1213 Deadlock found when trying to get lock; try restarting transaction"}]}
			if err.msg().contains('try restarting transaction') {
				eprintln('this might be a temporary error caused by updating the same entity multiple times - retrying ...')
				time.sleep(10 * time.second)
				l.sync(sync_data) or {
					eprintln('sync upsert also failed on retry - error: ${err} - giving up')
					return
				}
				eprintln('retry successful')
			}
		}
	}
}

// sync_upsert_queue doesn't immediatly process sync operations and must be processed with the Shopware 6 message queue
// pub fn (mut l Login) sync_upsert_queue(entity string, data []string) {
// 	chunks := arrays.chunk(data, 400) // split into chunks
// 	for i, chunk in chunks {
// 		c := chunk.filter(it != '')
// 		sync_data := '{"v-sync-${entity}":{"entity":"${entity}","action":"upsert","payload":[' +
// 			c.join(',') + ']}}'
// 		l.sync(sync_data) or {
// 			eprintln('sync upsert queue failed - error: ${err}')
// 			return
// 		}
// 	}
// }

// sync_delete is a shorthand function for sync with data chunking for large arrays
pub fn (mut l Login) sync_delete(entity string, data []string) {
	chunks := arrays.chunk(data, 400) // split into chunks
	for chunk in chunks {
		c := chunk.filter(it != '')
		sync_data := '{"v-sync-${entity}":{"entity":"${entity}","action":"delete","payload":[' +
			c.join(',') + ']}}'
		l.sync(sync_data) or { return }
	}
}

// get_last_sync returns the last sync payload
pub fn (mut l Login) get_last_sync() string {
	data := os.read_file(@FILE + '_api_retry_cache.json') or { return '' }
	return data
}

// resend_sync sends the last sync operation (sync saves data into a file) again to the shop api - useful for debugging or temporary errors
pub fn (mut l Login) resend_sync() {
	data := l.get_last_sync()
	if data == '' {
		eprintln('no last sync data found')
		return
	}
	l.auth()
	l.sync(data) or { return }
}

pub fn decode(data string) map[string]json2.Any {
	d := json2.raw_decode(data) or { return map[string]json2.Any{} }
	m := d.as_map()
	return m
}
