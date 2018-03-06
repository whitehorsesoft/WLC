require 'net/http'

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_001-050.html'))
File.open("questions1.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_051-090.html'))
File.open("questions2.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_091-150.html'))
File.open("questions3.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_151-196.html'))
File.open("questions4.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_fn_001-050.html'))
File.open("footnotes1.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_fn_051-090.html'))
File.open("footnotes2.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_fn_091-150.html'))
File.open("footnotes3.html", "a") { |file| file.write(response) }

response = Net::HTTP.get(URI('http://www.reformed.org/documents/wlc_w_proofs/WLC_fn_151-196.html'))
File.open("footnotes4.html", "a") { |file| file.write(response) }

