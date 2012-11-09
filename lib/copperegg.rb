require 'copperegg/metrics'
require 'copperegg/util'
require 'net/http'
require 'uri'

  API_VERSION = 'v2'
  DEFAULTS = {
      :apihost => 'https://api.copperegg.com',
      :ssl_verify_peer => false,
      #:ssl_ca_file => File.dirname(__FILE__) + '/../../../conf/cacert.pem',
      :timeout => 10
    }

module CopperEgg

end