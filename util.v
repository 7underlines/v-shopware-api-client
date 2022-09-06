module shopwareac

// Percent-encoding reserved characters eg. for filter parameters
[inline]
pub fn encode(s string) string {
	mut r := s
	r = r.replace('%', '%25')
	r = r.replace('!', '%21')
	r = r.replace('#', '%23')
	r = r.replace('$', '%24')
	r = r.replace('&', '%26')
	r = r.replace("'", '%27')
	r = r.replace('(', '%28')
	r = r.replace(')', '%29')
	r = r.replace('*', '%2A')
	r = r.replace('+', '%2B')
	r = r.replace(',', '%2C')
	r = r.replace('/', '%2F')
	r = r.replace(':', '%3A')
	r = r.replace(';', '%3B')
	r = r.replace('=', '%3D')
	r = r.replace('?', '%3F')
	r = r.replace('@', '%40')
	r = r.replace('[', '%5B')
	r = r.replace(']', '%5D')
	return r
}

// strip not allowed chars
[inline]
pub fn strip(s string) string {
	mut r := s
	r = r.replace("'", '')
	r = r.replace('"', '')
	r = r.replace('<', '')
	r = r.replace('>', '')
	r = r.replace('\t', '')
	r = r.replace('/', '')
	r = r.replace('\\', '')
	r = r.replace(':', '')
	r = r.replace('.', '')
	r = r.replace('%', '')
	r = r.replace('|', '')
	r = r.replace('&', '')
	r = r.replace('*', '')
	return r
}
