package com.Medconnect.Listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import com.Medconnect.Utils.DatabaseInitializer;

@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Hospital-System Web Application is starting up...");
        DatabaseInitializer.initializeDatabase();
        System.out.println("Hospital-System initialization completed.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Hospital-System Web Application is shutting down...");
    }
}
