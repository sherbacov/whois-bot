require 'sinatra'
require 'slack-ruby-client'
require 'net/dns'
require 'whois'

get '/' do 
	"hello world!"
	
end

post '/'  do
	text = params.fetch('text').strip

	case text

	when 'test'
		'MUAHAHAH THIS KINDA WORKS ALREADY'
end
end