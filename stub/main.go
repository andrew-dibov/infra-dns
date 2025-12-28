package main

import (
	"fmt"
	"net"
	"os"
	"strings"
	"time"
)

func randInt(max int) int {
	return int(time.Now().UnixNano() % int64(max))
}

func main() {
	domsEnv := os.Getenv("DOMAINS")

	var doms []string
	if domsEnv == "" {
		doms = []string{
			"google.com",
			"github.com",
			"youtube.com",
			"gulllulululululululu.com",
		}
	} else {
		doms = strings.Split(domsEnv, ",")
		for i, dom := range doms {
			doms[i] = strings.TrimSpace(dom)
		}
	}

	for req := 1; ; req++ {
		fmt.Println(time.Now().Format(time.RFC3339), " : ", req)
		fmt.Println()

		for i := 1; i <= randInt(25); i++ {
			fmt.Print("REQ : ", i, " : ")

			domain := doms[randInt(len(doms))]

			ips, err := net.LookupIP(domain)

			if err != nil {
				fmt.Print("ERR : ", err)
				fmt.Println()
			} else {
				fmt.Print("OK : ", len(ips), " addr : ")

				for j, ip := range ips {
					if j > 0 {
						fmt.Print(", ")
					}
					fmt.Print(ip.String())
				}

				fmt.Println()
			}

			time.Sleep(100 * time.Millisecond)
		}

		fmt.Println()
		time.Sleep(time.Duration((time.Now().Second()%5)+1) * time.Second)
	}
}
