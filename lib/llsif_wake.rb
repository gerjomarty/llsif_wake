require "bundler/setup"

Bundler.require(:default)

require "card"
require "card_instance"
require "kirara_ca_api"
require "output"
require "parser"

require "parser/login"
require "parser/member_list"
require "parser/present_box"

module LlsifWake
end