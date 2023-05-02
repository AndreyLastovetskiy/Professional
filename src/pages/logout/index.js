import { useEffect } from "react"
import { useNavigate } from "react-router"
import { useContext } from "../../hooks/context"

export const Logout = () => {
    const { accountState: [account, setAccount] } = useContext()
    const navigate = useNavigate()

    useEffect(() => {
        if(!account.length) navigate('/login')

        setAccount('')
        navigate('/')
    }, [])

    return <div></div>
}