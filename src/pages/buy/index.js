import { useEffect, useState } from "react"
import { useContext } from "../../hooks/context"

export const BuyTokens = () => {
    const { contract, accountState: [account, setAccount], web3 } = useContext()
    const [amount, setAmount] = useState('')
    const [price, setPrice] = useState('')

    const buyTokens = async () => {
        try {
            const cmonBN = web3.utils.toBN(10).pow(web3.utils.toBN(12))

            const actualAmount = web3.utils.toBN(amount).mul(cmonBN)
            const value = web3.utils.toBN(price)
                                    .mul(actualAmount)

            await contract.methods.buy(actualAmount).send({ from: account, value })
            // rerender header with new balance
            setAccount(account)
            alert('Successfully bought ' + amount + ' of CMON tokens')
        } catch (e) {
            console.error(e)
            alert(e)
        }
    }

    const getTokenPrice = async () => {
        const price = await contract.methods.getTokenPrice().call()
        setPrice(price)
    }

    useEffect(() => getTokenPrice, [])

    return <>
        Current price of CMON token: <strong>{(price * (10 ** 12) / 10 ** 18)} ETH</strong><br />
        Amount of CMON tokens (current phase): <input value={amount} onChange={(event) => setAmount(event.target.value)} type='number' /><br />
        <button onClick={buyTokens}>Buy</button>
    </>
}