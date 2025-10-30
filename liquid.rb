require 'trmnl/liquid'

markup = 'Hello {{ count | number_with_delimiter }} people!'
environment = TRMNL::Liquid.build_environment # same arguments as Liquid::Environment.build
template = Liquid::Template.parse(markup, environment: environment)
rendered = template.render({ 'count' => 1337 })
printf rendered

