import { useEffect, useState } from "react"
import { useNavigate } from "react-router"
import { useContext } from "../../hooks/context"

export const SignUp = () => {
    const { contract, web3, accountState: [account, setAccount] } = useContext()
    const [username, setUsername] = useState()
    const [password, setPassword] = useState()
    const [secret, setSecret] = useState()
    const navigate = useNavigate()

    useEffect(() => {
        if (account.length) return navigate('/')
    }, [])

    const signUp = async () => {
        try {
            const addr = await web3.eth.personal.newAccount(password);
            await web3.eth.personal.unlockAccount(addr, password, 0)
            await web3.eth.sendTransaction({ from: process.env.REACT_APP_DEFAULT_ACCOUNT, to: addr, value: web3.utils.toBN(10000).mul(web3.utils.toBN(10).pow(web3.utils.toBN(18))) })

            const secretHash = await contract.methods._keccak256(secret).call()
            await contract.methods.signUp(username, secretHash).send({ from: addr })
            web3.defaultAccount = addr;

            setAccount(addr)
            alert('Successfully signed up and logged in as ' + username + '.\nPress OK to proceed to homepage.')
            navigate('/')
        } catch (e) {
            console.error(e)
            alert(e)
        }
    }

    return <>
        Username: <input value={username} onChange={(event) => setUsername(event.target.value)} type='text' /><br />
        Password: <input value={password} onChange={(event) => setPassword(event.target.value)} type='password' /><br />
        Secret: <input value={secret} onChange={(event) => setSecret(event.target.value)} type='password' /><br />
        <button onClick={signUp}>Sign Up</button>
    </>
}