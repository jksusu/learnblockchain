package main

import (
	"fmt"
	"log"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

// ERC721ABI 是预解析的 ABI
var ERC721ABI, _ = abi.JSON(strings.NewReader(`[
    {"constant":true,"inputs":[{"name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"name":"owner","type":"address"}],"type":"function"},
    {"constant":true,"inputs":[{"name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"name":"","type":"string"}],"type":"function"}
]`))

type ERC721Contract struct {
	contract *bind.BoundContract
}

// NewERC721Contract 创建新的 ERC721 合约实例
func NewERC721Contract(address common.Address, client *ethclient.Client) (*ERC721Contract, error) {
	contract := bind.NewBoundContract(address, ERC721ABI, client, client, client)
	return &ERC721Contract{contract: contract}, nil
}

// OwnerOf 获取指定 tokenId 的持有者地址
func (c *ERC721Contract) OwnerOf(tokenId *big.Int) (common.Address, error) {
	var result []any
	err := c.contract.Call(nil, &result, "ownerOf", tokenId)
	if err != nil {
		return common.Address{}, fmt.Errorf("failed to call ownerOf: %v", err)
	}
	owner, ok := result[0].(common.Address)
	if !ok {
		return common.Address{}, fmt.Errorf("invalid ownerOf return type")
	}
	return owner, nil
}

// TokenURI 获取指定 tokenId 的元数据 URI
func (c *ERC721Contract) TokenURI(tokenId *big.Int) (string, error) {
	var result []any
	err := c.contract.Call(nil, &result, "tokenURI", tokenId)
	if err != nil {
		return "", fmt.Errorf("failed to call tokenURI: %v", err)
	}
	uri, ok := result[0].(string)
	if !ok {
		return "", fmt.Errorf("invalid tokenURI return type")
	}
	return uri, nil
}

func main() {
	contractAddress := common.HexToAddress("0x0483b0dfc6c78062b9e999a82ffb795925381415")
	rpcURL := "https://eth.llamarpc.com"
	tokenId := big.NewInt(2)

	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		panic("客户端创建失败")
	}
	defer client.Close()

	contract, err := NewERC721Contract(contractAddress, client)
	if err != nil {
		panic("合约客户端创建失败")
	}
	owner, err := contract.OwnerOf(tokenId)
	if err != nil {
		log.Printf("读取tokne持有人失败 %d: %v", tokenId, err)
	}
	tokenURI, err := contract.TokenURI(tokenId)
	if err != nil {
		log.Printf("查询nft url失败 %d: %v", tokenId, err)
	}
	fmt.Println(fmt.Sprintf("tokenId:%d ;拥有人是:%s; url: %s", tokenId, owner, tokenURI))
}
