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
require 'whois-parser'
require 'net/http'
require 'json'
require 'uri'

# Just returns a nice message if someone visits the URL directly.
get '/' do 
	"service is ok."
end

# Construct the message that gets sent back to Slack after the Whois query finishes
# http://mikeebert.tumblr.com/post/56891815151/posting-json-with-nethttp
# https://coderwall.com/p/c-mu-a/http-posts-in-ruby

def json_response(response_url, whois_response)
  data_output = {text: whois_response, response_type: "ephemeral"}
  json_headers = {"Content-type" => "application/json"}
  uri = URI.parse(response_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  res = http.post(uri.path, data_output.to_json, json_headers)
  return nil
end

def json_prelim_response(response_url, user_name)
  data_output = {text: "Hi " + user_name + ", let me check on that for you! Please hold...", response_type: "ephemeral"}
  json_headers = {"Content-type" => "application/json"}
  uri = URI.parse(response_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  res = http.post(uri.path, data_output.to_json, json_headers)
  return nil
end

# Define methods - Whois and DNS/Host..

def whois_query(domain)
  #whois = Whois::Client.new

  # run a Whois query on the domain we're passing in. Returns an object, but can be called as a string
  # if necessary (i.e. puts result)
  
  # result = whois.lookup(domain)
  # puts result
  
  # Return the whole record?
  # puts result

  # Return only some specific info...

  # domain_that_was_queried = result.domain
  # domain_created_on_date = result.created_on #Time/Nil
  # domain_updated_date = result.updated_on #Time/Nil
  # domain_expiration_date = result.expires_on
  # domain_registrar = result.registrar.name
  # domain_nameservers = result.nameservers
  # domain_registrant_contacts = result.registrant_contacts

  # # Let's output some of this stuff, to see if it's working.

  # # need to put all this in a JSON POST message...

  #puts "You asked about" + domain_that_was_queried.to_s + "...here's what I know: "
  # puts "Registered at:" + domain_registrar.to_s
  # puts "Expires on:" + domain_expiration_date.to_s
  # puts "Contact info:" + domain_registrant_contacts.to_s
  # puts domain_nameservers

  record = Whois.whois(domain).parser

  domain_name = record.domain
 	created_date = record.created_on
 	last_updated = created_date
  expiration_date = record.expires_on
   
  days_expire = (((record.expires_on - DateTime.now) / 86400).round - 1).to_s

 	registrar = record.registrar.id
 	#registrant_contacts = record.registrant_contacts
   #nameservers = record.nameservers.name
  nameservers = ""
  record.nameservers.each do |nameserver|
    nameservers = nameservers + "\n Name Server: " + nameserver.to_s 
  end
   
  puts "__Domain Name:__ " + domain_name.to_s + "\n Created Date: " + created_date.to_s 

  @whois_response =  "*Domain Name:* " + domain_name.to_s + "\n Registered On: " + created_date.to_s + "\n Expires On: " + expiration_date.to_s + " (" + days_expire +" days)" + "\n *Registrar:* " + registrar.to_s  + nameservers.to_s

end


def dns_query(domain)
	result = Resolver(domain)
	# a_records = Net::DNS::Resolver.start(domain, Net::DNS::A)
	# mx_records = Net::DNS::Resolver.start(domain, Net::DNS::MX)

	# header = a_records.header
	answers = result.answer
	# mx_answer = mx_records.answer

	# #puts "The packet is #{packet.data.size} bytes"
	# #puts "It contains #{header.anCount} answer entries"

	# answer.any? {|ans| p ans}

  reply = ""

  answers.each do |answer|
    reply = reply + "\n " + domain + " => " + answer.address.to_s + " (ttl expire - " + (answer.ttl / 60).round.to_s + "m)"
  end


	@dns_response = reply
	# @dns_response = answer.to_s "\n" + mx_answer.to_s
	#@dns_response = result.to_s
end

def whois
  domain = params.fetch('text').strip
  user_name = params.fetch('user_name')
  response_url = params.fetch('response_url')
 
  	#json_prelim_response(response_url, user_name)
  	
  	if domain =~ /^(.*?\..*?$)/
  		whois_query(domain)
  		dns_query(domain)
      
      #json_response(response_url, @whois_response)
    print @whois_response + @dns_response

  	else
  		"put a real domain name in, fool"
  	end

end


# Now the fun starts. Once someone POSTs to this app, it will return information.
post '/' do
  whois
end

post '/host/?' do
	dns
end

post '/test' do
	'Hello can you hear me'
end