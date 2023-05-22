package com.example.book_reader.common;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

public class GlobalVal {
    public static final ScriptEngine SCRIPT_ENGINE = new ScriptEngineManager().getEngineByName("rhino");
}
