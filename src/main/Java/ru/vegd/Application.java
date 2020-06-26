package ru.vegd;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import org.apache.commons.cli.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.stereotype.Component;
import ru.vegd.dao.StreetLevelCrimesDao;
import ru.vegd.dataReceiver.Receiver;
import ru.vegd.dataReceiver.utils.JsonToEntityConverter;
import ru.vegd.entity.StreetLevelCrimes;

import java.time.YearMonth;
import java.util.List;
import java.util.Properties;

@SpringBootApplication
@Component
public class Application {

    @Autowired
    StreetLevelCrimesDao streetLevelCrimesDao;

    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class)
                .web(WebApplicationType.NONE) // .REACTIVE, .SERVLET
                .run(args);

        ApplicationContext ctx =
                new AnnotationConfigApplicationContext("ru.vegd");

        Application application = ctx.getBean(Application.class);
        StreetLevelCrimesDao streetLevelCrimesDao = application.streetLevelCrimesDao;

        Options options = new Options();
        CommandLine cmd = null;
        String link = "https://data.police.uk/api/crimes-street/all-crime?lng=-0.242033&lat=51.467128&date=2018-01";
        String lng = null;
        String lat = null;
        String date = null;

        Option propertyOption = Option.builder()
                .longOpt("C")
                .argName("property=value")
                .hasArg()
                .valueSeparator()
                .build();
        options.addOption(propertyOption);

        CommandLineParser parser = new DefaultParser();
        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        if (cmd.hasOption("D")) {
            Properties properties = cmd.getOptionProperties("D");
            link = properties.getProperty("link");
            lng = properties.getProperty("lng");
            lat = properties.getProperty("lat");
            date = properties.getProperty("date");
        }

        YearMonth fromDate = YearMonth.of(2018, 1);
        YearMonth toDate = YearMonth.of(2018, 3);

        Receiver receiver = new Receiver(link);
        List<JsonArray> jsonArrayList = receiver.getData(fromDate, toDate);

        for (Integer id = 0; id < jsonArrayList.size(); id++) {
            JsonArray jsonArray = jsonArrayList.get(id);
            for (Integer z = 0; z < jsonArray.size(); z++) {
                JsonObject json = jsonArray.get(z).getAsJsonObject();
                JsonToEntityConverter jsonToEntityConverter = new JsonToEntityConverter();
                streetLevelCrimesDao.addCrime(jsonToEntityConverter.convert(json));
            }
        }
    }

}
