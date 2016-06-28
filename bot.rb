require 'sinatra'

get '/' do 
	"hello world!"
	
end

post 'whois'  do
	text = params.fetch('text').strip

	case text

	when 'test'
		'MUAHAHAH THIS KINDA WORKS ALREADY'
end