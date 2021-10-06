package io.confluent.demo.datamesh;

import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class PropertyToJsonConverter {
    public static void main(String[] args) throws IOException {
        Properties p = load(args[0]);
        Config cfg = ConfigFactory.parseProperties(p);
        System.out.println(
                cfg.root().render(com.typesafe.config.ConfigRenderOptions.concise()));
    }

    private static Properties load(String propFilePath) throws IOException {
        Properties prop = new Properties();
        try (InputStream input = new FileInputStream(propFilePath)) {
            prop.load(input);
        } catch (IOException ex) {
            ex.printStackTrace();
            throw ex;
        }
        return prop;
    }
}
