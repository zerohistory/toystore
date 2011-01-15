# Toystore : An ORM for key-value stores

## Inspiration:

  - [MongoMapper](http://github.com/jnunemaker/mongomapper)
  - [CassandraObject](http://github.com/NZKoz/cassandra_object)
  - [Ohm](http://github.com/soveran/ohm) and [Ohm-Contrib](http://github.com/sinefunc/ohm-contrib)

See examples/models.rb for potential direction.  The idea is that any key-value store (via adapters?) that supports read, write, delete
will work (memcache, membase, redis, couch, toyko. Potentially even RESTFUL services or sqlite with a single key-value table?)
  
## Installation