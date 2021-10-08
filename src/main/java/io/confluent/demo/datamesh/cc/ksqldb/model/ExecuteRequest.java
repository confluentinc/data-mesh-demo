package io.confluent.demo.datamesh.cc.ksqldb.model;

public class ExecuteRequest {
    private String sql;
    public String getSql() {
        return sql;
    }
    public void setSql(String sql) {this.sql = sql;}
}
