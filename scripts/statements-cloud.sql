CREATE STREAM pageviews WITH (kafka_topic='pageviews', value_format='AVRO');
CREATE STREAM users WITH (kafka_topic='users', value_format='AVRO');
