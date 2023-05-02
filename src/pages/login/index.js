import { useEffect, useState } from "react"
import { useLocation, useNavigate } from "react-router"
import { useContext } from "../../hooks/context"

export const Login = () => {
    const { contract, web3, accountState: [account, setAccount] } = useContext()
    const [password, setPassword] = useState('')
    const [username, setUsername] = useState('')
    const [secret, setSecret] = useState('')
    const navigate = useNavigate()

    const logIn = async () => {
        const { addr } = await contract.methods.getUserByUsername(username).call()
        try {
            await contract.methods.checkPasswordHash(username, secret).call()
            await web3.eth.personal.unlockAccount(addr, password, 0)
            web3.defaultAccount = addr;

            setAccount(addr)
            alert('Successfully logged in.\nPress OK to proceed to homepage.')
            navigate('/')
        } catch(e) {
            console.log(e)
            alert('Wrong password or secret!')
            setPassword('')
            setSecret('')
        }
    }

    useEffect(() => {
        if (account.length) navigate('/')
    }, [])

    return <>
        Username: <input value={username} onChange={(event) => setUsername(event.target.value)} type='text' /><br />
        Password: <input value={password} onChange={(event) => setPassword(event.target.value)} type='password' /><br />
        Secret: <input value={secret} onChange={(event) => setSecret(event.target.value)} type='password' /><br />
        <button onClick={logIn}>Log In</button>
    </>
}