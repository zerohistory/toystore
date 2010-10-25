What the 3 letter codes mean when they show up in logging:

  SET: write to store
  GET: read from store
  DEL: delete from store
  KEY: check if key exists in store

  IMG: read from identity map
  IMS: write to identity map
  IMD: delete from identity map

  RTS: read through set; when using multiple stores, it does read through
       caching and writes to stores that are not populated

  IEM: invalid embedded document
