CREATE STREAM stocktrades WITH (kafka_topic='stocktrades', value_format='AVRO');
CREATE STREAM pageviews WITH (kafka_topic='pageviews', value_format='AVRO');
CREATE TABLE users (id STRING PRIMARY KEY) WITH (kafka_topic='users', value_format='AVRO');
