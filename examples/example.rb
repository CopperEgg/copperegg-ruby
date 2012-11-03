#!/usr/bin/env ruby

require 'copperegg'
require 'redis'
require 'getoptlong'

apikey = "asdadasdasd"

rm = CopperEgg::Metrics.new(apikey)

puts rm.apikey

metrics = {}
time = Time.now.to_i

rm.store(metrics, time, "my_group_name")

data = rm.samples(time-300, time, "my_group_name", "metric_foo")

