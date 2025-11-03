require 'trmnl/liquid'
require 'optparse'
require 'json'
require 'cgi'

# CLI examples:
# - From file: ruby trmnl-liquid-cli.rb -i template.liquid -c '{"count":1337}'
# - From string (HTML-encoded): ruby trmnl-liquid-cli.rb -t "Hello {{ name }}" -c '{"name":"World"}'
#   Note: when using -t/--template, pass a template string that was encoded via PHP: htmlspecialchars($template, ENT_QUOTES, 'UTF-8')
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby trmnl-liquid-cli.rb (-i INPUT_FILE | -t TEMPLATE) -c JSON_CONTEXT'
  opts.on('-iFILE', '--input=FILE', 'Path to Liquid template file') { |v| options[:input] = v }
  opts.on('-tTEMPLATE', '--template=TEMPLATE', 'HTML-encoded Liquid template string (alternative to -i)') { |v| options[:template] = v }
  opts.on('-cJSON', '--context=JSON', 'JSON context (php json_encode with UNESCAPED flags supported)') { |v| options[:context] = v }
  opts.on('-h', '--help', 'Show help') do
    puts opts
    exit 0
  end
end.parse!(ARGV)

# Validate that exactly one of -i/--input or -t/--template is provided
input_provided = options[:input] && !options[:input].strip.empty?
template_provided = options[:template] && !options[:template].strip.empty?

if input_provided && template_provided
  warn 'Error: provide either -i/--input or -t/--template, not both'
  exit 1
elsif !input_provided && !template_provided
  warn 'Error: missing template. Provide -i FILE or -t TEMPLATE'
  exit 1
end

if input_provided && !File.file?(options[:input])
  warn "Error: input file not found: #{options[:input]}"
  exit 1
end

vars_str = options[:context] || '{}'

def deep_stringify_keys(obj)
  case obj
  when Hash
    obj.each_with_object({}) do |(k, v), h|
      h[k.to_s] = deep_stringify_keys(v)
    end
  when Array
    obj.map { |e| deep_stringify_keys(e) }
  else
    obj
  end
end

# Parse context strictly as JSON (expects php json_encode with UNESCAPED_UNICODE | UNESCAPED_SLASHES)
variables = begin
  JSON.parse(vars_str)
rescue JSON::ParserError => e
  warn "Error: failed to parse context (-c/--context) as JSON: #{e.message}"
  exit 2
end

unless variables.is_a?(Hash)
  warn 'Error: context (-c/--context) must decode to a JSON object/map'
  exit 2
end

variables = deep_stringify_keys(variables)

markup = if input_provided
  File.read(options[:input])
else
  CGI.unescapeHTML(options[:template].to_s)
end
environment = TRMNL::Liquid.build_environment # same arguments as Liquid::Environment.build
template = Liquid::Template.parse(markup, environment: environment)
rendered = template.render(variables)

printf rendered

