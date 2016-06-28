# DNS Bot
# This script is the skeleton for a bot that will automatically check DNS and Whois records for a given domain.
#
# Uses net/dns gem: https://github.com/bluemonk/net-dns
# Uses whois gem: https://whoisrb.org/
#
#


require 'sinatra'
require 'slack-ruby-client'
require 'net/dns'
require 'whois'
require 'net/http'
require 'json'


# Just returns a nice message if someone visits the URL directly.
get '/' do 
	"hello world!"
end


# Define methods - Whois and DNS/Host..

def whois_query(domain)
  whois = Whois::Client.new

  # run a Whois query on the domain we're passing in. Returns an object, but can be called as a string
  # if necessary (i.e. puts result)
  result = whois.lookup(domain)

  # Return the whole record?
  # puts result

  # Return only some specific info...

  domain_that_was_queried    = result.domain
  domain_created_on_date     = result.created_on #Time/Nil
  domain_updated_date        = result.updated_on #Time/Nil
  domain_expiration_date     = result.expires_on
  domain_registrar           = result.registrar
  domain_nameservers         = result.nameservers
  domain_registrant_contacts = result.registrant_contacts

  # Let's output some of this stuff, to see if it's working.

  # need to put all this in a JSON POST message...

  puts "You asked about" + domain_that_was_queried + "...here's what I know:"
  puts "Registered at:" + domain_registrar.name
  puts "Expires on:" + domain_expiration_date.to_s
  puts "Contact info:" + domain_registrant_contacts.to_s
  puts domain_nameservers
end


# Construct the message that gets sent back to Slack after the Whois query finishes
# http://mikeebert.tumblr.com/post/56891815151/posting-json-with-nethttp
def return_response(whois_response_json, response_url)

	uri = URI.parse(response_url)
	
	json_headers = { "Content-Type" => "application/json",
					"Accept" => "application/json" }

	http = Net::HTTP.new(uri.host)

	params = whois_response_json

	response = http.post(uri.path,params,json_headers)

end

def json_response_test(response_url)

	uri = URI.parse(response_url)
	
	json_headers = { "Content-Type" => "application/json",
					"Accept" => "application/json" }

	http = Net::HTTP.new(uri.host)

	params = {'text' => 'This is a test JSON response.'}

	response = http.post(uri.path,params,json_headers)
end



# Now the fun starts. Once someone POSTs to this app, it will return information.
post '/'  do
	domain = params.fetch('text').strip
	user_name = params.fetch('user_name')
	response_url = params.fetch('response_url')

	# case domain

	# 	when 'yo mama'
	# 		'MUAHAHAH THIS KINDA WORKS ALREADY'
	# 	end

	# 	when ''
	# 		'You need to provide a domain name! For example: google.com'
	# 	end

	# else
	'Let me check on that for you! Please hold...checking WHOIS for '+domain
	json_response_test(response_url)

		#whois_query(domain)


end

