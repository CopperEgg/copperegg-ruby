# CopperEgg Gem
The CopperEgg gem allows programmatic access to the CopperEgg API.  


## Usage

### Requirements

## Install

Via rubygems.org:

```
$ gem install copperegg-ruby
```

To build and install the development branch yourself from the latest source:

```
$ git clone git@github.com:copperegg/copperegg-ruby.git
$ cd copperegg-ruby
$ git checkout develop
$ gem build copperegg.gemspec
$ gem install copperegg-{version}.gem
```

## Getting Started

### Setup

``` ruby
require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'copperegg'

# Get a Metrics object:
apikey = 'sdf87xxxxxxxxxxxxxxxxxxxxx' # from the web UI
metrics = CopperEgg::Metrics.new(apikey)
```

### Get a metrics group:

``` ruby
group_name = "my_new_metrics_group"
mg = metrics.metric_group(group_name)
```

### Create a metric group:

``` ruby
  group_name = "this_is_a_new_group"
  groupcfg = {}
  groupcfg["name"] = group_name
  groupcfg["label"] = "Cool New Group Visible Name"
  groupcfg["frequency"] = "60"  # data is sent every 60s
  groupcfg["metrics"] = [{"type"=>"ce_gauge",   "name"=>"active_connections",     "unit"=>"Connections"},
                         {"type"=>"ce_gauge",   "name"=>"connections_accepts",    "unit"=>"Connections"},
                         {"type"=>"ce_gauge",   "name"=>"connections_handled",    "unit"=>"Connections"},
                         {"type"=>"ce_gauge",   "name"=>"connections_requested",  "unit"=>"Connections"},
                         {"type"=>"ce_gauge",   "name"=>"reading",                "unit"=>"Connections"},
                         {"type"=>"ce_gauge",   "name"=>"writing",                "unit"=>"Connections"},
                         {"type"=>"ce_gauge",   "name"=>"waiting",                "unit"=>"Connections"}
                       ]

  res = metrics.create_metric_group(group_name, groupcfg)
```

## Questions / Problems?


There are more detailed examples in the included [examples][examples]
directory.

Full [API docs][docs] are available.

[examples]:https://github.com/copperegg/copperegg-ruby/blob/master/examples
[docs]:http://dev.copperegg.com

## Copyright
Copyright 2012 CopperEgg - See LICENSE for details.
