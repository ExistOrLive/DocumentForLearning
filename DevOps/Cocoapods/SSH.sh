#! /usr/bin/expect
spawn ssh -l guest63 10.30.18.251
expect "Password:"
send "AYCf7wK2Y\r"

expect "Select page:"
send "0\r"

expect "Select server:"
send "26\r"

expect "Select account:"
send "2\r"

expect "Input account:"
send "zxin15\r"

expect "password:"
send "os10+ZTE\r"

interact





