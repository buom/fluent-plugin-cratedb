# Fluent::Plugin::CrateDB, a plugin for [Fluentd](http://fluentd.org)

fluent-plugin-cratedb is a buffered output plugin for fluentd and CrateDB.


## Installation

    $ fluent-gem install fluent-plugin-cratedb

## Usage

`type` `createdb`

--------------

**Options:**

`host`: cratedb host (default: 127.0.0.1)

`port`: cratedb port (default: 4200)

`hosts`: an array of servers including ports [127.0.0.1:4200, 10.0.0.1:4201]

`table`: bulk insert table (require)

`column_names`: bulk insert column (require)

`key_names`: key name values (default `column_names`)


## Configuration Example

```
<match mylog.*>
  @type cratedb
  host  localhost
  port  4200
  column_names id,user_name,created_at,updated_at
  table users
  flush_interval 10s
</match>
```

## Contributing


1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Licence


This package was distributed under Apache-2.0 licence, see LICENCE file for details.
