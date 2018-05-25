# CopperEgg Gem

The CopperEgg gem allows programmatic access to the Uptime Cloud Monitor API.

## Install

Via rubygems.org:

```
$ gem install copperegg
```

To build and install the development branch yourself from the latest source:

```
$ git clone git://github.com/CopperEgg/copperegg-ruby.git -b develop
$ cd copperegg-ruby
$ gem build copperegg.gemspec
$ gem install copperegg-{version}.gem
```

## Getting Started

#### Setup

``` ruby
require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'copperegg'
CopperEgg::Api.apikey = "sdf87xxxxxxxxxxxxxxxxxxxxx" # from the web UI
```

## Metric Groups:

#### Get a metric group:

``` ruby
metric_group = CopperEgg::MetricGroup.find("my_metric_group")
metric_group.name
# => "my_metric_group"
metric_group.label
# => "My Metric Group"
metric_group.metrics
# => [#<CopperEgg::MetricGroup::Metric:0x007fb43aab2570 @position=0, @type="ce_gauge", @name="metric1", @label="Metric 1", @unit="b">]
```

#### Create a metric group:

``` ruby
metric_group = CopperEgg::MetricGroup.new(:name => "my_new_metric_group", :label => "Cool New Group Visible Name", :frequency => 60) # data is sent every 60 seconds
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"active_connections",     "unit"=>"Connections"}
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"connections_accepts",    "unit"=>"Connections"}
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"connections_handled",    "unit"=>"Connections"}
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"connections_requested",  "unit"=>"Connections"}
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"reading",                "unit"=>"Connections"}
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"writing",                "unit"=>"Connections"}
metric_group.metrics << {"type"=>"ce_gauge",   "name"=>"waiting",                "unit"=>"Connections"}
metric_group.save
```

If a metric group by the same name already exists, that one will rather than creating a new one. In addition, if the metric group was previously removed it will be restored.

```ruby
metric_group2 = CopperEgg::MetricGroup.new(:name => "my_new_metric_group", :label => "New Group Version 2", :frequency => 60)
metric_group2.metrics << {"type"=>"ce_counter", "name"=>"active_connections", "unit"=>"Connections"}
metric_group2.save # this will perform an update to change the type of the metric 'active_connections' from 'ce_gauge' to 'ce_counter'

metric_group2.name
# => "my_metric_group"
```

#### Updating a metric group:

Labels, frequency, metric types and metric units can be updated and additional metrics can be added. Changes to the metric group name or names of metrics within will be ignored.

```ruby
metric_group.name = "this_will_be_ignored"
metric_group.label = "My New Metric Group"
metric_group.frequency = 5
metric_group.metrics << {"type"=>"ce_counter_f", "name"=>"new_metric"}
metric_group.save

metric_group.name
# => "my_metric_group"
metric_group.label
# => "My New Metric Group"
metric_group.frequency
# => 5
```

#### Delete a metric group

```ruby
metric_group.delete
```

## Samples

#### Post samples for a metric group

```ruby
CopperEgg::MetricSample.save(metric_group.name, "custom_identifier1", Time.now.to_i, "active_connections" => 2601, "connections_accepts" => 154, "connections_handled" => 128, "connections_requested" => 1342, ...)
```

#### Get samples

```ruby
# Get the most recent samples for a single metric
CopperEgg::MetricSample.samples(metric_group.name, "connections_accepts")

# Get the most recent samples for multiple metrics
CopperEgg::MetricSample.samples(metric_group.name, ["connections_accepts", "connections_handled", "reading", "writing"])

# Specify a start time and duration
CopperEgg::MetricSample.samples(metric_group.name, ["connections_accepts", "connections_handled", "reading", "writing"], :starttime => 4.hours.ago, :duration => 15.minutes)
```

The raw JSON response is returned as specified in the [API docs][sample_docs].

## Dashboards

#### Create a dashboard from a metric group

By default, the dashboard created will be named "_MetricGroupLabel_ Dashboard" and will have one timeline widget per metric matching all sources.

```ruby
# Creates a dashboard named "My Metric Group Dashboard"
dashboard = CopperEgg::CustomDashboard.create(metric_group)
```

You can pass an option to specify the name of the dashboard.

```ruby
dashboard = CopperEgg::CustomDashboard.create(metric_group, :name => "Cloud Servers")
```

If a single identifier is specified, the dashboard will be created having one value widget per metric matching the single identifier.

```ruby
dashboard = CopperEgg::CustomDashboard.create(metric_group, :name => "Cloud Servers", :identifiers => "custom_identifier1")
```

If an array of identifiers is specified, the dashboard will be created having one timeline widget per metric matching each identifier.

```ruby
dashboard = CopperEgg::CustomDashboard.create(metric_group, :name => "Cloud Servers", :identifiers => ["custom_identifier1", "custom_identifier2"])
```

You can limit the widgets created by metric.

```ruby
dashboard = CopperEgg::CustomDashboard.create(metric_group, :name => "Cloud Servers", :identifiers => ["custom_identifier1", "custom_identifier2"], :metrics => ["reading", "writing", "waiting"])
```

#### Get a dashboard

```ruby
dashboard = CopperEgg::CustomDashboard.find_by_name("My Metric Group Dashboard")
```

#### Delete a dashboard

Dashboards can be deleted like metric groups:

```ruby
dashboard.delete
```

## Tags

#### Getting all or specific tags

```ruby
tags_list = CopperEgg::Tag.find
tag = CopperEgg::Tag.find_by_name("my-tag")
```

#### Create a tag

```ruby
tag = CopperEgg::Tag.new({:name => "my-tag"})
tag.objects = ["object-identifier-1", "object-identifier-2"]
tag.save
```

#### Update a tag

```ruby
tag.objects = ["object-identifier-1", "object-identifier-2", "object-identifier-3"]
tag.save
```

#### Delete a tag

```ruby
tag.delete
```



## Questions / Problems?

There are more detailed examples in the [test classes][test_classes].

Full [API docs][docs] are available.

[sample_docs]:http://dev.copperegg.com/revealmetrics/samples.html
[test_classes]:https://github.com/copperegg/copperegg-ruby/tree/develop/test
[docs]:http://dev.copperegg.com

## Copyright
Copyright 2013 IDERA.
