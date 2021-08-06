package io.confluent.demo.datamesh;

import org.springframework.boot.env.PropertiesPropertySourceLoader;

public class ConfigPropertySourceLoader extends PropertiesPropertySourceLoader {
    @Override
    public String[] getFileExtensions() {
        return new String[] {"config"};
    }
}
