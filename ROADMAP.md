# 1.0

Those marked with (AM) mean that Active Model can be leveraged heavily for the 
mundane parts. The AM pieces will take less time, as most is written. You mostly 
just have to write the glue to integrate it with what you already have.

- [x] Persistence

  I left off this weekend at getting Moneta up to snuff, so this should be easy
  now. The only decision left is whether to store model objects as JSON in one 
  key or have a key for each attribute. There are pros/cons to each that we can
  talk through.

- [x] Typecasting

  String, Integer, Time, Date, Array, Set, Boolean, etc. One interesting problem
  with this is that different key/value stores support different data structures.
  Because redis stores sets natively, we'd probably want to take advantage of 
  that, whereas memcache it would just be stored as array.to_json. Have some good 
  ideas on how to leverage native functionality while falling back to JSON.

- [x] Callbacks (AM)

  Basically the same as AR and MM. before/after create, save, destroy, update, 
  and validate.

- [x] Validations (AM)

  Use AM. Only question would be validating uniqueness of which is always based 
  on the db. Different ways to do it that we can talk about.

- [x] Serialization (AM)

  JSON and XML. Both are important to you it sounds like for games and the new 
  one that uses JSON.

- [x] Associations

  The typical players, many, one, belongs to. Not sure of the best way to 
  actually persist this information, but I am very comfortable building all 
  the ruby that wraps it. We can talk about how to store the relationships 
  more later.

- [x] Identity Map

  This is pretty darn easy and makes it so that an object is only loaded from the 
  db in one place and as such if you modify it, it will be modified everywhere.

- [x] Dirty Tracking (AM)

  This might be less important to you as your data isn't updated as much, but 
  very useful and easy to add thanks to active model.

- Observers? (AM)

  I typically consider this less important, especially with as much as stuff is 
  backgrounded these days.

- Attr Protected/Accessible?

  Probably not as big of a deal for New Toy stuff as clients are written by you 
  but is also not a lot of work.
