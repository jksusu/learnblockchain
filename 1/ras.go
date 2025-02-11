package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

// 生成 RSA 公私钥对
func generateKeyPair(bits int) (*rsa.PrivateKey, error) {
	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
	if err != nil {
		return nil, err
	}
	return privateKey, nil
}

// 将私钥保存为 PEM 文件
func savePrivateKeyToFile(filename string, privateKey *rsa.PrivateKey) error {
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	pemBlock := &pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(privateKey),
	}
	return pem.Encode(file, pemBlock)
}

// 读取私钥文件
func readPrivateKey(filename string) (*rsa.PrivateKey, error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	block, _ := pem.Decode(data)
	if block == nil || block.Type != "PRIVATE KEY" {
		return nil, fmt.Errorf("无效的私钥格式")
	}

	privateKey, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	return privateKey, nil
}

// 读取公钥文件
func readPublicKey(filename string) (*rsa.PublicKey, error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	block, _ := pem.Decode(data)
	if block == nil || block.Type != "PUBLIC KEY" {
		return nil, fmt.Errorf("无效的公钥格式")
	}
	publicKey, err := x509.ParsePKCS1PublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	return publicKey, nil
}

// 将公钥保存为 PEM 文件
func savePublicKeyToFile(filename string, publicKey *rsa.PublicKey) error {
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	pubASN1 := x509.MarshalPKCS1PublicKey(publicKey)
	pemBlock := &pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: pubASN1,
	}
	return pem.Encode(file, pemBlock)
}

// 对数据进行签名
func signData(privateKey *rsa.PrivateKey, data []byte) ([]byte, error) {
	return rsa.SignPKCS1v15(rand.Reader, privateKey, 0, data)
}

// 验证签名
func verifySignature(publicKey *rsa.PublicKey, data []byte, signature []byte) error {
	return rsa.VerifyPKCS1v15(publicKey, 0, data, signature)
}

func main() {
	osPath, _ := os.Getwd()
	path := osPath + "/1/key/private_key.pem"
	// 读取私钥
	privateKey, err := readPrivateKey(path)
	if err != nil {
		log.Fatalf("读取私钥失败: %v", err)
	}
	fmt.Println("私钥读取成功")

	// 读取公钥
	pubPath := osPath + "/1/key/public_key.pem"
	publicKey, err := readPublicKey(pubPath)
	if err != nil {
		log.Fatalf("读取公钥失败: %v", err)
	}
	fmt.Println("公钥读取成功")

	//privateKey, err := generateKeyPair(2048)
	//if err != nil {
	//	log.Fatalf("生成密钥对失败: %v", err)
	//}
	//err = savePrivateKeyToFile("private_key.pem", privateKey)
	//if err != nil {
	//	log.Fatalf("保存私钥失败: %v", err)
	//}
	//err = savePublicKeyToFile("public_key.pem", &privateKey.PublicKey)
	//if err != nil {
	//	log.Fatalf("保存公钥失败: %v", err)
	//}

	nickname := "mt"
	addrss := "0000f058847ba5e1c58172e9b645367ca4d40a82fb2fd799db777c98bca9786e" // POW 条件：哈希值前缀为 4 个 0
	nonce := "1212"

	dataToSign := []byte(addrss + nickname + nonce)
	signature, err := signData(privateKey, dataToSign)
	if err != nil {
		log.Fatalf("签名失败: %v", err)
	}
	err = verifySignature(publicKey, dataToSign, signature)
	if err != nil {
		log.Fatalf("签名验证失败: %v", err)
	}
	fmt.Printf("签名验证成功！昵称: %s, nonce: %s, 签名: %x\n", nickname, nonce, signature)
}
