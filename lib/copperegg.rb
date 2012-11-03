require 'copperegg/metrics'
require 'copperegg/utils'
require 'net/http'
require 'uri'

  API_VERSION = 'v2'
  DEFAULTS = {
      :apihost => 'https://api.copperegg.com',
      :use_ssl => true,
      :ssl_verify_peer => true,
      #:ssl_ca_file => File.dirname(__FILE__) + '/../../../conf/cacert.pem',
      :timeout => 10
    }

module CopperEgg

end