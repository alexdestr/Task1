package ru.vegd.dao;

import ru.vegd.entity.StreetLevelCrime;

import java.time.YearMonth;
import java.util.List;

public interface StreetLevelCrimesDAO {
    void add(List<StreetLevelCrime> crimeList);
    void getMostDangerousStreets(YearMonth from, YearMonth to);
}
