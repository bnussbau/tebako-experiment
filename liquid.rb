require 'trmnl/liquid'
require 'optparse'
require 'json'
require 'yaml'

# CLI: ruby liquid.rb -i template.liquid -e "{ 'count': 1337 }"
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby liquid.rb -i INPUT_FILE -e JSON_ENV'
  opts.on('-iFILE', '--input=FILE', 'Path to Liquid template file') { |v| options[:input] = v }
  opts.on('-eJSON', '--env=JSON', 'JSON (or YAML) of resolved variables') { |v| options[:env] = v }
  opts.on('-h', '--help', 'Show help') do
    puts opts
    exit 0
  end
end.parse!(ARGV)

if options[:input].nil? || options[:input].strip.empty?
  warn 'Error: missing input template file (-i FILE)'
  exit 1
end

unless File.file?(options[:input])
  warn "Error: input file not found: #{options[:input]}"
  exit 1
end

vars_str = options[:env] || '{}'

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

# Prefer JSON, fall back to YAML to be lenient with single quotes, etc.
variables = begin
  JSON.parse(vars_str)
rescue JSON::ParserError
  begin
    YAML.safe_load(vars_str, permitted_classes: [], permitted_symbols: [], aliases: false) || {}
  rescue StandardError => e
    warn "Error: failed to parse variables (-e) as JSON or YAML: #{e.message}"
    exit 2
  end
end

unless variables.is_a?(Hash)
  warn 'Error: variables (-e) must decode to a JSON/YAML object/map'
  exit 2
end

variables = deep_stringify_keys(variables)

markup = File.read(options[:input])
environment = TRMNL::Liquid.build_environment # same arguments as Liquid::Environment.build
template = Liquid::Template.parse(markup, environment: environment)
rendered = template.render(variables)

printf rendered

