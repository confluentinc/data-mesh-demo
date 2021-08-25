package io.confluent.demo.datamesh.cc.ksqldb.model;

public class PostRequest {
    private String sql;

    public PostRequest(String sql) {
        this.sql = sql;
    }

    public String getSql() {
        return sql;
    }
}
