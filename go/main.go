package main

import (
    "database/sql"
    "errors"
    "fmt"
    "html/template"
    "log"
    "net/http"
    "os"
    "regexp"
    "strconv"
    "time"
    "unicode/utf8"

    "github.com/go-sql-driver/mysql"
)
var db *sql.DB

func main() {
    username := os.Getenv("DB_USER")
    password := os.Getenv("DB_PASS")
    cfg := mysql.Config{
        User:                 username,
        Passwd:               password,
        Net:                  "tcp",
        Addr:                 "127.0.0.1:3306",
        DBName:               "ocaidb",
        AllowNativePasswords: true,
    }

    var err error
    db, err = sql.Open("mysql", cfg.FormatDSN())
    
    pingErr := db.Ping()
    if pingErr != nil {
       //log.Fatal("2. ", pingErr)
    }
    fmt.Println("Connected!")

    if err != nil {
       log.Print(err.Error())
    }
    defer db.Close()
}
