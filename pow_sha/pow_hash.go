package main

import (
	"crypto/sha256"
	"fmt"
	"time"
)

// 实践 POW， 编写程序（编程语言不限）用自己的昵称 + nonce，不断修改nonce 进行 sha256 Hash 运算：
// 直到满足 4 个 0 开头的哈希值，打印出花费的时间、Hash 的内容及Hash值。
// 再次运算直到满足 5 个 0 开头的哈希值，打印出花费的时间、Hash 的内容及Hash值。
func main() {
	fmt.Println("第一课作业")
	var (
		username  = "mt"
		startTime = time.Now()
		nonce1    = 0 //随机数
	)
	go func() {
		for {
			strs := hash256Encode(fmt.Sprintf("%s%d", username, nonce1))
			if strs[:4] == "0000" {
				fmt.Println("当前的随机数是：", nonce1)
				fmt.Println("当前哈希地址是：", strs)
				elapsed := time.Since(startTime)
				fmt.Println(fmt.Sprintf("符合4个0需要的时间为: %d 毫秒", elapsed.Milliseconds()))
				break
			}
			nonce1++
		}
	}()

	var (
		startTime2 = time.Now()
		nonce2     = 0 //随机数
	)
	for {
		strs := hash256Encode(fmt.Sprintf("%s%d", username, nonce2))
		if strs[:5] == "00000" {
			fmt.Println("当前的随机数是：", nonce2)
			fmt.Println("当前哈希地址是：", strs)
			elapsed := time.Since(startTime2)
			fmt.Println(fmt.Sprintf("符合5个0需要的时间为: %d 毫秒", elapsed.Milliseconds()))
			break
		}
		nonce2++
	}
}

func hash256Encode(str string) string {
	hash := sha256.Sum256([]byte(str))
	hashString := fmt.Sprintf("%x", hash)
	return hashString
}
