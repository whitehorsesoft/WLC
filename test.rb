require 'net/http'

uri = URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_001-050.html')
puts Net::HTTP.get(uri)
