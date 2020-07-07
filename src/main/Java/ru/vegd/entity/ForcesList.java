package ru.vegd.entity;

import java.util.Objects;

public class ForcesList {

    private String id;
    private String name;

    public ForcesList() {}

    public ForcesList(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ForcesList that = (ForcesList) o;
        return Objects.equals(id, that.id) &&
                Objects.equals(name, that.name);
    }

    @Override
    public int hashCode() {

        return Objects.hash(id, name);
    }

    @Override
    public String toString() {
        return "ForcesList{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                '}';
    }
}
